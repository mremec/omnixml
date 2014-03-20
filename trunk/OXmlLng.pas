unit OXmlLng;

{

  Author:
    Ondrej Pokorny, http://www.kluug.net
    All Rights Reserved.

  License:
    MPL 1.1 / GPLv2 / LGPLv2 / FPC modified LGPLv2
    Please see the /license.txt file for more information.

}

{
  OXmlLng.pas

  Language definitions for OXml library.

}

{$I OXml.inc}

{$IFDEF O_DELPHI_XE4_UP}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

{$BOOLEVAL OFF}

interface

var
  OXmlLng_InvalidCData: String = '"%s" is not a valid CData text.';
  OXmlLng_InvalidText: String = '"%s" is not a valid text.';
  OXmlLng_InvalidComment: String = '"%s" is not a valid comment text.';
  OXmlLng_InvalidPITarget: String = '"%s" is not a valid processing instruction target.';
  OXmlLng_InvalidPIContent: String = '"%s" is not a valid processing instruction content.';
  OXmlLng_InvalidAttributeName: String = '"%s" is not a valid attribute name.';
  OXmlLng_InvalidElementName: String = '"%s" is not a valid element name.';
  OXmlLng_InvalidCharacterInText: String = 'The character "%s" cannot occur in text.';
  OXmlLng_InvalidCharacterInAttribute: String = 'The character "%s" cannot occur in attribute.';
  OXmlLng_InvalidStringInText: String = 'The string "%s" cannot occur in text.';
  OXmlLng_InvalidCharacterInElement: String = 'The character "%s" cannot occur in element header.';
  OXmlLng_InvalidAttributeStartChar: String = 'An attribute cannot start with the character "%s".';
  OXmlLng_EqualSignMustFollowAttribute: String = 'Equal sign must follow the attribute "%s".';
  OXmlLng_AttributeValueMustBeEnclosed: String = '"%s" attribute value must be enclosed in quotes.';
  OXmlLng_TooManyElementsClosed: String = 'Too many elements closed.';
  OXmlLng_UnclosedElementsInTheEnd: String = 'There are unclosed elements in the document end.';
  OXmlLng_WrongElementClosed: String = 'Trying to close wrong element. Close="%s", open element="%s".';
  OXmlLng_InvalidEntity: String = '"%s" is not a valid entity.';
  OXmlLng_ReadingAt: String =
    'Reading at:'+sLineBreak+
    'Line: %d'+sLineBreak+
    'Char: %d'+sLineBreak+
    'XML token line: %d'+sLineBreak+
    'XML token char: %d'+sLineBreak+
    'Position in source stub: %d'+sLineBreak+
    'Source stub:'+sLineBreak+
    '%s';

  OXmlLng_XPathPredicateNotSupported: String = 'XPath predicate "%s" is not supported.'+sLineBreak+'XPath: %s';
  OXmlLng_XPathPredicateNotValid: String = 'XPath predicate "%s" is not valid.'+sLineBreak+'XPath: %s';
  OXmlLng_XPathNotSupported: String = 'XPath is not supported.'+sLineBreak+'XPath: %s';

  OXmlLng_AppendFromDifferentDocument: String = 'You can''t append a node from a different XML document.';
  OXmlLng_InsertFromDifferentDocument: String = 'You can''t insert a node from a different XML document.';
  OXmlLng_InsertEqualNodes: String = 'Node to insert and reference node can''t be equal.';
  OXmlLng_ParentNodeCantBeNil: String = 'Parent node can''t be nil.';
  OXmlLng_ParentNodeMustBeNil: String = 'Parent node must be nil.';
  OXmlLng_NodeToDeleteNotAChild: String = 'You can''t delete a node that is not a child of current node.';
  OXmlLng_NodeToInsertNotAChild: String = 'You can''t insert node before a node that is not a child of current node.';
  OXmlLng_NodeMustBeDOMDocumentOrElement: String = 'Node must be a DOMDocument or an element.';
  OXmlLng_CannotSetText: String = 'You can''t set the text property of this node. Use NodeValue instead.';
  OXmlLng_ChildNotFound: String = 'Child not found.';
  OXmlLng_ListIndexOutOfRange: String = 'List index out of range.';
  OXmlLng_FeatureNotSupported: String = 'This feature is not supported.';
  OXmlLng_CannotWriteAttributesWhenFinished: String = 'You can''t add an attribute %s="%s" when the element header ("%s") has been finished.';
  OXmlLng_CannotSetIndentLevelAfterWrite: String = 'You can''t set the IndentLevel after something has been already written to the document.';
  OXmlLng_NodeNameCannotBeEmpty: String = 'Node name cannot be empty.';
  OXmlLng_XPathCannotBeEmpty: String = 'XPath cannot be empty.';
  OXmlLng_CannotWriteToVirtualMemoryStream: String = 'You cannot write to a TVirtualMemoryStream.';
  OXmlLng_CannotUndo2Times: String = 'Unsupported: you tried to run the undo function two times in a row.';

implementation

end.
