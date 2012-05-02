object fMain: TfMain
  Left = 376
  Top = 173
  AutoScroll = False
  Caption = 'OmniXML demo: Xtreme'
  ClientHeight = 281
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label8: TLabel
    Left = 8
    Top = 8
    Width = 361
    Height = 33
    AutoSize = False
    Caption = 
      'This demo shows how to create XML document, write different type' +
      ' of data to XML document and save it to a file.'
    WordWrap = True
  end
  object Bevel3: TBevel
    Left = 8
    Top = 48
    Width = 361
    Height = 2
  end
  object Bevel1: TBevel
    Left = 56
    Top = 112
    Width = 313
    Height = 2
  end
  object Label2: TLabel
    Left = 56
    Top = 56
    Width = 171
    Height = 13
    Caption = 'Name of the &file with XML document'
    FocusControl = eFileName
  end
  object Label10: TLabel
    Left = 8
    Top = 104
    Width = 44
    Height = 19
    Caption = 'Save '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Shell Dlg 2'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label9: TLabel
    Left = 56
    Top = 120
    Width = 125
    Height = 13
    Caption = 'Use &encoding (code page)'
  end
  object eFileName: TEdit
    Left = 56
    Top = 72
    Width = 241
    Height = 21
    TabOrder = 0
  end
  object cobCodePage: TComboBox
    Left = 56
    Top = 136
    Width = 241
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    Sorted = True
    TabOrder = 1
  end
  object bDriveSave: TButton
    Left = 59
    Top = 244
    Width = 238
    Height = 25
    Caption = '&Scan, create and save document'
    TabOrder = 3
    OnClick = bDriveSaveClick
  end
  object rgOutputFormat: TRadioGroup
    Left = 56
    Top = 168
    Width = 241
    Height = 65
    Caption = ' XML style format '
    ItemIndex = 2
    Items.Strings = (
      '&none (no formatting)'
      '&flat (CRLF before new tags)'
      '&indent (create hierarchy document)')
    TabOrder = 2
  end
end
