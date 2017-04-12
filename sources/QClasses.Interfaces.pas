unit QClasses.Interfaces;

interface

uses
  Data.DB, QClasses.Types;

type
  IQTable = interface(IUnknown)
    function GetTableDef: TQTableDef;
    function GetFieldByIndex(const AIndex: Integer): TQFieldDef;
    function GetFieldByName(const AFieldName: String): TQFieldDef;
    function GetFieldCount: Integer;
    function GetAvg(const AFieldName: string): TQFieldDef;
    function GetCount(const AFieldName: string): TQFieldDef;
    function GetMax(const AFieldName: string): TQFieldDef;
    function GetMin(const AFieldName: string): TQFieldDef;
    function GetSum(const AFieldName: string): TQFieldDef;
    function GetFieldIndexByName(const AFieldName: String): Integer;
    function GetFields(const AFieldName: string; const AAggregation: TQAggregationFunctionType=aftNone): TQFieldDef;
    property TableDef: TQTableDef read GetTableDef;
    function SelectFrom: QString; overload;
    function SelectFrom(const AFieldNames: array of string;
      const ATop: TQSelectTop=[]; const ATopCount: Cardinal=0): QString; overload;
    function SelectFrom(const AFieldNames: array of TQFieldDef;
      const ATop: TQSelectTop=[]; const ATopCount: Cardinal=0): QString; overload;
    function SelectDistinctFrom(const AFieldNames: array of string;
      const ATop: TQSelectTop=[]; const ATopCount: Cardinal=0): QString; overload;
    function SelectDistinctFrom(const AFieldNames: array of TQFieldDef;
      const ATop: TQSelectTop=[]; const ATopCount: Cardinal=0): QString; overload;
    property Count[const AFieldName: string]: TQFieldDef read GetCount;
    property Sum[const AFieldName: string]: TQFieldDef read GetSum;
    property Max[const AFieldName: string]: TQFieldDef read GetMax;
    property Min[const AFieldName: string]: TQFieldDef read GetMin;
    property Avg[const AFieldName: string]: TQFieldDef read GetAvg;
    property FieldCount: Integer read GetFieldCount;
    property FieldByIndex[const AIndex: Integer]: TQFieldDef read GetFieldByIndex;
    property FieldByName[const AFieldName: String]: TQFieldDef read GetFieldByName; default;
  end;

  IQConnection = interface
    function GetConnected: Boolean;
    property Connected: Boolean read GetConnected;
    function GetInitialCatalogName: string;
    property InitialCatalogName: string read GetInitialCatalogName;
    function OpenQuery(const ASQL: string): TDataSet;
  end;

implementation

end.
