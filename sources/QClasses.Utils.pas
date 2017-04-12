unit QClasses.Utils;

interface

uses
  System.SysUtils, System.Variants, QClasses.Types;

function QuoteSQLValue(const AValue: Variant): string;
function QuoteSQLKey(const AValue: Integer): string;
function QuoteSQLStr(const AValue: string): string;
function GetCompareValueString(const AOperator: TQComparisonOperator; const AFieldName: string; AValue: Variant;
  const AIsKey: Boolean=False; const ANegate: Boolean=False): string;
function GetCompareFieldsString(const AOperator: TQComparisonOperator; const AFieldName1, AFieldName2: string;
  const ANegate: Boolean=False): string;

function GetFieldOrderQString(const AValue: TQFieldOrderDirection): QString;
function GetFieldAggregationDescr(const AValue: TQAggregationFunctionType): QString;
function GetFieldDatetimeFunctionDescr(const AValue: TQDatetimeFunctionType): QString;
function GetLogicalOperatorDescr(const AValue: TQLogicalOperator): string;
function GetSelectArgumentDescr(const AValue: TQSelectArgument): string;
function GetSelectTopExpressionDescr(const ATopSet: TQSelectTop; const ACount: Cardinal): string;

implementation

const
  SQL_NULL = 'NULL';

function QuoteSQLValue(const AValue: Variant): string;
begin
  if VarIsEmpty(AValue) or VarIsNull(AValue) then
    Result := SQL_NULL
  else if VarIsStr(AValue) then
    Result := QuoteSQLStr(VarToStr(AValue))
  else if VarIsFloat(AValue) then
    Result := FloatToStr(AValue)
  else if VarIsType(AValue, varDate) then
    Result := QuoteSQLStr(FormatDatetime('yyyymmdd hh:nn:ss', VarToDateTime(AValue)))
  else
    Result := VarToStr(AValue);
end;

function QuoteSQLStr(const AValue: string): string;
begin
  if AValue.Trim.IsEmpty then
    Result := SQL_NULL
  else
    Result := 'N'+QuotedStr(AValue.Trim);
end;

function QuoteSQLKey(const AValue: Integer): string;
begin
  if AValue < 1 then
    Result := SQL_NULL
  else
    Result := QuoteSQLValue(AValue);
  Result := 'N'+Result;
end;

function GetCompareValueString(const AOperator: TQComparisonOperator; const AFieldName: string;
  AValue: Variant; const AIsKey: Boolean; const ANegate: Boolean): string;
var
  LValue: string;
begin
  if AIsKey then
    LValue := QuoteSQLKey(AValue)
  else
  begin
    if VarIsStr(AValue) then
    begin
      case AOperator of
        copStartsWith: AValue := AValue + '%';
        copEndsWith: AValue := '%' + AValue;
        copContains: AValue := '%' + AValue + '%';
      end;
    end;
    LValue := QuoteSQLValue(AValue);
  end;

  Result := GetCompareFieldsString(AOperator, AFieldName, LValue, ANegate);
end;

function GetCompareFieldsString(const AOperator: TQComparisonOperator; const AFieldName1, AFieldName2: string;
  const ANegate: Boolean): string;
var
  LVarCond: string;
begin
  if (Trim(AFieldName1)='') or (Trim(AFieldName2)='') then
    raise Exception.Create('FieldNames cannot be empty');

  Result := '';
  LVarCond := '';
  case AOperator of
    copEquals: LVarCond := '='+AFieldName2;
    copNotEquals: LVarCond := '<>'+AFieldName2;
    copLessThan: LVarCond := '<'+AFieldName2;
    copLessThanOrEqualTo: LVarCond := '<='+AFieldName2;
    copGreaterThan: LVarCond := '>'+AFieldName2;
    copGreaterThanOrEqualTo: LVarCond := '>='+AFieldName2;
    copStartsWith,
    copEndsWith,
    copContains,
    copLike: LVarCond := ' LIKE '+AFieldName2;
    copDoesNotStartWith: Result := GetCompareFieldsString(copStartsWith, AFieldName1, AFieldName2, True);
    copDoesNotEndWith: Result := GetCompareFieldsString(copEndsWith, AFieldName1, AFieldName2, True);
    copDoesNotContain: Result := GetCompareFieldsString(copContains, AFieldName1, AFieldName2, True);
    copNotLike: Result := GetCompareFieldsString(copLike, AFieldName1, AFieldName2, True);
    copDoesNotMatch: Result := GetCompareFieldsString(copMatch, AFieldName1, AFieldName2, True);
  end;

  if LVarCond <> '' then
  begin
    Result := AFieldName1 + LVarCond;
    if ANegate then
      Result := 'NOT ('+Result+')';
  end;
end;


function GetFieldOrderQString(const AValue: TQFieldOrderDirection): QString;
begin
  case AValue of
    fodNone: Result := '';
    fodASC: Result := 'ASC';
    fodDESC: Result := 'DESC';
  end;
end;

function GetFieldAggregationDescr(const AValue: TQAggregationFunctionType): QString;
begin
  case AValue of
    aftCount: Result := 'COUNT';
    aftSum: Result := 'SUM';
    aftMax: Result := 'MAX';
    aftMin: Result := 'MIN';
    aftAvg: Result := 'AVG';
    else Result := '';
  end;
end;

function GetFieldDatetimeFunctionDescr(const AValue: TQDatetimeFunctionType): QString;
begin
  case AValue of
    dftYear: Result := 'YEAR';
    dftMonth: Result := 'MONTH';
    dftDay: Result := 'DAY';
    else result := '';
  end;
end;

function GetLogicalOperatorDescr(const AValue: TQLogicalOperator): string;
begin
  case AValue of
    loAND: Result := 'AND';
    loOR: Result := 'OR';
    loIN: Result := 'IN';
    else Result := '';
  end;
end;

function GetSelectArgumentDescr(const AValue: TQSelectArgument): string;
begin
  case AValue of
    saAll: Result := 'ALL';
    saDistinct: Result := 'DISTINCT';
    else Result := '';
  end;
end;

function GetSelectTopExpressionDescr(const ATopSet: TQSelectTop; const ACount: Cardinal): string;
begin
  Result := '';
  if steTop in ATopSet then
  begin
    Result := 'TOP (%d)';
    if stePercent in ATopSet then
      Result := Result +' PERCENT';
    if steWithTies in ATopSet then
      Result := Result +' WITH TIES';
  end;
  if Result<>'' then
    Result := Format(Result, [ACount]);
end;


end.
