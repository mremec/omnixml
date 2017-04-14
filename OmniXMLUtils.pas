(*:XML helper unit. Contains routines to convert data, retrieve/set data of
   different types, manipulate nodes, load/save XML documents.
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2016 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : 2001-10-25
   Last modification : 2016-12-14
   Version           : 1.31a
</pre>*)(*
   History:
     1.31a: 2016-12-14
       - Fixed SelectNode when names of parent and child node are the same.
     1.31: 2013-12-13
       - Can be compiled without VCL (/dNOVCL). That also disables font persistency.
       - Added procedure SetNodeAttrs.
     1.30: 2011-03-01
       - Convert EFOpenError exception in XMLLoadFromFile to function result.
     1.29: 2011-02-07
       - Fixed possible accvio in SelectNode.
     1.29: 2010-07-06
       - Overloaded SelectNode.
     1.28: 2010-07-05
       - GetNodeText works when nil is passed as the 'parentNode' parameter. 
     1.27: 2010-05-27
       - (ia) Added handling of boolean strings 'true' and 'false'
     1.26: 2009-12-25
       - (mr) Base64 code optimization.
       - (mr) Overloaded Base64Encode, Base64Decode to work with buffer.
     1.25: 2008-04-09
       - Implemented enumerator XMLEnumNodes. Now you can do:
           for nodePassword in XMLEnumNodes(xmlConfig, '//*/PasswordHash') do
             SetTextChild(nodePassword, '(removed)');
     1.24: 2007-01-09
       - Added two additional overloads for Base64Encode and one for Base64Decode.
     1.23b: 2004-07-29
       - Updated GetNodeText to handle a case when #text subnode doesn't exist.
     1.23a: 2004-04-21
       - Updated GetNodeText, GetNodeCData to use .NodeValue instead of .Text internally.
     1.23: 2004-04-07
       - Added functions GetNodeTextFont and SetNodeTextFont.
     1.22a: 2004-04-07
       - Modified XMLBinaryToStr to always process entire stream.
       - Modified XMLStrToBinary to clear output stream at beginning.
     1.22: 2004-04-05
       - Added overloaded versions of GetNodeText and GetNodeCData.
     1.21: 2004-03-27
       - Added function AppendNode.
     1.20a: 2004-03-25
       - Fixed broken format strings (used for error reporting) in various XMLStrTo*
         functions.
     1.20: 2004-03-23
       - Added two more variants of Base64Encode and Base64Decode.
     1.19: 2004-03-01
       - GetNodeText*, GetNodeAttr*, and XMLStrTo* families extended with overloaded
         versions without a default value, raising exception on invalid/missing XML node.
     1.18: 2004-01-16
       - Functions OwnerDocument and DocumentElement made public.
     1.17: 2004-01-05
       - Remove some unnecessary 'overload' directives.
       - Added functions XMLStrToCurrency, XMLStrToCurrencyDef, XMLVariantToStr,
         and XMLCurrencyToStr.
       - Added function FindProcessingInstruction.
       - Added functions XMLSaveToAnsiString, XMLLoadFromAnsiString.
       - Fixed XMLSaveToString which incorrectly returned UTF8 string instead of
         UTF16.
     1.16: 2003-12-12
       - GetTextChild and SetTextChild made public.
       - New functions GetCDataChild and SetCDataChild.
       - New functions GetNodeCData and SetNodeCData.
       - New functions MoveNode and RenameNode.
       - Added functions XMLStrToExtended, XMLStrToExtendedDef, and
         XMLExtendedToStr.
     1.15b: 2003-10-01
       - Fixed another bug in SelectNode and EnsureNode (broken since 1.15).
     1.15a: 2003-09-22
       - Fixed bug in SelectNode and EnsureNode (broken since 1.15).
     1.15: 2003-09-21
       - Added function SelectNode.
     1.14: 2003-05-08
       - Overloaded Base64Encode, Base64Decode to work with strings too.
     1.13: 2003-04-01
       - Filter* and Find* routines modified to skip all non-ELEMENT_NODE nodes.
     1.12b: 2003-01-15
       - Safer implementation of some internal functions.
     1.12a: 2003-01-13
       - Adapted for latest fixes in OmniXML 2002-01-13.
     1.12: 2003-01-13
       - CopyNode, and CloneDocument made MS XML compatible.
       - Automatic DocumentElement dereferencing now works with MS XML.
     1.11: 2003-01-13
       - Fixed buggy GetNode(s)Text*/SetNode(s)Text* functions.
       - Fixed buggy CopyNode and CloneDocument.
     1.10a: 2003-01-09
       - Fixed filterProc support in the CopyNode.
     1.10: 2003-01-07
       - Added functions XMLLoadFromRegistry and XMLSaveToRegistry.
       - Added function CloneDocument.
       - Added parameter filterProc to the CopyNode procedure.
       - Smarter GetNodeAttr (automatically dereferences DocumentElement if
         root xml node is passed to it).
     1.09: 2002-12-26
       - Added procedure CopyNode that copies contents of one node into another.
       - Modified DeleteAllChildren to preserve Text property.
     1.08: 2002-12-21
       - Smarter GetNodeText (automatically dereferences DocumentElement if
         root xml node is passed to it).
     1.07a: 2002-12-10
       - Bug fixed in XMLSaveToString (broken since 1.06).
     1.07: 2002-12-09
       - Added XMLLoadFromFile and XMLSaveToFile.
       - Small code cleanup.
     1.06: 2002-12-09
       - MSXML compatible (define USE_MSXML).
     1.05a: 2002-11-23
       - Fixed bug in Base64Decode.
     1.05: 2002-11-05
       - Added function ConstructXMLDocument.
     1.04: 2002-10-03
       - Added function EnsureNode.
     1.03: 2002-09-24
       - Added procedure SetNodesText.
     1.02: 2002-09-23
       - SetNode* familiy of procedures changed into functions returning the
         modified node.
     1.01: 2001-11-07
       - (mr) Added function XMLDateTimeToStrEx.
       - (mr) ISODateTime2DateTime enhanced.
       - (mr) Bug fixed in Str2Time.
     1.0: 2001-10-25
       - Created by extracting common utilities from unit GpXML.
*)

unit OmniXMLUtils;

interface

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF (CompilerVersion >= 17)} //Delphi 2005 or newer
    {$DEFINE OmniXmlUtils_Enumerators}
  {$IFEND}
  {$IF CompilerVersion >= 20}  // Delphi 2009 or newer
    {$DEFINE OmniXmlUtils_Base64UsePointerMath}
  {$IFEND}
  {$IF CompilerVersion >= 23} // Delphi XE2 or newer
    {$DEFINE OmniXmlUtils_UseUITypes}
  {$IFEND}
{$ENDIF}

{$IFDEF NEXTGEN}
  {$DEFINE NoVCL}
{$ENDIF NEXTGEN}

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  Classes,
{$IFNDEF NoVCL}
  Graphics,
{$ENDIF}
  OmniXML_Types,
  OmniXML
{$IFDEF USE_MSXML}
  ,OmniXML_MSXML
{$ENDIF USE_MSXML}
{$IFDEF HAS_UNIT_VARIANTS}
  ,Variants
{$ENDIF DELPHI6_UP}
{$IFDEF OmniXmlUtils_UseUITypes}
  ,UITypes
{$ENDIF OmniXmlUtils_UseUITypes}
  ;

type
  {:Base class for OmniXMLUtils exceptions.
    @since   2004-03-01
  }
  EOmniXMLUtils = class(Exception);

  {:Delete the specified node.
  }
  procedure DeleteNode(parentNode: IXMLNode; nodeTag: string);

  {:Delete all/some children of the specified node.
  }
  procedure DeleteAllChildren(parentNode: IXMLNode; pattern: string = '');

  {:Retrive text child of the specified node.
  }
  function GetTextChild(node: IXMLNode): IXMLNode;

  {:Retrive CDATA child of the specified node.
  }
  function GetCDataChild(node: IXMLNode): IXMLNode;

  {:Returns CDATA value of the specified node.
  }
  function GetNodeCData(parentNode: IXMLNode; nodeTag: string;
    defaultValue: XmlString): XmlString; overload;

  {:Returns CDATA value of the specified node.
  }
  function GetNodeCData(node: IXMLNode): XmlString; overload;

  {:Returns text of the specified node. Result is True if node exists, False
    otherwise.
  }
  function GetNodeText(parentNode: IXMLNode; nodeTag: string;
    var nodeText: XmlString): boolean; overload;

  {:Returns text of the specified node. Result is True if node exists, False
    otherwise.
  }
  function GetNodeText(node: IXMLNode): XmlString; overload;

  {:Returns texts of all child nodes into the string list. Text for each child
    is trimmed before it is stored in the list. Caller must create result list
    in advance.
  }
  procedure GetNodesText(parentNode: IXMLNode; nodeTag: string;
    {var} nodesText: TStrings); overload;

  {:Returns texts of all child nodes as a CRLF-delimited string.
  }
  procedure GetNodesText(parentNode: IXMLNode; nodeTag: string;
    var nodesText: string); overload;

  {:A family of functions that will return node text reformatted into another
    type or default value if node doesn't exist or if node text is not in a
    proper format. Basically they all call GetNodeText and convert the result.
  }
  function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string; defaultValue: XmlString): XmlString; overload;
  function GetNodeTextReal(parentNode: IXMLNode; nodeTag: string; defaultValue: real): real; overload;
  function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string; defaultValue: integer): integer; overload;
  function GetNodeTextInt64(parentNode: IXMLNode; nodeTag: string; defaultValue: int64): int64; overload;
  function GetNodeTextBool(parentNode: IXMLNode; nodeTag: string; defaultValue: boolean): boolean; overload;
  function GetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string; defaultValue: TDateTime): TDateTime; overload;
  function GetNodeTextDate(parentNode: IXMLNode; nodeTag: string; defaultValue: TDateTime): TDateTime; overload;
  function GetNodeTextTime(parentNode: IXMLNode; nodeTag: string; defaultValue: TDateTime): TDateTime; overload;
  function GetNodeTextBinary(parentNode: IXMLNode; nodeTag: string; value: TStream): boolean;
{$IFNDEF NoVCL}
  function GetNodeTextFont(parentNode: IXMLNode; nodeTag: string; value: TFont): boolean;
{$ENDIF}

  {:A family of functions that will return node text reformatted into another
    type or raise exception if node doesn't exist or if node text is not in a
    proper format. Basically they all call GetNodeText and convert the result.
  }
  function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string): XmlString; overload;
  function GetNodeTextReal(parentNode: IXMLNode; nodeTag: string): real; overload;
  function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string): integer; overload;
  function GetNodeTextInt64(parentNode: IXMLNode; nodeTag: string): int64; overload;
  function GetNodeTextBool(parentNode: IXMLNode; nodeTag: string): boolean; overload;
  function GetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string): TDateTime; overload;
  function GetNodeTextDate(parentNode: IXMLNode; nodeTag: string): TDateTime; overload;
  function GetNodeTextTime(parentNode: IXMLNode; nodeTag: string): TDateTime; overload;

  {:Returns value of the specified attribute. Result is True if attribute
    exists, False otherwise.
  }
  function GetNodeAttr(parentNode: IXMLNode; attrName: string;
    var value: XmlString): boolean;
    
  {:A family of functions that will return attribute value reformatted into
    another type or default value if attribute doesn't exist or if attribute
    is not in a proper format. Basically they all call GetNodeAttr and
    convert the result.
  }
  function GetNodeAttrStr(parentNode: IXMLNode; attrName: string; defaultValue: XmlString): XmlString; overload;
  function GetNodeAttrReal(parentNode: IXMLNode; attrName: string; defaultValue: real): real; overload;
  function GetNodeAttrInt(parentNode: IXMLNode; attrName: string; defaultValue: integer): integer; overload;
  function GetNodeAttrInt64(parentNode: IXMLNode; attrName: string; defaultValue: int64): int64; overload;
  function GetNodeAttrBool(parentNode: IXMLNode; attrName: string; defaultValue: boolean): boolean; overload;
  function GetNodeAttrDateTime(parentNode: IXMLNode; attrName: string; defaultValue: TDateTime): TDateTime; overload;
  function GetNodeAttrDate(parentNode: IXMLNode; attrName: string; defaultValue: TDateTime): TDateTime; overload;
  function GetNodeAttrTime(parentNode: IXMLNode; attrName: string; defaultValue: TDateTime): TDateTime; overload;

  {:A family of functions that will return attribute value reformatted into
    another type or raise exception if attribute doesn't exist or if attribute
    is not in a proper format. Basically they all call GetNodeAttr and
    convert the result.
  }
  function GetNodeAttrStr(parentNode: IXMLNode; attrName: string): XmlString; overload;
  function GetNodeAttrReal(parentNode: IXMLNode; attrName: string): real; overload;
  function GetNodeAttrInt(parentNode: IXMLNode; attrName: string): integer; overload;
  function GetNodeAttrInt64(parentNode: IXMLNode; attrName: string): int64; overload;
  function GetNodeAttrBool(parentNode: IXMLNode; attrName: string): boolean; overload;
  function GetNodeAttrDateTime(parentNode: IXMLNode; attrName: string): TDateTime; overload;
  function GetNodeAttrDate(parentNode: IXMLNode; attrName: string): TDateTime; overload;
  function GetNodeAttrTime(parentNode: IXMLNode; attrName: string): TDateTime; overload;

  {:A family of functions used to convert string to some other value according
    to the conversion rules used in this unit. Used in Get* functions above.
  }
  function XMLStrToReal(nodeValue: XmlString; var value: real): boolean; overload;
  function XMLStrToReal(nodeValue: XmlString): real; overload;
  function XMLStrToRealDef(nodeValue: XmlString; defaultValue: real): real;
  function XMLStrToExtended(nodeValue: XmlString; var value: extended): boolean; overload;
  function XMLStrToExtended(nodeValue: XmlString): extended; overload;
  function XMLStrToExtendedDef(nodeValue: XmlString; defaultValue: extended): extended;
  function XMLStrToCurrency(nodeValue: XmlString; var value: Currency): boolean; overload;
  function XMLStrToCurrency(nodeValue: XmlString): Currency; overload;
  function XMLStrToCurrencyDef(nodeValue: XmlString; defaultValue: Currency): Currency;
  function XMLStrToInt(nodeValue: XmlString; var value: integer): boolean; overload;
  function XMLStrToInt(nodeValue: XmlString): integer; overload;
  function XMLStrToIntDef(nodeValue: XmlString; defaultValue: integer): integer;
  function XMLStrToInt64(nodeValue: XmlString; var value: int64): boolean; overload;
  function XMLStrToInt64(nodeValue: XmlString): int64; overload;
  function XMLStrToInt64Def(nodeValue: XmlString; defaultValue: int64): int64;
  function XMLStrToBool(nodeValue: XmlString; var value: boolean): boolean; overload;
  function XMLStrToBool(nodeValue: XmlString): boolean; overload;
  function XMLStrToBoolDef(nodeValue: XmlString; defaultValue: boolean): boolean;
  function XMLStrToDateTime(nodeValue: XmlString; var value: TDateTime): boolean; overload;
  function XMLStrToDateTime(nodeValue: XmlString): TDateTime; overload;
  function XMLStrToDateTimeDef(nodeValue: XmlString; defaultValue: TDateTime): TDateTime;
  function XMLStrToDate(nodeValue: XmlString; var value: TDateTime): boolean; overload;
  function XMLStrToDate(nodeValue: XmlString): TDateTime; overload;
  function XMLStrToDateDef(nodeValue: XmlString; defaultValue: TDateTime): TDateTime;
  function XMLStrToTime(nodeValue: XmlString; var value: TDateTime): boolean; overload;
  function XMLStrToTime(nodeValue: XmlString): TDateTime; overload;
  function XMLStrToTimeDef(nodeValue: XmlString; defaultValue: TDateTime): TDateTime;
  function XMLStrToBinary(nodeValue: XmlString; const value: TStream): boolean;

  {:Creates the node if it doesn't exist, then sets node CDATA to the specified
    value.
  }
  function SetNodeCData(parentNode: IXMLNode; nodeTag: string;
    value: XmlString): IXMLNode;

  {:Creates the node if it doesn't exist, then sets node text to the specified
    value.
  }
  function SetNodeText(parentNode: IXMLNode; nodeTag: string;
    value: XmlString): IXMLNode;

  {:Sets texts for many child nodes. All nodes are created anew.
  }
  procedure SetNodesText(parentNode: IXMLNode; nodeTag: string;
    nodesText: TStrings); overload;

  {:Sets texts for many child nodes. All nodes are created anew.
    @param nodesText Contains CRLF-delimited text list.
  }
  procedure SetNodesText(parentNode: IXMLNode; nodeTag: string;
    nodesText: string); overload;

  {:A family of functions that will first check that the node exists (creating
    it if necessary) and then set node text to the properly formatted value.
    Basically they all reformat the value to the string and then call
    SetNodeText.
  }
  function SetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
    value: XmlString): IXMLNode;
  function SetNodeTextReal(parentNode: IXMLNode; nodeTag: string;
    value: real): IXMLNode;
  function SetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
    value: integer): IXMLNode;
  function SetNodeTextInt64(parentNode: IXMLNode; nodeTag: string;
    value: int64): IXMLNode;
  function SetNodeTextBool(parentNode: IXMLNode; nodeTag: string;
    value: boolean): IXMLNode;
  function SetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string;
    value: TDateTime): IXMLNode;
  function SetNodeTextDate(parentNode: IXMLNode; nodeTag: string;
    value: TDateTime): IXMLNode;
  function SetNodeTextTime(parentNode: IXMLNode; nodeTag: string;
    value: TDateTime): IXMLNode;
  function SetNodeTextBinary(parentNode: IXMLNode; nodeTag: string;
    const value: TStream): IXMLNode;
{$IFNDEF NoVCL}
  function SetNodeTextFont(parentNode: IXMLNode; nodeTag: string;
    value: TFont): IXMLNode;
{$ENDIF}

  {:Set the value of the text child and return its interface.
  }
  function SetTextChild(node: IXMLNode; value: XmlString): IXMLNode;

  {:Set the value of the CDATA child and return its interface.
  }
  function SetCDataChild(node: IXMLNode; value: XmlString): IXMLNode;

  {:Creates the attribute if it doesn't exist, then sets it to the specified
    value.
  }
  procedure SetNodeAttr(parentNode: IXMLNode; attrName: string;
    value: XmlString);

  {:A family of functions that will first check that the attribute exists
    (creating it if necessary) and then set attribute's value to the properly
    formatted value. Basically they all reformat the value to the string and
    then call SetNodeAttr.
  }
  procedure SetNodeAttrStr(parentNode: IXMLNode; attrName: string;
    value: XmlString);
  procedure SetNodeAttrReal(parentNode: IXMLNode; attrName: string;
    value: real);
  procedure SetNodeAttrInt(parentNode: IXMLNode; attrName: string;
    value: integer);
  procedure SetNodeAttrInt64(parentNode: IXMLNode; attrName: string;
    value: int64);
  procedure SetNodeAttrBool(parentNode: IXMLNode; attrName: string;
    value: boolean);
  procedure SetNodeAttrDateTime(parentNode: IXMLNode; attrName: string;
    value: TDateTime);
  procedure SetNodeAttrDate(parentNode: IXMLNode; attrName: string;
    value: TDateTime);
  procedure SetNodeAttrTime(parentNode: IXMLNode; attrName: string;
    value: TDateTime);
  procedure SetNodeAttrs(parentNode: IXMLNode; attrNamesValues: array of string);

  {:A family of functions used to convert value to string according to the
    conversion rules used in this unit. Used in Set* functions above.
  }
  function XMLRealToStr(value: real; precision: byte = 15): XmlString;
  function XMLExtendedToStr(value: extended): XmlString;
  function XMLCurrencyToStr(value: Currency): XmlString;
  function XMLIntToStr(value: integer): XmlString;
  function XMLInt64ToStr(value: int64): XmlString;
  function XMLBoolToStr(value: boolean; useBoolStrs: boolean = false): XmlString;
  function XMLDateTimeToStr(value: TDateTime): XmlString;
  function XMLDateTimeToStrEx(value: TDateTime): XmlString;
  function XMLDateToStr(value: TDateTime): XmlString;
  function XMLTimeToStr(value: TDateTime): XmlString;
  function XMLBinaryToStr(value: TStream): XmlString;
  function XMLVariantToStr(value: Variant): XmlString;

{$IFNDEF USE_MSXML}
  {:Select specified child nodes. Can filter on subnode name and text.
  }
  function FilterNodes(parentNode: IXMLNode; matchesName: string;
    matchesText: string = ''): IXMLNodeList; overload;

  {:Select specified child nodes. Can filter on subnode name, subnode text and
    on grandchildren names.
  }
  function FilterNodes(parentNode: IXMLNode; matchesName, matchesText: string;
    matchesChildNames: array of string): IXMLNodeList; overload;

  {:Select specified child nodes. Can filter on subnode name, subnode text and
    on grandchildren names and text.
  }
  function FilterNodes(parentNode: IXMLNode; matchesName, matchesText: string;
    matchesChildNames, matchesChildText: array of string): IXMLNodeList; overload;
{$ENDIF USE_MSXML}

  {:Select first child node that satisfies the criteria. Can filter on subnode
    name and text.
  }
  function FindNode(parentNode: IXMLNode; const matchesName: string;
    const matchesText: string = ''): IXMLNode; overload;

  {:Select first child node that satisfies the criteria. Can filter on subnode
    name, subnode text and on grandchildren names.
  }
  function FindNode(parentNode: IXMLNode; const matchesName, matchesText: string;
    matchesChildNames: array of string): IXMLNode; overload;

  {:Select first child node that satisfies the criteria. Can filter on subnode
    name, subnode text and on grandchildren names and text.
  }
  function FindNode(parentNode: IXMLNode; const matchesName, matchesText: string;
    matchesChildNames, matchesChildText: array of string): IXMLNode; overload;

  {:Select first child with a specified attribute name, value pair.
  }
  function FindNodeByAttr(parentNode: IXMLNode; const matchesName, attributeName: string;
    const attributeValue: string = ''): IXMLNode;

  {:Returns 'processing instruction' node if it exists, nil otherwise.
  }
  function FindProcessingInstruction(
    xmlDocument: IXMLDocument): IXMLProcessingInstruction;

  {:Returns owner document interface of the specified node.
  }
  function OwnerDocument(node: IXMLNode): IXMLDocument;

  {:Returns document element node.
  }
  function DocumentElement(node: IXMLNode): IXMLElement;

{$IFDEF MSWINDOWS}
  {:Load XML document from the named RCDATA resource and return interface to it.
  }
  function XMLLoadFromResource(xmlDocument: IXMLDocument;
    const resourceName: string): boolean;
{$ENDIF}

  {:Load XML document from a wide string.
  }
  function XMLLoadFromString(xmlDocument: IXMLDocument;
    const xmlData: XmlString): boolean;

 {$IFDEF OmniXML_SupportAnsiStrings}
  {:Load XML document from an ansi string.
  }
  function XMLLoadFromAnsiString(xmlDocument: IXMLDocument;
    const xmlData: AnsiString): boolean;
 {$ENDIF OmniXML_SupportAnsiStrings}

  {:Save XML document to a wide string.
  }
  function XMLSaveToString(xmlDocument: IXMLDocument;
    outputFormat: TOutputFormat = ofNone): XmlString;

 {$IFDEF OmniXML_SupportAnsiStrings}
  {:Save XML document to an ansi string, automatically adding UTF8 processing
    instruction if required.
  }
  function XMLSaveToAnsiString(xmlDocument: IXMLDocument;
    outputFormat: TOutputFormat = ofNone): AnsiString;
 {$ENDIF OmniXML_SupportAnsiStrings}

  {:Load XML document from a stream.
  }
  function XMLLoadFromStream(xmlDocument: IXMLDocument;
    const xmlStream: TStream): boolean;

  {:Save XML document to a stream.
  }
  procedure XMLSaveToStream(xmlDocument: IXMLDocument;
    const xmlStream: TStream; outputFormat: TOutputFormat = ofNone);

  {:Load XML document from a file.
  }
  function XMLLoadFromFile(xmlDocument: IXMLDocument;
    const xmlFileName: string): boolean; overload;

  {:Load XML document from a file, returning error message on error.
  }
  function XMLLoadFromFile(xmlDocument: IXMLDocument; const xmlFileName: string;
    out errorMsg: string): boolean; overload;

  {:Save XML document to a file.
  }
  procedure XMLSaveToFile(xmlDocument: IXMLDocument;
    const xmlFileName: string; outputFormat: TOutputFormat = ofNone);

{$IFDEF MSWINDOWS}
  {:Load XML document from the registry.
  }
  function  XMLLoadFromRegistry(xmlDocument: IXMLDocument; rootKey: HKEY;
    const key, value: string): boolean;

  {:Save XML document to the registry.
  }
  function XMLSaveToRegistry(xmlDocument: IXMLDocument; rootKey: HKEY;
    const key, value: string; outputFormat: TOutputFormat): boolean;
{$ENDIF}

  {:Select single node possibly more than one level below.
  @since   2003-09-21
  }
  function SelectNode(parentNode: IXMLNode; const nodeTag: string): IXMLNode; overload;
  function SelectNode(parentNode: IXMLNode; const nodeTag: string; var childNode: IXMLNode): boolean; overload;

  {:Ensure that the node exists and return its interface.
  }
  function EnsureNode(parentNode: IXMLNode; nodeTag: string): IXMLNode;

  {:Append new child node to the parent.
    @since   2004-03-27
  }        
  function AppendNode(parentNode: IXMLNode; nodeTag: string): IXMLNode;

  {:Constructs XML document from given data.
  }
  function ConstructXMLDocument(const documentTag: string;
    const nodeTags, nodeValues: array of string): IXMLDocument; overload;

  {:Constructs XML document containing only documentelement node.
  }
  function ConstructXMLDocument(const documentTag: string): IXMLDocument; overload;

type
  TFilterXMLNodeEvent = procedure(node: IXMLNode; var canProcess: boolean) of object;

  {:Copies contents of one node into another. Some (sub)nodes can optionally be
    filtered out during the copy operation.
  }
  procedure CopyNode(sourceNode, targetNode: IXMLNode;
    copySubnodes: boolean = true; filterProc: TFilterXMLNodeEvent = nil);

  {:Copies contents of one node into another, then removes source node. Some
    (sub)nodes can optionally be filtered out during the copy operation.
  }
  procedure MoveNode(sourceNode, targetNode: IXMLNode;
    copySubnodes: boolean = true; filterProc: TFilterXMLNodeEvent = nil);

  {:Generates a copy of old node with new name, removes old node, and returns
    interface of the new node.
  }
  function RenameNode(node: IXMLNode; const newName: string): IXMLNode;

  {:Creates a copy of a XML document. Some nodes can optionally be filtered out
    during the copy operation.
    @since   2003-01-06
  }
  function CloneDocument(sourceDoc: IXMLDocument;
    filterProc: TFilterXMLNodeEvent = nil): IXMLDocument;

  {:Decode base64-encoded buffer.
  }
  function Base64Decode(Encoded, Decoded: Pointer; EncodedSize: Integer; var DecodedSize: Integer): Boolean; overload;

  {:Decode base64-encoded stream.
  }
  function  Base64Decode(const encoded, decoded: TStream): boolean; overload;

  {:Decode base64-encoded string.
  }
  function  Base64Decode(const encoded: string; decoded: TStream): boolean; overload;

  {:Decode base64-encoded string.
  }
  function  Base64Decode(const encoded: string; var decoded: string): boolean; overload;

  {:Decode base64-encoded string.
  }
  function  Base64Decode(const encoded: string): string; overload;

  {:Encode a buffer into base64 form.
  }
  function  Base64Encode(Decoded, Encoded: Pointer; Size: Integer): Integer; overload;

  {:Encode a stream into base64 form.
  }
  procedure Base64Encode(const decoded, encoded: TStream); overload;

  {:Encode a stream into base64 form.
  }
  procedure Base64Encode(decoded: TStream; var encoded: string); overload;

  {:Encode a stream into base64 form.
  }
  function  Base64Encode(decoded: TStream): string; overload;

  {:Encode a stream into base64 form.
  }
  function  Base64Encode(const decoded: string): string; overload;

  {:Encode a string into base64 form.
  }
  procedure Base64Encode(const decoded: string; var encoded: string); overload;

{$IFDEF OmniXmlUtils_Enumerators}
type
  XMLEnumerator = class
  strict private
    xeCurrent : IXMLNode;
    xeNodeList: IXMLNodeList;
  public
    constructor Create(nodeList: IXMLNodeList);
    function  GetCurrent: IXMLNode; inline;
    function  MoveNext: boolean; inline;
    property Current: IXMLNode read GetCurrent;
  end; { XMLEnumerator }

  XMLEnumeratorFactory = record
  strict private
    xefNodeList: IXMLNodeList;
    xefPattern : string;
    xefRootNode: IXMLNode;
  public
    constructor Create(rootNode: IXMLNode; const pattern: string); overload;
    constructor Create(nodeList: IXMLNodeList); overload;
    function  GetEnumerator: XMLEnumerator;
  end; { XMLEnumeratorFactory }

function XMLEnumNodes(xmlDocument: IXMLDocument; pattern: string): XMLEnumeratorFactory; overload;
function XMLEnumNodes(xmlNode: IXMLNode; pattern: string): XMLEnumeratorFactory; overload;
function XMLEnumNodes(xmlNodeList: IXMLNodeList) : XMLEnumeratorFactory; overload;
{$ENDIF OmniXmlUtils_Enumerators}

implementation

{$IFDEF MSWINDOWS}
uses
  Registry;
{$ENDIF}

const
  DEFAULT_DECIMALSEPARATOR  = '.'; // don't change!
  DEFAULT_TRUE              = '1'; // don't change!
  DEFAULT_TRUE_STR          = 'true'; // don't change!
  DEFAULT_FALSE             = '0'; // don't change!
  DEFAULT_FALSE_STR         = 'false'; // don't change!
  DEFAULT_DATETIMESEPARATOR = 'T'; // don't change!
  DEFAULT_DATESEPARATOR     = '-'; // don't change!
  DEFAULT_TIMESEPARATOR     = ':'; // don't change!
  DEFAULT_MSSEPARATOR       = '.'; // don't change!

function DecimalSeparator: char;
begin
  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF RTLVersion >= 22.0}  // Delphi XE
    Result := FormatSettings.DecimalSeparator;
    {$ELSE}
    Result := SysUtils.DecimalSeparator;  // Delphi 2010 and below
    {$IFEND}
  {$ELSE}
  Result := SysUtils.DecimalSeparator;
  {$ENDIF}  // CONDITIONALEXPRESSIONS
end; { DecimalSeparator }

{:Convert time from string (ISO format) to TDateTime.
}
function Str2Time(s: string): TDateTime;
var
  hour  : word;
  minute: word;
  msec  : word;
  p     : integer;
  second: word;
begin
  s := Trim(s);
  if s = '' then
    Result := 0
  else begin
    p := Pos(DEFAULT_TIMESEPARATOR,s);
    hour := StrToInt(Copy(s,1,p-1));
    Delete(s,1,p);
    p := Pos(DEFAULT_TIMESEPARATOR,s);
    minute := StrToInt(Copy(s,1,p-1));
    Delete(s,1,p);
    p := Pos(DEFAULT_MSSEPARATOR,s);
    if p > 0 then begin
      msec := StrToInt(Copy(s,p+1,Length(s)-p));
      Delete(s,p,Length(s)-p+1);
    end
    else
      msec := 0;
    second := StrToInt(s);
    Result := EncodeTime(hour,minute,second,msec);
  end;
end; { Str2Time }

{:Convert date/time from string (ISO format) to TDateTime.
}
function ISODateTime2DateTime (const ISODT: String): TDateTime;
var
  day   : word;
  month : word;
  p     : integer;
  sDate : string;
  sTime : string;
  year  : word;
begin
  p := Pos (DEFAULT_DATETIMESEPARATOR,ISODT);
  // detect all known date/time formats
  if (p = 0) and (Pos(DEFAULT_DATESEPARATOR, ISODT) > 0) then
    p := Length(ISODT) + 1;
  sDate := Trim(Copy(ISODT,1,p-1));
  sTime := Trim(Copy(ISODT,p+1,Length(ISODT)-p));
  Result := 0;
  if sDate <> '' then begin
    p := Pos (DEFAULT_DATESEPARATOR,sDate);
    year :=  StrToInt(Copy(sDate,1,p-1));
    Delete(sDate,1,p);
    p := Pos (DEFAULT_DATESEPARATOR,sDate);
    month :=  StrToInt(Copy(sDate,1,p-1));
    day := StrToInt(Copy(sDate,p+1,Length(sDate)-p));
    Result := EncodeDate(year,month,day);
  end;
  Result := Result + Frac(Str2Time(sTime));
end; { ISODateTime2DateTime }


{ Base64 code }

{$IFOPT R+} {$DEFINE OmniXMLUtils_Base64_EnableRangeChecking} {$ENDIF}
{$R-}
{$IFOPT Q+} {$DEFINE OmniXMLUtils_Base64_EnableOverflowChecking} {$ENDIF}
{$Q-}
{$IFOPT O-} {$DEFINE OmniXMLUtils_Base64_DisableOptimization} {$ENDIF}
{$O+}

const
  CB64DecodedBufferSize = 52488;
  CB64EncodedBufferSize = 69984;
  CB64InvalidData = $FF;
  CB64PaddingZero = $FE;

var
  B64EncodeTable: array[0..63] of Byte;
  B64DecodeTable: array[0..255] of Byte;

procedure Base64Setup;
var
  i: Integer;
begin
  // build encode table
  for i := 0 to 25 do
  begin
    B64EncodeTable[i] := i + Ord('A');
    B64EncodeTable[i+26] := i + Ord('a');
  end;

  for i := 0 to 9 do
    B64EncodeTable[i+52] := i + Ord('0');

  B64EncodeTable[62] := Ord('+');
  B64EncodeTable[63] := Ord('/');

  // build decode table
  for i := 0 to 255 do
  begin
    case i of
      Ord('A')..Ord('Z'): B64DecodeTable[i] := i - Ord('A');
      Ord('a')..Ord('z'): B64DecodeTable[i] := i - Ord('a') + 26;
      Ord('0')..Ord('9'): B64DecodeTable[i] := i - Ord('0') + 52;
      Ord('+'): B64DecodeTable[i] := 62;
      Ord('/'): B64DecodeTable[i] := 63;
      Ord('='): B64DecodeTable[i] := CB64PaddingZero;
    else
      B64DecodeTable[i] := CB64InvalidData;
    end;
  end;
end;

{$IFDEF OmniXmlUtils_Base64UsePointerMath}

function Base64EncodeOptimized(Decoded, Encoded: PByte; Size: Integer): Integer; overload;
begin
  Result := ((Size + 2) div 3) * 4;

  while Size >= 3 do
  begin
    Encoded[0] := B64EncodeTable[Decoded[0] shr 2];
    Encoded[1] := B64EncodeTable[((Decoded[0] and $03) shl 4) or (Decoded[1] shr 4)];
    Encoded[2] := B64EncodeTable[((Decoded[1] and $0f) shl 2) or (Decoded[2] shr 6)];
    Encoded[3] := B64EncodeTable[Decoded[2] and $3f];

    Inc(Decoded, 3);
    Inc(Encoded, 4);
    Dec(Size, 3);
  end;

  if Size = 1 then
  begin
    Encoded[0] := B64EncodeTable[Decoded[0] shr 2];
    Encoded[1] := B64EncodeTable[(Decoded[0] and $03) shl 4];
    Encoded[2] := Ord('=');
    Encoded[3] := Ord('=');
  end
  else if Size = 2 then
  begin
    Encoded[0] := B64EncodeTable[Decoded[0] shr 2];
    Encoded[1] := B64EncodeTable[((Decoded[0] and $03) shl 4) or (Decoded[1] shr 4)];
    Encoded[2] := B64EncodeTable[(Decoded[1] and $0f) shl 2];
    Encoded[3] := Ord('=');
  end;
end;

{$ELSE}

function Base64EncodeOptimized(Decoded, Encoded: Pointer; Size: Integer): Integer; overload;
var
  B1, B2, B3: Byte;
  AD: PByte;
  AE: PByte;
begin
  Result := ((Size + 2) div 3) * 4;

  AD := PByte(Decoded);
  AE := PByte(Encoded);

  while Size >= 3 do
  begin
    B1 := AD^;
    Inc(AD);
    B2 := AD^;
    Inc(AD);
    B3 := AD^;
    Inc(AD);

    AE^ := B64EncodeTable[B1 shr 2];
    Inc(AE);
    AE^ := B64EncodeTable[((B1 and $03) shl 4) or (B2 shr 4)];
    Inc(AE);
    AE^ := B64EncodeTable[((B2 and $0f) shl 2) or (B3 shr 6)];
    Inc(AE);
    AE^ := B64EncodeTable[B3 and $3f];
    Inc(AE);

    Dec(Size, 3);
  end;

  if Size = 1 then
  begin
    B1 := AD^;

    AE^ := B64EncodeTable[B1 shr 2];
    Inc(AE);
    AE^ := B64EncodeTable[(B1 and $03) shl 4];
    Inc(AE);
    AE^ := Ord('=');
    Inc(AE);
    AE^ := Ord('=');
  end
  else if Size = 2 then
  begin
    B1 := AD^;
    Inc(AD);
    B2 := AD^;

    AE^ := B64EncodeTable[B1 shr 2];
    Inc(AE);
    AE^ := B64EncodeTable[((B1 and $03) shl 4) or (B2 shr 4)];
    Inc(AE);
    AE^ := B64EncodeTable[(B2 and $0f) shl 2];
    Inc(AE);
    AE^ := Ord('=');
  end;
end;

{$ENDIF}  // OmniXmlUtils_Base64UsePointerMath

function Base64Encode(Decoded, Encoded: Pointer; Size: Integer): Integer; overload;
begin
  Result := Base64EncodeOptimized(Decoded, Encoded, Size);
end;

procedure Base64Encode(const decoded, encoded: TStream); overload;
var
  DecBuffer: Pointer;
  EncBuffer: Pointer;
  DecSize: Integer;
  EncSize: Integer;
begin
  if decoded.Size = 0 then
    Exit;

  GetMem(DecBuffer, CB64DecodedBufferSize);
  try
    GetMem(EncBuffer, CB64EncodedBufferSize);
    try
      repeat
        DecSize := decoded.Read(DecBuffer^, CB64DecodedBufferSize);
        EncSize := Base64Encode(DecBuffer, EncBuffer, DecSize);
        encoded.Write(EncBuffer^, EncSize);
      until DecSize <> CB64DecodedBufferSize;
    finally
      FreeMem(EncBuffer);
    end;
  finally
    FreeMem(DecBuffer);
  end;
end;

function Base64Decode(Encoded, Decoded: Pointer; EncodedSize: Integer; var DecodedSize: Integer): Boolean; overload;
var
  AE: PByte;
  AD: PByte;
  QData: array[0..3] of Byte;
  QIndex: Integer;
begin
  Result := True;
  if (EncodedSize mod 4) <> 0 then
  begin
    Result := False;
    Exit;
  end;

  DecodedSize := (EncodedSize div 4) * 3;
  AE := PByte(Encoded);
  AD := PByte(Decoded);

  while EncodedSize > 0 do
  begin
    for QIndex := 0 to 3 do
    begin
      QData[QIndex] := B64DecodeTable[AE^];

      case QData[QIndex] of
        CB64InvalidData:
          begin
            Result := False;
            Exit;
          end;
        CB64PaddingZero: Dec(DecodedSize);
      end;

      Inc(AE);
    end;

    AD^ := Byte((QData[0] shl 2) or (QData[1] shr 4));
    Inc(AD);

    if (QData[2] <> CB64PaddingZero) and (QData[3] = CB64PaddingZero) then
    begin
      AD^ := Byte((QData[1] shl 4) or (QData[2] shr 2));
      Inc(AD);
    end
    else if (QData[2] <> CB64PaddingZero) then
    begin
      AD^ := Byte((QData[1] shl 4) or (QData[2] shr 2));
      Inc(AD);
      AD^ := Byte((QData[2] shl 6) or (QData[3]));
      Inc(AD);
    end;

    Dec(EncodedSize, 4);
  end;
end;

function Base64Decode(const encoded, decoded: TStream): Boolean; overload;
var
  EncBuffer: Pointer;
  DecBuffer: Pointer;
  EncSize: Integer;
  DecSize: Integer;
begin
  Result := True;

  GetMem(EncBuffer, CB64EncodedBufferSize);
  try
    GetMem(DecBuffer, CB64DecodedBufferSize);
    try
      repeat
        EncSize := encoded.Read(EncBuffer^, CB64EncodedBufferSize);
        if Base64Decode(EncBuffer, DecBuffer, EncSize, DecSize) then
          decoded.Write(DecBuffer^, DecSize)
        else
        begin
          Result := False;
          Break;
        end;
      until EncSize <> CB64EncodedBufferSize;
    finally
      FreeMem(DecBuffer);
    end;
  finally
    FreeMem(EncBuffer);
  end;
end;

{$IFDEF OmniXMLUtils_Base64_EnableRangeChecking} {$R+} {$ENDIF}
{$IFDEF OmniXMLUtils_Base64_EnableOverflowChecking} {$Q+} {$ENDIF}
{$IFDEF OmniXMLUtils_Base64_DisableOptimization} {$O-} {$ENDIF}

function Base64Decode(const encoded: string; decoded: TStream): boolean; overload;
var
  encStr: TStringStream;
begin
  encStr := TStringStream.Create(encoded);
  try
    Result := Base64Decode(encStr, decoded);
  finally FreeAndNil(encStr); end;
end; { Base64Decode }

function Base64Decode(const encoded: string; var decoded: string): boolean;
var
  decStr: TStringStream;
begin
  decStr := TStringStream.Create('');
  try
    Result := Base64Decode(encoded, decStr);
    if Result then
      decoded := decStr.DataString;
  finally FreeAndNil(decStr); end;
end; { Base64Decode }

function Base64Decode(const encoded: string): string;
begin
  Base64Decode(encoded, Result);
end; { Base64Decode }

procedure Base64Encode(decoded: TStream; var encoded: string); overload;
var
  encStr: TStringStream;
begin
  encStr := TStringStream.Create('');
  try
    Base64Encode(decoded, encStr);
    encoded := encStr.DataString;
  finally FreeAndNil(encStr); end;
end; { Base64Encode }

function Base64Encode(decoded: TStream): string;
begin
  Base64Encode(decoded, Result);
end; { Base64Encode }

procedure Base64Encode(const decoded: string; var encoded: string);
var
  decStr: TStringStream;
begin
  decStr := TStringStream.Create(decoded);
  try
    Base64Encode(decStr, encoded);
  finally FreeAndNil(decStr); end;
end; { Base64Encode }

function Base64Encode(const decoded: string): string;
begin
  Base64Encode(decoded, Result);
end; { Base64Encode }

{:Checks whether the specified node is an xml document node.
  @since   2003-01-13
}
function IsDocument(node: IXMLNode): boolean;
var
  docNode: IXMLDocument;
begin
  Result := Supports(node, IXMLDocument, docNode);
end; { IsDocument }

{:@since   2003-01-13
}
function OwnerDocument(node: IXMLNode): IXMLDocument;
begin
  if not Supports(node, IXMLDocument, Result) then
    Result := node.OwnerDocument;
end; { OwnerDocument }

{:@since   2003-01-13
}
function DocumentElement(node: IXMLNode): IXMLElement;
begin
  Result := OwnerDocument(node).DocumentElement;
end; { DocumentElement }

{:@since   2003-01-13
}
function GetTextChild(node: IXMLNode): IXMLNode;
var
  iText: integer;
begin
  Result := nil;
  if not assigned(node) then
    Exit;
  for iText := 0 to node.ChildNodes.Length-1 do
    if node.ChildNodes.Item[iText].NodeType = TEXT_NODE then begin
      Result := node.ChildNodes.Item[iText];
      break; //for
    end;
end; { GetTextChild }

{:@since   2003-12-12
}
function GetCDataChild(node: IXMLNode): IXMLNode;
var
  iText: integer;
begin
  Result := nil;
  if not assigned(node) then
    Exit;
  for iText := 0 to node.ChildNodes.Length-1 do
    if node.ChildNodes.Item[iText].NodeType = CDATA_SECTION_NODE then begin
      Result := node.ChildNodes.Item[iText];
      break; //for
    end;
end; { GetCDataChild }

{:@since   2003-01-13
}
function SetTextChild(node: IXMLNode; value: XmlString): IXMLNode;
var
  iText: integer;
begin
  iText := 0;
  while iText < node.ChildNodes.Length do begin
    if node.ChildNodes.Item[iText].NodeType = TEXT_NODE then
      node.RemoveChild(node.ChildNodes.Item[iText])
    else
      Inc(iText);
  end; //while
  Result := OwnerDocument(node).CreateTextNode(value);
  node.AppendChild(Result);
end; { SetTextChild }

{:@since   2003-12-12
}
function SetCDataChild(node: IXMLNode; value: XmlString): IXMLNode;
var
  iText: integer;
begin
  iText := 0;
  while iText < node.ChildNodes.Length do begin
    if node.ChildNodes.Item[iText].NodeType = CDATA_SECTION_NODE then
      node.RemoveChild(node.ChildNodes.Item[iText])
    else
      Inc(iText);
  end; //while
  Result := OwnerDocument(node).CreateCDATASection(value);
  node.AppendChild(Result);
end; { SetCDataChild }

{:@param   parentNode Parent of the node to be deleted.
  @param   nodeTag    Name of the node (which is child of parentNode) to be
                      deleted.
}
procedure DeleteNode(parentNode: IXMLNode; nodeTag: string);
var
  myNode: IXMLNode;
begin
  myNode := parentNode.SelectSingleNode(nodeTag);
  if assigned(myNode) then
    parentNode.RemoveChild(myNode);
end; { DeleteNode }

{:@param   parentNode Node containing children to be deleted.
  @param   pattern    Name of the children nodes that have to be deleted. If
                      empty, all children will be deleted.
}
procedure DeleteAllChildren(parentNode: IXMLNode; pattern: string = '');
var
  myNode  : IXMLNode;
  oldText : XmlString;
  textNode: IXMLNode;
begin
  textNode := GetTextChild(parentNode);
  if assigned(textNode) then // following code will delete TEXT_NODE
    oldText := textNode.Text;
  repeat
    if pattern = '' then
      myNode := parentNode.FirstChild
    else
      myNode := parentNode.SelectSingleNode(pattern);
    if assigned(myNode) then
      parentNode.RemoveChild(myNode);
  until not assigned(myNode);
  if assigned(textNode) then 
    SetTextChild(parentNode, oldText);
end; { DeleteAllChildren }

function XMLStrToReal(nodeValue: XmlString; var value: real): boolean;
begin
  try
    value := XMLStrToReal(nodeValue);
    Result := true;
  except
    on EConvertError do
      Result := false;
  end;
end; { XMLStrToReal }

function XMLStrToReal(nodeValue: XmlString): real;
begin
  Result := StrToFloat(StringReplace(nodeValue, DEFAULT_DECIMALSEPARATOR,
    DecimalSeparator, [rfReplaceAll]));
end; { XMLStrToReal }

function XMLStrToRealDef(nodeValue: XmlString; defaultValue: real): real;
begin
  if not XMLStrToReal(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToRealDef }

function XMLStrToExtended(nodeValue: XmlString; var value: extended): boolean;
begin
  try
    value := XMLStrToExtended(nodeValue);
    Result := true;
  except
    on EConvertError do
      Result := false;
  end;
end; { XMLStrToExtended }

function XMLStrToExtended(nodeValue: XmlString): extended;
begin
  try
    Result := StrToFloat(StringReplace(nodeValue, DEFAULT_DECIMALSEPARATOR,
      DecimalSeparator, [rfReplaceAll]));
  except
    on EConvertError do begin
      if (nodeValue = 'INF') or (nodeValue = '+INF') then 
        Result := 1.1e+4932
      else if nodeValue = '-INF' then
        Result := 3.4e-4932
      else
        raise;
    end;
  end;
end; { XMLStrToExtended }

function XMLStrToExtendedDef(nodeValue: XmlString; defaultValue: extended): extended;
begin
  if not XMLStrToExtended(nodeValue, Result) then
    Result := defaultValue;
end; { XMLStrToExtendedDef }

function StrToCurr(const S: string): Currency;
begin
  TextToFloat(PChar(S), Result, fvCurrency);
end; { StrToCurr }

function XMLStrToCurrency(nodeValue: XmlString; var value: Currency): boolean;
begin
  try
    value := XMLStrToCurrency(nodeValue);
    Result := true;
  except
    on EConvertError do
      Result := false;
  end;
end; { XMLStrToCurrency }

function XMLStrToCurrency(nodeValue: XmlString): Currency;
begin
  Result := StrToCurr(StringReplace(nodeValue, DEFAULT_DECIMALSEPARATOR,
    DecimalSeparator, [rfReplaceAll]));
end; { XMLStrToCurrency }

function XMLStrToCurrencyDef(nodeValue: XmlString; defaultValue: Currency): Currency;
begin
  if not XMLStrToCurrency(nodeValue, Result) then
    Result := defaultValue;
end; { XMLStrToCurrencyDef }

function XMLStrToInt(nodeValue: XmlString; var value: integer): boolean;
begin
  try
    value := XMLStrToInt(nodeValue);
    Result := true;
  except
    on EConvertError do
      Result := false;
  end;
end; { XMLStrToInt }

function XMLStrToInt(nodeValue: XmlString): integer;
begin
  Result := StrToInt(nodeValue);
end; { XMLStrToInt }

function XMLStrToIntDef(nodeValue: XmlString; defaultValue: integer): integer;
begin
  if not XMLStrToInt(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToIntDef }

function XMLStrToInt64(nodeValue: XmlString; var value: int64): boolean;
begin
  try
    value := XMLStrToInt64(nodeValue);
    Result := true;
  except
    on EConvertError do
      Result := false;
  end;
end; { XMLStrToInt64 }

function XMLStrToInt64(nodeValue: XmlString): int64;
begin
  Result := StrToInt64(nodeValue);
end; { XMLStrToInt64 }

function XMLStrToInt64Def(nodeValue: XmlString; defaultValue: int64): int64;
begin
  if not XMLStrToInt64(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToInt64Def }

function XMLStrToBool(nodeValue: XmlString; var value: boolean): boolean;
begin
  if (nodeValue = DEFAULT_TRUE) or (nodeValue = DEFAULT_TRUE_STR) then begin
    value := true;
    Result := true;
  end
  else if (nodeValue = DEFAULT_FALSE) or (nodeValue = DEFAULT_FALSE_STR) then begin
    value := false;
    Result := true;
  end
  else
    Result := false;
end; { XMLStrToBool }

function XMLStrToBool(nodeValue: XmlString): boolean; overload;
begin
  if not XMLStrToBool(nodeValue, Result) then
    raise EOmniXMLUtils.CreateFmt('%s is not a boolean value', [nodeValue]);
end; { XMLStrToBool }

function XMLStrToBoolDef(nodeValue: XmlString; defaultValue: boolean): boolean;
begin
  if not XMLStrToBool(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToBoolDef }

function XMLStrToDateTime(nodeValue: XmlString; var value: TDateTime): boolean;
begin
  try
    value := ISODateTime2DateTime(nodeValue);
    Result := true;
  except
    Result := false;
  end;
end; { XMLStrToDateTime }

function XMLStrToDateTime(nodeValue: XmlString): TDateTime;
begin
  if not XMLStrToDateTime(nodeValue, Result) then
    raise EOmniXMLUtils.CreateFmt('%s is not an ISO datetime value', [nodeValue]);
end; { XMLStrToDateTime }

function XMLStrToDateTimeDef(nodeValue: XmlString; defaultValue: TDateTime): TDateTime;
begin
  if not XMLStrToDateTime(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToDateTimeDef }

function XMLStrToDate(nodeValue: XmlString; var value: TDateTime): boolean;
begin
  try
    value := Int(ISODateTime2DateTime(nodeValue));
    Result := true;
  except
    Result := false;
  end;
end; { XMLStrToDate }

function XMLStrToDate(nodeValue: XmlString): TDateTime;
begin
  if not XMLStrToDate(nodeValue, Result) then
    raise EOmniXMLUtils.CreateFmt('%s is not an ISO date value', [nodeValue]);
end; { XMLStrToDate }

function XMLStrToDateDef(nodeValue: XmlString; defaultValue: TDateTime): TDateTime;
begin
  if not XMLStrToDate(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToDateDef }

function XMLStrToTime(nodeValue: XmlString; var value: TDateTime): boolean;
begin
  try
    value := Str2Time(nodeValue);
    Result := true;
  except
    Result := false;
  end;
end; { XMLStrToTime }

function XMLStrToTime(nodeValue: XmlString): TDateTime;
begin
  if not XMLStrToTime(nodeValue, Result) then
    raise EOmniXMLUtils.CreateFmt('%s is not a time value', [nodeValue]);
end; { XMLStrToTime }

function XMLStrToTimeDef(nodeValue: XmlString; defaultValue: TDateTime): TDateTime;
begin
  if not XMLStrToTime(nodeValue,Result) then
    Result := defaultValue;
end; { XMLStrToTimeDef }

function XMLStrToBinary(nodeValue: XmlString; const value: TStream): boolean;
var
  nodeStream: TStringStream;
begin
  value.Size := 0;
  nodeStream := TStringStream.Create(nodeValue);
  try
    Result := Base64Decode(nodeStream, value);
  finally FreeAndNil(nodeStream); end;
end; { XMLStrToBinary }

{:@since   2003-12-12
}        
function GetNodeCData(parentNode: IXMLNode; nodeTag: string;
  defaultValue: XmlString): XmlString;
var
  myNode: IXMLNode;
begin
  Result := defaultValue;
  myNode := SelectNode(parentNode, nodeTag);
  if assigned(myNode) then begin
    myNode := GetCDataChild(myNode);
    if assigned(myNode) then
      Result := myNode.NodeValue
  end;
end; { GetNodeCData }

function GetNodeCData(node: IXMLNode): XmlString;
var
  cdataNode: IXMLNode;
begin
  cdataNode := GetCDataChild(node);
  if assigned(cdataNode) then
    Result := cdataNode.NodeValue
  else
    Result := '';
end; { GetNodeCData }

function GetNodeText(parentNode: IXMLNode; nodeTag: string;
  var nodeText: XmlString): boolean;
var
  myNode: IXMLNode;
begin
  Result := false;
  if assigned(parentNode) then begin
    myNode := SelectNode(parentNode, nodeTag);
    if assigned(myNode) then begin
      myNode := GetTextChild(myNode);
      if assigned(myNode) then
        nodeText := myNode.NodeValue
      else
        nodeText := '';
      Result := true;
    end;
  end;
end; { GetNodeText }

function GetNodeText(node: IXMLNode): XmlString;
var
  textNode: IXMLNode;
begin
  textNode := GetTextChild(node);
  if assigned(textNode) then
    Result := textNode.NodeValue
  else
    Result := '';
end; { GetNodeText }

procedure GetNodesText(parentNode: IXMLNode; nodeTag: string;
  {var} nodesText: TStrings); 
var
  iNode: integer;
  nodes: IXMLNodeList;
begin
  nodesText.Clear;
  nodes := parentNode.SelectNodes(nodeTag);
  for iNode := 0 to nodes.Length-1 do
    nodesText.Add(Trim(nodes.Item[iNode].Text));
end; { GetNodesText }

procedure GetNodesText(parentNode: IXMLNode; nodeTag: string;
  var nodesText: string); 
var
  texts: TStringList;
begin
  texts := TStringList.Create;
  try
    GetNodesText(parentNode, nodeTag, texts);
    nodesText := texts.Text;
  finally FreeAndNil(texts); end;
end; { GetNodesText }

function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
  defaultValue: XmlString): XmlString;
begin
  if not GetNodeText(parentNode, nodeTag, Result) then
    Result := defaultValue
  else
    Result := Trim(Result);
end; { GetNodeTextStr }

function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string): XmlString;
begin
  if not GetNodeText(parentNode, nodeTag, Result) then
    raise EOmniXMLUtils.CreateFmt('GetNodeTextStr: No text in the the %s node', [nodeTag]);
end; { GetNodeTextStr }

function GetNodeTextReal(parentNode: IXMLNode; nodeTag: string;
  defaultValue: real): real;
var
  nodeText: XmlString;
begin
  if not GetNodeText(parentNode, nodeTag, nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToRealDef(nodeText, defaultValue);
end; { GetNodeTextReal }

function GetNodeTextReal(parentNode: IXMLNode; nodeTag: string): real;
begin
  Result := XMLStrToReal(GetNodeTextStr(parentNode, nodeTag));
end; { GetNodeTextReal }

function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
  defaultValue: integer): integer;
var
  nodeText: XmlString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToIntDef(nodeText,defaultValue);
end; { GetNodeTextInt }

function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string): integer;
begin
  Result := XMLStrToInt(GetNodeTextStr(parentNode, nodeTag));
end; { GetNodeTextInt }

function GetNodeTextInt64(parentNode: IXMLNode; nodeTag: string;
  defaultValue: int64): int64;
var
  nodeText: XmlString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToInt64Def(nodeText,defaultValue);
end; { GetNodeTextInt64 }

function GetNodeTextInt64(parentNode: IXMLNode; nodeTag: string): int64;
begin
  Result := XMLStrToInt64(GetNodeTextStr(parentNode, nodeTag));
end; { GetNodeTextInt64 }

function GetNodeTextBool(parentNode: IXMLNode; nodeTag: string;
  defaultValue: boolean): boolean;
var
  nodeText: XmlString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToBoolDef(nodeText,defaultValue);
end; { GetNodeTextBool }

function GetNodeTextBool(parentNode: IXMLNode; nodeTag: string): boolean;
begin
  Result := XMLStrToBool(GetNodeTextStr(parentNode, nodeTag));
end; { GetNodeTextBool }

function GetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string;
  defaultValue: TDateTime): TDateTime;
var
  nodeText: XmlString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToDateTimeDef(nodeText,defaultValue);
end; { GetNodeTextDateTime }

function GetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string): TDateTime;
begin
  Result := XMLStrToDateTime(GetNodeTextStr(parentNode, nodeTag));
end; { GetNodeTextDateTime }

function GetNodeTextDate(parentNode: IXMLNode; nodeTag: string;
  defaultValue: TDateTime): TDateTime;
var
  nodeText: XmlString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToDateDef(nodeText,defaultValue);
end; { GetNodeTextDate }

function GetNodeTextDate(parentNode: IXMLNode; nodeTag: string): TDateTime;
begin
  Result := XMLStrToDate(GetNodeTextStr(parentNode, nodeTag));
end; { GetNodeTextDate }

function GetNodeTextTime(parentNode: IXMLNode; nodeTag: string;
  defaultValue: TDateTime): TDateTime;
var
  nodeText: XmlString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToTimeDef(nodeText,defaultValue);
end; { GetNodeTextTime }

function GetNodeTextTime(parentNode: IXMLNode; nodeTag: string): TDateTime;
begin
  Result := XMLStrToTime(GetNodeTextStr(parentNode, nodeTag));
end; { GetNodeTextTime }

function GetNodeTextBinary(parentNode: IXMLNode; nodeTag: string;
  value: TStream): boolean;
var
  decoded: TMemoryStream;
begin
  decoded := TMemoryStream.Create;
  try
    Result := XMLStrToBinary(GetNodeTextStr(parentNode, nodeTag, ''), decoded);
    if Result then
      value.CopyFrom(decoded, 0);
  finally FreeAndNil(decoded); end;
end; { GetNodeTextBinary }

{$IFNDEF NoVCL}
function GetNodeTextFont(parentNode: IXMLNode; nodeTag: string; value: TFont): boolean;
var
  fontNode: IXMLNode;
  fStyle  : TFontStyles;
  iStyle  : integer;
begin
  Result := false;
  fontNode := SelectNode(parentNode, nodeTag);
  if assigned(fontNode) then begin
    value.Name := GetNodeTextStr(fontNode, 'Name', value.Name);
    value.Charset := GetNodeAttrInt(fontNode, 'Charset', value.Charset);
    value.Color := GetNodeAttrInt(fontNode, 'Color', value.Color);
    value.Height := GetNodeAttrInt(fontNode, 'Height', value.Height);
    value.Pitch := TFontPitch(GetNodeAttrInt(fontNode, 'Pitch', Ord(value.Pitch)));
    value.Size := GetNodeAttrInt(fontNode, 'Size', value.Size);
    fStyle := value.Style;
    iStyle := 0;
    Move(fStyle, iStyle, SizeOf(TFontStyles));
    iStyle := GetNodeAttrInt(fontNode, 'Style', iStyle);
    Move(iStyle, fStyle, SizeOf(TFontStyles));
    value.Style := fStyle;
    Result := true;
  end;
end; { GetNodeTextFont }
{$ENDIF}

function GetNodeAttr(parentNode: IXMLNode; attrName: string;
  var value: XmlString): boolean;
var
  attrNode: IXMLNode;
begin
  if IsDocument(parentNode) and assigned(DocumentElement(parentNode)) then
    parentNode := DocumentElement(parentNode);
  attrNode := parentNode.Attributes.GetNamedItem(attrName);
  if not assigned(attrNode) then
    Result := false
  else begin
    value := attrNode.NodeValue;
    Result := true;
  end;
end; { GetNodeAttr }

function GetNodeAttrStr(parentNode: IXMLNode; attrName: string;
  defaultValue: XmlString): XmlString;
begin
  if not GetNodeAttr(parentNode, attrName, Result) then
    Result := defaultValue
  else
    Result := Trim(Result);
end; { GetNodeAttrStr }

function GetNodeAttrStr(parentNode: IXMLNode; attrName: string): XmlString;
begin
  if not GetNodeAttr(parentNode, attrName, Result) then
    raise EOmniXMLUtils.CreateFmt('GetNodeAttrStr: No attribute %s in the the %s node',
      [attrName, parentNode.NodeName]);
end; { GetNodeAttrStr }

function GetNodeAttrReal(parentNode: IXMLNode; attrName: string;
  defaultValue: real): real;
var
  attrValue: XmlString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToRealDef(attrValue,defaultValue);
end; { GetNodeAttrReal }

function GetNodeAttrReal(parentNode: IXMLNode; attrName: string): real;
begin
  Result := XMLStrToReal(GetNodeAttrStr(parentNode, attrName));
end; { GetNodeAttrReal }

function GetNodeAttrInt(parentNode: IXMLNode; attrName: string;
  defaultValue: integer): integer;
var
  attrValue: XmlString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToIntDef(attrValue,defaultValue);
end; { GetNodeAttrInt }

function GetNodeAttrInt(parentNode: IXMLNode; attrName: string): integer;
begin
  Result := XMLStrToInt(GetNodeAttrStr(parentNode, attrName));
end; { GetNodeAttrInt }

function GetNodeAttrInt64(parentNode: IXMLNode; attrName: string;
  defaultValue: int64): int64;
var
  attrValue: XmlString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToInt64Def(attrValue,defaultValue);
end; { GetNodeAttrInt64 }

function GetNodeAttrInt64(parentNode: IXMLNode; attrName: string): int64;
begin
  Result := XMLStrToInt64(GetNodeAttrStr(parentNode, attrName));
end; { GetNodeAttrInt64 }

function GetNodeAttrBool(parentNode: IXMLNode; attrName: string;
  defaultValue: boolean): boolean;
var
  attrValue: XmlString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToBoolDef(attrValue,defaultValue);
end; { GetNodeAttrBool }

function GetNodeAttrBool(parentNode: IXMLNode; attrName: string): boolean;
begin
  Result := XMLStrToBool(GetNodeAttrStr(parentNode, attrName));
end; { GetNodeAttrBool }

function GetNodeAttrDateTime(parentNode: IXMLNode; attrName: string;
  defaultValue: TDateTime): TDateTime;
var
  attrValue: XmlString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToDateTimeDef(attrValue,defaultValue);
end; { GetNodeAttrDateTime }

function GetNodeAttrDateTime(parentNode: IXMLNode; attrName: string): TDateTime;
begin
  Result := XMLStrToDateTime(GetNodeAttrStr(parentNode, attrName));
end; { GetNodeAttrDateTime }

function GetNodeAttrDate(parentNode: IXMLNode; attrName: string;
  defaultValue: TDateTime): TDateTime;
var
  attrValue: XmlString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToDateDef(attrValue,defaultValue);
end; { GetNodeAttrDate }

function GetNodeAttrDate(parentNode: IXMLNode; attrName: string): TDateTime;
begin
  Result := XMLStrToDate(GetNodeAttrStr(parentNode, attrName));
end; { GetNodeAttrDate }

function GetNodeAttrTime(parentNode: IXMLNode; attrName: string;
  defaultValue: TDateTime): TDateTime;
var
  attrValue: XmlString;
begin
  if not GetNodeAttr(parentNode,attrName,attrValue) then
    Result := defaultValue
  else
    Result := XMLStrToTimeDef(attrValue,defaultValue);
end; { GetNodeAttrTime }

function GetNodeAttrTime(parentNode: IXMLNode; attrName: string): TDateTime;
begin
  Result := XMLStrToTime(GetNodeAttrStr(parentNode, attrName));
end; { GetNodeAttrTime }

function XMLRealToStr(value: real; precision: byte = 15): XmlString;
begin
  Result := StringReplace(FloatToStrF(value, ffGeneral, precision, 0),
    DecimalSeparator, DEFAULT_DECIMALSEPARATOR, [rfReplaceAll]);
end; { XMLRealToStr }

function XMLExtendedToStr(value: extended): XmlString;
begin
  Result := StringReplace(FloatToStr(value),
    DecimalSeparator, DEFAULT_DECIMALSEPARATOR, [rfReplaceAll]);
end; { XMLExtendedToStr }

function XMLCurrencyToStr(value: Currency): XmlString;
begin
  Result := StringReplace(CurrToStr(value),
    DecimalSeparator, DEFAULT_DECIMALSEPARATOR, [rfReplaceAll]);
end; { XMLExtendedToStr }

function XMLIntToStr(value: integer): XmlString;
begin
  Result := IntToStr(value);
end; { XMLIntToStr }

function XMLInt64ToStr(value: int64): XmlString;
begin
  Result := IntToStr(value)
end; { XMLInt64ToStr }

function XMLBoolToStr(value: boolean; useBoolStrs: boolean = false): XmlString;
begin
  if value then
    if useBoolStrs then
      Result := DEFAULT_TRUE_STR
    else
      Result := DEFAULT_TRUE
  else
    if useBoolStrs then
      Result := DEFAULT_FALSE_STR
    else
      Result := DEFAULT_FALSE;
end; { XMLBoolToStr }

function XMLDateTimeToStr(value: TDateTime): XmlString;
begin
  if Trunc(value) = 0 then
    Result := FormatDateTime('"'+DEFAULT_DATETIMESEPARATOR+'"hh":"mm":"ss.zzz',value)
  else
    Result := FormatDateTime('yyyy-mm-dd"'+
      DEFAULT_DATETIMESEPARATOR+'"hh":"mm":"ss.zzz',value);
end; { XMLDateTimeToStr }

function XMLDateTimeToStrEx(value: TDateTime): XmlString;
begin
  if Trunc(value) = 0 then
    Result := XMLTimeToStr(value)
  else if Frac(Value) = 0 then
    Result := XMLDateToStr(value)
  else
    Result := XMLDateTimeToStr(value);
end; { XMLDateTimeToStrEx }

function XMLDateToStr(value: TDateTime): XmlString;
begin
  Result := FormatDateTime('yyyy-mm-dd',value);
end; { XMLDateToStr }

function XMLTimeToStr(value: TDateTime): XmlString;
begin
  Result := FormatDateTime('hh":"mm":"ss.zzz',value);
end; { XMLTimeToStr }

function XMLBinaryToStr(value: TStream): XmlString;
var
  nodeStream: TStringStream;
begin
  value.Position := 0;
  nodeStream := TStringStream.Create('');
  try
    Base64Encode(value, nodeStream);
    Result := nodeStream.DataString;
  finally FreeAndNil(nodeStream); end;
end; { XMLBinaryToStr }

function XMLVariantToStr(value: Variant): XmlString;
begin
  case VarType(value) of
    varSingle, varDouble, varCurrency:
      Result := XMLExtendedToStr(value);
    varDate:
      Result := XMLDateTimeToStrEx(value);
    varBoolean:
      Result := XMLBoolToStr(value);
    else
      Result := value;
  end; //case
end; { XMLVariantToStr }

function SetNodeCData(parentNode: IXMLNode; nodeTag: string;
  value: XmlString): IXMLNode;
begin
  Result := EnsureNode(parentNode, nodeTag);
  SetCDataChild(Result, value);
end; { SetNodeCData }

function SetNodeText(parentNode: IXMLNode; nodeTag: string;
  value: XmlString): IXMLNode;
begin
  Result := EnsureNode(parentNode, nodeTag);
  SetTextChild(Result, value);
end; { SetNodeText }

procedure SetNodesText(parentNode: IXMLNode; nodeTag: string;
  nodesText: TStrings); 
var
  childNode: IXMLNode;
  iText    : integer;
begin
  for iText := 0 to nodesText.Count-1 do begin
    childNode := OwnerDocument(parentNode).CreateElement(nodeTag);
    parentNode.AppendChild(childNode);
    childNode.Text := nodesText[iText];
  end; //for
end; { SetNodesText }

procedure SetNodesText(parentNode: IXMLNode; nodeTag: string;
  nodesText: string); 
var
  texts: TStringList;
begin
  texts := TStringList.Create;
  try
    texts.Text := nodesText;
    SetNodesText(parentNode, nodeTag, texts);
  finally FreeAndNil(texts); end;
end; { SetNodesText }

function SetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
  value: XmlString): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,value);
end; { SetNodeTextStr }

function SetNodeTextReal(parentNode: IXMLNode; nodeTag: string;
  value: real): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLRealToStr(value));
end; { SetNodeTextReal }

function SetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
  value: integer): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLIntToStr(value));
end; { SetNodeTextInt }

function SetNodeTextInt64(parentNode: IXMLNode; nodeTag: string;
  value: int64): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLInt64ToStr(value));
end; { SetNodeTextInt64 }

function SetNodeTextBool(parentNode: IXMLNode; nodeTag: string;
  value: boolean): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLBoolToStr(value));
end; { SetNodeTextBool }

function SetNodeTextDateTime(parentNode: IXMLNode; nodeTag: string;
  value: TDateTime): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLDateTimeToStr(value));
end; { SetNodeTextDateTime }

function SetNodeTextDate(parentNode: IXMLNode; nodeTag: string;
  value: TDateTime): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLDateToStr(value));
end; { SetNodeTextDate }

function SetNodeTextTime(parentNode: IXMLNode; nodeTag: string;
  value: TDateTime): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLTimeToStr(value));
end; { SetNodeTextTime }

function SetNodeTextBinary(parentNode: IXMLNode; nodeTag: string;
  const value: TStream): IXMLNode;
begin
  Result := SetNodeText(parentNode,nodeTag,XMLBinaryToStr(value));
end; { SetNodeTextBinary }

{$IFNDEF NoVCL}
function SetNodeTextFont(parentNode: IXMLNode; nodeTag: string;
  value: TFont): IXMLNode;
var
  fontNode  : IXMLNode;
  fStyle    : TFontStyles;
  iStyle    : integer;
begin
  fontNode := EnsureNode(parentNode, nodeTag);
  SetNodeTextStr(fontNode, 'Name', value.Name);
  SetNodeAttrInt(fontNode, 'Charset', value.Charset);
  SetNodeAttrInt(fontNode, 'Color', value.Color);
  SetNodeAttrInt(fontNode, 'Height', value.Height);
  SetNodeAttrInt(fontNode, 'Pitch', Ord(value.Pitch));
  SetNodeAttrInt(fontNode, 'Size', value.Size);
  fStyle := value.Style;
  iStyle := 0;
  Move(fStyle, iStyle, SizeOf(TFontStyles));
  SetNodeAttrInt(fontNode, 'Style', iStyle);
end; { SetNodeTextFont }
{$ENDIF}

procedure SetNodeAttr(parentNode: IXMLNode; attrName: string;
  value: XmlString);
var
  attrNode: IXMLNode;
begin
  attrNode := OwnerDocument(parentNode).CreateAttribute(attrName);
  attrNode.NodeValue := value;
  parentNode.Attributes.SetNamedItem(attrNode);
end; { SetNodeAttr }

procedure SetNodeAttrStr(parentNode: IXMLNode; attrName: string;
  value: XmlString);
begin
  SetNodeAttr(parentNode,attrName,value);
end; { SetNodeAttrStr }

procedure SetNodeAttrReal(parentNode: IXMLNode; attrName: string;
  value: real);
begin
  SetNodeAttr(parentNode,attrName,XMLRealToStr(value));
end; { SetNodeAttrReal }

procedure SetNodeAttrInt(parentNode: IXMLNode; attrName: string;
  value: integer);
begin
  SetNodeAttr(parentNode,attrName,XMLIntToStr(value));
end; { SetNodeAttrInt }

procedure SetNodeAttrInt64(parentNode: IXMLNode; attrName: string;
  value: int64);
begin
  SetNodeAttr(parentNode,attrName,XMLInt64ToStr(value));
end; { SetNodeAttrInt64 }

procedure SetNodeAttrBool(parentNode: IXMLNode; attrName: string;
  value: boolean);
begin
  SetNodeAttr(parentNode,attrName,XMLBoolToStr(value));
end; { SetNodeAttrBool }

procedure SetNodeAttrDateTime(parentNode: IXMLNode; attrName: string;
  value: TDateTime);
begin
  SetNodeAttr(parentNode,attrName,XMLDateTimeToStr(value));
end; { SetNodeAttrDateTime }

procedure SetNodeAttrDate(parentNode: IXMLNode; attrName: string;
  value: TDateTime);
begin
  SetNodeAttr(parentNode,attrName,XMLDateToStr(value));
end; { SetNodeAttrDate }

procedure SetNodeAttrTime(parentNode: IXMLNode; attrName: string;
  value: TDateTime);
begin
  SetNodeAttr(parentNode,attrName,XMLTimeToStr(value));
end; { SetNodeAttrTime }

procedure SetNodeAttrs(parentNode: IXMLNode; attrNamesValues: array of string);
var
  nameValue: string;
  name: string;
  value: string;
  valuePos: Integer;
  I: Integer;
begin
  for I := Low(attrNamesValues) to High(attrNamesValues) do
  begin
    nameValue := attrNamesValues[I];
    valuePos := Pos('=', nameValue);
    if valuePos > 0 then
    begin
      name := Copy(nameValue, 1, valuePos-1);
      value := Copy(nameValue, valuePos+1, Length(nameValue));
      if Length(value) > 0 then
      begin
        if value[1] = '"' then
          Delete(value, 1, 1);
        if value[Length(value)] = '"' then
          SetLength(value, Length(value)-1);
      end;
    end
    else
    begin
      name := nameValue;
      value := '';
    end;
    SetNodeAttr(parentNode, name, value);
  end;
end; { SetNodeAttrs }

{$IFNDEF USE_MSXML}
function InternalFilterNodes(parentNode: IXMLNode; matchesName,
  matchesText: string;
  matchOnGrandchildrenName, matchOnGrandchildrenText: boolean;
  matchesChildNames, matchesChildText: array of string): IXMLNodeList;
var
  childNode  : IXMLNode;
  grandNode  : IXMLNode;
  iGrandChild: integer;
  iNode      : integer;
  matches    : boolean;
begin
  Result := TXMLNodeList.Create;
  iNode := 0;
  while iNode < parentNode.ChildNodes.Length do begin
    childNode := parentNode.ChildNodes.Item[iNode];
    if childNode.NodeType = ELEMENT_NODE then begin
      matches := true;
      if matches and (matchesName <> '') then
        matches := (childNode.NodeName = matchesName);
      if matches and (matchesText <> '') then
        matches := (Trim(childNode.Text) = matchesText);
      if matches and matchOnGrandchildrenName then begin
        for iGrandChild := Low(matchesChildNames) to High(matchesChildNames) do
        begin
          grandNode := childNode.SelectSingleNode(matchesChildNames[iGrandChild]);
          if not assigned(grandNode) then begin
            matches := false;
            break; //for
          end
          else begin
            if matchOnGrandchildrenText and
               (iGrandChild >= Low(matchesChildText)) and
               (iGrandChild <= High(matchesChildText)) then
              matches := (Trim(grandNode.Text) = matchesChildText[iGrandChild]);
          end;
        end; //for
      end;
      if matches then
        Result.AddNode(parentNode.ChildNodes.Item[iNode]);
    end;
    Inc(iNode);
  end;
end; { InternalFilterNodes }

{:@param   parentNode        Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesChildNames If not empty, grandchildren nodes with specified
                             names must exist. Only if they exist, child node
                             can be included in the result list.
  @param   matchesChildText  If not empty, grandchildren nodes text is checked.
                             For each grandchildren node named
                             matchesChildNames[], its text must equal
                             matchesChildText[]. Only if this condition is
                             satisfied, child node can be included in the result
                             list.
  @returns List of child nodes that satisfy conditions described above.
  @since   2001-09-25
}
function FilterNodes(parentNode: IXMLNode; matchesName, matchesText: string;
  matchesChildNames, matchesChildText: array of string): IXMLNodeList;
begin
  Result := InternalFilterNodes(parentNode, matchesName, matchesText,
    true, true, matchesChildNames, matchesChildText);
end; { FilterNodes }

{:@param   parentNode        Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesChildNames If not empty, grandchildren nodes with specified
                             names must exist. Only if they exist, child node
                             can be included in the result list.
  @returns List of child nodes that satisfy conditions described above.
  @since   2001-09-26
}
function FilterNodes(parentNode: IXMLNode; matchesName, matchesText: string;
  matchesChildNames: array of string): IXMLNodeList;
begin
  Result := InternalFilterNodes(parentNode, matchesName, matchesText,
    true, false, matchesChildNames, ['']);
end; { FilterNodes }

{:@param   parentNode        Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @returns List of child nodes that satisfy conditions described above.
  @since   2001-09-25
}
function FilterNodes(parentNode: IXMLNode; matchesName,
  matchesText: string): IXMLNodeList;
begin
  Result := InternalFilterNodes(parentNode, matchesName, matchesText,
    false, false, [''], ['']);
end; { FilterNodes }
{$ENDIF USE_MSXML}

function InternalFindNode(parentNode: IXMLNode; matchesName,
  matchesText: string;
  matchOnGrandchildrenName, matchOnGrandchildrenText: boolean;
  matchesChildNames, matchesChildText: array of string): IXMLNode;
var
  childNode  : IXMLNode;
  grandNode  : IXMLNode;
  iGrandChild: integer;
  iNode      : integer;
  matches    : boolean;
begin
  Result := nil;
  iNode := 0;
  while iNode < parentNode.ChildNodes.Length do begin
    childNode := parentNode.ChildNodes.Item[iNode];
    if childNode.NodeType = ELEMENT_NODE then begin
      matches := true;
      if matches and (matchesName <> '') then
        matches := (SameText(childNode.NodeName, matchesName));
      if matches and (matchesText <> '') then
        matches := (Trim(childNode.Text) = matchesText);
      if matches and matchOnGrandchildrenName then begin
        for iGrandChild := Low(matchesChildNames) to High(matchesChildNames) do
        begin
          grandNode := childNode.SelectSingleNode(matchesChildNames[iGrandChild]);
          if not assigned(grandNode) then begin
            matches := false;
            break; //for
          end
          else begin
            if matchOnGrandchildrenText and
               (iGrandChild >= Low(matchesChildText)) and
               (iGrandChild <= High(matchesChildText)) then
              matches := (Trim(grandNode.Text) = matchesChildText[iGrandChild]);
          end;
        end; //for
      end;
      if matches then begin
        Result := parentNode.ChildNodes.Item[iNode];
        Exit;
      end;
    end;
    Inc(iNode);
  end;
end; { InternalFilterNodes }

{:@param   parentNode        Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesChildNames If not empty, grandchildren nodes with specified
                             names must exist. Only if they exist, child node
                             can be included in the result list.
  @param   matchesChildText  If not empty, grandchildren nodes text is checked.
                             For each grandchildren node named
                             matchesChildNames[], its text must equal
                             matchesChildText[]. Only if this condition is
                             satisfied, child node can be included in the result
                             list.
  @returns First child node that satisfies conditions described above.
  @since   2001-09-25
}
function FindNode(parentNode: IXMLNode; const matchesName, matchesText: string;
  matchesChildNames, matchesChildText: array of string): IXMLNode;
begin
  Result := InternalFindNode(parentNode, matchesName, matchesText,
    true, true, matchesChildNames, matchesChildText);
end; { FindNode }

{:@param   parentNode        Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesChildNames If not empty, grandchildren nodes with specified
                             names must exist. Only if they exist, child node
                             can be included in the result list.
  @returns First child node that satisfies conditions described above.
  @since   2001-09-26
}
function FindNode(parentNode: IXMLNode; const matchesName, matchesText: string;
  matchesChildNames: array of string): IXMLNode;
begin
  Result := InternalFindNode(parentNode, matchesName, matchesText,
    true, false, matchesChildNames, ['']);
end; { FindNode }

{:@param   parentNode        Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @param   matchesText       If not empty, child node text is checked. Only if
                             equal to this parameter, child node can be
                             included in the result list.
  @returns First child node that satisfies conditions described above.
  @since   2001-09-25
}
function FindNode(parentNode: IXMLNode; const matchesName, matchesText: string): IXMLNode;
begin
  Result := InternalFindNode(parentNode, matchesName, matchesText,
    false, false, [''], ['']);
end; { FindNode }

{:@param   parentNode        Parent node for the filter operation.
  @param   matchesName       If not empty, child node name is checked to be equal to this
                             parameter.
  @param   attributeName     Child node must contain this attribute.
  @param   attributeValue    If not empty, 'attributeName' attribute is checked to be
                             equal to this parameter.
  @returns First child node that satisfies conditions described above.
  @since   2005-06-03
}
function FindNodeByAttr(parentNode: IXMLNode; const matchesName, attributeName,
  attributeValue: string): IXMLNode;
var
  attrValue  : XmlString;
  childNode  : IXMLNode;
  iNode      : integer;
  matches    : boolean;
begin
  Result := nil;
  iNode := 0;
  while iNode < parentNode.ChildNodes.Length do begin
    childNode := parentNode.ChildNodes.Item[iNode];
    if childNode.NodeType = ELEMENT_NODE then begin
      matches := true;
      if matches and (matchesName <> '') then
        matches := (SameText(childNode.NodeName, matchesName));
      if matches then
        matches := GetNodeAttr(childNode, attributeName, attrValue);
      if matches and (attributeValue <> '') then
        matches := SameText(attrValue, attributeValue);
      if matches then begin
        Result := parentNode.ChildNodes.Item[iNode];
        break; //while
      end;
    end;
    Inc(iNode);
  end;
end; { FindNodeByAttr }

{:@since   2004-01-05
}        
function FindProcessingInstruction(
  xmlDocument: IXMLDocument): IXMLProcessingInstruction;
begin
  if (xmlDocument.ChildNodes.Length <= 0) or
     (not Supports(xmlDocument.ChildNodes.Item[0], IXMLProcessingInstruction, Result))
  then
    Result := nil;
end; { FindProcessingInstruction }

{:@param   parentNode Parent node.
  @param   nodeTag    Tag of the child node.
  @since   2003-09-21
}
function SelectNode(parentNode: IXMLNode; const nodeTag: string): IXMLNode;
begin
  SelectNode(parentNode, nodeTag, Result);
end; { SelectNode }

function SelectNode(parentNode: IXMLNode; const nodeTag: string; var childNode: IXMLNode): boolean;
begin
  if IsDocument(parentNode) and (assigned(DocumentElement(parentNode))) then begin
    childNode := DocumentElement(parentNode);
    if (nodeTag <> '') and assigned(childNode) and (childNode.NodeName = nodeTag) then begin
      Result := true;
      Exit;
    end;
  end
  else
    childNode := parentNode;
  if (nodeTag <> '') and assigned(childNode) then
    childNode := childNode.SelectSingleNode(nodeTag);
  Result := assigned(childNode);
end; { SelectNode }

{:@param   parentNode Parent node.
  @param   nodeTag    Tag of the child node.
  @since   2002-10-03
}
function EnsureNode(parentNode: IXMLNode; nodeTag: string): IXMLNode;
begin
  Result := SelectNode(parentNode, nodeTag);
  if not assigned(Result) then
    Result := AppendNode(parentNode, nodeTag);
end; { EnsureNode }

{:@param   parentNode Parent node.
  @param   nodeTag    Tag of the child node.
  @since   2004-03-27
}
function AppendNode(parentNode: IXMLNode; nodeTag: string): IXMLNode;
begin
  Result := OwnerDocument(parentNode).CreateElement(nodeTag);
  SelectNode(parentNode, '').AppendChild(Result);
end; { AppendNode }

{$IFDEF MSWINDOWS}
{:@param   resourceName Name of the RCDATA resource.
  @returns XML document interface or nil if error occured during load.
  @since   2001-09-25
}
function XMLLoadFromResource(xmlDocument: IXMLDocument;
  const resourceName: string): boolean;
var
  rstr: TResourceStream;
begin
  rstr := TResourceStream.Create(HInstance,resourceName,RT_RCDATA);
  try
    Result := XMLLoadFromStream(xmlDocument, rstr);
  finally FreeAndNil(rstr); end;
end; { XMLLoadFromResource }
{$ENDIF}

{:@param   xmlDocument XML document.
  @param   xmlData     XML document, stored in the string.
  @returns True if xmlData was successfully parsed and loaded into the
           xmlDocument.
  @since   2001-09-26
}
function XMLLoadFromString(xmlDocument: IXMLDocument;
  const xmlData: XmlString): boolean;
begin
  Result := xmlDocument.LoadXML(xmlData);
end; { XMLLoadFromString }

{$IFDEF OmniXML_SupportAnsiStrings}
{:@param   xmlDocument XML document.
  @param   xmlData     XML document, stored in the string.
  @returns True if xmlData was successfully parsed and loaded into the
           xmlDocument.
  @since   2004-01-05
}
function XMLLoadFromAnsiString(xmlDocument: IXMLDocument;
  const xmlData: AnsiString): boolean;
var
  sStr: TStringStream;
begin
  sStr := TStringStream.Create(xmlData);
  try
    Result := XMLLoadFromStream(xmlDocument, sStr);
  finally FreeAndNil(sStr); end;
end; { XMLLoadFromString }
{$ENDIF OmniXML_SupportAnsiStrings}

{:@param   xmlDocument  XML document.
  @param   outputFormat XML document formatting.
  @returns Contents of the XML document, stored in the string.
  @since   2001-09-26
}
function XMLSaveToString(xmlDocument: IXMLDocument;
  outputFormat: TOutputFormat = ofNone): XmlString;
{$IFNDEF USE_MSXML}
var
  str: TStringStream;
{$ENDIF USE_MSXML}
begin
{$IFNDEF USE_MSXML}
  if outputFormat = ofNone then
    Result := xmlDocument.XML
  else begin
    if FindProcessingInstruction(xmlDocument) = nil then
      xmlDocument.InsertBefore(xmlDocument.CreateProcessingInstruction('xml',
        'version="1.0" encoding="utf-16"'), xmlDocument.DocumentElement);
    str := TStringStream.Create('');
    try
      XMLSaveToStream(xmlDocument, str, outputFormat);
      SetLength(Result, (str.Size - SizeOf(XmlChar)) div 2);
      str.Seek(SizeOf(XmlChar), soFromBeginning);
      str.Read(PWideChar(Result)^, str.Size - SizeOf(XmlChar));
    finally FreeAndNil(str); end;
  end;
{$ELSE}
  Result := xmlDocument.XML;
{$ENDIF USE_MSXML}
end; { XMLSaveToString }

{$IFDEF OmniXML_SupportAnsiStrings}
{:@param   xmlDocument  XML document.
  @param   outputFormat XML document formatting.
  @returns Contents of the XML document, stored in the string.
  @since   2004-01-05
}
function XMLSaveToAnsiString(xmlDocument: IXMLDocument;
  outputFormat: TOutputFormat = ofNone): AnsiString;
var
  sStr: TStringStream;
begin
  sStr := TStringStream.Create('');
  try
    XMLSaveToStream(xmlDocument, sStr, outputFormat);
    Result := AnsiString(sStr.DataString);
  finally FreeAndNil(sStr); end;
end; { XMLSaveToString }
{$ENDIF OmniXML_SupportAnsiStrings}

{:@param   xmlDocument XML document.
  @param   xmlStream   Stream containing XML document.
  @returns True if xmlData was successfully parsed and loaded into the
           xmlDocument.
  @since   2001-10-24
}
function XMLLoadFromStream(xmlDocument: IXMLDocument;
  const xmlStream: TStream): boolean;
{$IFDEF USE_MSXML}
var
  sstr: TStringStream;
{$ENDIF USE_MSXML}
begin
{$IFNDEF USE_MSXML}
  Result := xmlDocument.LoadFromStream(xmlStream);
{$ELSE}
  sstr := TStringStream.Create('');
  try
    sstr.CopyFrom(xmlStream,0);
    Result := XMLLoadFromString(xmlDocument, sstr.DataString);
  finally FreeAndNil(sstr); end;
{$ENDIF USE_MSXML}
end; { XMLLoadFromStream }

{:@param   xmlDocument XML document.
  @param   xmlStream   Stream that will receive the XML document.
  @param   outputFormat XML document formatting.
  @since   2001-10-24
}
procedure XMLSaveToStream(xmlDocument: IXMLDocument;
  const xmlStream: TStream; outputFormat: TOutputFormat = ofNone);
{$IFDEF USE_MSXML}
var
  sstr: TStringStream;
{$ENDIF USE_MSXML}
begin
{$IFNDEF USE_MSXML}
  xmlDocument.SaveToStream(xmlStream, outputFormat);
{$ELSE}
  sstr := TStringStream.Create(XMLSaveToString(xmlDocument, outputFormat));
  try
    xmlStream.CopyFrom(sstr, 0);
  finally FreeAndNil(sstr); end;
{$ENDIF USE_MSXML}
end; { XMLSaveToStream }

{:@param   xmlDocument XML document.
  @param   xmlFileName Name of the file containing XML document.
  @returns True if contents of file were successfully parsed and loaded into the
           xmlDocument.
  @since   2001-10-24
}
function XMLLoadFromFile(xmlDocument: IXMLDocument; const xmlFileName: string): boolean;
var
  errorMsg: string;
begin
  Result := XMLLoadFromFile(xmlDocument, xmlFileName, errorMsg);
end; { XMLLoadFromFile }

{:@param   xmlDocument XML document.
  @param   xmlFileName Name of the file containing XML document.
  @param   errorMsg Empty if XML was loaded without a problem, error message instead.
  @returns True if contents of file were successfully parsed and loaded into the
           xmlDocument.
  @since   2014-11-19
}
function XMLLoadFromFile(xmlDocument: IXMLDocument; const xmlFileName: string;
  out errorMsg: string): boolean;
begin
  errorMsg := '';
  try
    Result := xmlDocument.Load(xmlFileName);
  except
    on E: EFOpenError do begin
      errorMsg := E.Message;
      Result := false;
    end;
  end;
end; { XMLLoadFromFile }

{:@param   xmlDocument  XML document.
  @param   xmlFileName  Name of the file containing XML document.
  @param   outputFormat XML document formatting.
  @since   2001-10-24
}
procedure XMLSaveToFile(xmlDocument: IXMLDocument;
  const xmlFileName: string; outputFormat: TOutputFormat = ofNone);
begin
{$IFNDEF USE_MSXML}
  xmlDocument.Save(xmlFileName, outputFormat);
{$ELSE}
  xmlDocument.Save(xmlFileName);
{$ENDIF USE_MSXML}
end; { XMLSaveToFile }

{$IFDEF MSWINDOWS}
{:@param   xmlDocument XML document.
  @param   rootKey     Root registry key.
  @param   key         Registry key.
  @param   value       Registry value containing the string representation of
                       the XML document.
  @returns True if contents of file were successfully parsed and loaded into the
           xmlDocument.
  @since   2003-01-06
}        
function XMLLoadFromRegistry(xmlDocument: IXMLDocument; rootKey: HKEY;
  const key, value: string): boolean;
var
  reg: TRegistry;
begin
  Result := false;
  reg := TRegistry.Create;
  try
    reg.RootKey := rootKey;
    if reg.OpenKeyReadonly(key) then try
      if reg.ValueExists(value) then begin
        try
          Result := XMLLoadFromString(xmlDocument, reg.ReadString(value));
        except end;
      end;
    finally reg.CloseKey; end;
  finally FreeAndNil(reg); end;
end; { XMLLoadFromRegistry }

{:@param   xmlDocument XML document.
  @param   rootKey     Root registry key.
  @param   key         Registry key.
  @param   value       Registry value to contain the string representation of
                       the XML document.
  @returns False if document cannot be saved. 
  @param   outputFormat XML document formatting.
  @since   2003-01-06
}        
function XMLSaveToRegistry(xmlDocument: IXMLDocument; rootKey: HKEY;
  const key, value: string; outputFormat: TOutputFormat): boolean;
var
  reg    : TRegistry;
  xmlData: string;
begin
  Result := false;
  xmlData := XMLSaveToString(xmlDocument);
  reg := TRegistry.Create;
  try
    reg.RootKey := rootKey;
    if reg.OpenKey(key,true) then try
      try
        reg.WriteString(value, xmlData);
        Result := true;
      except end;
    finally reg.CloseKey; end;
  finally FreeAndNil(reg); end;
end; { XMLSaveToRegistry }
{$ENDIF}

{:@param   documentTag Tag for the document element.
  @param   nodeTags    Tags for nodes to be set.
  @param   nodeValues  Node values, corresponding 1:1 to the nodeTags.
  @since   2002-11-05
}
function ConstructXMLDocument(const documentTag: string;
  const nodeTags, nodeValues: array of string): IXMLDocument;
var
  iNode   : integer;
  rootNode: IXMLNode;
begin
  if Length(nodeTags) <> Length(nodeValues) then
    raise EOmniXMLUtils.Create('ConstructXMLDocument: tags and values arrays are of different length!');
  Result := CreateXMLDoc;
  rootNode := EnsureNode(Result, documentTag);
  for iNode := Low(nodeTags) to High(nodeTags) do
    SetNodeText(rootNode, nodeTags[iNode], nodeValues[iNode]);
end; { ConstructXMLDocument }

{:@param   documentTag Tag for the document element.
  @since   2002-11-05
}
function ConstructXMLDocument(const documentTag: string): IXMLDocument;
begin
  Result := CreateXMLDoc;
  EnsureNode(Result, documentTag);
end; { ConstructXMLDocument }

{:@param   sourceNode   Source of the copy operation.
  @param   targetNode   Target of the copy operation. Already existing child
                        nodes will be cleared.
  @param   copySubnodes If true (default), subnodes will be copied too.
  @param   filterProc   If assigned, filtering procedure that can prevent a
                        (child) node from being copied to the target node.
  @since   2002-12-26
}
procedure CopyNode(sourceNode, targetNode: IXMLNode; copySubnodes: boolean;
  filterProc: TFilterXMLNodeEvent);
var
  alreadyDeleted: TStringList;
  attrib        : IXMLNode;
  doCopy        : boolean;
  iAttrib       : integer;
  iNode         : integer;
  sourceChild   : IXMLNode;
  targetChild   : IXMLNode;
  targetElement : IXMLElement;
begin
  if targetNode.NodeType = ELEMENT_NODE then begin
    while targetNode.Attributes.Length > 0 do
      targetNode.Attributes.RemoveNamedItem(targetNode.Attributes.Item[0].NodeName);
    if sourceNode.NodeType = ELEMENT_NODE then begin
      targetElement := (targetNode as IXMLElement);
      for iAttrib := 0 to sourceNode.Attributes.Length-1 do begin
        attrib := sourceNode.Attributes.Item[iAttrib];
        targetElement.SetAttribute(attrib.NodeName, (attrib as IXMLAttr).Value);
      end;
    end;
  end;
  alreadyDeleted := TStringList.Create;
  try
    for iNode := 0 to sourceNode.ChildNodes.Length-1 do begin
      sourceChild := sourceNode.ChildNodes.Item[iNode];
      if sourceChild.NodeType = TEXT_NODE then begin
        targetChild := targetNode.AppendChild(
          OwnerDocument(targetNode).CreateTextNode(sourceChild.Text));
      end
      else begin
        doCopy := true;
        if assigned(filterProc) then
          filterProc(sourceChild, doCopy);
        if doCopy then begin
          if alreadyDeleted.IndexOf(sourceChild.NodeName) < 0 then begin
            DeleteAllChildren(targetNode, sourceChild.NodeName);
            alreadyDeleted.Add(sourceChild.NodeName);
          end;
          targetChild := targetNode.AppendChild(
            OwnerDocument(targetNode).CreateElement(sourceChild.NodeName));
          if copySubnodes then
            CopyNode(sourceChild, targetChild, copySubnodes, filterProc);
        end;
      end;
    end;
  finally FreeAndNil(alreadyDeleted); end;
end; { CopyNode }

procedure MoveNode(sourceNode, targetNode: IXMLNode; copySubnodes: boolean;
  filterProc: TFilterXMLNodeEvent);
begin
  CopyNode(sourceNode, targetNode, copySubnodes, filterProc);
  sourceNode.ParentNode.RemoveChild(sourceNode);
end; { MoveNode }

function RenameNode(node: IXMLNode; const newName: string): IXMLNode;
begin
  Result := EnsureNode(node.ParentNode, newName);
  MoveNode(node, Result);
end; { RenameNode }

{:@param   sourceDoc  Source XML document.
  @param   filterProc If assigned, filtering procedure that can prevent a node
                      from being copied to the target document.
  @returns New XML document.
  @since   2003-01-06
}        
function CloneDocument(sourceDoc: IXMLDocument;
  filterProc: TFilterXMLNodeEvent): IXMLDocument;
begin
  Result := CreateXMLDoc;
  if assigned(DocumentElement(sourceDoc)) then begin
    EnsureNode(Result, DocumentElement(sourceDoc).NodeName);
    CopyNode(DocumentElement(sourceDoc), DocumentElement(Result), true,
      filterProc);
  end;
end; { CloneDocument }

{$IFDEF OmniXmlUtils_Enumerators}

function XMLEnumNodes(xmlDocument: IXMLDocument; pattern: string): XMLEnumeratorFactory;
begin
  Result := XMLEnumeratorFactory.Create(xmlDocument.DocumentElement,  pattern);
end; { XMLEnumNodes }

function XMLEnumNodes(xmlNode: IXMLNode; pattern: string): XMLEnumeratorFactory;
begin
  Result := XMLEnumeratorFactory.Create(xmlNode, pattern);
end; { XMLEnumNodes }

function XMLEnumNodes(xmlNodeList: IXMLNodeList) : XMLEnumeratorFactory;
begin
  Result := XMLEnumeratorFactory.Create(xmlNodeList);
end; { XMLEnumNodes }

{ XMLEnumerator }

constructor XMLEnumerator.Create(nodeList: IXMLNodeList);
begin
  xeNodeList := nodeList;
  xeNodeList.Reset;
end; { XMLEnumerator.Create }

function XMLEnumerator.GetCurrent: IXMLNode;
begin
  Result := xeCurrent;
end; { XMLEnumerator.GetCurrent }

function XMLEnumerator.MoveNext: boolean;
begin
  xeCurrent := xeNodeList.NextNode;
  Result := assigned(xeCurrent);
end; { XMLEnumerator.MoveNext }

{ XMLEnumeratorFactory }

constructor XMLEnumeratorFactory.Create(rootNode: IXMLNode; const pattern: string);
begin
  xefRootNode := rootNode;
  xefPattern := pattern;
end; { XMLEnumeratorFactory.Create }

constructor XMLEnumeratorFactory.Create(nodeList: IXMLNodeList);
begin
  xefNodeList := nodeList;
end; { XMLEnumeratorFactory.Create }

function XMLEnumeratorFactory.GetEnumerator: XMLEnumerator;
begin
  if assigned(xefNodeList) then
    Result := XMLEnumerator.Create(xefNodeList)
  else
    Result := XMLEnumerator.Create(xefRootNode.SelectNodes(xefPattern));
end; { XMLEnumeratorFactory.GetEnumerator }

{$ENDIF OmniXmlUtils_Enumerators}

initialization
  Base64Setup;

end.
