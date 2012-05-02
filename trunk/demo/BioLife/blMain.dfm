object frmBioLife: TfrmBioLife
  Left = 374
  Top = 200
  Width = 683
  Height = 611
  ActiveControl = lbLog
  Caption = 'OmniXML: BioLife demo'
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
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 417
    Height = 448
    Align = alLeft
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object lbLog: TListBox
    Left = 0
    Top = 448
    Width = 675
    Height = 129
    Align = alBottom
    ItemHeight = 13
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 417
    Top = 0
    Width = 258
    Height = 448
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object DBMemo1: TDBMemo
      Left = 0
      Top = 0
      Width = 258
      Height = 225
      Align = alTop
      DataField = 'Notes'
      DataSource = DataSource1
      TabOrder = 0
    end
    object DBImage1: TDBImage
      Left = 0
      Top = 225
      Width = 258
      Height = 223
      Align = alClient
      DataField = 'Graphic'
      DataSource = DataSource1
      TabOrder = 1
    end
  end
  object tblBioLife: TTable
    DatabaseName = 'DBDEMOS'
    TableName = 'biolife.db'
    Left = 576
    Top = 16
  end
  object memBioLife: TkbmMemTable
    DesignActivation = True
    AttachedAutoRefresh = True
    AttachMaxCount = 1
    FieldDefs = <
      item
        Name = 'Species No'
        DataType = ftFloat
      end
      item
        Name = 'Category'
        DataType = ftString
        Size = 15
      end
      item
        Name = 'Common_Name'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'Species Name'
        DataType = ftString
        Size = 40
      end
      item
        Name = 'Length (cm)'
        DataType = ftFloat
      end
      item
        Name = 'Length_In'
        DataType = ftFloat
      end
      item
        Name = 'Notes'
        DataType = ftMemo
        Size = 50
      end
      item
        Name = 'Graphic'
        DataType = ftGraphic
      end>
    IndexDefs = <>
    SortOptions = []
    PersistentBackup = False
    ProgressFlags = [mtpcLoad, mtpcSave, mtpcCopy]
    FilterOptions = []
    Version = '3.07'
    LanguageID = 0
    SortID = 0
    SubLanguageID = 1
    LocaleID = 1024
    Left = 608
    Top = 16
    object memBioLifeSpeciesNo: TFloatField
      FieldName = 'Species No'
    end
    object memBioLifeCategory: TStringField
      FieldName = 'Category'
      Size = 15
    end
    object memBioLifeCommon_Name: TStringField
      FieldName = 'Common_Name'
      Size = 30
    end
    object memBioLifeSpeciesName: TStringField
      FieldName = 'Species Name'
      Size = 40
    end
    object memBioLifeLengthcm: TFloatField
      FieldName = 'Length (cm)'
    end
    object memBioLifeLength_In: TFloatField
      FieldName = 'Length_In'
    end
    object memBioLifeNotes: TMemoField
      FieldName = 'Notes'
      BlobType = ftMemo
      Size = 50
    end
    object memBioLifeGraphic: TGraphicField
      FieldName = 'Graphic'
      BlobType = ftGraphic
    end
  end
  object DataSource1: TDataSource
    DataSet = memBioLife
    Left = 640
    Top = 16
  end
end
