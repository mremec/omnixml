object fMain: TfMain
  Left = 108
  Top = 166
  BorderStyle = bsDialog
  Caption = 'OmniXML demo: ErrorInfo'
  ClientHeight = 514
  ClientWidth = 792
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 336
    Top = 280
    Width = 81
    Height = 13
    Caption = 'Error information'
  end
  object Label2: TLabel
    Left = 336
    Top = 8
    Width = 69
    Height = 13
    Caption = 'XML document'
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 194
    Height = 13
    Caption = 'What type of error do you want to test?'
  end
  object bTest: TButton
    Left = 96
    Top = 480
    Width = 233
    Height = 25
    Caption = 'TEST'
    Default = True
    TabOrder = 0
    OnClick = bTestClick
  end
  object mErrorInfo: TMemo
    Left = 336
    Top = 296
    Width = 441
    Height = 177
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
  end
  object reXML: TRichEdit
    Left = 336
    Top = 24
    Width = 441
    Height = 249
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      '<?xml version="1.0"?>'
      '<customer id="1">'
      '  <date joined="2001-03-20" />'
      '  <first_name>Joe &#33;</first_name>'
      '  <last_name>Smith &amp; Jones &#x21;</last_name>'
      '</customer>')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
    WantTabs = True
  end
  object tvErrorCases: TTreeView
    Left = 8
    Top = 24
    Width = 321
    Height = 449
    AutoExpand = True
    HideSelection = False
    Indent = 19
    ReadOnly = True
    TabOrder = 3
    OnChange = tvErrorCasesChange
  end
  object chbAutoTest: TCheckBox
    Left = 8
    Top = 484
    Width = 81
    Height = 17
    Caption = 'auto test'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
end
