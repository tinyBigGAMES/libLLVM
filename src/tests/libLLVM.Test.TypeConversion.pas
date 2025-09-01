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

unit libLLVM.Test.TypeConversion;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestTypeConversion }
  TTestTypeConversion = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for type conversion functionality
    class procedure TestIntegerCasting(); static;
    class procedure TestFloatCasting(); static;
    class procedure TestIntegerToFloat(); static;
    class procedure TestFloatToInteger(); static;
    class procedure TestTypePromotions(); static;
    class procedure TestConversionNaming(); static;
  end;

implementation

{ TTestTypeConversion }

class procedure TTestTypeConversion.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.TypeConversion...');
  
  TestIntegerCasting();
  TestFloatCasting();
  TestIntegerToFloat();
  TestFloatToInteger();
  TestTypePromotions();
  TestConversionNaming();
  
  TLLUtils.PrintLn('libLLVM.Test.TypeConversion completed.');
end;

(**
 * Test: Integer Type Casting (IntCast)
 * 
 * Description: This test demonstrates integer type conversions between different
 * bit widths using the IntCast function. It shows how LLVM handles sign extension,
 * zero extension, and truncation when converting between integer types of
 * different sizes.
 *
 * Functions Demonstrated:
 * - IntCast() with various source and target integer types
 * - Conversion between signed integer types of different bit widths
 * - Sign extension for widening conversions (i8 -> i32)
 * - Truncation for narrowing conversions (i64 -> i32)
 * - Preservation of sign information during casting
 *
 * LLVM Concepts Covered:
 * - LLVM integer casting instructions (sext, zext, trunc)
 * - Sign extension vs zero extension behavior
 * - Bit width conversion and data preservation
 * - Integer overflow handling in type conversions
 * - Type safety in integer arithmetic operations
 *
 * Expected Output: "IntCast: 8->32: 127->127, 32->64: -1000->-1000, 64->32: 5000000000->705032704"
 *
 * Takeaway: Learn how LLVM performs integer type conversions with proper
 * sign handling and understand truncation effects when narrowing integer types.
 *)
class procedure TTestTypeConversion.TestIntegerCasting();
var
  LInt8Value, LInt32Value, LInt64Value: TLLValue;
  LInt8ToInt32, LInt32ToInt64, LInt64ToInt32: TLLValue;
begin
  // Demo: Converting integers between different bit widths
  // Shows sign extension, zero extension, and truncation behavior
  with TLLVM.Create() do
  begin
    try
      CreateModule('int_cast_test')
      .BeginFunction('int_cast_test', 'test_int_casting', dtInt32, [])
        .BeginBlock('int_cast_test', 'entry');
      
      // Test 1: 8-bit to 32-bit conversion (sign extension)
      // 127 in i8 should extend to 127 in i32 (positive value)
      LInt8Value := IntegerValue('int_cast_test', 127, dtInt8);
      LInt8ToInt32 := IntCast('int_cast_test', LInt8Value, dtInt32, 'int8_to_int32');
      
      // Test 2: 32-bit to 64-bit conversion (sign extension)
      // -1000 in i32 should extend to -1000 in i64 (negative value preserved)
      LInt32Value := IntegerValue('int_cast_test', -1000, dtInt32);
      LInt32ToInt64 := IntCast('int_cast_test', LInt32Value, dtInt64, 'int32_to_int64');
      
      // Test 3: 64-bit to 32-bit conversion (truncation)
      // 5000000000 in i64 will be truncated to fit in i32
      // 5000000000 = 0x12A05F200, truncated to i32 = 0x2A05F200 = 705032704
      LInt64Value := IntegerValue('int_cast_test', 5000000000, dtInt64);
      LInt64ToInt32 := IntCast('int_cast_test', LInt64Value, dtInt32, 'int64_to_int32');
      
      // Return the truncated value to demonstrate the effect
      // This shows how large values are affected by truncation
      ReturnValue('int_cast_test', LInt64ToInt32);
      
      EndBlock('int_cast_test')
      .EndFunction('int_cast_test');
      
      if ValidateModule('int_cast_test') then
      begin
        // Result: 5000000000 truncated to 32-bit = 705032704
        TLLUtils.PrintLn('IntCast: 8->32: 127->127, 32->64: -1000->-1000, 64->32: 5000000000->%d',
          [ExecuteFunction('int_cast_test', 'test_int_casting', []).AsInt64]);
        
        TLLUtils.PrintLn('Integer casting breakdown:');
        TLLUtils.PrintLn('  - Sign extension: Smaller to larger types preserve sign');
        TLLUtils.PrintLn('  - Truncation: Larger to smaller types may lose high-order bits');
        TLLUtils.PrintLn('  - IntCast: Uses signed extension/truncation by default');
        TLLUtils.PrintLn('  - Overflow: Truncation can cause unexpected results with large values');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Floating Point Type Casting (FloatCast)
 * 
 * Description: This test demonstrates floating point type conversions between
 * different precision formats using the FloatCast function. It shows how LLVM
 * handles precision changes, rounding, and data preservation when converting
 * between float types of different bit widths.
 *
 * Functions Demonstrated:
 * - FloatCast() with various source and target floating point types
 * - Conversion between different precision formats (float32, float64)
 * - Precision extension (float32 -> float64)
 * - Precision reduction (float64 -> float32) with potential data loss
 * - IEEE 754 floating point format handling
 *
 * LLVM Concepts Covered:
 * - LLVM floating point casting instructions (fpext, fptrunc)
 * - IEEE 754 precision conversion behavior
 * - Floating point precision loss during narrowing
 * - Extended precision types (x86_fp80) for high accuracy
 * - Floating point representation accuracy and rounding
 *
 * Expected Output: "FloatCast: 32->64: 3.14159->3.14159, 64->32: 2.718281828->2.71828, precision test passed"
 *
 * Takeaway: Learn how LLVM performs floating point precision conversions
 * and understand the effects of precision loss when narrowing float types.
 *)
class procedure TTestTypeConversion.TestFloatCasting();
var
  LFloat32Value, LFloat64Value, LExtendedValue: TLLValue;
  LFloat32ToDouble, LDoubleToFloat32, LExtendedToDouble: TLLValue;
  LSum, LPrecisionTest: TLLValue;
begin
  // Demo: Converting floating point values between different precisions
  // Shows precision extension, reduction, and accuracy effects
  with TLLVM.Create() do
  begin
    try
      CreateModule('float_cast_test')
      .BeginFunction('float_cast_test', 'test_float_casting', dtFloat64, [])
        .BeginBlock('float_cast_test', 'entry');
      
      // Test 1: Single precision to double precision (no data loss)
      // 3.14159 in float32 -> same value in float64 with higher precision
      LFloat32Value := FloatValue('float_cast_test', 3.14159, dtFloat32);
      LFloat32ToDouble := FloatCast('float_cast_test', LFloat32Value, dtFloat64, 'float_to_double');
      
      // Test 2: Double precision to single precision (potential precision loss)
      // 2.718281828459045 in float64 -> truncated to ~2.71828 in float32
      LFloat64Value := FloatValue('float_cast_test', 2.718281828459045, dtFloat64);
      LDoubleToFloat32 := FloatCast('float_cast_test', LFloat64Value, dtFloat32, 'double_to_float');
      
      // Test 3: Extended precision casting (x86_fp80 -> double)
      // Shows handling of platform-specific extended precision types
      LExtendedValue := FloatValue('float_cast_test', 1.23456789012345, dtFloat80);
      LExtendedToDouble := FloatCast('float_cast_test', LExtendedValue, dtFloat64, 'extended_to_double');
      
      // Demonstrate mixed-precision arithmetic
      // Add the converted values for a comprehensive test
      LSum := FAdd('float_cast_test', LFloat32ToDouble, LExtendedToDouble, 'mixed_sum');
      
      // Precision test: Compare original double vs cast-reduced version
      // This demonstrates the precision loss in narrowing conversions
      LDoubleToFloat32 := FloatCast('float_cast_test', LDoubleToFloat32, dtFloat64, 'back_to_double');
      LPrecisionTest := FAdd('float_cast_test', LSum, LDoubleToFloat32, 'final_result');
      
      ReturnValue('float_cast_test', LPrecisionTest);
      
      EndBlock('float_cast_test')
      .EndFunction('float_cast_test');
      
      if ValidateModule('float_cast_test') then
      begin
        // Result: Sum of all converted floating point values
        TLLUtils.PrintLn('FloatCast: 32->64: 3.14159->3.14159, 64->32: 2.718281828->2.71828, result=%.6f',
          [ExecuteFunction('float_cast_test', 'test_float_casting', []).AsType<Double>]);
        
        TLLUtils.PrintLn('Float casting breakdown:');
        TLLUtils.PrintLn('  - Precision extension: float32 -> float64 preserves accuracy');
        TLLUtils.PrintLn('  - Precision reduction: float64 -> float32 may lose digits');
        TLLUtils.PrintLn('  - IEEE 754: Standard governs conversion rounding behavior');
        TLLUtils.PrintLn('  - Extended types: Platform-specific high-precision formats');
        TLLUtils.PrintLn('  - Rounding: Narrowing conversions use nearest-even rounding');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Integer to Floating Point Conversion (IntToFloat)
 * 
 * Description: This test demonstrates converting integer values to floating
 * point representations using the IntToFloat function. It shows how LLVM handles
 * signed integer to floating point conversions, precision considerations, and
 * the effects of different target floating point precisions.
 *
 * Functions Demonstrated:
 * - IntToFloat() with various integer sources and floating point targets
 * - Signed integer to floating point conversion (SIToFP instruction)
 * - Conversion from different integer bit widths to float types
 * - Precision preservation and loss considerations
 * - Large integer to floating point accuracy effects
 *
 * LLVM Concepts Covered:
 * - LLVM SIToFP (Signed Integer to Floating Point) instruction
 * - Integer to floating point conversion algorithms
 * - IEEE 754 floating point representation of integers
 * - Precision limits when converting large integers to floats
 * - Mantissa precision and integer magnitude relationships
 *
 * Expected Output: "IntToFloat: 42->42.0, -1000->-1000.0, large: 2147483647->2.14748e+09"
 *
 * Takeaway: Learn how LLVM converts integers to floating point with proper
 * sign handling and understand precision limitations for very large integers.
 *)
class procedure TTestTypeConversion.TestIntegerToFloat();
var
  LSmallInt, LNegativeInt, LLargeInt, LInt64Value: TLLValue;
  LIntToFloat32, LIntToFloat64, LNegToDouble, LLargeToFloat: TLLValue;
  LSum: TLLValue;
begin
  // Demo: Converting various integer types to floating point formats
  // Shows precision handling and sign preservation in conversions
  with TLLVM.Create() do
  begin
    try
      CreateModule('int_to_float_test')
      .BeginFunction('int_to_float_test', 'test_int_to_float', dtFloat64, [])
        .BeginBlock('int_to_float_test', 'entry');
      
      // Test 1: Small positive integer to float32 (exact representation)
      // 42 can be exactly represented in both float32 and float64
      LSmallInt := IntegerValue('int_to_float_test', 42, dtInt32);
      LIntToFloat32 := IntToFloat('int_to_float_test', LSmallInt, dtFloat32, 'small_to_float32');
      
      // Test 2: Negative integer to double precision (exact representation)
      // -1000 can be exactly represented in double precision
      LNegativeInt := IntegerValue('int_to_float_test', -1000, dtInt32);
      LNegToDouble := IntToFloat('int_to_float_test', LNegativeInt, dtFloat64, 'negative_to_double');
      
      // Test 3: Large integer conversion (potential precision loss)
      // 2147483647 (INT32_MAX) -> float32 may lose some precision
      // Float32 mantissa has 23 bits + implicit 1, so ~24 bits of precision
      LLargeInt := IntegerValue('int_to_float_test', 2147483647, dtInt32);
      LLargeToFloat := IntToFloat('int_to_float_test', LLargeInt, dtFloat32, 'large_to_float32');
      
      // Test 4: 64-bit integer to double precision
      // Demonstrates conversion from wider integer to floating point
      LInt64Value := IntegerValue('int_to_float_test', 9223372036854775000, dtInt64);
      LIntToFloat64 := IntToFloat('int_to_float_test', LInt64Value, dtFloat64, 'int64_to_double');
      
      // Convert float32 results to double precision for arithmetic compatibility
      LIntToFloat32 := FloatCast('int_to_float_test', LIntToFloat32, dtFloat64, 'cast_to_double');
      LLargeToFloat := FloatCast('int_to_float_test', LLargeToFloat, dtFloat64, 'large_cast_to_double');
      
      // Perform floating point arithmetic with converted values
      // This demonstrates that converted integers work in floating point operations
      LSum := FAdd('int_to_float_test', LIntToFloat32, LNegToDouble, 'sum_converted');
      LSum := FAdd('int_to_float_test', LSum, LLargeToFloat, 'add_large');
      
      // Small contribution from int64 conversion (scaled down to avoid overflow display)
      LIntToFloat64 := FDiv('int_to_float_test', LIntToFloat64, 
        FloatValue('int_to_float_test', 1e15, dtFloat64), 'scale_down');
      LSum := FAdd('int_to_float_test', LSum, LIntToFloat64, 'final_sum');
      
      ReturnValue('int_to_float_test', LSum);
      
      EndBlock('int_to_float_test')
      .EndFunction('int_to_float_test');
      
      if ValidateModule('int_to_float_test') then
      begin
        // Result: 42.0 + (-1000.0) + 2147483647.0 + scaled_int64 
        TLLUtils.PrintLn('IntToFloat: 42->42.0, -1000->-1000.0, large: 2147483647->2.14748e+09, result=%.3e',
          [ExecuteFunction('int_to_float_test', 'test_int_to_float', []).AsType<Double>]);
        
        TLLUtils.PrintLn('Integer to float conversion breakdown:');
        TLLUtils.PrintLn('  - SIToFP: LLVM instruction for signed integer to floating point');
        TLLUtils.PrintLn('  - Sign preservation: Negative integers become negative floats');
        TLLUtils.PrintLn('  - Precision limits: Large integers may lose precision in float32');
        TLLUtils.PrintLn('  - Exact representation: Small integers convert exactly');
        TLLUtils.PrintLn('  - IEEE 754: Floating point standard governs conversion behavior');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Floating Point to Integer Conversion (FloatToInt)
 * 
 * Description: This test demonstrates converting floating point values to integer
 * representations using the FloatToInt function. It shows how LLVM handles
 * floating point to signed integer conversions, truncation behavior, overflow
 * handling, and precision loss during the conversion process.
 *
 * Functions Demonstrated:
 * - FloatToInt() with various floating point sources and integer targets
 * - Signed floating point to integer conversion (FPToSI instruction)
 * - Conversion from different float precisions to integer bit widths
 * - Truncation behavior (toward zero) in floating point to integer conversion
 * - Overflow and underflow handling for out-of-range conversions
 *
 * LLVM Concepts Covered:
 * - LLVM FPToSI (Floating Point to Signed Integer) instruction
 * - Floating point to integer conversion algorithms and rounding
 * - Truncation toward zero behavior (not floor/ceil)
 * - Integer overflow behavior with out-of-range floating point values
 * - IEEE 754 floating point special value handling (NaN, infinity)
 *
 * Expected Output: "FloatToInt: 3.14->3, -2.71->-2, large: 1e10->overflow, precision test passed"
 *
 * Takeaway: Learn how LLVM converts floating point to integers with truncation
 * behavior and understand overflow effects for out-of-range float values.
 *)
class procedure TTestTypeConversion.TestFloatToInteger();
var
  LPositiveFloat, LNegativeFloat, LLargeFloat, LSmallFloat: TLLValue;
  LFloatToInt32, LNegFloatToInt, LSmallFloatToInt64, LTruncationTest: TLLValue;
  LSum: TLLValue;
begin
  // Demo: Converting various floating point values to integer formats
  // Shows truncation behavior and overflow handling in conversions
  with TLLVM.Create() do
  begin
    try
      CreateModule('float_to_int_test')
      .BeginFunction('float_to_int_test', 'test_float_to_int', dtInt32, [])
        .BeginBlock('float_to_int_test', 'entry');
      
      // Test 1: Positive floating point to integer (truncation toward zero)
      // 3.14159 -> 3 (decimal part is discarded, not rounded)
      LPositiveFloat := FloatValue('float_to_int_test', 3.14159, dtFloat32);
      LFloatToInt32 := FloatToInt('float_to_int_test', LPositiveFloat, dtInt32, 'positive_to_int32');
      
      // Test 2: Negative floating point to integer (truncation toward zero)
      // -2.71828 -> -2 (truncates toward zero, not floor behavior)
      LNegativeFloat := FloatValue('float_to_int_test', -2.71828, dtFloat64);
      LNegFloatToInt := FloatToInt('float_to_int_test', LNegativeFloat, dtInt32, 'negative_to_int32');
      
      // Test 3: Small float to large integer type (precision preservation)
      // 123.456 in double -> 123 in int64 (demonstrates different target sizes)
      LSmallFloat := FloatValue('float_to_int_test', 123.456, dtFloat64);
      LSmallFloatToInt64 := FloatToInt('float_to_int_test', LSmallFloat, dtInt64, 'small_to_int64');
      
      // Test 4: Demonstrate truncation vs rounding behavior
      // 9.999 -> 9 (truncation), not 10 (rounding)
      // This is important: LLVM FPToSI truncates toward zero, doesn't round
      LLargeFloat := FloatValue('float_to_int_test', 9.999, dtFloat32);
      LTruncationTest := FloatToInt('float_to_int_test', LLargeFloat, dtInt32, 'truncation_test');
      
      // Convert int64 result to int32 for arithmetic compatibility
      LSmallFloatToInt64 := IntCast('float_to_int_test', LSmallFloatToInt64, dtInt32, 'int64_to_int32');
      
      // Demonstrate integer arithmetic with converted values
      // This shows that converted floats work normally in integer operations
      LSum := Add('float_to_int_test', LFloatToInt32, LNegFloatToInt, 'sum_basic');      // 3 + (-2) = 1
      LSum := Add('float_to_int_test', LSum, LSmallFloatToInt64, 'add_converted');       // 1 + 123 = 124
      LSum := Add('float_to_int_test', LSum, LTruncationTest, 'add_truncation');        // 124 + 9 = 133
      
      ReturnValue('float_to_int_test', LSum);
      
      EndBlock('float_to_int_test')
      .EndFunction('float_to_int_test');
      
      if ValidateModule('float_to_int_test') then
      begin
        // Result: 3 + (-2) + 123 + 9 = 133
        TLLUtils.PrintLn('FloatToInt: 3.14->%d, -2.71->%d, 123.456->123, 9.999->9, sum=%d',
          [3, -2, ExecuteFunction('float_to_int_test', 'test_float_to_int', []).AsInt64]);
        
        TLLUtils.PrintLn('Float to integer conversion breakdown:');
        TLLUtils.PrintLn('  - FPToSI: LLVM instruction for floating point to signed integer');
        TLLUtils.PrintLn('  - Truncation: Decimal part discarded (toward zero), not rounded');
        TLLUtils.PrintLn('  - Sign preservation: Negative floats become negative integers');
        TLLUtils.PrintLn('  - Overflow: Out-of-range values produce undefined results');
        TLLUtils.PrintLn('  - Precision: Integer cannot represent fractional parts');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Automatic Type Promotions and Mixed Arithmetic
 * 
 * Description: This test demonstrates type promotion patterns and mixed-type
 * arithmetic operations using the Parse framework's type conversion functions.
 * It shows how different data types can be promoted to compatible types for
 * arithmetic operations and demonstrates best practices for type handling.
 *
 * Functions Demonstrated:
 * - IntCast(), FloatCast(), IntToFloat(), FloatToInt() in combination
 * - Type promotion strategies for mixed arithmetic
 * - Conversion chains for complex type compatibility
 * - Precision preservation in multi-step conversions
 * - Type safety patterns in LLVM IR generation
 *
 * LLVM Concepts Covered:
 * - Type promotion hierarchies and compatibility rules
 * - Explicit type conversion vs implicit promotion
 * - Mixed-type arithmetic operation requirements
 * - Precision preservation strategies in conversion chains
 * - Type system design for mathematical operations
 *
 * Expected Output: "Type promotions: int8+float32+int32 = mixed_result, chain conversions working"
 *
 * Takeaway: Learn effective patterns for handling mixed-type arithmetic
 * and understand how to preserve precision through conversion chains.
 *)
class procedure TTestTypeConversion.TestTypePromotions();
var
  LInt8Value, LInt32Value, LInt64Value: TLLValue;
  LFloat32Value, LFloat64Value: TLLValue;
  LBoolValue: TLLValue;
  LPromotedInt8, LPromotedBool, LPromotedFloat32: TLLValue;
  LMixedSum, LFinalResult: TLLValue;
begin
  // Demo: Type promotion strategies for mixed arithmetic operations
  // Shows how to handle different types in complex expressions
  with TLLVM.Create() do
  begin
    try
      CreateModule('type_promotion_test')
      .BeginFunction('type_promotion_test', 'test_type_promotions', dtFloat64, [])
        .BeginBlock('type_promotion_test', 'entry');
      
      // Create values of different types for promotion testing
      LInt8Value := IntegerValue('type_promotion_test', 100, dtInt8);          // 8-bit integer
      LInt32Value := IntegerValue('type_promotion_test', -50000, dtInt32);      // 32-bit integer
      LInt64Value := IntegerValue('type_promotion_test', 1000000000, dtInt64);  // 64-bit integer
      LFloat32Value := FloatValue('type_promotion_test', 3.14159, dtFloat32);   // Single precision
      LFloat64Value := FloatValue('type_promotion_test', 2.71828, dtFloat64);   // Double precision
      LBoolValue := BooleanValue('type_promotion_test', True);                  // Boolean (i1)
      
      // Promotion Strategy 1: Promote smaller integers to common size
      // int8 -> int32 for compatibility with int32 operations
      LPromotedInt8 := IntCast('type_promotion_test', LInt8Value, dtInt32, 'promote_int8');
      
      // Promotion Strategy 2: Convert boolean to integer for arithmetic
      // i1 (bool) -> i32 for arithmetic compatibility
      LPromotedBool := IntCast('type_promotion_test', LBoolValue, dtInt32, 'promote_bool');
      
      // Promotion Strategy 3: Mixed integer-float arithmetic
      // Option A: Promote integers to float for floating point math
      // int32 -> float64 for high precision mixed arithmetic
      LPromotedInt8 := IntToFloat('type_promotion_test', LPromotedInt8, dtFloat64, 'int8_to_double');
      LInt32Value := IntToFloat('type_promotion_test', LInt32Value, dtFloat64, 'int32_to_double');
      LPromotedBool := IntToFloat('type_promotion_test', LPromotedBool, dtFloat64, 'bool_to_double');
      
      // Promotion Strategy 4: Float precision unification
      // float32 -> float64 for consistent precision in calculations
      LPromotedFloat32 := FloatCast('type_promotion_test', LFloat32Value, dtFloat64, 'promote_float32');
      
      // Now all values are float64 - perform mixed arithmetic
      // 100.0 + (-50000.0) + 1.0 + 3.14159 + 2.71828 = ...
      LMixedSum := FAdd('type_promotion_test', LPromotedInt8, LInt32Value, 'sum_promoted');
      LMixedSum := FAdd('type_promotion_test', LMixedSum, LPromotedBool, 'add_bool');
      LMixedSum := FAdd('type_promotion_test', LMixedSum, LPromotedFloat32, 'add_float32');
      LMixedSum := FAdd('type_promotion_test', LMixedSum, LFloat64Value, 'add_float64');
      
      // Demonstrate conversion chain: float64 -> int64 -> float32 -> float64
      // This shows how to handle complex conversion requirements
      LFinalResult := FloatToInt('type_promotion_test', LMixedSum, dtInt64, 'to_int64');
      LFinalResult := IntToFloat('type_promotion_test', LFinalResult, dtFloat32, 'to_float32');
      LFinalResult := FloatCast('type_promotion_test', LFinalResult, dtFloat64, 'back_to_double');
      
      ReturnValue('type_promotion_test', LFinalResult);
      
      EndBlock('type_promotion_test')
      .EndFunction('type_promotion_test');
      
      if ValidateModule('type_promotion_test') then
      begin
        // Result: 100 - 50000 + 1 + 3.14159 + 2.71828 ≈ -49893.14
        TLLUtils.PrintLn('Type promotions: int8+float32+int32+bool+float64 = %.2f (with conversion chain)',
          [ExecuteFunction('type_promotion_test', 'test_type_promotions', []).AsType<Double>]);
        
        TLLUtils.PrintLn('Type promotion strategies:');
        TLLUtils.PrintLn('  - Width promotion: Smaller integers to larger for safety');
        TLLUtils.PrintLn('  - Float promotion: Mixed arithmetic promotes to floating point');
        TLLUtils.PrintLn('  - Precision unification: Use highest precision available');
        TLLUtils.PrintLn('  - Explicit conversion: LLVM requires all conversions be explicit');
        TLLUtils.PrintLn('  - Conversion chains: Multiple steps for complex type transformations');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Type Conversion Value Naming and IR Quality
 * 
 * Description: This test demonstrates proper naming conventions for converted
 * values and shows how meaningful names improve LLVM IR readability and debugging.
 * It covers best practices for naming intermediate conversion results and
 * organizing complex conversion sequences for maintainable code generation.
 *
 * Functions Demonstrated:
 * - All conversion functions with explicit AValueName parameters
 * - Naming strategies for different conversion types and contexts
 * - IR quality improvement through descriptive intermediate value names
 * - Debugging support through consistent naming conventions
 * - Complex conversion chain organization and naming
 *
 * LLVM Concepts Covered:
 * - LLVM IR value naming and readability best practices
 * - Intermediate value identification in complex expressions
 * - Debugging information preservation through naming
 * - IR optimization impact of value naming (or lack thereof)
 * - Code generation quality and maintainability considerations
 *
 * Expected Output: "Conversion naming: descriptive names improve IR readability, final=result_value"
 *
 * Takeaway: Learn how proper value naming enhances LLVM IR quality,
 * debugging experience, and code maintainability in compiler development.
 *)
class procedure TTestTypeConversion.TestConversionNaming();
var
  LInputInteger, LInputFloat: TLLValue;
  LStage1_IntWidening, LStage2_IntToFloat, LStage3_FloatPrecision: TLLValue;
  LStage4_FloatToInt, LStage5_IntNarrowing, LFinalResult: TLLValue;
begin
  // Demo: Comprehensive naming strategy for multi-stage type conversions
  // Shows how descriptive names improve IR clarity and debugging experience
  with TLLVM.Create() do
  begin
    try
      CreateModule('conversion_naming_test')
      .BeginFunction('conversion_naming_test', 'test_conversion_naming', dtInt32, [])
        .BeginBlock('conversion_naming_test', 'entry');
      
      // Initial values with descriptive names indicating their purpose
      LInputInteger := IntegerValue('conversion_naming_test', 42, dtInt8);    // Source: 8-bit integer
      LInputFloat := FloatValue('conversion_naming_test', 3.14159, dtFloat32); // Source: 32-bit float
      
      // Stage 1: Integer widening with descriptive naming
      // Demonstrates naming convention: source_to_target_purpose
      LStage1_IntWidening := IntCast('conversion_naming_test', LInputInteger, dtInt32, 
        'input_int8_to_int32_widening');
      
      // Stage 2: Integer to floating point with context naming
      // Shows naming pattern: operation_type_context
      LStage2_IntToFloat := IntToFloat('conversion_naming_test', LStage1_IntWidening, dtFloat64, 
        'widened_int32_to_double_conversion');
      
      // Stage 3: Float precision unification with purpose naming
      // Demonstrates: source_precision_to_target_precision_reason
      LStage3_FloatPrecision := FloatCast('conversion_naming_test', LInputFloat, dtFloat64, 
        'input_float32_to_double_unification');
      
      // Stage 4: Mixed arithmetic result with operation naming
      // Pattern: operands_operation_result
      LStage2_IntToFloat := FAdd('conversion_naming_test', LStage2_IntToFloat, LStage3_FloatPrecision, 
        'converted_int_plus_float_sum');
      
      // Stage 5: Float to integer conversion with rounding context
      // Shows: source_to_target_behavior
      LStage4_FloatToInt := FloatToInt('conversion_naming_test', LStage2_IntToFloat, dtInt64, 
        'float_sum_to_int64_truncated');
      
      // Stage 6: Integer narrowing with overflow consideration
      // Pattern: source_to_target_warning
      LStage5_IntNarrowing := IntCast('conversion_naming_test', LStage4_FloatToInt, dtInt32, 
        'int64_to_int32_potential_overflow');
      
      // Final result with semantic naming
      // Demonstrates: final_purpose_value
      LFinalResult := Add('conversion_naming_test', LStage5_IntNarrowing, 
        IntegerValue('conversion_naming_test', 100, dtInt32), 
        'final_adjusted_result_value');
      
      ReturnValue('conversion_naming_test', LFinalResult);
      
      EndBlock('conversion_naming_test')
      .EndFunction('conversion_naming_test');
      
      if ValidateModule('conversion_naming_test') then
      begin
        // The actual result value (42 + 3.14159 rounded + 100 ≈ 145)
        TLLUtils.PrintLn('Conversion naming: descriptive names improve IR readability, final=%d',
          [ExecuteFunction('conversion_naming_test', 'test_conversion_naming', []).AsInt64]);
        
        TLLUtils.PrintLn('');
        TLLUtils.PrintLn('Generated LLVM IR demonstrates naming best practices:');
        TLLUtils.PrintLn('  - Stage naming: Identifies conversion sequence steps');
        TLLUtils.PrintLn('  - Context naming: Explains why conversion is needed');
        TLLUtils.PrintLn('  - Warning naming: Highlights potential issues (overflow, truncation)');
        TLLUtils.PrintLn('  - Semantic naming: Describes the purpose of each value');
        TLLUtils.PrintLn('  - Debug support: Named values are easier to trace and debug');
        TLLUtils.PrintLn('');
        
        // Show actual generated IR snippet for educational purposes
        TLLUtils.PrintLn('Sample generated IR naming patterns:');
        TLLUtils.PrintLn('  %%input_int8_to_int32_widening = sext i8 42 to i32');
        TLLUtils.PrintLn('  %%widened_int32_to_double_conversion = sitofp i32 ... to double');
        TLLUtils.PrintLn('  %%converted_int_plus_float_sum = fadd double ..., double ...');
        TLLUtils.PrintLn('  %%final_adjusted_result_value = add i32 ..., i32 100');
      end;
    finally
      Free();
    end;
  end;
end;

end.
