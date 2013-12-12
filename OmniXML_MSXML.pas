(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with the *
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *
* the specific language governing rights and limitations under the License.    *
*                                                                              *
* The Original Code is OmniXML_MSXML.pas                                       *
*                                                                              *
* The Initial Developer of the Original Code is Miha Remec                     *
*   http://MihaRemec.com/                                                      *
*******************************************************************************)
unit OmniXML_MSXML;

interface

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

{$IFNDEF MSWINDOWS}
  {$MESSAGE FATAL 'MSXML can only be used on Windows platform'}
{$ENDIF}

uses
  ComObj, {$IFDEF DELPHI6_UP} MSXML {$ELSE} MSXML2_TLB {$ENDIF};

type
  IXMLDocument = IXMLDOMDocument;
  IXMLText = IXMLDOMText;
  IXMLElement = IXMLDOMElement;
  IXMLProcessingInstruction = IXMLDOMProcessingInstruction;
  IXMLCDATASection = IXMLDOMCDATASection;
  IXMLComment = IXMLDOMComment;
  IXMLAttr = IXMLDOMAttribute;
  IXMLNodeList = IXMLDOMNodeList;
  IXMLNamedNodeMap = IXMLDOMNamedNodeMap;
  IXMLNode = IXMLDOMNode;
  IXMLParseError = IXMLDOMParseError;

const
  DEFAULT_TRUE = '1';
  DEFAULT_FALSE = '0';

const
  ELEMENT_NODE = NODE_ELEMENT;
  ATTRIBUTE_NODE = NODE_ATTRIBUTE;
  TEXT_NODE = NODE_TEXT;
  CDATA_SECTION_NODE = NODE_CDATA_SECTION;
  ENTITY_REFERENCE_NODE = NODE_ENTITY_REFERENCE;
  ENTITY_NODE = NODE_ENTITY;
  PROCESSING_INSTRUCTION_NODE = NODE_PROCESSING_INSTRUCTION;
  COMMENT_NODE = NODE_COMMENT;
  DOCUMENT_NODE = NODE_DOCUMENT;
  DOCUMENT_TYPE_NODE = NODE_DOCUMENT_TYPE;
  DOCUMENT_FRAGMENT_NODE = NODE_DOCUMENT_FRAGMENT;
  NOTATION_NODE = NODE_NOTATION;

function CreateXMLDoc: IXMLDocument;
  
implementation

function CreateXMLDoc: IXMLDocument;
begin
  Result := CreateComObject(CLASS_DOMDocument) as IXMLDOMDocument;
end;

end.

