object fMain: TfMain
  Left = 268
  Top = 192
  BorderStyle = bsDialog
  Caption = 'OmniXML demo: Storage'
  ClientHeight = 355
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
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 128
    Width = 361
    Height = 2
  end
  object Label10: TLabel
    Left = 8
    Top = 120
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 325
    Height = 19
    Caption = 'How to use OmniXMLPersistent.pas unit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Shell Dlg 2'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Bevel2: TBevel
    Left = 8
    Top = 312
    Width = 361
    Height = 2
  end
  object Label11: TLabel
    Left = 8
    Top = 304
    Width = 44
    Height = 19
    Caption = 'Load '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Shell Dlg 2'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object bWriteToFile: TButton
    Left = 56
    Top = 264
    Width = 313
    Height = 33
    Caption = 'Write persistent classes to XML files'
    Default = True
    TabOrder = 0
    OnClick = bWriteToFileClick
  end
  object bLoadFromFile: TButton
    Left = 56
    Top = 320
    Width = 313
    Height = 25
    Caption = 'Load persistent class (PX) from file and save it again'
    TabOrder = 1
    OnClick = bLoadFromFileClick
  end
  object mDescription: TMemo
    Left = 8
    Top = 32
    Width = 361
    Height = 73
    TabStop = False
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      'This demo shows how to use OmniXMLPersistent unit with '
      
        'TOmniXMLWriter and TOmniXMLReader. With those two classes you ca' +
        'n '
      
        'save any persistent class (TPersistent descendant) that has publ' +
        'ished '
      
        'properties. Write/Read routines will iterate through list of pub' +
        'lished '
      'properties and save them to XML file.')
    ReadOnly = True
    TabOrder = 2
  end
  object rgPropsFormat: TRadioGroup
    Left = 56
    Top = 136
    Width = 313
    Height = 49
    Caption = ' How do you want to write properties? '
    ItemIndex = 1
    Items.Strings = (
      'as &attributes'
      'as &nodes')
    TabOrder = 3
  end
  object rgOutputFormat: TRadioGroup
    Left = 56
    Top = 192
    Width = 313
    Height = 65
    Caption = ' XML style format '
    ItemIndex = 2
    Items.Strings = (
      '&none (no formatting)'
      '&flat (CRLF before new tags)'
      '&indent (create hierarchy document)')
    TabOrder = 4
  end
end
