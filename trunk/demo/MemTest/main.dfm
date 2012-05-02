object fMain: TfMain
  Left = 269
  Top = 139
  Width = 402
  Height = 385
  Caption = 'OmniXML demo: MemTest'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label8: TLabel
    Left = 8
    Top = 8
    Width = 361
    Height = 33
    AutoSize = False
    Caption = 
      'This demo was written to test for potential memory leaks. OmniXM' +
      'L has been tested with MemProof - no leaks were found.'
    WordWrap = True
  end
  object Bevel3: TBevel
    Left = 8
    Top = 48
    Width = 361
    Height = 2
  end
  object bCreateXMLDoc: TButton
    Left = 8
    Top = 64
    Width = 145
    Height = 25
    Action = actCreateXMLDoc
    TabOrder = 0
  end
  object bFreeXMLDoc: TButton
    Left = 8
    Top = 88
    Width = 145
    Height = 25
    Action = actFreeXMLDoc
    TabOrder = 1
  end
  object bCreateAndFree: TButton
    Left = 160
    Top = 64
    Width = 145
    Height = 49
    Caption = 'Create && nil'
    TabOrder = 2
    OnClick = bCreateAndFreeClick
  end
  object bCreateElement: TButton
    Left = 8
    Top = 128
    Width = 145
    Height = 25
    Action = actCreateElement
    TabOrder = 3
  end
  object bCreateAttr: TButton
    Left = 16
    Top = 152
    Width = 145
    Height = 25
    Action = actCreateAttribute
    TabOrder = 4
  end
  object bSetAttr: TButton
    Left = 24
    Top = 176
    Width = 145
    Height = 25
    Action = actSetAttribute
    TabOrder = 5
  end
  object bSimpleCycle: TButton
    Left = 160
    Top = 256
    Width = 145
    Height = 25
    Caption = 'Simple Cycle'
    TabOrder = 8
    OnClick = bSimpleCycleClick
  end
  object bLoadAndSelectNodes: TButton
    Left = 16
    Top = 296
    Width = 145
    Height = 25
    Caption = 'Load && SelectNodes'
    TabOrder = 9
    OnClick = bLoadAndSelectNodesClick
  end
  object bAppendChild: TButton
    Left = 16
    Top = 200
    Width = 145
    Height = 25
    Action = actAppendChild
    TabOrder = 6
  end
  object bFreeElement: TButton
    Left = 8
    Top = 224
    Width = 145
    Height = 25
    Action = actFreeElement
    TabOrder = 7
  end
  object ActionList1: TActionList
    Left = 320
    Top = 144
    object actCreateElement: TAction
      Caption = 'CreateElement'
      OnExecute = actCreateElementExecute
      OnUpdate = actCreateElementUpdate
    end
    object actAppendChild: TAction
      Caption = 'AppendChild(Element)'
      OnExecute = actAppendChildExecute
      OnUpdate = actAppendChildUpdate
    end
    object actCreateAttribute: TAction
      Caption = 'CreateAttribute'
      OnExecute = actCreateAttributeExecute
      OnUpdate = actCreateAttributeUpdate
    end
    object actSetAttribute: TAction
      Caption = 'Element.SetAttribute'
      OnExecute = actSetAttributeExecute
      OnUpdate = actSetAttributeUpdate
    end
    object actFreeElement: TAction
      Caption = 'Element := nil'
      OnExecute = actFreeElementExecute
      OnUpdate = actFreeElementUpdate
    end
    object actCreateXMLDoc: TAction
      Caption = 'CreateXMLDoc'
      OnExecute = actCreateXMLDocExecute
    end
    object actFreeXMLDoc: TAction
      Caption = 'XMLDoc := nil'
      OnExecute = actFreeXMLDocExecute
      OnUpdate = actFreeXMLDocUpdate
    end
  end
end
