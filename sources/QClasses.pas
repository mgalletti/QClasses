unit QClasses;

interface

uses
  System.SysUtils, System.Generics.Collections, Data.DB, QClasses.Types, QClasses.Interfaces;

type
  TQStringHelper = record helper for QString
  private
    function GetJoinPredicate(const AJoinType: TQJoinType): string;
    function XJoin(const AJoinType: TQJoinType; const AJoinTable: IQTable; const AJoinField, AMasterField: TQFieldDef): QString; overload;
    function XJoin(const AJoinType: TQJoinType; const AJoinTable: IQTable; const AJoinField, ACompareField: string): QString; overload;
    function XJoin(const AJoinType: TQJoinType; const AJoinTable: IQTable; const AJoinField: TQFieldDef; const AValue: Variant): QString; overload;
  public
    function Add(const AStatement: QString): QString;
    function InnerJoin(const AJoinTable: IQTable; const AJoinField, AMasterField: TQFieldDef): QString; overload;
    function InnerJoin(const AJoinTable: IQTable; const AJoinField: TQFieldDef; const AValue: Variant): QString; overload;
    function LeftOuterJoin(const AJoinTable: IQTable; const AJoinField, AMasterField: TQFieldDef): QString; overload;
    function LeftOuterJoin(const AJoinTable: IQTable; const AJoinField: TQFieldDef; const AValue: Variant): QString; overload;
    function RightOuterJoin(const AJoinTable: IQTable; const AJoinField, AMasterField: TQFieldDef): QString; overload;
    function RightOuterJoin(const AJoinTable: IQTable; const AJoinField: TQFieldDef; const AValue: Variant): QString; overload;
    function Where(const ACondition: QStringWhere): QString;
    function GroupBy(const AFields: array of string): QString; overload;
    function GroupBy(const AFields: array of TQFieldDef): QString; overload;
    function OrderBy(const AFields: array of TQOrderByFieldDef): QString; overload;
    function OrderBy(const AFields: array of TQOrderByIndexDef): QString; overload;
    function Union: QString;
    function UnionAll: QString;
  end;

  TQStringWhereHelper = record helper for QStringWhere
  private
    function XCondition(const AOperator: TQLogicalOperator; const AComparison: TQFieldsComparison): QStringWhere; overload;
    function XCondition(const AOperator: TQLogicalOperator; const AComparison: TQFieldValueComparison): QStringWhere; overload;
    function XCondition(const AOperator: TQLogicalOperator; const AField: TQFieldDef; const ACompOp: TQComparisonOperator; const AParamName: string): QStringWhere; overload;
    function XCondition(const AOperator: TQLogicalOperator; const ACondition: QStringWhere): QStringWhere; overload;
  public
    function OrIf(const AField1: TQFieldDef; const AOperator: TQComparisonOperator; const AField2: TQFieldDef): QStringWhere; overload;
    function OrIf(const AField: TQFieldDef; const AOperator: TQComparisonOperator; const AValue: Variant): QStringWhere; overload;
    function OrIf(const ACondition: QStringWhere): QStringWhere; overload;
    function AndIf(const AField1: TQFieldDef; const AOperator: TQComparisonOperator; const AField2: TQFieldDef): QStringWhere; overload;
    function AndIf(const AField: TQFieldDef; const AOperator: TQComparisonOperator; const AValue: Variant): QStringWhere; overload;
    function AndIf(const ACondition: QStringWhere): QStringWhere; overload;
  end;

  TQStringCaseHelper = record helper for QStringCase
  private
    function XCase(const AFieldName: string): QStringCase;
    function XWhen(const ACondition: QStringCase): QStringCase;
    function XThenVal(const AValue: string): QStringCase;
    function XElseVal(const AValue: string): QStringCase;
    function XCaseEnd(AFieldAlias: string): QStringCase;
  public
    function CaseBegin(AField: TQFieldDef): QStringCase; overload;
    function CaseBegin: QStringCase; overload;
    function When(const AComparison: TQFieldsComparison): QStringCase; overload;
    function When(const AComparison: TQFieldValueComparison): QStringCase; overload;
    function When(const AConstantValue: Variant): QStringCase; overload;
    function ThenVal(const AConstantValue: Variant): QStringCase; overload;
    function ThenVal(const AField: TQFieldDef): QStringCase; overload;
    function ElseVal(const AConstantValue: Variant): QStringCase; overload;
    function ElseVal(const AField: TQFieldDef): QStringCase; overload;
    function CaseEnd(const AFieldAlias: string): QStringCase; overload;
    function CaseEnd: QStringCase; overload;
    function ToFieldDef(const AFieldAlias: string): TQFieldDef;
  end;

  TQTable = class(TInterfacedObject, IQTable)
  private
    FTableDef: TQTableDef;
    FFields: TList<TQFieldDef>;
    function GetTableDef: TQTableDef;
    function GetFieldByIndex(const AIndex: Integer): TQFieldDef;
    function GetFieldByName(const AFieldName: String): TQFieldDef;
    function GetFieldCount: Integer;
    function GetFields(const AFieldName: string; const AAggregation: TQAggregationFunctionType=aftNone): TQFieldDef; overload;
    function GetAvg(const AFieldName: string): TQFieldDef;
    function GetCount(const AFieldName: string): TQFieldDef;
    function GetMax(const AFieldName: string): TQFieldDef;
    function GetMin(const AFieldName: string): TQFieldDef;
    function GetSum(const AFieldName: string): TQFieldDef;
    function InnerSelectFrom(const AArgument: TQSelectArgument; const AFieldNames: array of TQFieldDef;
      const ATop: TQSelectTop=[]; const ATopCount: Cardinal=0): QString; overload;
    function InnerSelectFrom(const AArgument: TQSelectArgument; const AFieldNames: array of string;
      const ATop: TQSelectTop=[]; const ATopCount: Cardinal=0): QString; overload;
  public
    constructor Create;
    destructor Destroy; override;
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
    property FieldCount: Integer read GetFieldCount;
    property FieldByIndex[const AIndex: Integer]: TQFieldDef read GetFieldByIndex;
    property Count[const AFieldName: string]: TQFieldDef read GetCount;
    property Sum[const AFieldName: string]: TQFieldDef read GetSum;
    property Max[const AFieldName: string]: TQFieldDef read GetMax;
    property Min[const AFieldName: string]: TQFieldDef read GetMin;
    property Avg[const AFieldName: string]: TQFieldDef read GetAvg;
    property FieldByName[const AFieldName: string]: TQFieldDef read GetFieldByName; default;
    function GetFieldIndexByName(const AFieldName: String): Integer;
  end;

  // Get new IQTable
  function GetQTable(const AConnection: IQConnection; const ATableName: string; const AFullyQualifiedName: Boolean=False): IQTable; overload;
  function GetQTable(const AConnection: IQConnection; const ATableName, ATableAlias: string; const AFullyQualifiedName: Boolean=False): IQTable; overload;
  function GetQTable(const AConnection: IQConnection; const ATableName, ATableAlias, ASchemaName: string; const AFullyQualifiedName: Boolean=False): IQTable; overload;
  // Case when
  function CaseBegin(AField: TQFieldDef): QStringCase; overload;
  function CaseBegin: QStringCase; overload;
  // Field
  function Value(const AValue: Variant; const AFieldAlias: string): TQFieldDef;
  // Null values
  function IsNull(ACheckField, AReplacementField: TQFieldDef; const AFieldAlias: string=''): TQFieldDef; overload;
  function IsNull(ACheckField: TQFieldDef; const AReplacementValue: Variant; const AFieldAlias: string=''): TQFieldDef; overload;
  // Param name fast formatting
  function QParam(const AParamName: string): string;
  // Where
  function Condition(const AField1: TQFieldDef; const AOperator: TQComparisonOperator; const AField2: TQFieldDef): QStringWhere; overload;
  function Condition(const AField: TQFieldDef; const AOperator: TQComparisonOperator; const AValue: Variant): QStringWhere; overload;
  function Condition(const ACondition: QStringWhere): QStringWhere; overload;
  function FieldInSet(const AField: TQFieldDef; const AValues: array of Variant): QStringWhere;
  function Exists(const ACondition: QString): QStringWhere;
  function NotExists(const ACondition: QString): QStringWhere;
  function Between(const AField: TQFieldDef; const AStartValue, AEndValue: Variant): QStringWhere;
  // OrderBy
  function ASC(const AField: TQFieldDef): TQOrderByFieldDef; overload;
  function ASC(const AIndex: Integer): TQOrderByIndexDef; overload;
  function DESC(const AField: TQFieldDef): TQOrderByFieldDef; overload;
  function DESC(const AIndex: Integer): TQOrderByIndexDef; overload;

type
  TQTableManager = class
  private
    FUseFullyQualifiedNames: Boolean;
    procedure SetUseFullyQualifiedNames(const Value: Boolean);
    function GetConnection: IQConnection;
  protected
    FConnection: IQConnection;
    FQTableCache: TList<IQTable>;
  public
    constructor Create(const AConnection: IQConnection);
    destructor Destroy; override;
    function GetTable(const ATableName: string; const ATableAlias: string=''; const ASchemaName: string=Q_DEFAULT_SCHEMA): IQTable;
    procedure ClearCache;
    property UseFullyQualifiedNames: Boolean read FUseFullyQualifiedNames write SetUseFullyQualifiedNames;
    property Connection: IQConnection read GetConnection;
  end;

implementation

uses
  System.Variants, QClasses.Utils;


{ TQStringHelper }

function TQStringHelper.Add(const AStatement: QString): QString;
begin
  Result := Self + #13#10 + AStatement;
end;

function TQStringHelper.GetJoinPredicate(const AJoinType: TQJoinType): string;
begin
  case AJoinType of
    qjtInner: Result := ' INNER';
    qjtLeftOuter: Result := ' LEFT OUTER';
    qjtRightOuter: Result := ' RIGHT OUTER';
    else Result := '';
  end;
end;

function TQStringHelper.XJoin(const AJoinType: TQJoinType; const AJoinTable: IQTable;
  const AJoinField, AMasterField: TQFieldDef): QString;
begin
  Result := XJoin(AJoinType, AJoinTable, AJoinField.FullName, AMasterField.FullName);
end;

function TQStringHelper.XJoin(const AJoinType: TQJoinType;
  const AJoinTable: IQTable; const AJoinField,
  ACompareField: string): QString;
begin
  Result := GetJoinPredicate(AJoinType)+' JOIN '+AJoinTable.TableDef.FullName+' ON '+AJoinField+'='+ACompareField;
end;

function TQStringHelper.XJoin(const AJoinType: TQJoinType;
  const AJoinTable: IQTable; const AJoinField: TQFieldDef;
  const AValue: Variant): QString;
begin
  Result := XJoin(AJoinType, AJoinTable, AJoinField.FullName, QuoteSQLValue(AValue));
end;

function TQStringHelper.InnerJoin(const AJoinTable: IQTable; const AJoinField, AMasterField: TQFieldDef): QString;
begin
  Result := Add(XJoin(qjtInner, AJoinTable, AJoinField, AMasterField));
end;

function TQStringHelper.LeftOuterJoin(const AJoinTable: IQTable; const AJoinField, AMasterField: TQFieldDef): QString;
begin
  Result := Add(XJoin(qjtLeftOuter, AJoinTable, AJoinField, AMasterField));
end;

function TQStringHelper.RightOuterJoin(const AJoinTable: IQTable; const AJoinField, AMasterField: TQFieldDef): QString;
begin
  Result := Add(XJoin(qjtRightOuter, AJoinTable, AJoinField, AMasterField));
end;

function TQStringHelper.Where(const ACondition: QStringWhere): QString;
begin
  Result := Add('WHERE '+ACondition);
end;

function TQStringHelper.GroupBy(const AFields: array of TQFieldDef): QString;
var
  LFieldNames: array of string;
  I: Integer;
begin
  SetLength(LFieldNames, Length(AFields));
  for I := 0 to Length(AFields)-1 do
    LFieldNames[I] := AFields[I].FullName;

  Result := GroupBy(LFieldNames);
end;

function TQStringHelper.InnerJoin(const AJoinTable: IQTable;
  const AJoinField: TQFieldDef; const AValue: Variant): QString;
begin
  Result := Add(XJoin(qjtInner, AJoinTable, AJoinField, AValue));
end;

function TQStringHelper.LeftOuterJoin(const AJoinTable: IQTable;
  const AJoinField: TQFieldDef; const AValue: Variant): QString;
begin
  Result := Self + #13#10 + XJoin(qjtLeftOuter, AJoinTable, AJoinField, AValue);
end;

function TQStringHelper.GroupBy(const AFields: array of string): QString;
var
  LField: string;
begin
  Result := '';
  for LField in AFields do
    Result := Result + ',' + LField;

  if Result<>'' then
  begin
    Delete(Result, 1, 1);
    Result := Add('GROUP BY '+Result);
  end
  else
    Result := Self;
end;

function TQStringHelper.OrderBy(const AFields: array of TQOrderByFieldDef): QString;
var
  LField: TQOrderByFieldDef;
begin
  for LField in AFields do
    Result := Result + ','+LField.GetFieldName;
  if Result<>'' then
  begin
    Delete(Result, 1, 1);
    Result := Add('ORDER BY '+Result);
  end
  else
    Result := Self;
end;

function TQStringHelper.OrderBy(const AFields: array of TQOrderByIndexDef): QString;
var
  LField: TQOrderByIndexDef;
begin
  for LField in AFields do
    Result := Result + ','+IntToStr(LField.Index)+' '+GetFieldOrderQString(LField.OrderDirection);
  if Result<>'' then
  begin
    Delete(Result, 1, 1);
    Result := Add('ORDER BY '+Result);
  end
  else
    Result := Self;
end;

function TQStringHelper.RightOuterJoin(const AJoinTable: IQTable;
  const AJoinField: TQFieldDef; const AValue: Variant): QString;
begin
  Result := Add(XJoin(qjtRightOuter, AJoinTable, AJoinField, AValue));
end;

function TQStringHelper.Union: QString;
begin
  Result := Add('UNION' + #13#10);
end;

function TQStringHelper.UnionAll: QString;
begin
  Result := Add('UNION ALL' + #13#10);
end;

{ TQStringWhereHelper }

function TQStringWhereHelper.AndIf(const AField1: TQFieldDef;
  const AOperator: TQComparisonOperator;
  const AField2: TQFieldDef): QStringWhere;
var
  LComparison: TQFieldsComparison;
begin
  LComparison.Format(AField1, AField2, AOperator);
  Result := XCondition(loAND, LComparison);
end;

function TQStringWhereHelper.AndIf(const AField: TQFieldDef;
  const AOperator: TQComparisonOperator; const AValue: Variant): QStringWhere;
var
  LComparison: TQFieldValueComparison;
begin
  if VarIsStr(AValue) and (string(AValue)<>'') and (string(AValue)[1]=':') then
    Result := XCondition(loAND, AField, AOperator, AValue)
  else
  begin
    LComparison.Format(AField, AValue, AOperator);
    Result := XCondition(loAND, LComparison);
  end;
end;

function TQStringWhereHelper.AndIf(const ACondition: QStringWhere): QStringWhere;
begin
  Result := XCondition(loAND, ACondition);
end;

//function TQStringWhereHelper.Exists(const ACondition: QString): QStringWhere;
//begin
//  Result := Self + 'EXISTS ('+ACondition+')';
//end;

//function TQStringWhereHelper.NotExists(const ACondition: QString): QStringWhere;
//begin
//  Result := Self + 'NOT EXISTS ('+ACondition+')';
//end;

function TQStringWhereHelper.OrIf(const AField1: TQFieldDef;
  const AOperator: TQComparisonOperator;
  const AField2: TQFieldDef): QStringWhere;
var
  LComparison: TQFieldsComparison;
begin
  LComparison.Format(AField1, AField2, AOperator);
  Result := XCondition(loOR, LComparison);
end;

function TQStringWhereHelper.OrIf(const AField: TQFieldDef;
  const AOperator: TQComparisonOperator; const AValue: Variant): QStringWhere;
var
  LComparison: TQFieldValueComparison;
begin
  if VarIsStr(AValue) and (string(AValue)<>'') and (string(AValue)[1]=':') then
    Result := XCondition(loOR, AField, AOperator, AValue)
  else
  begin
    LComparison.Format(AField, AValue, AOperator);
    Result := XCondition(loOR, LComparison);
  end;
end;

function TQStringWhereHelper.OrIf(const ACondition: QStringWhere): QStringWhere;
begin
  Result := XCondition(loOR, ACondition);
end;

function TQStringWhereHelper.XCondition(const AOperator: TQLogicalOperator;
  const AField: TQFieldDef; const ACompOp: TQComparisonOperator;
  const AParamName: string): QStringWhere;
begin
  Result := XCondition(AOperator, GetCompareFieldsString(ACompOp, AField.FullName, AParamName));
end;

function TQStringWhereHelper.XCondition(const AOperator: TQLogicalOperator;
  const ACondition: QStringWhere): QStringWhere;
var
  LOp: string;
begin
  LOp := GetLogicalOperatorDescr(AOperator);
  if LOp<>'' then
    LOp := ' '+LOp+' ';
  Result := Self+LOp+'('+ACondition+')';
end;

function TQStringWhereHelper.XCondition(const AOperator: TQLogicalOperator;
  const AComparison: TQFieldsComparison): QStringWhere;
begin
  Result := XCondition(AOperator, GetCompareFieldsString(AComparison.CompOp, AComparison.Field1.FullName, AComparison.Field2.FullName));
end;

function TQStringWhereHelper.XCondition(const AOperator: TQLogicalOperator;
  const AComparison: TQFieldValueComparison): QStringWhere;
begin
  Result := XCondition(AOperator, GetCompareValueString(AComparison.CompOp, AComparison.Field.FullName, AComparison.Value, AComparison.IsKey));
end;

{ TQStringCaseHelper }

function TQStringCaseHelper.CaseBegin(AField: TQFieldDef): QStringCase;
begin
  Result := XCase(AField.FullName);
end;

function TQStringCaseHelper.CaseBegin: QStringCase;
begin
  Result := XCase('');
end;

function TQStringCaseHelper.CaseEnd: QStringCase;
begin
  Result := XCaseEnd('');
end;

function TQStringCaseHelper.CaseEnd(const AFieldAlias: string): QStringCase;
begin
  Result := XCaseEnd(AFieldAlias);
end;

function TQStringCaseHelper.ElseVal(const AField: TQFieldDef): QStringCase;
begin
  Result := XElseVal(AField.FullName);
end;

function TQStringCaseHelper.ElseVal(const AConstantValue: Variant): QStringCase;
begin
  Result := XElseVal(QuoteSQLValue(AConstantValue));
end;

function TQStringCaseHelper.ThenVal(const AField: TQFieldDef): QStringCase;
begin
  Result := XThenVal(AField.FullName);
end;

function TQStringCaseHelper.ToFieldDef(const AFieldAlias: string): TQFieldDef;
begin
  Result.FieldName := Self;
  Result.FieldAlias := AFieldAlias;
  Result.DataType := ftUnknown;
  Result.RefTable := Result.RefTable.Empty;
  Result.AggregationFunction := aftNone;
end;

function TQStringCaseHelper.ThenVal(const AConstantValue: Variant): QStringCase;
begin
  Result := XThenVal(QuoteSQLValue(AConstantValue));
end;

function TQStringCaseHelper.When(const AConstantValue: Variant): QStringCase;
begin
  Result := XWhen(QuoteSQLValue(AConstantValue));
end;

function TQStringCaseHelper.When(const AComparison: TQFieldValueComparison): QStringCase;
begin
  Result := XWhen(GetCompareValueString(AComparison.CompOp, AComparison.Field.FullName, AComparison.Value, AComparison.IsKey));
end;

function TQStringCaseHelper.When(const AComparison: TQFieldsComparison): QStringCase;
begin
  Result := XWhen(GetCompareFieldsString(AComparison.CompOp, AComparison.Field1.FullName, AComparison.Field2.FullName));
end;

function TQStringCaseHelper.XWhen(const ACondition: QStringCase): QStringCase;
begin
  Result := Self + #13#10 +'WHEN '+ACondition;
end;

function TQStringCaseHelper.XCase(const AFieldName: string): QStringCase;
begin
  Result := 'CASE '+AFieldName;
end;

function TQStringCaseHelper.XCaseEnd(AFieldAlias: string): QStringCase;
begin
  if AFieldAlias.Trim<>'' then
    AFieldAlias := ' ['+AFieldAlias+']'
  else
    AFieldAlias := '';
  Result := Self + #13#10 + 'END'+AFieldAlias;
end;

function TQStringCaseHelper.XElseVal(const AValue: string): QStringCase;
begin
  Result := Self + ' ELSE ' + AValue;
end;

function TQStringCaseHelper.XThenVal(const AValue: string): QStringCase;
begin
  Result := Self + ' THEN ' + AValue;
end;

function ASC(const AField: TQFieldDef): TQOrderByFieldDef; overload;
begin
  Result.Format(AField, fodASC);
end;

function ASC(const AIndex: Integer): TQOrderByIndexDef; overload;
begin
  Result.Format(AIndex, fodASC);
end;

function DESC(const AField: TQFieldDef): TQOrderByFieldDef; overload;
begin
  Result.Format(AField, fodDESC);
end;

function DESC(const AIndex: Integer): TQOrderByIndexDef; overload;
begin
  Result.Format(AIndex, fodDESC);
end;

function GetQTable(const AConnection: IQConnection; const ATableName, ATableAlias, ASchemaName: string;
  const AFullyQualifiedName: Boolean): IQTable;
var
  //LQry: TCSEQuery;
  LDataSet: TDataSet;
  LTableDef: TQTableDef;
  LFieldDef: TQFieldDef;
  I: Integer;
begin
  Result := nil;

  LTableDef.TableName := Format('%s', [Trim(ATableName)]);

  if ATableAlias<>'' then
    LTableDef.TableAlias := ATableAlias
  else
    LTableDef.TableAlias := LTableDef.TableName;

  if Trim(ASchemaName)<>'' then
    LTableDef.SchemaName := Format('%s', [Trim(ASchemaName)]);

  LDataSet := AConnection.OpenQuery('SET FMTONLY ON; SELECT * FROM '+LTableDef.FullName+'; SET FMTONLY OFF;');
  try
    if AFullyQualifiedName then
      LTableDef.InitialCatalogName := AConnection.InitialCatalogName
    else
      LTableDef.InitialCatalogName := '';

    if LDataSet.FieldCount>0 then
    begin
      Result := TQTable.Create;
      TQTable(Result).FTableDef := LTableDef;
      for I := 0 to LDataSet.FieldCount-1 do
      begin
        LFieldDef.FieldName := LDataSet.Fields[I].FieldName;
        LFieldDef.FieldAlias := LTableDef.TableAlias+'_'+LFieldDef.FieldName;
        LFieldDef.DataType := LDataSet.Fields[I].DataType;
        LFieldDef.RefTable := LTableDef;
        LFieldDef.AggregationFunction := aftNone;
        LFieldDef.DatetimeFunction := dftNone;
        TQTable(Result).FFields.Add(LFieldDef);
      end;
    end;
  finally
    LDataSet.Free;
  end;
end;

function GetQTable(const AConnection: IQConnection; const ATableName: string;
  const AFullyQualifiedName: Boolean): IQTable;
begin
  Result := GetQTable(AConnection, ATableName, '', '', AFullyQualifiedName);
end;

function GetQTable(const AConnection: IQConnection; const ATableName, ATableAlias: string;
  const AFullyQualifiedName: Boolean): IQTable;
begin
  Result := GetQTable(AConnection, ATableName, ATableAlias, '', AFullyQualifiedName);
end;

function CaseBegin(AField: TQFieldDef): QStringCase;
begin
  Result := '';
  Result := Result.CaseBegin(AField);
end;

function CaseBegin: QStringCase;
begin
  Result := '';
  Result := Result.CaseBegin;
end;

// Field
function Value(const AValue: Variant; const AFieldAlias: string): TQFieldDef;
begin
  Result.FieldName := QuoteSQLValue(AValue);
  Result.FieldAlias := AFieldAlias;
  Result.DataType := VarTypeToDataType(VarType(AValue));
  Result.RefTable := Result.RefTable.Empty;
  Result.AggregationFunction := aftNone;
end;

// Null values
function IsNull(ACheckField: TQFieldDef; const AReplacementValue: Variant; const AFieldAlias: string): TQFieldDef;
begin
  Result := IsNull(ACheckField, Value(AReplacementValue, ''), AFieldAlias);
end;

function IsNull(ACheckField, AReplacementField: TQFieldDef; const AFieldAlias: string): TQFieldDef;
begin
  Result := Result.Empty;
  Result.FieldName := Format('ISNULL(%s, %s)', [ACheckField.FullName, AReplacementField.FullName]);
  Result.FieldAlias := AFieldAlias;
end;

// Param name fast formatting
function QParam(const AParamName: string): string;
begin
  Result := ':'+AParamName;
end;

// Where
function Condition(const AField1: TQFieldDef; const AOperator: TQComparisonOperator; const AField2: TQFieldDef): QStringWhere; overload;
var
  LCond: TQFieldsComparison;
begin
  LCond.Format(AField1, AField2, AOperator);
  Result := '';
  Result := Result.XCondition(TQLogicalOperator(-1), LCond);
end;

function Condition(const AField: TQFieldDef; const AOperator: TQComparisonOperator; const AValue: Variant): QStringWhere; overload;
var
  LComparison: TQFieldValueComparison;
begin
  Result := '';
  if VarIsStr(AValue) and (string(AValue)<>'') and (string(AValue)[1]=':') then
    Result := Result.XCondition(TQLogicalOperator(-1), AField, AOperator, AValue)
  else
  begin
    LComparison.Format(AField, AValue, AOperator);
    Result := Result.XCondition(TQLogicalOperator(-1), LComparison);
  end;
end;

function Condition(const ACondition: QStringWhere): QStringWhere; overload;
begin
  Result := Result.XCondition(TQLogicalOperator(-1), ACondition);
end;

function FieldInSet(const AField: TQFieldDef; const AValues: array of Variant): QStringWhere;
var
  AValueList: string;
  LVal: Variant;
begin
  AValueList := '';
  for LVal in AValues do
    AValueList := AValueList + ',' + QuoteSQLValue(LVal);

  if AValueList<>'' then
  begin
    Delete(AValueList, 1, 1);
    Result := Condition(AField.FullName+' IN ('+AValueList+')');
  end
  else
    Result := '';
end;

function Exists(const ACondition: QString): QStringWhere;
begin
  Result := 'EXISTS ('+ACondition+')';
end;

function NotExists(const ACondition: QString): QStringWhere;
begin
  Result := 'NOT EXISTS ('+ACondition+')';
end;

function Between(const AField: TQFieldDef; const AStartValue, AEndValue: Variant): QStringWhere;
begin
  Result := Result.XCondition(TQLogicalOperator(-1), Format('%s BETWEEN %s AND %s', [AField.FullName, QuoteSQLValue(AStartValue), QuoteSQLValue(AEndValue)]));
end;

{ TQTable }

constructor TQTable.Create;
begin
  FFields := TList<TQFieldDef>.Create;
end;

destructor TQTable.Destroy;
begin
  if Assigned(FFields) then
    FreeAndNil(FFields);

  inherited;
end;

function TQTable.GetAvg(const AFieldName: string): TQFieldDef;
begin
  Result := GetFields(AFieldName, aftAvg);
end;

function TQTable.GetCount(const AFieldName: string): TQFieldDef;
begin
  Result := GetFields(AFieldName, aftCount);
end;

function TQTable.GetFieldByIndex(const AIndex: Integer): TQFieldDef;
begin
  Result := FFields[AIndex];
end;

function TQTable.GetFieldByName(const AFieldName: String): TQFieldDef;
begin
  Result := FieldByIndex[GetFieldIndexByName(AFieldName)];
end;

function TQTable.GetFieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TQTable.GetFieldIndexByName(const AFieldName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FieldCount-1 do
    if CompareText(FFields[I].FieldName, AFieldName)=0 then
    begin
      Result := I;
      Break;
    end;
end;

function TQTable.GetFields(const AFieldName: string;
  const AAggregation: TQAggregationFunctionType): TQFieldDef;
begin
  Result := FieldByName[AFieldName];
  Result.AggregationFunction := AAggregation;
end;

function TQTable.GetMax(const AFieldName: string): TQFieldDef;
begin
  Result := GetFields(AFieldName, aftMax);
end;

function TQTable.GetMin(const AFieldName: string): TQFieldDef;
begin
  Result := GetFields(AFieldName, aftMin);
end;

function TQTable.GetSum(const AFieldName: string): TQFieldDef;
begin
  Result := GetFields(AFieldName, aftSum);
end;

function TQTable.GetTableDef: TQTableDef;
begin
  Result := FTableDef
end;

function TQTable.InnerSelectFrom(const AArgument: TQSelectArgument;
  const AFieldNames: array of string; const ATop: TQSelectTop;
  const ATopCount: Cardinal): QString;
var
  LFieldName, LFieldList: string;
  I: Integer;
begin
  LFieldList := '';
  if Length(AFieldNames)>0 then
  begin
    for LFieldName in AFieldNames do
      LFieldList := LFieldList + ',' + LFieldName;
  end
  else
    for I := 0 to FieldCount-1 do
      LFieldList := LFieldList + ',' + FieldByIndex[i].SelectFieldName;

  if LFieldList<>'' then
  begin
    Delete(LFieldList, 1, 1);
    Result := Format('SELECT %s %s %s '+#13#10+'FROM %s ',
      [GetSelectArgumentDescr(AArgument), GetSelectTopExpressionDescr(ATop, ATopCount),
      LFieldList, FTableDef.FullName]);
  end;
end;

function TQTable.InnerSelectFrom(const AArgument: TQSelectArgument;
  const AFieldNames: array of TQFieldDef; const ATop: TQSelectTop;
  const ATopCount: Cardinal): QString;
var
  LFieldNames: array of string;
  I: Integer;
begin
  SetLength(LFieldNames, Length(AFieldNames));
  for I := 0 to Length(AFieldNames)-1 do
    LFieldNames[I] := AFieldNames[I].SelectFieldName;

  Result := InnerSelectFrom(AArgument, LFieldNames, ATop, ATopCount);
end;

function TQTable.SelectFrom: QString;
var
  LFieldNames: array of string;
begin
  SetLength(LFieldNames, 0);
  Result := SelectFrom(LFieldNames);
end;

function TQTable.SelectDistinctFrom(const AFieldNames: array of string;
  const ATop: TQSelectTop; const ATopCount: Cardinal): QString;
begin
  Result := InnerSelectFrom(saDistinct, AFieldNames, ATop, ATopCount);
end;

function TQTable.SelectDistinctFrom(const AFieldNames: array of TQFieldDef;
  const ATop: TQSelectTop; const ATopCount: Cardinal): QString;
begin
  Result := InnerSelectFrom(saDistinct, AFieldNames, ATop, ATopCount);
end;

function TQTable.SelectFrom(const AFieldNames: array of TQFieldDef;
  const ATop: TQSelectTop; const ATopCount: Cardinal): QString;
begin
  Result := InnerSelectFrom(saNone, AFieldNames, ATop, ATopCount);
end;

function TQTable.SelectFrom(const AFieldNames: array of string;
  const ATop: TQSelectTop; const ATopCount: Cardinal): QString;
begin
  Result := InnerSelectFrom(saNone, AFieldNames, ATop, ATopCount);
end;

{ TQTableManager }

procedure TQTableManager.ClearCache;
begin
  FQTableCache.Clear;
end;

constructor TQTableManager.Create(const AConnection: IQConnection);
begin
  if not AConnection.Connected then
    raise Exception.Create('Connection must be active');
  FConnection := AConnection;

  FQTableCache := TList<IQTable>.Create;
end;

destructor TQTableManager.Destroy;
begin
  ClearCache;
  FQTableCache.Free;

  inherited;
end;

function TQTableManager.GetConnection: IQConnection;
begin
  Result := FConnection;
end;

function TQTableManager.GetTable(const ATableName, ATableAlias, ASchemaName: string): IQTable;
var
  LTable: IQTable;
begin
  Result := nil;
  for LTable in FQTableCache do
  begin
    if (CompareText(LTable.TableDef.TableName, ATableName)=0) and
      (CompareText(LTable.TableDef.TableAlias, ATableAlias)=0) and
      (CompareText(LTable.TableDef.SchemaName, ASchemaName)=0) then
    begin
      Result := LTable;
      Break;
    end;
  end;

  if not Assigned(Result) then
  begin
    Result := GetQTable(FConnection, ATableName, ATableAlias, ASchemaName, UseFullyQualifiedNames);
    FQtableCache.Add(Result);
  end;
end;

procedure TQTableManager.SetUseFullyQualifiedNames(const Value: Boolean);
begin
  FUseFullyQualifiedNames := Value;
end;

end.