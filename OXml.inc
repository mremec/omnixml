
{$IFNDEF FPC}
  {$IF (CompilerVersion >= 25.0)}
    {$LEGACYIFEND ON}
  {$IFEND}

  {$IF CompilerVersion >= 15}
    {$DEFINE O_DELPHI_7_UP}
  {$IFEND}
  {$IF CompilerVersion >= 17}
    {$DEFINE O_DELPHI_2005_UP}
  {$IFEND}
  {$IF CompilerVersion >= 18}
    {$DEFINE O_DELPHI_2006_UP}
  {$IFEND}
  {$IF CompilerVersion >= 20}
    {$DEFINE O_DELPHI_2009_UP}
  {$IFEND}
  {$IF CompilerVersion = 20}
    {$DEFINE O_DELPHI_2009}
  {$IFEND}
  {$IF CompilerVersion >= 21}
    {$DEFINE O_DELPHI_2010_UP}
  {$IFEND}
  {$IF CompilerVersion >= 22}
    {$DEFINE O_DELPHI_XE_UP}
  {$IFEND}
  {$IF CompilerVersion >= 23}
    {$DEFINE O_DELPHI_XE2_UP}
  {$IFEND}
  {$IF CompilerVersion >= 24}
    {$DEFINE O_DELPHI_XE3_UP}
  {$IFEND}
  {$IF CompilerVersion >= 25}
    {$DEFINE O_DELPHI_XE4_UP}
  {$IFEND}
  {$IF CompilerVersion >= 26}
    {$DEFINE O_DELPHI_XE5_UP}
  {$IFEND}


  {$IFNDEF O_DELPHI_2009_UP}
    {$DEFINE O_DELPHI_2007_DOWN}
  {$ENDIF}
  {$IF CompilerVersion < 17}
    {$DEFINE O_DELPHI_7_DOWN}
  {$IFEND}
  {$IFNDEF O_DELPHI_7_UP}
    {$DEFINE O_DELPHI_6_DOWN}
  {$ENDIF}
{$ENDIF}

{$IF DEFINED(O_DELPHI_2009_UP) OR DEFINED(FPC)}
  {$DEFINE O_UNICODE}
{$IFEND}

{$IF DEFINED(O_DELPHI_2009_UP)}
  {$DEFINE O_GENERICS}
  {$DEFINE O_ANONYMOUS_METHODS}
  {$DEFINE O_GENERICBYTES}
{$IFEND}

{$IF DEFINED(FPC) OR NOT DEFINED(NEXTGEN)}
  {$DEFINE O_RAWBYTESTRING}
{$IFEND}

{$IF DEFINED(O_DELPHI_2009_UP) OR DEFINED(FPC)}
  {$DEFINE O_ENUMERATORS}
{$IFEND}

{$IF DEFINED(O_DELPHI_2006_UP) OR DEFINED(FPC)}
  {$DEFINE O_CLASS_HELPERS}
  {$DEFINE O_EXTRECORDS}
{$IFEND}

{$IF DEFINED(O_DELPHI_2009_UP) OR DEFINED(FPC)}
  {$DEFINE O_INLINE}//inline has a bug in Delphi 2007
{$IFEND}

{$IF DEFINED(O_DELPHI_XE2_UP)}
  {$DEFINE O_NAMESPACES}
{$IFEND}

