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
  libLLVM,
  libLLVM.Utils,
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
  libLLVM.Test.Arithmetic;

procedure RunTests();
var
  LNum: UInt32;
begin
  try
    TLLUtils.PrintLn('=== libLLVM v%s ===', [TLLVM.GetVersionStr()]);
    TLLUtils.PrintLn('Running LLVM v%s', [TLLVM.GetLLVMVersionStr()]);
    TLLUtils.PrintLn();

    LNum := 15;

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
