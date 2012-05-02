object Form1: TForm1
  Left = 372
  Top = 331
  Width = 560
  Height = 552
  Caption = 'OmniXMLProperties demo / RSS Reader'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblRSS: TLabel
    Left = 8
    Top = 16
    Width = 29
    Height = 16
    Caption = 'RSS:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object inpRSS: TEdit
    Left = 48
    Top = 12
    Width = 440
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = 'summary.xml'
  end
  object btnSelectRSS: TButton
    Left = 491
    Top = 10
    Width = 53
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Select'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnSelectRSSClick
  end
  object lbLog: TListBox
    Left = 8
    Top = 48
    Width = 536
    Height = 462
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 2
  end
  object OpenDialog1: TOpenDialog
    Left = 256
    Top = 8
  end
end
