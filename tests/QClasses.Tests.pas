unit QClasses.Tests;

interface

uses
  TestFramework, Data.DBXJSON, QClasses, QClasses.Interfaces, Data.DB;

// AdventureWorksLT2012 Example DB: https://msftdbprodsamples.codeplex.com/downloads/get/478215

type
  TTestQClasses = class(TTestCase)
  private
    FManager: TQTableManager;
    function GetConnection: IQConnection;
    procedure TestSQL(const ASQL: string);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSelectStarFrom;
    procedure TestSimpleJoin;
    procedure TestGroupingMaxOrder;
    procedure TestNestedConditions;
    procedure TestTopStatement;
    procedure TestBetweenStatement;
  end;

implementation

uses
  QClasses.Adapters, ADODB, QClasses.Types, System.SysUtils;

{ TTestQClasses }

function TTestQClasses.GetConnection: IQConnection;
var
  LConn: TADOConnection;
begin
  LConn := TADOConnection.Create(nil);
  LConn.ConnectionString := 'Provider=SQLNCLI11;Integrated Security=SSPI;Data source=localhost;Initial Catalog=AdventureWorksLT2012';
  LConn.LoginPrompt := False;
  LConn.Connected := True;
  Result := TQADOConnectionAdapter.Create(LConn);
end;

procedure TTestQClasses.SetUp;
begin
  inherited;
  FManager := TQTableManager.Create(GetConnection);
end;

procedure TTestQClasses.TearDown;
begin
  inherited;
  FManager.Free;
end;

procedure TTestQClasses.TestSelectStarFrom;
var
  LTable: IQTable;
begin
  LTable := FManager.GetTable('Product', 'P', 'SalesLT');
  TestSQL(LTable.SelectFrom);
end;

procedure TTestQClasses.TestSimpleJoin;
var
  LProduct, LCategory: IQTable;
begin
  LProduct := FManager.GetTable('Product', 'P', 'SalesLT');
  LCategory := FManager.GetTable('ProductCategory', 'C', 'SalesLT');
  TestSQL(
    LProduct
      .SelectFrom([LProduct['ProductID'], LProduct['Name'], LCategory['Name'].AsAlias('Category')])
      .InnerJoin(LCategory, LCategory['ProductCategoryID'], LProduct['ProductCategoryID'])
      .Where(
        Condition(LCategory['Name'], copEquals, 'Mountain Bikes')
        .OrIf(LCategory['Name'], copEquals, 'Road Bikes'))
  );
end;

procedure TTestQClasses.TestSQL(const ASQL: string);
var
  LDataSet: TDataSet;
begin
  Status(ASQL);
  LDataSet := FManager.Connection.OpenQuery(ASQL);
  try
    Check(LDataSet.Active, 'Query error');
  finally
    LDataSet.Free;
  end;
end;

procedure TTestQClasses.TestGroupingMaxOrder;
var
  LOrders: IQTable;
begin
  LOrders := FManager.GetTable('SalesOrderHeader', 'O', 'SalesLT');
  TestSQL(
    LOrders
      .SelectFrom([LOrders['OrderDate'].Year, LOrders.Count['SalesOrderNumber'], LOrders.Max['TotalDue']])
      .GroupBy([LOrders['OrderDate'].Year])
      .OrderBy([DESC(LOrders['OrderDate'])])
  );
end;

procedure TTestQClasses.TestNestedConditions;
var
  LOrders, LCustomers, LAddress: IQTable;
begin
  LOrders := FManager.GetTable('SalesOrderHeader', 'O', 'SalesLT');
  LCustomers := FManager.GetTable('Customer', 'C', 'SalesLT');
  LAddress := FManager.GetTable('Address', 'A', 'SalesLT');

  TestSQL(
    LOrders
      .SelectFrom([LOrders['OrderDate'], LOrders['SalesOrderNumber'], LOrders['TotalDue'],
        LCustomers['CompanyName'], LAddress['CountryRegion']])
      .InnerJoin(LCustomers, LCustomers['CustomerID'], LOrders['CustomerID'])
      .InnerJoin(LAddress, LAddress['AddressID'], LOrders['ShipToAddressID'])
      .Where(
        Condition(
          Condition(LCustomers['CompanyName'], copLike, '%BIKE%')
          .AndIf(LOrders['TotalDue'], copGreaterThanOrEqualTo, 5000)
        )
        .OrIf(
          Condition(LAddress['CountryRegion'], copEquals, 'United Kingdom')
          .AndIf(LOrders['TotalDue'], copGreaterThanOrEqualTo, 10000)
        )
      )
    );
end;

procedure TTestQClasses.TestTopStatement;
var
  LOrders, LCustomers: IQTable;
begin
  LOrders := FManager.GetTable('SalesOrderHeader', 'O', 'SalesLT');
  LCustomers := FManager.GetTable('Customer', 'C', 'SalesLT');

  TestSQL(
    LOrders
      .SelectFrom([LOrders['OrderDate'], LOrders['SalesOrderNumber'],
        LCustomers['CompanyName'], LOrders['TotalDue']], [steTop], 10)
      .InnerJoin(LCustomers, LCustomers['CustomerID'], LOrders['CustomerID'])
      .OrderBy([DESC(2)])
  );
end;

procedure TTestQClasses.TestBetweenStatement;
var
  LOrders, LDetail, LProducts: IQTable;
begin
  LOrders := FManager.GetTable('SalesOrderHeader', 'O', 'SalesLT');
  LDetail := Fmanager.GetTable('SalesOrderDetail', 'D', 'SalesLT');
  LProducts := Fmanager.GetTable('Product', 'P', 'SalesLT');

  TestSQL(
    LOrders
      .SelectDistinctFrom([LOrders['SalesOrderNumber'], LProducts['Name'].AsAlias('ProductName'),
        LDetail['OrderQty'], LDetail['LineTotal']])
      .InnerJoin(LDetail, LDetail['SalesOrderID'], LOrders['SalesOrderID'])
      .InnerJoin(LProducts, LProducts['ProductID'], LDetail['ProductID'])
      .Where(Between(LProducts['SellStartDate'], EncodeDate(2002, 7, 1), EncodeDate(2002, 12, 1)))
  );
end;

initialization
  RegisterTest(TTestQClasses.Suite);

end.
