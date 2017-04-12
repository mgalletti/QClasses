program QClassesTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  QClasses in '..\sources\QClasses.pas',
  QClasses.Tests in 'QClasses.Tests.pas',
  QClasses.Interfaces in '..\sources\QClasses.Interfaces.pas',
  QClasses.Types in '..\sources\QClasses.Types.pas',
  QClasses.Utils in '..\sources\QClasses.Utils.pas',
  QClasses.Adapters in '..\sources\QClasses.Adapters.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;

end.

