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

unit libLLVM.Test.Comparison;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestComparison }
  TTestComparison = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for comparison operations functionality
    class procedure TestIntegerComparisons(); static;
    class procedure TestFloatingPointComparisons(); static;
    class procedure TestEqualityComparisons(); static;
    class procedure TestOrderingComparisons(); static;
    class procedure TestComparisonNaming(); static;
  end;

implementation

{ TTestComparison }

class procedure TTestComparison.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.Comparison...');
  
  TestIntegerComparisons();
  TestFloatingPointComparisons();
  TestEqualityComparisons();
  TestOrderingComparisons();
  TestComparisonNaming();
  
  TLLUtils.PrintLn('libLLVM.Test.Comparison completed.');
end;

class procedure TTestComparison.TestIntegerComparisons();
var
  LParse: TLLVM;
  LModuleId: string;
  LResult: TLLValue;
  LActualResult: Boolean;
begin
  TLLUtils.PrintLn('  Testing integer comparisons...');
  
  LParse := TLLVM.Create();
  try
    LModuleId := 'test_int_comparisons';
    LParse.CreateModule(LModuleId);
    
    // Test IsEqual with equal values (10 == 10) -> should return true
    LParse.BeginFunction(LModuleId, 'test_equal', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsEqual(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 10), 'eq_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsEqual with different values (10 == 5) -> should return false
    LParse.BeginFunction(LModuleId, 'test_not_equal_vals', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsEqual(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 5), 'eq_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsNotEqual with different values (10 != 5) -> should return true
    LParse.BeginFunction(LModuleId, 'test_not_equal', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsNotEqual(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 5), 'ne_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsNotEqual with equal values (10 != 10) -> should return false
    LParse.BeginFunction(LModuleId, 'test_not_equal_same', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsNotEqual(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 10), 'ne_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsLess (5 < 10) -> should return true
    LParse.BeginFunction(LModuleId, 'test_less_true', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsLess(LModuleId, LParse.IntegerValue(LModuleId, 5), LParse.IntegerValue(LModuleId, 10), 'lt_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsLess (10 < 5) -> should return false
    LParse.BeginFunction(LModuleId, 'test_less_false', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsLess(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 5), 'lt_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsLessEqual (5 <= 10) -> should return true
    LParse.BeginFunction(LModuleId, 'test_less_equal_true', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsLessEqual(LModuleId, LParse.IntegerValue(LModuleId, 5), LParse.IntegerValue(LModuleId, 10), 'le_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsLessEqual (10 <= 10) -> should return true
    LParse.BeginFunction(LModuleId, 'test_less_equal_same', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsLessEqual(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 10), 'le_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsLessEqual (15 <= 10) -> should return false
    LParse.BeginFunction(LModuleId, 'test_less_equal_false', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsLessEqual(LModuleId, LParse.IntegerValue(LModuleId, 15), LParse.IntegerValue(LModuleId, 10), 'le_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsGreater (10 > 5) -> should return true
    LParse.BeginFunction(LModuleId, 'test_greater_true', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsGreater(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 5), 'gt_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsGreater (5 > 10) -> should return false
    LParse.BeginFunction(LModuleId, 'test_greater_false', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsGreater(LModuleId, LParse.IntegerValue(LModuleId, 5), LParse.IntegerValue(LModuleId, 10), 'gt_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsGreaterEqual (10 >= 5) -> should return true
    LParse.BeginFunction(LModuleId, 'test_greater_equal_true', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsGreaterEqual(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 5), 'ge_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsGreaterEqual (10 >= 10) -> should return true
    LParse.BeginFunction(LModuleId, 'test_greater_equal_same', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsGreaterEqual(LModuleId, LParse.IntegerValue(LModuleId, 10), LParse.IntegerValue(LModuleId, 10), 'ge_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test IsGreaterEqual (5 >= 10) -> should return false
    LParse.BeginFunction(LModuleId, 'test_greater_equal_false', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsGreaterEqual(LModuleId, LParse.IntegerValue(LModuleId, 5), LParse.IntegerValue(LModuleId, 10), 'ge_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test with negative numbers: (-5 < 0) -> should return true
    LParse.BeginFunction(LModuleId, 'test_negative_less', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsLess(LModuleId, LParse.IntegerValue(LModuleId, -5), LParse.IntegerValue(LModuleId, 0), 'lt_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test with negative numbers: (-10 > -20) -> should return true
    LParse.BeginFunction(LModuleId, 'test_negative_greater', dtInt1, []);
    LParse.BeginBlock(LModuleId, 'entry');
    LResult := LParse.IsGreater(LModuleId, LParse.IntegerValue(LModuleId, -10), LParse.IntegerValue(LModuleId, -20), 'gt_result');
    LParse.ReturnValue(LModuleId, LResult);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Validate and prepare for JIT execution
    if not LParse.ValidateModule(LModuleId) then
    begin
      TLLUtils.PrintLn('    ERROR: Module validation failed');
      Exit;
    end;
    
    // Execute all test functions and verify results
    TLLUtils.Print('    IsEqual(10, 10): ');
    LActualResult := LParse.ExecuteFunction(LModuleId, 'test_equal', []).AsType<Byte>.ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsEqual(10, 5): ');
    if not LParse.ExecuteFunction(LModuleId, 'test_not_equal_vals', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    IsNotEqual(10, 5): ');
    if LParse.ExecuteFunction(LModuleId, 'test_not_equal', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsNotEqual(10, 10): ');
    if not LParse.ExecuteFunction(LModuleId, 'test_not_equal_same', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    IsLess(5, 10): ');
    if LParse.ExecuteFunction(LModuleId, 'test_less_true', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsLess(10, 5): ');
    if  not LParse.ExecuteFunction(LModuleId, 'test_less_false', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    IsLessEqual(5, 10): ');
    if LParse.ExecuteFunction(LModuleId, 'test_less_equal_true', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsLessEqual(10, 10): ');
    if LParse.ExecuteFunction(LModuleId, 'test_less_equal_same', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsLessEqual(15, 10): ');
    if not LParse.ExecuteFunction(LModuleId, 'test_less_equal_false', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    IsGreater(10, 5): ');
    if  LParse.ExecuteFunction(LModuleId, 'test_greater_true', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsGreater(5, 10): ');
    if not LParse.ExecuteFunction(LModuleId, 'test_greater_false', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    IsGreaterEqual(10, 5): ');
    if LParse.ExecuteFunction(LModuleId, 'test_greater_equal_true', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsGreaterEqual(10, 10): ');
    if LParse.ExecuteFunction(LModuleId, 'test_greater_equal_same', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsGreaterEqual(5, 10): ');
    if not LParse.ExecuteFunction(LModuleId, 'test_greater_equal_false', []).AsType<Int32>.ToBoolean() then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    IsLess(-5, 0): ');
    if LParse.ExecuteFunction(LModuleId, 'test_negative_less', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    IsGreater(-10, -20): ');
    if LParse.ExecuteFunction(LModuleId, 'test_negative_greater', []).AsType<Byte>.ToBoolean() then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    // Clean up
    LParse.DeleteModule(LModuleId);
    
  finally
    LParse.Free();
  end;
  
  TLLUtils.PrintLn('  Integer comparison tests completed.');
end;

class procedure TTestComparison.TestFloatingPointComparisons();
var
  LModuleId: string;
  LResult: TLLValue;
  LActualResult: Boolean;
begin
  TLLUtils.PrintLn('  Testing floating point comparisons...');
  
  with TLLVM.Create() do
  begin
    LModuleId := 'test_float_comparisons';
    CreateModule(LModuleId);

    // Test FIsEqual with equal values (5.0 == 5.0) -> should return true
    BeginFunction(LModuleId, 'test_equal', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsEqual(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 5.0), 'feq_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsEqual with different values (5.0 == 3.5) -> should return false
    BeginFunction(LModuleId, 'test_not_equal_vals', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsEqual(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 3.5), 'feq_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsNotEqual with different values (5.0 != 3.5) -> should return true
    BeginFunction(LModuleId, 'test_not_equal', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsNotEqual(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 3.5), 'fne_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsNotEqual with equal values (5.0 != 5.0) -> should return false
    BeginFunction(LModuleId, 'test_not_equal_same', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsNotEqual(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 5.0), 'fne_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsLess (3.5 < 5.0) -> should return true
    BeginFunction(LModuleId, 'test_less_true', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLess(LModuleId, FloatValue(LModuleId, 3.5), FloatValue(LModuleId, 5.0), 'flt_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsLess (5.0 < 3.5) -> should return false
    BeginFunction(LModuleId, 'test_less_false', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLess(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 3.5), 'flt_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsLessEqual (3.5 <= 5.0) -> should return true
    BeginFunction(LModuleId, 'test_less_equal_true', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLessEqual(LModuleId, FloatValue(LModuleId, 3.5), FloatValue(LModuleId, 5.0), 'fle_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsLessEqual (5.0 <= 5.0) -> should return true
    BeginFunction(LModuleId, 'test_less_equal_same', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLessEqual(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 5.0), 'fle_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsLessEqual (6.5 <= 5.0) -> should return false
    BeginFunction(LModuleId, 'test_less_equal_false', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLessEqual(LModuleId, FloatValue(LModuleId, 6.5), FloatValue(LModuleId, 5.0), 'fle_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsGreater (5.0 > 3.5) -> should return true
    BeginFunction(LModuleId, 'test_greater_true', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreater(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 3.5), 'fgt_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsGreater (3.5 > 5.0) -> should return false
    BeginFunction(LModuleId, 'test_greater_false', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreater(LModuleId, FloatValue(LModuleId, 3.5), FloatValue(LModuleId, 5.0), 'fgt_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsGreaterEqual (5.0 >= 3.5) -> should return true
    BeginFunction(LModuleId, 'test_greater_equal_true', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreaterEqual(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 3.5), 'fge_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsGreaterEqual (5.0 >= 5.0) -> should return true
    BeginFunction(LModuleId, 'test_greater_equal_same', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreaterEqual(LModuleId, FloatValue(LModuleId, 5.0), FloatValue(LModuleId, 5.0), 'fge_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test FIsGreaterEqual (3.5 >= 5.0) -> should return false
    BeginFunction(LModuleId, 'test_greater_equal_false', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreaterEqual(LModuleId, FloatValue(LModuleId, 3.5), FloatValue(LModuleId, 5.0), 'fge_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test with negative numbers: (-2.5 < 0.0) -> should return true
    BeginFunction(LModuleId, 'test_negative_less', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLess(LModuleId, FloatValue(LModuleId, -2.5), FloatValue(LModuleId, 0.0), 'flt_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test with negative numbers: (-1.5 > -3.5) -> should return true
    BeginFunction(LModuleId, 'test_negative_greater', dtInt1, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreater(LModuleId, FloatValue(LModuleId, -1.5), FloatValue(LModuleId, -3.5), 'fgt_result');
    ReturnValue(LModuleId, LResult);
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Validate and prepare for JIT execution
    if not ValidateModule(LModuleId) then
    begin
      TLLUtils.PrintLn('    ERROR: Module validation failed');
      Exit;
    end;
    
    // Execute all test functions and verify results
    TLLUtils.Print('    FIsEqual(5.0, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_equal', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    FIsEqual(5.0, 3.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_not_equal_vals', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if not LActualResult then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    FIsNotEqual(5.0, 3.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_not_equal', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    FIsNotEqual(5.0, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_not_equal_same', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if not LActualResult then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    FIsLess(3.5, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_less_true', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    FIsLess(5.0, 3.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_less_false', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if not LActualResult then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    FIsLessEqual(3.5, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_less_equal_true', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    FIsLessEqual(5.0, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_less_equal_same', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    FIsLessEqual(6.5, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_less_equal_false', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if not LActualResult then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    FIsGreater(5.0, 3.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_greater_true', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    FIsGreater(3.5, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_greater_false', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if not LActualResult then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');
    
    TLLUtils.Print('    FIsGreaterEqual(5.0, 3.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_greater_equal_true', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    FIsGreaterEqual(5.0, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_greater_equal_same', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');
    
    TLLUtils.Print('    FIsGreaterEqual(3.5, 5.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_greater_equal_false', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if not LActualResult then
      TLLUtils.PrintLn('PASS (false)')
    else
      TLLUtils.PrintLn('FAIL (Expected: false, Got: true)');

    TLLUtils.Print('    FIsLess(-2.5, 0.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_negative_less', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');

    TLLUtils.Print('    FIsGreater(-1.5, -3.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_negative_greater', []);
    LActualResult := LResult.AsType<Byte>().ToBoolean();
    if LActualResult then
      TLLUtils.PrintLn('PASS (true)')
    else
      TLLUtils.PrintLn('FAIL (Expected: true, Got: false)');
    
    // Clean up
    DeleteModule(LModuleId);
  end;
  
  TLLUtils.PrintLn('  Floating point comparison tests completed.');
end;

class procedure TTestComparison.TestEqualityComparisons();
var
  LModuleId: string;
  LResult: TLLValue;
  LActualResult: Boolean;
begin
  TLLUtils.PrintLn('  Testing equality comparisons (integer vs float)...');
  
  with TLLVM.Create() do
  begin
    LModuleId := 'test_equality_comparisons';
    CreateModule(LModuleId);

    // Test integer equality: IsEqual(10, 10) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_int_equal', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsEqual(LModuleId, IntegerValue(LModuleId, 10), IntegerValue(LModuleId, 10), 'int_eq_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float equality: FIsEqual(10.0, 10.0) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_float_equal', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsEqual(LModuleId, FloatValue(LModuleId, 10.0), FloatValue(LModuleId, 10.0), 'float_eq_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test integer inequality: IsNotEqual(10, 5) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_int_not_equal', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsNotEqual(LModuleId, IntegerValue(LModuleId, 10), IntegerValue(LModuleId, 5), 'int_ne_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float inequality: FIsNotEqual(10.0, 5.5) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_float_not_equal', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsNotEqual(LModuleId, FloatValue(LModuleId, 10.0), FloatValue(LModuleId, 5.5), 'float_ne_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test integer equality false case: IsEqual(10, 5) -> should return 0 (false)
    BeginFunction(LModuleId, 'test_int_equal_false', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsEqual(LModuleId, IntegerValue(LModuleId, 10), IntegerValue(LModuleId, 5), 'int_eq_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float equality false case: FIsEqual(10.0, 5.5) -> should return 0 (false)
    BeginFunction(LModuleId, 'test_float_equal_false', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsEqual(LModuleId, FloatValue(LModuleId, 10.0), FloatValue(LModuleId, 5.5), 'float_eq_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test integer inequality false case: IsNotEqual(10, 10) -> should return 0 (false)
    BeginFunction(LModuleId, 'test_int_not_equal_false', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsNotEqual(LModuleId, IntegerValue(LModuleId, 10), IntegerValue(LModuleId, 10), 'int_ne_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float inequality false case: FIsNotEqual(10.0, 10.0) -> should return 0 (false)
    BeginFunction(LModuleId, 'test_float_not_equal_false', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsNotEqual(LModuleId, FloatValue(LModuleId, 10.0), FloatValue(LModuleId, 10.0), 'float_ne_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Validate and prepare for JIT execution
    if not ValidateModule(LModuleId) then
    begin
      TLLUtils.PrintLn('    ERROR: Module validation failed');
      Exit;
    end;
    
    // Execute all test functions and verify results
    TLLUtils.Print('    IsEqual(10, 10): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_equal', []);
    LActualResult := LResult.AsType<Int32>().ToBoolean;
    if LActualResult then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsEqual(10.0, 10.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_equal', []);
    LActualResult := LResult.AsType<Int32>().ToBoolean;
    if LActualResult then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    IsNotEqual(10, 5): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_not_equal', []);
    LActualResult := LResult.AsType<Int32>().ToBoolean;
    if LActualResult then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsNotEqual(10.0, 5.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_not_equal', []);
    LActualResult := LResult.AsType<Int32>().ToBoolean;
    if LActualResult then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    IsEqual(10, 5): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_equal_false', []);
    LActualResult := LResult.AsType<Int32>().ToBoolean;
    if not LActualResult then
      TLLUtils.PrintLn('PASS (0)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 0, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsEqual(10.0, 5.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_equal_false', []);
    LActualResult := LResult.AsType<Int32>().ToBoolean;
    if not LActualResult then
      TLLUtils.PrintLn('PASS (0)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 0, Got: %d)', [LActualResult]);

    TLLUtils.Print('    IsNotEqual(10, 10): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_not_equal_false', []);
    LActualResult := LResult.AsType<Int32>().ToBoolean;
    if not LActualResult then
      TLLUtils.PrintLn('PASS (0)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 0, Got: %d)', [LActualResult]);
    
    TLLUtils.Print('    FIsNotEqual(10.0, 10.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_not_equal_false', []);
    LActualResult := LResult.AsType<Int32>().ToBoolean;
    if not LActualResult then
      TLLUtils.PrintLn('PASS (0)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 0, Got: %d)', [LActualResult]);
    
    // Clean up
    DeleteModule(LModuleId);
  end;
  
  TLLUtils.PrintLn('  Equality comparison tests completed.');
end;

class procedure TTestComparison.TestOrderingComparisons();
var
  LModuleId: string;
  LResult: TLLValue;
  LActualResult: Integer;
begin
  TLLUtils.PrintLn('  Testing ordering comparisons (integer vs float)...');
  
  with TLLVM.Create() do
  begin
    LModuleId := 'test_ordering_comparisons';
    CreateModule(LModuleId);
    
    // Test integer less than: IsLess(5, 10) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_int_less_true', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsLess(LModuleId, IntegerValue(LModuleId, 5), IntegerValue(LModuleId, 10), 'int_lt_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float less than: FIsLess(5.5, 10.0) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_float_less_true', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLess(LModuleId, FloatValue(LModuleId, 5.5), FloatValue(LModuleId, 10.0), 'float_lt_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test integer greater than: IsGreater(10, 5) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_int_greater_true', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsGreater(LModuleId, IntegerValue(LModuleId, 10), IntegerValue(LModuleId, 5), 'int_gt_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float greater than: FIsGreater(10.0, 5.5) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_float_greater_true', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreater(LModuleId, FloatValue(LModuleId, 10.0), FloatValue(LModuleId, 5.5), 'float_gt_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test integer less than or equal: IsLessEqual(5, 5) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_int_less_equal_true', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsLessEqual(LModuleId, IntegerValue(LModuleId, 5), IntegerValue(LModuleId, 5), 'int_le_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float less than or equal: FIsLessEqual(5.5, 5.5) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_float_less_equal_true', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLessEqual(LModuleId, FloatValue(LModuleId, 5.5), FloatValue(LModuleId, 5.5), 'float_le_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test integer greater than or equal: IsGreaterEqual(10, 10) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_int_greater_equal_true', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsGreaterEqual(LModuleId, IntegerValue(LModuleId, 10), IntegerValue(LModuleId, 10), 'int_ge_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float greater than or equal: FIsGreaterEqual(10.0, 10.0) -> should return 1 (true)
    BeginFunction(LModuleId, 'test_float_greater_equal_true', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreaterEqual(LModuleId, FloatValue(LModuleId, 10.0), FloatValue(LModuleId, 10.0), 'float_ge_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test integer less than false case: IsLess(10, 5) -> should return 0 (false)
    BeginFunction(LModuleId, 'test_int_less_false', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsLess(LModuleId, IntegerValue(LModuleId, 10), IntegerValue(LModuleId, 5), 'int_lt_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test float less than false case: FIsLess(10.0, 5.5) -> should return 0 (false)
    BeginFunction(LModuleId, 'test_float_less_false', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLess(LModuleId, FloatValue(LModuleId, 10.0), FloatValue(LModuleId, 5.5), 'float_lt_result');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Validate and prepare for JIT execution
    if not ValidateModule(LModuleId) then
    begin
      TLLUtils.PrintLn('    ERROR: Module validation failed');
      Exit;
    end;
    
    // Execute all test functions and verify results
    TLLUtils.Print('    IsLess(5, 10): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_less_true', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsLess(5.5, 10.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_less_true', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    IsGreater(10, 5): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_greater_true', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsGreater(10.0, 5.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_greater_true', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    IsLessEqual(5, 5): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_less_equal_true', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsLessEqual(5.5, 5.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_less_equal_true', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    IsGreaterEqual(10, 10): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_greater_equal_true', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsGreaterEqual(10.0, 10.0): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_greater_equal_true', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    IsLess(10, 5): ');
    LResult := ExecuteFunction(LModuleId, 'test_int_less_false', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 0 then
      TLLUtils.PrintLn('PASS (0)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 0, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsLess(10.0, 5.5): ');
    LResult := ExecuteFunction(LModuleId, 'test_float_less_false', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 0 then
      TLLUtils.PrintLn('PASS (0)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 0, Got: %d)', [LActualResult]);
    
    // Clean up
    DeleteModule(LModuleId);
  end;
  
  TLLUtils.PrintLn('  Ordering comparison tests completed.');
end;

class procedure TTestComparison.TestComparisonNaming();
var
  LModuleId: string;
  LResult: TLLValue;
  LActualResult: Integer;
begin
  TLLUtils.PrintLn('  Testing comparison value naming...');
  
  with TLLVM.Create() do
  begin
    LModuleId := 'test_comparison_naming';
    CreateModule(LModuleId);
    
    // Test custom naming for IsEqual
    BeginFunction(LModuleId, 'test_custom_equal', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsEqual(LModuleId, IntegerValue(LModuleId, 42), IntegerValue(LModuleId, 42), 'my_custom_eq');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test custom naming for FIsLess
    BeginFunction(LModuleId, 'test_custom_float_less', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsLess(LModuleId, FloatValue(LModuleId, 3.14), FloatValue(LModuleId, 9.81), 'special_lt');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test custom naming for IsGreater
    BeginFunction(LModuleId, 'test_custom_greater', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsGreater(LModuleId, IntegerValue(LModuleId, 100), IntegerValue(LModuleId, 50), 'big_gt_small');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test custom naming for FIsGreaterEqual
    BeginFunction(LModuleId, 'test_custom_float_ge', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsGreaterEqual(LModuleId, FloatValue(LModuleId, 2.718), FloatValue(LModuleId, 2.718), 'euler_ge_euler');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test custom naming for IsNotEqual
    BeginFunction(LModuleId, 'test_custom_not_equal', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsNotEqual(LModuleId, IntegerValue(LModuleId, 7), IntegerValue(LModuleId, 13), 'lucky_ne_unlucky');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test custom naming for IsLessEqual
    BeginFunction(LModuleId, 'test_custom_less_equal', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsLessEqual(LModuleId, IntegerValue(LModuleId, 25), IntegerValue(LModuleId, 25), 'quarter_le_quarter');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test with empty string (should use default naming)
    BeginFunction(LModuleId, 'test_default_naming', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := FIsNotEqual(LModuleId, FloatValue(LModuleId, 1.0), FloatValue(LModuleId, 2.0), '');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Test with very long custom name
    BeginFunction(LModuleId, 'test_long_name', dtInt32, []);
    BeginBlock(LModuleId, 'entry');
    LResult := IsEqual(LModuleId, IntegerValue(LModuleId, 0), IntegerValue(LModuleId, 0), 'this_is_a_very_long_descriptive_comparison_name_for_testing');
    ReturnValue(LModuleId, IntCast(LModuleId, LResult, dtInt32, 'cast_result'));
    EndBlock(LModuleId);
    EndFunction(LModuleId);
    
    // Validate and prepare for JIT execution
    if not ValidateModule(LModuleId) then
    begin
      TLLUtils.PrintLn('    ERROR: Module validation failed');
      Exit;
    end;
    
    // Execute all test functions and verify results
    TLLUtils.Print('    IsEqual with custom name "my_custom_eq": ');
    LResult := ExecuteFunction(LModuleId, 'test_custom_equal', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsLess with custom name "special_lt": ');
    LResult := ExecuteFunction(LModuleId, 'test_custom_float_less', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);
    
    TLLUtils.Print('    IsGreater with custom name "big_gt_small": ');
    LResult := ExecuteFunction(LModuleId, 'test_custom_greater', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsGreaterEqual with custom name "euler_ge_euler": ');
    LResult := ExecuteFunction(LModuleId, 'test_custom_float_ge', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);
    
    TLLUtils.Print('    IsNotEqual with custom name "lucky_ne_unlucky": ');
    LResult := ExecuteFunction(LModuleId, 'test_custom_not_equal', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    IsLessEqual with custom name "quarter_le_quarter": ');
    LResult := ExecuteFunction(LModuleId, 'test_custom_less_equal', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);

    TLLUtils.Print('    FIsNotEqual with default naming (empty string): ');
    LResult := ExecuteFunction(LModuleId, 'test_default_naming', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);
    
    TLLUtils.Print('    IsEqual with very long custom name: ');
    LResult := ExecuteFunction(LModuleId, 'test_long_name', []);
    LActualResult := Ord(LResult.AsType<Int32>().ToBoolean());
    if LActualResult = 1 then
      TLLUtils.PrintLn('PASS (1)')
    else
      TLLUtils.PrintLn('FAIL (Expected: 1, Got: %d)', [LActualResult]);
    
    // Clean up
    DeleteModule(LModuleId);
  end;
  
  TLLUtils.PrintLn('  Comparison value naming tests completed.');
end;

end.
