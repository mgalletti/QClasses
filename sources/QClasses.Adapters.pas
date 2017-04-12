unit QClasses.Adapters;

interface

uses
  QClasses.Interfaces, Data.DB, ADODB;

type
  TQADOConnectionAdapter = class(TInterfacedObject, IQConnection)
  private
    FConnection: TADOConnection;
    FOwnsObject: Boolean;
  public
    constructor Create(const AConnection: TADOConnection; const AOwnsObject: Boolean = False);
    destructor Destroy; override;
    function GetConnected: Boolean;
    property Connected: Boolean read GetConnected;
    function GetInitialCatalogName: string;
    property InitialCatalogName: string read GetInitialCatalogName;
    function OpenQuery(const ASQL: string): TDataSet;
  end;


implementation

{ TQADOConnectionAdapter }

constructor TQADOConnectionAdapter.Create(const AConnection: TADOConnection; const AOwnsObject: Boolean);
begin
  FConnection := AConnection;
  FOwnsObject := AOwnsObject;
end;

destructor TQADOConnectionAdapter.Destroy;
begin
  if FOwnsObject then
    FConnection.Free;
  inherited;
end;

function TQADOConnectionAdapter.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

function TQADOConnectionAdapter.GetInitialCatalogName: string;
begin
  Result := FConnection.Properties.Item['Initial Catalog'].Value;
end;

function TQADOConnectionAdapter.OpenQuery(const ASQL: string): TDataSet;
var
  LDataSet: TADODataSet;
begin
  LDataSet := TADODataSet.Create(FConnection);
  LDataSet.Connection := FConnection;
  LDataSet.CommandType := cmdText;
  LDataSet.CommandText := ASQL;
  LDataSet.Open;
  Result := LDataSet;
end;

end.
