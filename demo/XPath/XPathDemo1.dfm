object frmXPathDemo: TfrmXPathDemo
  Left = 310
  Top = 275
  BorderStyle = bsDialog
  Caption = 'OmniXMLXpath demo'
  ClientHeight = 408
  ClientWidth = 706
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblSourceDocument: TLabel
    Left = 16
    Top = 8
    Width = 83
    Height = 13
    Caption = 'Source document'
  end
  object lab: TLabel
    Left = 16
    Top = 312
    Width = 40
    Height = 13
    Caption = 'Example'
    FocusControl = outExpression
  end
  object lblDescription: TLabel
    Left = 16
    Top = 256
    Width = 53
    Height = 13
    Caption = 'Description'
    FocusControl = cbxExample
  end
  object bvlVert1: TBevel
    Left = 352
    Top = 8
    Width = 17
    Height = 390
    Shape = bsLeftLine
  end
  object lblResult: TLabel
    Left = 368
    Top = 8
    Width = 30
    Height = 13
    Caption = 'Result'
    FocusControl = outResult
  end
  object inpSourceDocument: TMemo
    Left = 16
    Top = 27
    Width = 321
    Height = 215
    Lines.Strings = (
      '<bookstore>'
      '  <book>'
      '    <title lang="eng">Harry Potter</title>'
      '  </book>'
      '  <book>'
      '    <title lang="eng">Learning XML</title>'
      '  </book>'
      '  <book>'
      '    <title lang="slo">Z OmniXML v lepso prihodnost</title>'
      '    <year>2006</year>'
      '  </book>'
      '  <book>'
      '    <title>Kwe sona standwa sam</title>'
      '  </book>'
      '</bookstore>')
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object cbxExample: TComboBox
    Left = 16
    Top = 272
    Width = 321
    Height = 21
    Style = csDropDownList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnChange = cbxExampleChange
  end
  object btnExecute: TButton
    Left = 224
    Top = 368
    Width = 113
    Height = 25
    Caption = 'Execute >>'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = btnExecuteClick
  end
  object outExpression: TEdit
    Left = 16
    Top = 328
    Width = 321
    Height = 21
    ParentColor = True
    ReadOnly = True
    TabOrder = 2
  end
  object outResult: TMemo
    Left = 368
    Top = 27
    Width = 321
    Height = 322
    ParentColor = True
    ReadOnly = True
    TabOrder = 5
  end
  object btnClose: TButton
    Left = 576
    Top = 368
    Width = 113
    Height = 25
    Caption = 'Close'
    TabOrder = 6
    OnClick = btnCloseClick
  end
  object btnTestAll: TButton
    Left = 16
    Top = 368
    Width = 75
    Height = 25
    Caption = 'Test all'
    TabOrder = 3
    OnClick = btnTestAllClick
  end
end
