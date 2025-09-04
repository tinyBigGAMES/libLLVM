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

program Testbed;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UTestbed in 'UTestbed.pas',
  Dlluminator in '..\..\src\Dlluminator.pas',
  libLLVM in '..\..\src\libLLVM.pas',
  libLLVM.API in '..\..\src\libLLVM.API.pas',
  libLLVM.Utils in '..\..\src\libLLVM.Utils.pas',
  libLLVM.Test.Arithmetic in '..\..\src\tests\libLLVM.Test.Arithmetic.pas',
  libLLVM.Test.BasicBlock in '..\..\src\tests\libLLVM.Test.BasicBlock.pas',
  libLLVM.Test.Bitwise in '..\..\src\tests\libLLVM.Test.Bitwise.pas',
  libLLVM.Test.Comparison in '..\..\src\tests\libLLVM.Test.Comparison.pas',
  libLLVM.Test.ControlFlow in '..\..\src\tests\libLLVM.Test.ControlFlow.pas',
  libLLVM.Test.FunctionCall in '..\..\src\tests\libLLVM.Test.FunctionCall.pas',
  libLLVM.Test.Functions in '..\..\src\tests\libLLVM.Test.Functions.pas',
  libLLVM.Test.JIT in '..\..\src\tests\libLLVM.Test.JIT.pas',
  libLLVM.Test.Memory in '..\..\src\tests\libLLVM.Test.Memory.pas',
  libLLVM.Test.Module in '..\..\src\tests\libLLVM.Test.Module.pas',
  libLLVM.Test.TypeConversion in '..\..\src\tests\libLLVM.Test.TypeConversion.pas',
  libLLVM.Test.Types in '..\..\src\tests\libLLVM.Test.Types.pas',
  libLLVM.Test.Values in '..\..\src\tests\libLLVM.Test.Values.pas',
  libLLVM.Test.Variable in '..\..\src\tests\libLLVM.Test.Variable.pas',
  libLLVM.Test.CodeGen in '..\..\src\tests\libLLVM.Test.CodeGen.pas',
  libLLVM.LLD in '..\..\src\libLLVM.LLD.pas',
  libLLVM.Test.ObjectCompilation in '..\..\src\tests\libLLVM.Test.ObjectCompilation.pas';

begin
  RunTests();
end.
