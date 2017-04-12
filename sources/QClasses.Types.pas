unit QClasses.Types;

interface

uses
  System.SysUtils, Data.DB;

const
  Q_DEFAULT_SCHEMA = 'dbo';

type
  TQJoinType = (qjtInner, qjtLeftOuter, qjtRightOuter);
  TQFieldOrderDirection = (fodNone, fodASC, fodDESC);
  TQSelectArgument = (saNone, saAll, saDistinct);
  TQSelectTopExpression = (steTop, stePercent, steWithTies);
  TQSelectTop = set of TQSelectTopExpression;
  TQLogicalOperator = (loAND, loOR, loIN);

  TQAggregationFunctionType = (
    aftNone,
    aftCount,
    aftSum,
    aftMax,
    aftMin,
    aftAvg
  );

  TQComparisonOperator = (
    copNone,
    copEquals,               // Tests for two values being equal.
    copNotEquals,            // Tests for two values being not equal.
    copLessThan,             //	Tests for the value being less than the comparison value.
    copLessThanOrEqualTo,    // Tests for the value being less than or equal to the comparison value.
    copGreaterThan,          // Tests for the value being greater than the comparison value.
    copGreaterThanOrEqualTo, // Tests for the value being greater than or equal to the comparison value.
    copStartsWith,           // Tests to see if the value starts with the comparison value.
    copEndsWith,             // Tests to see if the value ends with the comparison value.
    copContains,             // Tests to see if the value contains the comparison value.
    copLike,                 // Will do a wild-card comparison of the value to the comparison value where the comparison value is the wild card string.
    copMatch,                // Will do a regular expression comparison of the value to the comparison value where the comparison value is the regular expression string.
    copDoesNotStartWith,     // Complement of StartsWith.
    copDoesNotEndWith,       // Complement of EndsWith.
    copDoesNotContain,       // Complement of Contains.
    copNotLike,              // Complement of Like.
    copDoesNotMatch,         // Complement of Match.
    copTop,                  // Tests to see if the value is in the top 'X' values where 'X' is specified in the operand.
    copTopPercentile,        // Tests to see if the value is in the top 'X' percentile of values where 'X' is specified in the operand.
    copBottom,               // Tests to see if the value is in the bottom 'X' values where 'X' is specified in the operand.
    copBottomPercentile      // Tests to see if the value is in the bottom 'X' percentile of values where 'X' is specified in the operand.
  );


  QString = type string;
  QStringCondition = type string;
  QStringWhere = type string;
  QStringCase = type string;

  TQTableDef = record
    TableName: string;
    TableAlias: string;
    SchemaName: string;
    InitialCatalogName: string;
    function Empty: TQTableDef;
    function FullName: string;
  end;
  PQTableDef = ^TQTableDef;

  TQFieldDef = record
    FieldName: string;
    FieldAlias: string;
    DataType: TFieldType;
    RefTable: TQTableDef;
    AggregationFunction: TQAggregationFunctionType;
    class operator Add(a, b: TQFieldDef): TQFieldDef;      // Addition of two operands
    class operator Subtract(a, b: TQFieldDef): TQFieldDef; // Subtraction
    function Empty: TQFieldDef;
    function FullName: string;
    function SelectFieldName: string;
    function AsAlias(const AFieldAlias: string): TQFieldDef;
  end;

  TQFieldsComparison = record
    Field1: TQFieldDef;
    Field2: TQFieldDef;
    CompOp: TQComparisonOperator;
    procedure Format(const AField1, AField2: TQFieldDef; const ACompOp: TQComparisonOperator);
  end;

  TQFieldValueComparison = record
    Field: TQFieldDef;
    Value: Variant;
    CompOp: TQComparisonOperator;
    IsKey: Boolean;
    procedure Format(const AField: TQFieldDef; const AValue: Variant;
      const ACompOp: TQComparisonOperator; const AIsKey: Boolean=False);
  end;

  TQOrderByFieldDef = record
    FieldDef: TQFieldDef;
    OrderDirection: TQFieldOrderDirection;
    procedure Format(const AFieldDef: TQFieldDef; const AOrderDirection: TQFieldOrderDirection);
  end;

  TQOrderByIndexDef = record
    Index: Integer;
    OrderDirection: TQFieldOrderDirection;
    procedure Format(const AIndex: Integer; const AOrderDirection: TQFieldOrderDirection);
  end;

implementation

uses
  QClasses.Utils;

{ TQFieldDef }

class operator TQFieldDef.Add(a, b: TQFieldDef): TQFieldDef;
begin
  if a.DataType = b.DataType then
  begin
    Result.FieldName := a.FieldName + '+' + b.FieldName;
    Result.FieldAlias := b.FieldAlias;
    Result.DataType := b.DataType;
    Result.RefTable := b.RefTable;
    Result.AggregationFunction := aftNone;
  end
  else
    raise EArgumentException.Create('Fields must be of same datatype');
end;

function TQFieldDef.AsAlias(const AFieldAlias: string): TQFieldDef;
begin
  Result := Self;
  Result.FieldAlias := AFieldAlias;
end;

function TQFieldDef.Empty: TQFieldDef;
begin
  Result.FieldName := '';
  Result.FieldAlias := '';
  Result.DataType := ftUnknown;
  Result.RefTable := Result.RefTable.Empty;
  Result.AggregationFunction := aftNone;
end;

function TQFieldDef.FullName: string;
begin
  if RefTable.TableAlias<>'' then
    Result := RefTable.TableAlias + '.'
  else
    Result := '';
  Result := Result + FieldName;
end;

function TQFieldDef.SelectFieldName: string;
var
  LFunc: string;
begin
  Result := FullName;
  LFunc := GetFieldAggregationDescr(AggregationFunction);
  if LFunc<>'' then
    Result := Format('%s(%s)', [LFunc, Result]);
  if FieldAlias<>'' then
    Result := Result + ' AS ' + FieldAlias;
end;

class operator TQFieldDef.Subtract(a, b: TQFieldDef): TQFieldDef;
begin
  if a.DataType = b.DataType then
  begin
    Result.FieldName := a.FieldName + '-' + b.FieldName;
    Result.FieldAlias := b.FieldAlias;
    Result.DataType := b.DataType;
    Result.RefTable := b.RefTable;
    Result.AggregationFunction := aftNone;
  end
  else
    raise EArgumentException.Create('Fields must be of same datatype');
end;

{ TQTableDef }

function TQTableDef.Empty: TQTableDef;
begin
  Result.TableName := '';
  Result.TableAlias := '';
  Result.SchemaName := '';
  Result.InitialCatalogName := '';
end;

function TQTableDef.FullName: string;
begin
  if InitialCatalogName.Trim<>'' then
  begin
    if SchemaName.Trim='' then
      SchemaName := Q_DEFAULT_SCHEMA;
    Result := InitialCatalogName.Trim + '.';
  end
  else
    Result := '';

  if SchemaName<>'' then
    Result := Result + SchemaName + '.';

  Result := Result + TableName;
  if TableAlias<>'' then
    Result := Result + ' AS ' + TableAlias;
end;

{ TQFieldsComparison }

procedure TQFieldsComparison.Format(const AField1, AField2: TQFieldDef;
  const ACompOp: TQComparisonOperator);
begin
  Self.Field1 := AField1;
  Self.Field2 := AField2;
  Self.CompOp := ACompOp;
end;

{ TQFieldValueComparison }

procedure TQFieldValueComparison.Format(const AField: TQFieldDef;
  const AValue: Variant; const ACompOp: TQComparisonOperator;
  const AIsKey: Boolean);
begin
  Self.Field := AField;
  Self.Value := AValue;
  Self.CompOp := ACompOp;
  Self.IsKey := AIsKey;
end;

{ TQOrderByFieldDef }

procedure TQOrderByFieldDef.Format(const AFieldDef: TQFieldDef; const AOrderDirection: TQFieldOrderDirection);
begin
  Self.FieldDef := AFieldDef;
  Self.OrderDirection := AOrderDirection;
end;

{ TQOrderByIndexDef }

procedure TQOrderByIndexDef.Format(const AIndex: Integer;
  const AOrderDirection: TQFieldOrderDirection);
begin
  Self.Index := AIndex;
  Self.OrderDirection := AOrderDirection;
end;

end.
