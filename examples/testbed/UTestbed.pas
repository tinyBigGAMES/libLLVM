{===============================================================================
      _ _ _    _    _ __   ____  __ ™
     | (_) |__| |  | |\ \ / /  \/  |
     | | | '_ \ |__| |_\ V /| |\/| |
     |_|_|_.__/____|____\_/ |_|  |_|
  LLVM Compiler Infrastructure for Delphi

 Copyright © 2025-present tinyBigGAMES™ LLC
 All Rights Reserved.

 https://github.com/tinyBigGAMES/libLLVM
===============================================================================}

unit UTestbed;

interface

procedure RunTests();

implementation

uses
  System.SysUtils,
  System.IOUtils,
  libLLVM,
  libLLVM.Utils,
  libLLVM.MetaLang,
  libLLVM.Test.CodeGen,
  libLLVM.Test.Variable,
  libLLVM.Test.Values,
  libLLVM.Test.Types,
  libLLVM.Test.TypeConversion,
  libLLVM.Test.Module,
  libLLVM.Test.Memory,
  libLLVM.Test.JIT,
  libLLVM.Test.Functions,
  libLLVM.Test.FunctionCall,
  libLLVM.Test.ControlFlow,
  libLLVM.Test.Comparison,
  libLLVM.Test.Bitwise,
  libLLVM.Test.BasicBlock,
  libLLVM.Test.Arithmetic,
  libLLVM.Test.ObjectCompilation,
  libLLVM.Test.MetaLang;

// Test add_two_numbers DLL created by Test #17, make sure you run it first
{$WARN SYMBOL_PLATFORM OFF}
function add_two_numbers(a, b: int32): int32; cdecl; external 'simple_math.dll' delayed;
{$WARN SYMBOL_PLATFORM ON}
procedure test_add_two_numbers_dll();
begin
  if not TFile.Exists('simple_math.dll') then
  begin
    raise Exception.Create('You must run Test #17 first');
  end;

  TLLUtils.PrintLn('10 + 10 = %d', [add_two_numbers(10, 10)]);
end;

procedure RunTests();
var
  LNum: UInt32;
begin
  try
    TLLUtils.PrintLn('=== libLLVM v%s ===', [TLLVM.GetVersionStr()]);
    TLLUtils.PrintLn('Running LLVM v%s', [TLLVM.GetLLVMVersionStr()]);
    TLLUtils.PrintLn();

    LNum := 17;

    case LNum of
      01: TTestArithmetic.RunAllTests();
      02: TTestBasicBlock.RunAllTests();
      03: TTestBitwise.RunAllTests();
      04: TTestComparison.RunAllTests();
      05: TTestControlFlow.RunAllTests();
      06: TTestFunctionCall.RunAllTests();
      07: TTestFunction.RunAllTests();
      08: TTestJIT.RunAllTests();
      09: TTestMemory.RunAllTests();
      10: TTestModule.RunAllTests();
      11: TTestTypeConversion.RunAllTests();
      12: TTestTypes.RunAllTests();
      13: TTestValues.RunAllTests();
      14: TTestVariable.RunAllTests();
      15: TTestCodeGen.RunAllTests();
      16: TTestObjectCompilation.RunAllTests();
      17: TTestMetaLang.RunAllTests();
      18: test_add_two_numbers_dll();

    else
      TLLUtils.Print('Invalid test number.');
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  TLLUtils.Pause();
end;

end.
