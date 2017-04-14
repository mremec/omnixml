{$IFDEF FPC}
  {$DEFINE UNICODE}
{$ENDIF}

{$DEFINE OmniXML_SupportAnsiStrings}

{$IFDEF CONDITIONALEXPRESSIONS}

  {$IF Declared(CompilerVersion) and (CompilerVersion >= 25.0)}
    {$LEGACYIFEND ON}
    {$DEFINE DELPHIXE4_UP}
  {$IFEND}

  {$IF Declared(CompilerVersion) and (CompilerVersion >= 24.0)}  // Delphi XE3 or newer
    {$DEFINE DELPHIXE3_UP}
    {$DEFINE OmniXML_HasZeroBasedStrings}
  {$IFEND}  // Declared(CompilerVersion) and (CompilerVersion >= 24.0)

  {$IF Declared(CompilerVersion) and (CompilerVersion >= 23.0)}
    {$DEFINE DELPHIXE2_UP}
    {$DEFINE OmniXML_Namespaces}
  {$IFEND}  // Declared(CompilerVersion) and (CompilerVersion >= 23.0)

  {$IF Declared(CompilerVersion) and (CompilerVersion >= 20.0)}  // Delphi 2009 or newer
    {$DEFINE DELPHI2009_UP}
    {$DEFINE OmniXML_Generics}
  {$IFEND}  // Declared(CompilerVersion) and (CompilerVersion >= 20.0)

  {$IF Declared(CompilerVersion) and (CompilerVersion >= 14.0)}  // Delphi 6 or newer
    {$DEFINE HAS_UNIT_VARIANTS}
    {$DEFINE DELPHI6_UP}
  {$IFEND}  // Declared(CompilerVersion) and (CompilerVersion >= 14.0)

  {$IFDEF UNICODE}  // Delphi with Unicode support
    {$DEFINE OmniXML_Unicode}
  {$ENDIF}  // UNICODE

  {$IFDEF NEXTGEN}
    {$UNDEF OmniXML_SupportAnsiStrings}
  {$ENDIF NEXTGEN}

{$ENDIF}  // CONDITIONALEXPRESSIONS

{$I OmniXML_JEDI.inc}
