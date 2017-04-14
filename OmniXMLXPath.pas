(*:Simplified XPath parser.
   Based on XPath tutorial from http://www.w3schools.com/xpath/default.asp.
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2015 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : 2005-10-28
   Last modification : 2015-07-27
   Version           : 1.04
</pre>*)(*
   History:
     1.04: Improved filter processor to support consecutive filters, such as:
           /SubtitlerStatusInfo/Status/Decoders/Item[Index="1"][Initialized="yes"][InputPresent="yes"]
     1.03: 2011-08-30
       - Added support for the '..' element.
     1.02: 2010-07-06
       - Added support for predicates [node] and [node='value'].
     1.01a: 2008-01-10
       - Parser was calling 8-bit versions of Pos and PosEx. Fixed PosEx to accept
         16-bit parameters and added 16-bit version of Pos.
     1.01: 2006-02-02
       - Added support for parameters in double quotes.
         Example: /bookstore/book/title[@lang="eng"].
       - Added support for the '.' element.
         Example: ./title.
     1.0b: 2006-01-12
       - Fixed bug in nested query processing.
     1.0a: 2005-11-03
       - Passing IXMLDocument to the XPathSelect with absolute expression (starting in
         '/') resulted in wrong output.
     1.0: 2005-10-30
       - Released.
*)

unit OmniXMLXPath;

interface

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

uses
  {$IFDEF OmniXML_Namespaces}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}
  OmniXML_Types, OmniXML;

type
  {:Exceptions raised on invalid XPath expressions.
    @since   2005-10-28
  }
  EXMLXPath = class(Exception);

  {:Simplified XPath expression evaluator.

     Currently supported syntax elements are:
       nodename	   selects all child nodes of the node
       /           selects from the root node
       //          selects in complete subtree
       @	         selects attributes
       .           selects the current node
       ..          selects the parrent of the current node

     Currently supported predicates are:
       [n] 	       selects the n-th subelement of the current element ('n' is a number,
                   first subelement has index 1)
       [@attr]     selects all subelements that have an attribute named 'attr'
       [@attr='x'] selects all subelements that have an attribute named 'attr'
       or          with a value of 'x'
       [@attr="x"]
       [node]      selects all subelements named 'node'
       [node='x']  selects all subelements named node containing test 'x'
       or
       [node="x"]

     Currently supported wildcards are:
       *           matches any element node

     Examples:
       /bookstore/book[1]                      select the first book in bookstore
       /bookstore/book/title[@lang=''eng'']    select all english books
       //title[@lang=''eng'']                  select all english books
       //title                                 select all titles
       /bookstore/book/title                   select all titles
       /bookstore//title[@lang]                select all titles with lang attribute
       /bookstore/book[3]/*                    select all nodes of the third book
       /bookstore//book[title="Harry Potter"]  select all Harry Potter books
       @lang                                   select lang attribute of the current node
       /bookstore/book[1]/title/@lang          select language of the first book
       /bookstore/book/title/@lang             select all languages
       //title/@lang                           select all languages
       //book//@lang                           select all languages
       //@lang                                 select all languages
       title                                   select the title subnode of some node
       ./title                                 select the title subnode of some node

    @param    rootNode   Starting node.
    @param    expression XPath expression.
    @since    2005-10-28
  }
  function XPathSelect(rootNode: IXMLNode; const expression: XmlString): IXMLNodeList;

implementation

type
  {:XPath element processing flags.
    @enum    pefScanTree  Scan complete tree under the parent node (triggered by the //
                          prefix).
    @since   2005-10-28
  }
  TXMLXPathElementFlag = (pefScanTree);
  TXMLXPathElementFlags = set of TXMLXPathElementFlag;

  {:XPath evaluator class.
    @since   2005-10-28
  }
  TXMLXPathEvaluator = class
  private
    FExpression   : XmlString;
    FPosExpression: integer;
  protected
    procedure CollectChildNodes(node: IXMLNode; const element: XmlString;
      element_type: integer; recurse: boolean; endList: IXMLNodeList);
    procedure CopyList(startList, endList: IXMLNodeList);
    procedure EvaluateNode(node: IXMLNode; const element, predicate: XmlString;
      flags: TXMLXPathElementFlags; endList: IXMLNodeList);
    procedure EvaluatePart(startList: IXMLNodeList; const element, predicate: XmlString;
      flags: TXMLXPathElementFlags; endList: IXMLNodeList);
    procedure FilterByAttrib(startList: IXMLNodeList; const attribName, attribValue:
      XmlString; const NotEQ: boolean; endList: IXMLNodeList);
    procedure FilterByChild(startList: IXMLNodeList; const childName,
      childValue: XmlString; endList: IXMLNodeList);
    procedure FilterNodes(startList: IXMLNodeList; const predicate: XmlString;
      endList: IXMLNodeList);
    function  GetNextExpressionPart(var element, predicate: XmlString;
      var flags: TXMLXPathElementFlags): boolean;
    procedure InitializeExpressionParser(const expression: XmlString);
    function  Pos(ch: WideChar; const s: XmlString): integer;
    function  PosEx(ch: WideChar; const s: XmlString; offset: integer = 1): integer;
    procedure SplitExpression(const predicate: XmlString; var left, op,
      right: XmlString);
  public
    function Evaluate(rootNode: IXMLNode; const expression: XmlString): IXMLNodeList;
  end; { TXMLXPathEvaluator }

{ publics }

  {:Evaluates XML document from the given node according to the specified XPath expression
    and returns list of matching nodes.
    @since   2005-10-28
  }
  function XPathSelect(rootNode: IXMLNode; const expression: XmlString): IXMLNodeList;
  var
    xPath: TXMLXPathEvaluator;
  begin
    xPath := TXMLXPathEvaluator.Create;
    try
      Result := xPath.Evaluate(rootNode, expression);
    finally	FreeAndNil(xpath); end;
  end; { XPathSelect }

{ TXMLXPathEvaluator }

{:Selects child nodes or attributes matching specified name, optionally recursing into
  each subnode.
  @since   2005-10-28
}
procedure TXMLXPathEvaluator.CollectChildNodes(node: IXMLNode; const element: XmlString;
  element_type: integer; recurse: boolean; endList: IXMLNodeList);
var
  childNode: IXMLNode;
  iNode    : integer;
  matchAll : boolean;
  nodeList : IXMLCustomList;
begin
  matchAll := (element = '*');
  if element_type = ATTRIBUTE_NODE then
    nodeList := node.Attributes
  else
    nodeList := node.ChildNodes;
  for iNode := 0 to nodeList.Length-1 do begin
    childNode := nodeList.Item[iNode];
    if (childNode.NodeType = element_type) and
       (matchAll or (childNode.NodeName = element))
    then
      endList.Add(childNode);
    if recurse and (childNode.NodeType = ELEMENT_NODE) then
      CollectChildNodes(childNode, element, element_type, true, endList);
  end;
  //if recursion is on and we were iterating over attributes, we must also check child nodes
  if recurse and (element_type = ATTRIBUTE_NODE) then begin
    for iNode := 0 to node.ChildNodes.Length-1 do begin
      childNode := node.ChildNodes.Item[iNode];
      if childNode.NodeType = ELEMENT_NODE then
        CollectChildNodes(childNode, element, element_type, true, endList);
    end; //for iNode;
  end;
end; { TXMLXPathEvaluator.CollectChildNodes }

{:Copies one node list to another.
  @since   2005-10-28
}
procedure TXMLXPathEvaluator.CopyList(startList, endList: IXMLNodeList);
var
  iNode: integer;
begin
  for iNode := 0 to startList.Length-1 do
    endList.Add(startList.Item[iNode]);
end; { TXMLXPathEvaluator.CopyList }

{:Evaluates XML document from the given node according to the specified XPath expression
  and returns list of matching nodes.
  @since   2005-10-28
}
function TXMLXPathEvaluator.Evaluate(rootNode: IXMLNode; const expression: XmlString):
  IXMLNodeList;
var
  element  : XmlString;
  flags    : TXMLXPathElementFlags;
  predicate: XmlString;
  startList: IXMLNodeList;
  endList  : IXMLNodeList;
begin
  endList := TXMLNodeList.Create;
  if expression <> '' then begin
    if expression[1] <> '/' then
      endList.AddNode(rootNode)
    else if rootNode.OwnerDocument = nil then // already at root
      endList.AddNode(rootNode)
    else
      endList.AddNode(rootNode.OwnerDocument);
    InitializeExpressionParser(expression);
    while GetNextExpressionPart(element, predicate, flags) do begin
      startList := endList;
      endList := TXMLNodeList.Create;
      EvaluatePart(startList, element, predicate, flags, endList);
    end;
  end;
  Result := endList;
end; { TXMLXPathEvaluator.Evaluate }

{:Evaluates one node and stores all matched subnodes in endList.
  @since   2005-10-28
}
procedure TXMLXPathEvaluator.EvaluateNode(node: IXMLNode; const element,
  predicate: XmlString; flags: TXMLXPathElementFlags; endList: IXMLNodeList);
var
  tempList: IXMLNodeList;
begin
  tempList := TXMLNodeList.Create;
  if element = '.' then
    endList.Add(node)
  else if element = '..' then begin
    if assigned(node.ParentNode) then
      endList.Add(node.ParentNode);
  end
  else begin
    if (element <> '') and (element[1] = '@') then
      CollectChildNodes(node, Copy(element, 2, Length(element)-1), ATTRIBUTE_NODE,
        pefScanTree in flags, tempList)
    else if element <> '' then
      CollectChildNodes(node, element, ELEMENT_NODE, pefScanTree in flags, tempList)
    else
      tempList.Add(node);
    FilterNodes(tempList, predicate, endList);
  end;
end; { TXMLXPathEvaluator.EvaluateNode }

{:Evaluates all nodes in start list according to element, predicate, and flags, and
  returns all matched subnodes in endList.
  @since   2005-10-28
}
procedure TXMLXPathEvaluator.EvaluatePart(startList: IXMLNodeList; const element,
  predicate: XmlString; flags: TXMLXPathElementFlags; endList: IXMLNodeList);
var
  iNode: integer;
begin
  endList.Clear;
  for iNode := 0 to startList.Length-1 do
    EvaluateNode(startList.Item[iNode], element, predicate, flags, endList);
end; { TXMLXPathEvaluator.EvaluatePart }

{:Copies one list to another and filters on attribute name/content.
  @since   2005-10-28
}
procedure TXMLXPathEvaluator.FilterByAttrib(startList: IXMLNodeList; const attribName,
  attribValue: XmlString;  const NotEQ: boolean; endList: IXMLNodeList);
var
  attrNode     : IXMLNode;
  iNode        : integer;
  matchAnyValue: boolean;
begin
  matchAnyValue := (attribValue = '*');
  for iNode := 0 to startList.Length-1 do begin
    attrNode := startList.Item[iNode].Attributes.GetNamedItem(attribName);
    if assigned(attrNode) and (matchAnyValue or ((attrNode.NodeValue = attribValue) xor NotEQ )) then
      endList.Add(startList.Item[iNode]);
  end;
end; { TXMLXPathEvaluator.FilterByAttrib }

{:Copies one list to another and filters on child name/content.
  @since   2010-07-06
}
procedure TXMLXPathEvaluator.FilterByChild(startList: IXMLNodeList; const childName,
  childValue: XmlString; endList: IXMLNodeList);

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

var
  childNode    : IXMLNode;
  iNode        : integer;
  matchAnyValue: boolean;
begin
  matchAnyValue := (childValue = '*');
  for iNode := 0 to startList.Length-1 do begin
    childNode := startList.Item[iNode].SelectSingleNode(childName);
    if assigned(childNode) then begin
      if matchAnyValue then
        endList.Add(startList.Item[iNode])
      else begin
        childNode := GetTextChild(childNode);
        if assigned(childNode) and (childNode.NodeValue = childValue) then
          endList.Add(startList.Item[iNode]);
      end;
    end;
  end;
end; { TXMLXPathEvaluator.FilterByChild }

procedure TXMLXPathEvaluator.FilterNodes(startList: IXMLNodeList; const
  predicate: XmlString; endList: IXMLNodeList);
var
  code      : integer;
  idxElement: integer;
  left      : XmlString;
  op        : XmlString;
  right     : XmlString;
begin
  if predicate = '' then
    CopyList(startList, endList)
  else begin
    Val(predicate, idxElement, code);
    if code = 0 then begin // [n] 
      if idxElement <= 0 then
        raise EXMLXPath.CreateFmt('Invalid predicate [%s]', [predicate]);
      if idxElement <= startList.Length then
        endList.Add(startList.Item[idxElement-1]);
    end
    else if predicate[1] <> '@' then begin
      SplitExpression(predicate, left, op, right);
      if op = '' then // [node]
        FilterByChild(startList, left, '*', endList)
      else if op = '=' then // [node='test']
        FilterByChild(startList, left, right, endList)
      else
        raise EXMLXPath.CreateFmt('Unsupported operator [%s]', [predicate]);
    end
    else begin
      SplitExpression(Copy(predicate, 2, Length(predicate)-1), left, op, right);
      if op = '' then // [@attrib]
        FilterByAttrib(startList, left, '*', false, endList)
      else if (op = '=') or (op = '!=') then // [@attrib='x']
        FilterByAttrib(startList, left, right, op = '!=', endList)
      else
        raise EXMLXPath.CreateFmt('Unsupported operator [%s]', [predicate]);
    end;
  end;
end; { TXMLXPathEvaluator.FilterNodes }

{:Extract next element, predicate and flags from the expression.
  @returns False if there are no more elements in the expression.
  @since   2005-10-28
}
function TXMLXPathEvaluator.GetNextExpressionPart(var element, predicate: XmlString;
  var flags: TXMLXPathElementFlags): boolean;
var
  endElement   : integer;
  pEndPredicate: integer;
  pPredicate   : integer;
begin
  if FPosExpression > Length(FExpression) then
    Result := false
  else begin
    flags := [];
    if FExpression[FPosExpression] = '/' then begin
      Inc(FPosExpression); // initial '/' was already taken into account in Evaluate
      if FExpression[FPosExpression] = '/' then begin
        Inc(FPosExpression);
        Include(flags, pefScanTree);
      end;
    end;
    endElement := PosEx('/', FExpression, FPosExpression);
    if endElement = 0 then
      endElement := Length(FExpression) + 1;
    element := Copy(FExpression, FPosExpression, endElement - FPosExpression);
    FPosExpression := endElement;
    if element = '' then
      raise EXMLXPath.CreateFmt('Empty element at position %d', [FPosExpression]);
    pPredicate := Pos('[', element);
    if pPredicate = 0 then begin
      if Pos(']', element) > 0 then
        raise EXMLXPath.CreateFmt('Invalid syntax at position %d', [Pos(']', element)]);
      predicate := '';
    end
    else begin
      if Copy(element, Length(element), 1) <> ']' then
        raise EXMLXPath.CreateFmt('Invalid syntax at position %d',
                [FPosExpression + Length(element) - 1]);
      pEndPredicate := Pos(']', element);
      if pEndPredicate < Length(element) then begin
        //extract only the first filter
        Dec(FPosExpression, Length(element) - pEndPredicate);
        element := Copy(element, 1, pEndPredicate);
      end;
      predicate := Copy(element, pPredicate+1, Length(element)-pPredicate-1);
      Delete(element, pPredicate, Length(element)-pPredicate+1);
    end;                                                                    
    Result := true;
  end;
end; { TXMLXPathEvaluator.GetNextExpressionPart }

{:Initializes expression parser.
  @since   2005-10-28
}
procedure TXMLXPathEvaluator.InitializeExpressionParser(const expression: XmlString);
begin
  FExpression := expression;
  FPosExpression := 1;
end; { TXMLXPathEvaluator.InitializeExpressionParser }

function TXMLXPathEvaluator.Pos(ch: WideChar; const s: XmlString): integer;
begin
  Result := PosEx(ch, s);
end; { TXMLXPathEvaluator.Pos }

function TXMLXPathEvaluator.PosEx(ch: WideChar; const s: XmlString; offset: integer = 1): integer;
begin
  for Result := offset to Length(s) do begin
    if s[Result] = ch then
      Exit;
  end;
  Result := 0;
end; { TXMLXPathEvaluator.PosEx }

{:Splits expression into left side, operator, and right side.
  Currently, only '=' operator is recognized.
  @since   2005-10-28
}
procedure TXMLXPathEvaluator.SplitExpression(const predicate: XmlString; var left, op,
  right: XmlString);
var
  pOp, pOpLen: integer;
begin
  pOp := Pos('=', predicate);
  if pOp = 0 then begin
    left := predicate;
    op := '';
    right := '';
  end
  else begin
    pOpLen := 1;
    if pOp > 1 then  // != operator ???
       if predicate[pOp-1] = '!' then begin
          Inc(pOpLen);
          Dec(pOp);
       end;

    left := Trim(Copy(predicate, 1, pOp-1));
    // op := predicate[pOp];
    op := Copy(predicate, pOp, pOpLen);
    right := Trim(Copy(predicate, pOp+pOpLen, Length(predicate)));
    if (right[1] = '''') and (right[Length(right)] = '''') then
      right := Copy(right, 2, Length(right)-2)
    else if (right[1] = '"') and (right[Length(right)] = '"') then
      right := Copy(right, 2, Length(right)-2);
  end;
end; { TXMLXPathEvaluator.SplitExpression }

end.
