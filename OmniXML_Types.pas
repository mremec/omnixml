(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use this file except in compliance with the
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
* the specific language governing rights and limitations under the License.
*
* The Original Code is OmniXML_Types.pas
*
* The Initial Developer of the Original Code is Miha Remec
*   http://omnixml.com/
*******************************************************************************)
unit OmniXML_Types;

interface

uses OWideSupp;

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

type
  XmlString = OWideString;
  PXmlString = ^OWideString;
  XmlChar = OWideChar;
  PXmlChar = POWideChar;
  {$IFDEF FPC}
  RawByteString = AnsiString;
  {$ENDIF}

implementation

end.
