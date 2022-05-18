(*:XML helper unit. Contains routines to copy data between XML and TDataSet.
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2003 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : 2001-10-24
   Last modification : 2003-03-31
   Version           : 1.03
</pre>*)(*
   History:
     1.04: 2022-05-18
       - Fixed a bug in XMLNodeToDatasetRow and DatasetRowToXMLNode that
         occurs when .Fields and .FieldDefs collections of TDataSet have 
         different member count and type. A typical case is when calculated
         or lookup fields are created only in FieldDefs collection.
     1.03: 2003-03-31
       - Added methods DatasetToXMLFile, DatasetToXMLString, XMLFileToDataset,
         XMLStringToDataset.
       - Added parameter doNotExport to the Dataset*ToXML* methods containing
         semicolon-delimited list of fields not to be exported.
       - Added parameter doNotImport to the XML*ToDataset* methods containing
         semicolon-delimited list of fields not to be imported.
       - Added optional parameter outputFormat to the DatasetToXMLDocument
         method.
       - DatasetToXML wrapped into ds.DisableControls/ds.EnableControls. This
         also applies to all DatasetToXML* methods. Initial position in the
         dataset is now preserved.
       - Fixed XMLNodeToDatasetRow to ignore case of the field name.
       - Added testing for rootTag non-emptiness.
       - Added <?xml version="1.0"?> to the exported XML document.
       - Modified XMLToDataset method to skip non-ELEMENT_NODE nodes so one can
         add comments to the XML file.
       - Modified XML*ToDataset* methods to raise exception EOmniXMLDatabase
         on errors.
       - Modified XMLNodeToDatasetRow to raise exception EOmniXMLDatabase if
         XML field doesn't exist in the table. This exception can be skipped
         if option odbIgnoreMissingColumns is passed to the XML*ToDataset*
         method.
       - Modified XMLNodeToDatasetRow to raise exception EOmniXMLDatabase if
         database column is not of a supported type. This exception can be
         skipped if option odbIgnoreUnsupportedColumns is passed to the
         XML*ToDataset* method.
       - Modified DatasetRowToXMLNode to raise exception EOmniXMLDatabase if
         database column is not of a supported type. This exception can be
         skipped if option odbIgnoreUnsupportedColumns is passed to the
         Dataset*ToXML* method.
     1.02: 2002-12-09
       - MSXML compatible (define USE_MSXML).
     1.01a: 2002-11-05
       - Modified function CleanupNodeName to use OmniXML.CharIs_Name.
     1.01: 2002-10-22
       - Updated to skip hidden fields (like DB_KEY returned from IBObjects
         queries).
       - Added numbers as valid tag characters (function CleanupNodeName).
     1.0: 2001-10-24
       - Created by extracting database-related functionality from unit GpXML.
*)

unit OmniXMLDatabase;

interface

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  SysUtils, Classes, DB,
  OmniXML
{$IFDEF USE_MSXML}, OmniXML_MSXML {$ENDIF USE_MSXML}
  ;

type
  //:OmniXMLDatabase-specific exception.
  EOmniXMLDatabase = Exception;

  //:Import-export options.
  TOmniXMLDatabaseOption = (odbIgnoreUnsupportedColumns, odbIgnoreMissingColumns);

  //:Set of all import-export options.
  TOmniXMLDatabaseOptions = set of TOmniXMLDatabaseOption; 

  {:Export currently selected dataset row to the XML node. Used internally in
    the DatasetToXML.
  }
  procedure DatasetRowToXMLNode(ds: TDataSet; dsNode: IXMLNode;
    const doNotExport: string = ''; options: TOmniXMLDatabaseOptions = []);

  {:Export dataset to the XML node. Child nodes will be used to store the data.
    Existing child nodes will be removed. To read data back into the dataset use
    the XMLToDataset function.
  }
  procedure DatasetToXML(ds: TDataSet; parentNode: IXMLNode;
    const doNotExport: string = ''; options: TOmniXMLDatabaseOptions = []);

  {:Export dataset to the XML document, then take string representation of the
    XML document and return it as as stream. Stream is emptied before it is
    written to.
  }
  procedure DatasetToXMLDocument(ds: TDataSet; xmlDocument: TStream;
    const rootTag: string; const doNotExport: string = '';
    outputFormat: TOutputFormat = ofNone; options: TOmniXMLDatabaseOptions = []);

  {:Export dataset to the XML document, then take string representation of the
    XML document and save it into a file.
  }
  procedure DatasetToXMLFile(ds: TDataSet; const xmlFileName: string;
    const rootTag: string; const doNotExport: string = '';
    outputFormat: TOutputFormat = ofNone; options: TOmniXMLDatabaseOptions = []);

  {:Export dataset to the XML document, then take string representation of the
    XML document and return it as as string.
  }
  function DatasetToXMLString(ds: TDataSet; const rootTag: string;
    const doNotExport: string = ''; outputFormat: TOutputFormat = ofNone;
    options: TOmniXMLDatabaseOptions = []): string;

  {:Append new dataset row, copy node data into equally-named fields, and post
    the changes.
  }
  procedure XMLNodeToDatasetRow(dsNode: IXMLNode; ds: TDataSet;
    const doNotImport: string = ''; options: TOmniXMLDatabaseOptions = []);

  {:Import data created with DatasetToXML from the XML node to the dataset.
    Existing dataset content won't be touched.
  }
  procedure XMLToDataset(parentNode: IXMLNode; ds: TDataSet;
    const doNotImport: string = ''; options: TOmniXMLDatabaseOptions = []);

  {:Create XML document from the textual representation stored in the stream,
    then copy its contents into the dataset. Dataset will be emptied before the
    import. XML document must be created with the DatasetToXML* call.
    Before reading, stream's position is reset to 0 and all data from the stream
    is read.
  }
  procedure XMLDocumentToDataset(xmlDocument: TStream; ds: TDataSet;
    const doNotImport: string = ''; options: TOmniXMLDatabaseOptions = []);

  {:Create XML document from the textual representation stored in the file,
    then copy its contents into the dataset. Dataset will be emptied before the
    import. XML document must be created with the DatasetToXML* call.
  }
  procedure XMLFileToDataset(const xmlFileName: string; ds: TDataSet;
    const doNotImport: string = ''; options: TOmniXMLDatabaseOptions = []);

  {:Create XML document from the textual representation stored in the string,
    then copy its contents into the dataset. Dataset will be emptied before the
    import. XML document must be created with the DatasetToXMLD* call.
  }
  procedure XMLStringToDataset(const xmlString: string; ds: TDataSet;
    const doNotImport: string = ''; options: TOmniXMLDatabaseOptions = []);

implementation

uses
  OmniXMLUtils;

const
  //:Node name to be used in TDataSet <-> XML conversion.
  CXMLDatasetRows = 'ROW'; // don't change!

  //:Atribute that specifies whether field is empty (NULL).
  CXMLFieldIsEmpty = 'isEmpty'; // don't change!

{:Clean XML node name to only contain valid characters. Unicode is politely
  ignored.
}
function CleanupNodeName(nodeName: string): string;
var
  iNodeName: integer;
begin
  SetLength(Result, Length(nodeName)); // best guess;
  for iNodeName := 1 to Length(nodeName) do begin
    if CharIs_Name(WideChar(nodeName[iNodeName]), false) then
      Result[iNodeName] := nodeName[iNodeName]
    else
      Result[iNodeName] := '_';
  end; //for iNodeName
  if (Length(nodeName) > 0) and (not CharIs_Name(WideChar(Result[1]), true)) then 
    Result[1] := 'z';
end; { CleanupNodeName }

{:@param   ds          Dataset row to be exported.
  @param   dsNode      XML node to take data from the dataset row. Existing
                       content will be removed.
  @param   doNotExport Semicolon-delimited list of fields that should not be
                       exported. No extraneous whitespace should be used.
  @param   options     Export options.
  @since   2001-09-09
}
procedure DatasetRowToXMLNode(ds: TDataSet; dsNode: IXMLNode;
  const doNotExport: string; options: TOmniXMLDatabaseOptions);
var
  field       : TField;
  fieldClass  : TFieldClass;
  fieldElement: IXMLElement;
  iField      : integer;
  memStr      : TMemoryStream;
  nodeName    : string;
  notExport   : string;
begin
  if doNotExport = '' then
    notExport := ''
  else
    notExport := ';' + doNotExport + ';';
  DeleteAllChildren(dsNode);
  for iField := 0 to ds.FieldDefs.Count-1 do begin
    if faHiddenCol in ds.FieldDefs[iField].Attributes then
      continue;
    field := ds.FieldByName(ds.FieldDefs[iField].Name);
    fieldClass := ds.FieldDefs[iField].FieldClass;
    if (notExport = '') or (Pos(';'+field.FieldName+';', notExport) = 0) then begin
      nodeName := CleanupNodeName(field.FieldName);
      fieldElement := dsNode.OwnerDocument.CreateElement(nodeName);
      dsNode.AppendChild(fieldElement);
      if field.IsNull then
        fieldElement.SetAttribute(CXMLFieldIsEmpty, XMLBoolToStr(true))
      else begin
        if fieldClass.InheritsFrom(TStringField) then
          fieldElement.Text := field.AsString
        // check for TAutoIncField must be before TIntegerField
        else if fieldClass.InheritsFrom(TAutoIncField) then
          // skipped
        else if fieldClass.InheritsFrom(TIntegerField) then
          fieldElement.Text := XMLIntToStr(field.AsInteger)
        else if fieldClass.InheritsFrom(TLargeIntField) then
          fieldElement.Text := XMLInt64ToStr((field as TLargeintField).AsLargeInt)
        else if fieldClass.InheritsFrom(TBCDField) or
                fieldClass.InheritsFrom(TCurrencyField) then
          fieldElement.Text := XMLRealToStr(field.AsCurrency)
        else if fieldClass.InheritsFrom(TFloatField) then
          fieldElement.Text := XMLRealToStr(field.AsFloat)
        else if fieldClass.InheritsFrom(TDateField) then
          fieldElement.Text := XMLDateToStr(field.AsDateTime)
        else if fieldClass.InheritsFrom(TTimeField) then
          fieldElement.Text := XMLTimeToStr(field.AsDateTime)
        else if fieldClass.InheritsFrom(TDateTimeField) then
          fieldElement.Text := XMLDateTimeToStr(field.AsDateTime)
        else if fieldClass.InheritsFrom(TBooleanField) then
          fieldElement.Text := XMLBoolToStr(field.AsBoolean)
        else if fieldClass.InheritsFrom(TBlobField) then
        begin
          memStr := TMemoryStream.Create;
          try
            (field as TBLOBField).SaveToStream(memStr);
            memStr.Position := 0;
            SetNodeTextBinary(dsNode, nodeName, memStr);
          finally FreeAndNil(memStr); end;
        end
        else if fieldClass.InheritsFrom(TBytesField) then
        begin
          memStr := TMemoryStream.Create;
          try
            memStr.SetSize(field.DataSize);
            (field as TBytesField).GetData(memStr.Memory);
            SetNodeTextBinary(dsNode, nodeName, memStr);
          finally FreeAndNil(memStr); end;
        end
        else begin
          if not (odbIgnoreUnsupportedColumns in options) then
            raise EOmniXMLDatabase.CreateFmt('Unsupported column type in column %s', [field.FieldName]);
        end;
      end;
    end; //if notExport ...
  end; //for
end; { DatasetRowToXMLNode }

{:@param   ds          Dataset to be exported.
  @param   parentNode  Node containing exported data, stored in CXMLDatasetRows
                       children.
  @param   doNotExport Semicolon-delimited list of fields that should not be
                       exported. No extraneous whitespace should be used.
  @param   options     Export options.
  @since   2001-09-09
}        
procedure DatasetToXML(ds: TDataSet; parentNode: IXMLNode;
  const doNotExport: string; options: TOmniXMLDatabaseOptions);
var
  myNode  : IXMLNode;
  startPos: TBookmark;
begin
  DeleteAllChildren(parentNode, CXMLDatasetRows);
  ds.DisableControls;
  try
    startPos := ds.GetBookmark;
    try
      ds.First;
      while not ds.Eof do begin
        myNode := parentNode.OwnerDocument.CreateElement(CXMLDatasetRows);
        parentNode.AppendChild(myNode);
        DatasetRowToXMLNode(ds, myNode, doNotExport, options);
        ds.Next;
      end; //while
    finally
      try ds.GotoBookmark(startPos); except end;
      ds.FreeBookmark(startPos);
    end;
  finally ds.EnableControls; end;
end; { DatasetToXML }

{:@param   ds           Dataset to be exported.
  @param   xmlDocument  Textual representation of the XML document holding data
                        from the ds, stored in the stream.
  @param   doNotExport  Semicolon-delimited list of fields that should not be
                        exported. No extraneous whitespace should be used.
  @param   outputFormat XML document formatting.
  @param   options      Export options.
  @since   2001-09-09
}
procedure DatasetToXMLDocument(ds: TDataSet; xmlDocument: TStream;
  const rootTag: string; const doNotExport: string;
  outputFormat: TOutputFormat; options: TOmniXMLDatabaseOptions);
var
  xml: IXMLDocument;
begin
  if Trim(rootTag) = '' then
    raise Exception.Create('DatasetToXMLDocument: rootTag must not be empty');
  xml := CreateXMLDoc;
  xml.AppendChild(xml.CreateProcessingInstruction('xml', 'version="1.0"'));
  xml.AppendChild(xml.CreateElement(rootTag));
  DatasetToXML(ds, xml.DocumentElement, doNotExport, options);
  xmlDocument.Position := 0;
  xmlDocument.Size := 0;
  XMLSaveToStream(xml, xmlDocument, outputFormat);
end; { DatasetToXMLDocument }

{:@param   ds           Dataset to be exported.
  @param   xmlFileName  Name of the file to receive XML document.
  @param   doNotExport  Semicolon-delimited list of fields that should not be
                        exported. No extraneous whitespace should be used.
  @param   outputFormat XML document formatting.
  @param   options      Export options.
  @since   2003-03-28
}
procedure DatasetToXMLFile(ds: TDataSet; const xmlFileName: string;
  const rootTag: string; const doNotExport: string;
  outputFormat: TOutputFormat; options: TOmniXMLDatabaseOptions);
var
  fs: TFileStream;
begin
  if Trim(rootTag) = '' then
    raise Exception.Create('DatasetToXMLFile: rootTag must not be empty');
  fs := TFileStream.Create(xmlFileName, fmCreate);
  try
    DatasetToXMLDocument(ds, fs, rootTag, doNotExport, outputFormat, options);
  finally FreeAndNil(fs); end;
end; { DatasetToXMLFile }

{:@param   ds           Dataset to be exported.
  @param   doNotExport  Semicolon-delimited list of fields that should not be
                        exported. No extraneous whitespace should be used.
  @param   outputFormat XML document formatting.
  @param   options      Export options.
  @returns Textual representation of the XML document holding data from the ds.
  @since   2003-03-28
}
function DatasetToXMLString(ds: TDataSet; const rootTag: string;
  const doNotExport: string; outputFormat: TOutputFormat;
  options: TOmniXMLDatabaseOptions): string;
var
  ss: TStringStream;
begin
  if Trim(rootTag) = '' then
    raise Exception.Create('DatasetToXMLString: rootTag must not be empty');
  ss := TStringStream.Create('');
  try
    DatasetToXMLDocument(ds, ss, rootTag, doNotExport, outputFormat, options);
    Result := ss.DataString;
  finally FreeAndNil(ss); end;
end; { DatasetToXMLString }

{:@param   dsNode      Node holding the data to be exported to the dataset.
  @param   ds          Dataset to take data from the dsNode.
  @param   doNotImport Semicolon-delimited list of fields that should not be
                       imported. No extraneous whitespace should be used.
  @param   options     Import options.
  @since   2001-09-09
}        
procedure XMLNodeToDatasetRow(dsNode: IXMLNode; ds: TDataSet;
  const doNotImport: string; options: TOmniXMLDatabaseOptions);
var
  field       : TField;
  fieldClass  : TClass;
  fieldElement: IXMLElement;
  fieldNode   : IXMLNode;
  memStr      : TMemoryStream;
  myNode      : IXMLNode;
  myNodes     : IXMLNodeList;
  nodeData    : WideString;
  nodeName    : string;
  notImport   : string;

  function FindField(nodeName: string): TField;
  var
    iField: integer;
  begin
    for iField := 0 to ds.Fields.Count-1 do begin
      Result := ds.Fields[iField];
      if AnsiSameText(CleanupNodeName(Result.FieldName), nodeName) then
        Exit;
    end; //for
    Result := nil;
  end; { FindField }

begin { XMLNodeToDatasetRow }
  if doNotImport = '' then
    notImport := ''
  else
    notImport := ';' + doNotImport + ';';
  ds.Append;
  myNodes := dsNode.ChildNodes;
  myNodes.Reset;
  repeat
    myNode := myNodes.NextNode;
    if assigned(myNode) and (myNode.NodeType = ELEMENT_NODE) then begin
      nodeName := myNode.NodeName;
      field := FindField(nodeName);
      if (notImport = '') or (Pos(';'+field.FieldName+';', notImport) = 0) then begin
        if not assigned(field) then begin
          if not (odbIgnoreMissingColumns in options) then
            raise EOmniXMLDatabase.CreateFmt('Field %s does not exist in the table', [nodeName]);
        end
        else begin
          fieldNode := dsNode.SelectSingleNode(nodeName);
          field.Clear;
          if assigned(fieldNode) and
             Supports(fieldNode, IXMLElement, fieldElement) and
             (fieldElement.GetAttribute(CXMLFieldIsEmpty) <> XMLBoolToStr(true)) then
          begin
            nodeData := fieldNode.Text;
            fieldClass := ds.Fields[field.Index].ClassType;
            if fieldClass.InheritsFrom(TStringField) then
              field.AsString := nodeData
            // check for TAutoIncField must be before TIntegerField
            else if fieldClass.InheritsFrom(TAutoIncField) then
              // skipped
            else if fieldClass.InheritsFrom(TIntegerField) then
              field.AsInteger := XMLStrToIntDef(nodeData, 0)
            else if fieldClass.InheritsFrom(TLargeIntField) then
              (field as TLargeintField).AsLargeInt := XMLStrToInt64Def(nodeData, 0)
            else if fieldClass.InheritsFrom(TBCDField) or
                    fieldClass.InheritsFrom(TCurrencyField) then
              field.AsCurrency := XMLStrToRealDef(nodeData, 0)
            else if fieldClass.InheritsFrom(TFloatField) then
              field.AsFloat := XMLStrToRealDef(nodeData, 0)
            else if fieldClass.InheritsFrom(TDateField) then
              field.AsDateTime := XMLStrToDateDef(nodeData, 0)
            else if fieldClass.InheritsFrom(TTimeField) then
              field.AsDateTime := XMLStrToTimeDef(nodeData, 0)
            else if fieldClass.InheritsFrom(TDateTimeField) then
              field.AsDateTime := XMLStrToDateTimeDef(nodeData, 0)
            else if fieldClass.InheritsFrom(TBooleanField) then
              field.AsBoolean := XMLStrToBoolDef(nodeData, false)
            else if fieldClass.InheritsFrom(TBlobField) then
            begin
              memStr := TMemoryStream.Create;
              try
                GetNodeTextBinary(dsNode, nodeName, memStr);
                memStr.Position := 0;
                (field as TBLOBField).LoadFromStream(memStr);
              finally FreeAndNil(memStr); end;
            end
            else if fieldClass.InheritsFrom(TBytesField) then
            begin
              memStr := TMemoryStream.Create;
              try
                GetNodeTextBinary(dsNode, nodeName, memStr);
                memStr.Position := 0;
                field.Size := memStr.Size;
                (field as TBytesField).SetData(memStr.Memory);
              finally FreeAndNil(memStr); end;
            end
            else begin
              if not (odbIgnoreUnsupportedColumns in options) then
                raise EOmniXMLDatabase.CreateFmt('Unsupported column type in column %s', [field.FieldName]);
            end;
          end;
        end;
      end; //if notImport ...
    end;
  until not assigned(myNode);
  ds.Post;
end; { XMLNodeToDatasetRow }

{:@param   parentNode  Node that holds CXMLDatasetRows children that will be
                       exported to the dataset.
  @param   ds          Dataset to take data from the parentNode.
  @param   doNotImport Semicolon-delimited list of fields that should not be
                       imported. No extraneous whitespace should be used.
  @param   options     Import options.
  @since   2001-09-09
}
procedure XMLToDataset(parentNode: IXMLNode; ds: TDataSet;
  const doNotImport: string; options: TOmniXMLDatabaseOptions);
var
  myNode : IXMLNode;
  myNodes: IXMLNodeList;
begin
  if assigned(parentNode) then begin
    myNodes := parentNode.SelectNodes(CXMLDatasetRows);
    myNodes.Reset;
    ds.DisableControls;
    try
      repeat
        myNode := myNodes.NextNode;
        if assigned(myNode) and (myNode.NodeType = ELEMENT_NODE) then
          XMLNodeToDatasetRow(myNode, ds, doNotImport, options);
      until not assigned(myNode);
    finally ds.EnableControls; end;
  end;
end; { XMLToDataset }

{:@param   xmlDocument Textual representation of the XML document, stored in the
                       stream.
  @param   ds          Dataset to take data from the XML document.
  @param   doNotImport Semicolon-delimited list of fields that should not be
                       imported. No extraneous whitespace should be used.
  @param   options     Import options.
  @since   2001-09-09
}
procedure XMLDocumentToDataset(xmlDocument: TStream; ds: TDataSet;
  const doNotImport: string; options: TOmniXMLDatabaseOptions);
var
  xml: IXMLDocument;
begin
  xml := CreateXMLDoc;
  xmlDocument.Position := 0;
  if XMLLoadFromStream(xml, xmlDocument) then begin
    if assigned(xml.DocumentElement) then
      XMLToDataset(xml.DocumentElement, ds, doNotImport, options);
  end
  else 
    raise EOmniXMLDatabase.CreateFmt(
      'Failed to parse XML document. Error occured at character %d line %d. Reason: %s',
      [xml.ParseError.LinePos, xml.ParseError.LinePos, xml.ParseError.Reason]);
end; { XMLDocumentToDataset }

{:@param   xmlFileName Name of the file containing XML document.
  @param   ds          Dataset to take data from the XML document.
  @param   doNotImport Semicolon-delimited list of fields that should not be
                       imported. No extraneous whitespace should be used.
  @param   options     Import options.
  @since   2003-03-28
}        
procedure XMLFileToDataset(const xmlFileName: string; ds: TDataSet;
  const doNotImport: string; options: TOmniXMLDatabaseOptions);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(xmlFileName, fmOpenRead);
  try
    XMLDocumentToDataset(fs, ds, doNotImport, options);
  finally FreeAndNil(fs); end;
end; { XMLFileToDataset }

{:@param   xmlString   String containing XML document.
  @param   ds          Dataset to take data from the XML document.
  @param   doNotImport Semicolon-delimited list of fields that should not be
                       imported. No extraneous whitespace should be used.
  @param   options     Import options.
  @since   2003-03-28
}
procedure XMLStringToDataset(const xmlString: string; ds: TDataSet;
  const doNotImport: string; options: TOmniXMLDatabaseOptions);
var
  ss: TStringStream;
begin
  ss := TStringStream.Create(xmlString);
  try
    XMLDocumentToDataset(ss, ds, doNotImport, options);
  finally FreeAndNil(ss); end;
end; { XMLStringToDataset }

end.
