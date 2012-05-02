unit rrRSS;

interface

uses
  OmniXML, OmniXMLProperties;

type
TRSSImage = class(TGpXMLData)
  public
    constructor Create(node: IXMLNode); override;
  published
    property Title: WideString index 0 read GetXMLPropWide write SetXMLPropWide;
    property URL: WideString index 1 read GetXMLPropWide write SetXMLPropWide;
    property Link: WideString index 2 read GetXMLPropWide write SetXMLPropWide;
    property Width: Integer index 3 read GetXMLPropInt write SetXMLPropInt;
    property Height: Integer index 4 read GetXMLPropInt write SetXMLPropInt;
    property Description: WideString index 5 read GetXMLPropWide write SetXMLPropWide;
end;

TRSSEnclosure = class(TGpXMLData)
  public
    constructor Create(node: IXMLNode); override;
  published
    property Url: WideString index 0 read GetXMLAttrPropWide write SetXMLAttrPropWide;
    property Length: Integer index 1 read GetXMLAttrPropInt write SetXMLAttrPropInt;
    property EnclosureType: WideString index 2 read GetXMLAttrPropWide write SetXMLAttrPropWide;
end;

TRSSGuid = class(TGpXMLData)
  public
    constructor Create(node: IXMLNode); override;
  published
    property IsPermaLink: WideString index 0 read GetXMLAttrPropWide write SetXMLAttrPropWide;
    property Value: WideString index 1 read GetXMLPropWide write SetXMLPropWide;
end;

TRSSItem = class(TGpXMLData)
  private
    rssEnclosure: TRSSEnclosure;
    rssGUID: TRSSGuid;
  public
    constructor Create(node: IXMLNode); override;
    destructor  Destroy; override;
  published
    property Title: WideString index 0 read GetXMLPropWide write SetXMLPropWide;
    property Link: WideString index 1 read GetXMLPropWide write SetXMLPropWide;
    property Description: WideString index 2 read GetXMLPropCDataOrTextWide write SetXMLPropWide;
    property Author: WideString index 3 read GetXMLPropWide write SetXMLPropWide;
    property Category: WideString index 4 read GetXMLPropWide write SetXMLPropWide;
    property Comments: WideString index 5 read GetXMLPropWide write SetXMLPropWide;
    property PubDate: WideString index 6 read GetXMLPropWide write SetXMLPropWide;
    property Source: WideString index 7 read GetXMLPropWide write SetXMLPropWide;
    property Enclosure: TRSSEnclosure read rssEnclosure;
    property Guid: TRSSGuid read rssGuid;
end;

TRSSItems = class(TGpXMLList)
  protected
    function GetItem(idxItem: Integer): TRSSItem;
  public
    constructor Create(parentNode: IXMLNode; childTag: WideString); reintroduce;
    property Items[idxItem: Integer]: TRSSItem read GetItem; default;
end;

TRSSChannel = class(TGpXMLData)
  private
    rssImage: TRSSImage;
    rssItems: TRSSItems;
  public
    constructor Create(node: IXMLNode); override;
    destructor  Destroy; override;
  published
    property Title: WideString index 0 read GetXMLPropWide write SetXMLPropWide;
    property Link: WideString index 1 read GetXMLPropWide write SetXMLPropWide;
    property Description: WideString index 2 read GetXMLPropWide write SetXMLPropWide;
    property Language: WideString index 3 read GetXMLPropWide write SetXMLPropWide;
    property Copyright: WideString index 4 read GetXMLPropWide write SetXMLPropWide;
    property ManagingEditor: WideString index 5 read GetXMLPropWide write SetXMLPropWide;
    property WebMaster: WideString index 6 read GetXMLPropWide write SetXMLPropWide;
    property PubDate: WideString index 7 read GetXMLPropWide write SetXMLPropWide;
    property LastBuildDate: WideString index 8 read GetXMLPropWide write SetXMLPropWide;
    property Category: WideString index 9 read GetXMLPropWide write SetXMLPropWide;
    property Generator: WideString index 10 read GetXMLPropWide write SetXMLPropWide;
    property Docs: WideString index 11 read GetXMLPropWide write SetXMLPropWide;
    property Cloud: WideString index 12 read GetXMLPropWide write SetXMLPropWide;
    property Ttl: Integer index 13 read GetXMLPropInt write SetXMLPropInt;
    property Rating: WideString index 14 read GetXMLPropWide write SetXMLPropWide;
    property Image: TRSSImage read rssImage;
    property Items: TRSSItems read rssItems;
end;

TRSS = class(TGpXMLDocList)
  private
    function GetChannel(idxChannel: Integer): TRSSChannel;
  public
    constructor Create; reintroduce;
    property Channel[idxChannel: Integer]: TRSSChannel read GetChannel; default;
  published
     property Version: WideString index 0 read GetXMLAttrPropWide write SetXMLAttrPropWide;
end;

implementation

uses
  SysUtils;

{ TRSSImage }

constructor TRSSImage.Create(node: IXMLNode);
begin
  inherited;
  InitChildNodes(
    ['title', 'url', 'link', 'width', 'height', 'description'],
    ['', '', '', 0, 0, '']);
end;

{ TRSSEnclosure }

constructor TRSSEnclosure.Create(node: IXMLNode);
begin
  inherited;

  InitChildNodes(
    ['url', 'length', 'type'],
    ['', 0, '']);
end;

{ TRSSGuid }

constructor TRSSGuid.Create(node: IXMLNode);
begin
  inherited;

  InitChildNodes(
    ['isPermaLink', ''],
    ['true', '']);
end;

{ TRSSItem }

constructor TRSSItem.Create(node: IXMLNode);
begin
  inherited;
  InitChildNodes(
    ['title', 'link', 'description', 'author', 'category', 'comments', 'pubDate',
     'source'],
    ['', '', '', '', '', '', 'Sat, 30 Dec 1899 00:00:00',
     '']);

  rssEnclosure := TRSSEnclosure.Create(node, 'enclosure');
  rssGuid := TRSSGuid.Create(node, 'guid');
end;

destructor TRSSItem.Destroy;
begin
  FreeAndNil(rssEnclosure);
  FreeAndNil(rssGuid);

  inherited;
end;

{ TItems }

constructor TRSSItems.Create(parentNode: IXMLNode; childTag: WideString);
begin
  inherited Create(parentNode, '', 'item', TRSSItem);
end; 

function TRSSItems.GetItem(idxItem: Integer): TRSSItem;
begin
  Result := TRSSItem(inherited Items[idxItem]);
end; 

{ TRSSChannel }

constructor TRSSChannel.Create(node: IXMLNode);
begin
  inherited;
  InitChildNodes(
    ['title', 'link', 'description', 'language', 'copyright', 'managingEditor',
     'webMaster', 'pubDate', 'lastBuildDate', 'category', 'generator', 'docs',
     'cloud', 'ttl', 'rating'],
    ['', '', '', '', '', '',
     '', 'Sat, 30 Dec 1899 00:00:00', 'Sat, 30 Dec 1899 00:00:00', '', '', '',
     '', 0, '']);

  rssImage := TRSSImage.Create(node, 'image');
  rssItems := TRSSItems.Create(node, 'item');
end;

destructor TRSSChannel.Destroy;
begin
  FreeAndNil(rssImage);
  FreeAndNil(rssItems);
  inherited Destroy;
end; 

{ TRSS }

constructor TRSS.Create;
begin
  inherited Create('rss', '', 'channel', TRSSChannel);
  InitChildNodes(['version'], ['']);
end; 

function TRSS.GetChannel(idxChannel: Integer): TRSSChannel;
begin
  Result := TRSSChannel(Items[idxChannel]);
end;

end.

