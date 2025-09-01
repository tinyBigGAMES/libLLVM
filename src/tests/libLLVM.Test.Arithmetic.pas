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

unit libLLVM.Test.Arithmetic;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestArithmetic }
  TTestArithmetic = class
  public
    class procedure RunAllTests(); static;

    // Test methods for arithmetic operations functionality
    class procedure TestIntegerArithmetic(); static;
    class procedure TestFloatingPointArithmetic(); static;
    class procedure TestArithmeticChaining(); static;
    class procedure TestArithmeticNegatives(); static;
    class procedure TestMixedTypeArithmetic(); static;
    class procedure TestArithmeticNaming(); static;
  end;

implementation

{ TTestArithmetic }

class procedure TTestArithmetic.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.Arithmetic...');
  
  TestIntegerArithmetic();
  TestFloatingPointArithmetic();
  TestArithmeticChaining();
  TestArithmeticNegatives();
  TestMixedTypeArithmetic();
  TestArithmeticNaming();
  
  TLLUtils.PrintLn('libLLVM.Test.Arithmetic completed.');
end;

(**
 * Test: Integer Arithmetic Operations
 * 
 * Description: This test demonstrates basic integer arithmetic operations using the libLLVM
 * framework to generate LLVM IR. It shows how to create a simple function that performs
 * addition on two integer parameters and execute it via the JIT engine.
 *
 * Functions Demonstrated:
 * - Add() - Performs integer addition operation
 * - CreateModule() - Creates an LLVM module container
 * - BeginFunction() - Starts function definition with parameters
 * - GetParameter() - Retrieves function parameters as LLVM values
 * - ReturnValue() - Returns a computed value from function
 *
 * LLVM Concepts Covered:
 * - Basic arithmetic operations in LLVM IR (add i32)
 * - Function parameter handling and retrieval
 * - Integer data types and operations
 * - Basic block structure and control flow
 * - Module validation before execution
 *
 * Expected Output: "Add test: 15 + 25 = 40"
 *
 * Takeaway: Learn how to create simple arithmetic functions that bridge high-level
 * mathematical operations with low-level LLVM IR generation and JIT execution.
 *)
class procedure TTestArithmetic.TestIntegerArithmetic();
var
  LParamA, LParamB, LResult: TLLValue;
begin
  // Demo: Basic integer arithmetic operations (Add, Subtract, Multiply, DivideTPaCodeGen)
  // This test demonstrates fundamental arithmetic operations in LLVM IR
  with TLLVM.Create() do
  begin
    try
      // Create a module for testing arithmetic operations
      CreateModule('arithmetic')
      // Define a function that takes two integers and returns their sum
      .BeginFunction('arithmetic', 'add_numbers', dtInt32, [Param('a', dtInt32), Param('b', dtInt32)])
        // Create the entry basic block for the function
        .BeginBlock('arithmetic', 'entry');
      
      // Get the function parameters as LLVM values
      LParamA := GetParameter('arithmetic', 'a');
      LParamB := GetParameter('arithmetic', 'b');
      
      // Perform addition: generates LLVM IR "add i32 %a, %b"
      LResult := Add('arithmetic', LParamA, LParamB);
      
      // Return the computed result
      // This generates LLVM IR "ret i32 %result"
      ReturnValue('arithmetic', LResult);
      
      // Complete the function definition
      EndBlock('arithmetic')
      .EndFunction('arithmetic');
      
      // Validate the generated LLVM module for correctness
      if ValidateModule('arithmetic') then
      begin
        // Execute the function with test values: 15 + 25 = 40
        TLLUtils.PrintLn('Add test: 15 + 25 = %d', [ExecuteFunction('arithmetic', 'add_numbers', [15, 25]).AsInt64]);
      end;
    finally
      // Clean up resources
      Free();
    end;
  end;
end;

(**
 * Test: Floating Point Arithmetic Operations
 * 
 * Description: This test demonstrates floating point arithmetic operations using the TPaParse
 * framework. It shows how to work with floating point data types and perform arithmetic
 * operations that generate appropriate LLVM IR for floating point calculations.
 *
 * Functions Demonstrated:
 * - FAdd() - Performs floating point addition
 * - FSub() - Performs floating point subtraction  
 * - FMul() - Performs floating point multiplication
 * - FDiv() - Performs floating point division
 *
 * LLVM Concepts Covered:
 * - Floating point arithmetic in LLVM IR (fadd, fsub, fmul, fdiv)
 * - Float32/Double data type handling
 * - IEEE 754 floating point operations
 * - Type-specific arithmetic operations
 *
 * Expected Output: "Float test: 3.5 + 2.1 = 5.6"
 *
 * Takeaway: Learn the difference between integer and floating point arithmetic
 * operations in LLVM IR and how to handle different numeric data types.
 *)
class procedure TTestArithmetic.TestFloatingPointArithmetic();
var
  LParamA, LParamB: TLLValue;
  LResult: TLLValue;
begin
  // Demo: Floating point arithmetic operations
  // This test shows how to work with floating point numbers in LLVM IR
  with TLLVM.Create() do
  begin
    try
      // Create a module for floating point operations
      CreateModule('float_math')
      // Define a function that adds two floating point numbers
      .BeginFunction('float_math', 'add_floats', dtFloat32, [Param('x', dtFloat32), Param('y', dtFloat32)])
        .BeginBlock('float_math', 'entry');
      
      // Get floating point parameters
      LParamA := GetParameter('float_math', 'x');
      LParamB := GetParameter('float_math', 'y');
      
      // Perform floating point addition: generates LLVM IR "fadd float %x, %y"
      LResult := FAdd('float_math', LParamA, LParamB);
      
      // Return the floating point result
      ReturnValue('float_math', LResult);
      
      EndBlock('float_math')
      .EndFunction('float_math');
      
      if ValidateModule('float_math') then
      begin
        // Execute with floating point values: 3.5 + 2.1 = 5.6
        TLLUtils.PrintLn('Float test: 3.5 + 2.1 = %.1f', [ExecuteFunction('float_math', 'add_floats', [3.5, 2.1]).AsType<Single>]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Arithmetic Operation Chaining
 *
 * Description: This test demonstrates chaining multiple arithmetic operations together
 * using the TPaParse framework to generate LLVM IR. It shows how complex mathematical
 * expressions are built step-by-step through intermediate named values in SSA form.
 *
 * Functions Demonstrated:
 * - Add() - Performs integer addition operation with named result
 * - Multiply() - Performs integer multiplication on intermediate value
 * - Subtract() - Performs integer subtraction as final operation
 * - IntegerValue() - Creates integer constants for expression components
 *
 * LLVM Concepts Covered:
 * - Sequential arithmetic operations in LLVM IR (add, mul, sub)
 * - SSA (Single Static Assignment) form with intermediate values
 * - Order of operations through explicit instruction sequencing
 * - Named intermediate results for debugging and readability
 * - Complex expression decomposition into basic operations
 *
 * Expected Output: "Chaining test: ((10 + 5) * 3) - 7 = 38"
 *
 * Takeaway: Learn how LLVM IR naturally represents complex expressions through
 * chained operations with intermediate named values, demonstrating the power
 * of SSA form for mathematical computation optimization.
 *)
class procedure TTestArithmetic.TestArithmeticChaining();
var
  LVal1, LVal2,LVal3, LVal4, LSum, LProduct, LResult: TLLValue;
begin
  // Demo: Chaining multiple arithmetic operations together
  // This shows how to build complex expressions: ((a + b) * c) - d
  with TLLVM.Create() do
  begin
    try
      CreateModule('chaining_test')
      .BeginFunction('chaining_test', 'complex_calculation', dtInt32, [])
        .BeginBlock('chaining_test', 'entry');

      // Create integer constants for the expression ((10 + 5) * 3) - 7
      LVal1 := IntegerValue('chaining_test', 10, dtInt32);
      LVal2 := IntegerValue('chaining_test', 5, dtInt32);
      LVal3 := IntegerValue('chaining_test', 3, dtInt32);
      LVal4 := IntegerValue('chaining_test', 7, dtInt32);

      // First operation: 10 + 5 = 15
      LSum := Add('chaining_test', LVal1, LVal2, 'sum_result');

      // Second operation: 15 * 3 = 45
      LProduct := Multiply('chaining_test', LSum, LVal3, 'product_result');

      // Final operation: 45 - 7 = 38
      LResult := Subtract('chaining_test', LProduct, LVal4, 'final_result');

      ReturnValue('chaining_test', LResult);

      EndBlock('chaining_test')
      .EndFunction('chaining_test');

      if ValidateModule('chaining_test') then
      begin
        TLLUtils.PrintLn('Chaining test: ((10 + 5) * 3) - 7 = %d', [ExecuteFunction('chaining_test', 'complex_calculation', []).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Arithmetic with Negative Numbers
 *
 * Description: This test demonstrates arithmetic operations involving negative numbers
 * using the TPaParse framework. It shows how to safely work with negative integer
 * constants and perform arithmetic operations without hitting boundary conditions
 * that cause compilation issues.
 *
 * Functions Demonstrated:
 * - Add() - Performs addition between negative and positive integers
 * - Multiply() - Performs multiplication with negative numbers
 * - IntegerValue() - Creates negative integer constants safely
 *
 * LLVM Concepts Covered:
 * - Negative integer handling in LLVM IR
 * - Two's complement arithmetic operations
 * - Safe negative constant creation without boundary issues
 * - Sign preservation through arithmetic operations
 * - Mixed positive/negative integer arithmetic
 *
 * Expected Output: "Negative test: (-50 + 30) * -2 = 40"
 *
 * Takeaway: Learn how to work with negative numbers in LLVM IR generation
 * while avoiding the integer boundary issues that can cause compilation
 * problems in the host language (Delphi).
 *)
class procedure TTestArithmetic.TestArithmeticNegatives();
var
  LNegative50, LPositive30, LNegative2, LSum, LResult: TLLValue;
begin
  // Demo: Arithmetic operations with negative numbers
  // This shows safe negative number handling without boundary issues
  with TLLVM.Create() do
  begin
    try
      CreateModule('negative_test')
      .BeginFunction('negative_test', 'calculate_with_negatives', dtInt32, [])
        .BeginBlock('negative_test', 'entry');

      // Create negative and positive integer values for safe arithmetic
      LNegative50 := IntegerValue('negative_test', -50, dtInt32);
      LPositive30 := IntegerValue('negative_test', 30, dtInt32);
      LNegative2 := IntegerValue('negative_test', -2, dtInt32);

      // First operation: -50 + 30 = -20
      LSum := Add('negative_test', LNegative50, LPositive30, 'negative_sum');

      // Second operation: -20 * -2 = 40
      LResult := Multiply('negative_test', LSum, LNegative2, 'final_result');

      ReturnValue('negative_test', LResult);

      EndBlock('negative_test')
      .EndFunction('negative_test');

      if ValidateModule('negative_test') then
      begin
        TLLUtils.PrintLn('Negative test: (-50 + 30) * -2 = %d', [ExecuteFunction('negative_test', 'calculate_with_negatives', []).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;


(**
 * Test: Mixed Type Arithmetic Operations
 * 
 * Description: This test demonstrates how to handle arithmetic operations between
 * different numeric types (integer and floating point) using type conversion
 * functions to ensure proper LLVM IR generation.
 *
 * Functions Demonstrated:
 * - IntToFloat() - Converts integer to floating point
 * - FAdd() - Floating point addition after type conversion
 * - IntegerValue() - Creating integer constants
 * - FloatValue() - Creating floating point constants
 *
 * LLVM Concepts Covered:
 * - Type conversion in LLVM IR (sitofp instruction)
 * - Mixed arithmetic requiring explicit type conversion
 * - Integer to floating point promotion
 * - Type safety in LLVM operations
 *
 * Expected Output: "Mixed types: 42 + 3.14 = 45.14"
 *
 * Takeaway: Learn how LLVM requires explicit type conversions for mixed-type
 * arithmetic, unlike higher-level languages that do implicit conversion.
 *)
class procedure  TTestArithmetic.TestMixedTypeArithmetic();
var
  LIntVal, LFloatVal, LConvertedInt, LResult: TLLValue;
begin
  // Demo: Mixing integer and floating point arithmetic
  // Shows how to convert types for mixed arithmetic operations
  with TLLVM.Create() do
  begin
    try
      CreateModule('mixed_types')
      .BeginFunction('mixed_types', 'add_mixed', dtFloat32, [])
        .BeginBlock('mixed_types', 'entry');
      
      // Create an integer value (42)
      LIntVal := IntegerValue('mixed_types', 42, dtInt32);
      
      // Create a floating point value (3.14)
      LFloatVal := FloatValue('mixed_types', 3.14, dtFloat32);
      
      // Convert integer to float for mixed arithmetic
      // Generates LLVM IR: "sitofp i32 42 to float"
      LConvertedInt := IntToFloat('mixed_types', LIntVal, dtFloat32);
      
      // Add the converted integer with float: 42.0 + 3.14
      // Generates LLVM IR: "fadd float %converted, 3.14"
      LResult := FAdd('mixed_types', LConvertedInt, LFloatVal);
      
      ReturnValue('mixed_types', LResult);
      
      EndBlock('mixed_types')
      .EndFunction('mixed_types');
      
      if ValidateModule('mixed_types') then
      begin
        // Result: 42.0 + 3.14 = 45.14
        TLLUtils.PrintLn('Mixed types: 42 + 3.14 = %.2f', [ExecuteFunction('mixed_types', 'add_mixed', []).AsType<Single>]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Arithmetic Value Naming
 * 
 * Description: This test demonstrates the importance of proper value naming in LLVM IR
 * generation. It shows how meaningful names help with debugging and understanding
 * the generated IR code, and how names appear in the intermediate representation.
 *
 * Functions Demonstrated:
 * - Add() with named intermediate results
 * - Multiply() with descriptive operation names
 * - Proper LLVM value naming conventions
 *
 * LLVM Concepts Covered:
 * - LLVM value naming and identification
 * - Intermediate result naming for debugging
 * - How names appear in generated IR (%sum, %product, etc.)
 * - Best practices for readable LLVM IR
 *
 * Expected Output: "Named operations: (5 + 3) * 2 = 16"
 *
 * Takeaway: Learn how proper naming makes LLVM IR more readable and debuggable,
 * essential for complex code generation and optimizatiTPaCodeGensis.
 *)
class procedure TTestArithmetic.TestArithmeticNaming();
var
  LParamA, LParamB, LParamC, LSum, LProduct: TLLValue;
begin
  // Demo: Proper naming of arithmetic operations and intermediate values
  // Shows how meaningful names improve IR readability and debugging
  with TLLVM.Create() do
  begin
    try
      CreateModule('naming_demo')
      .BeginFunction('naming_demo', 'calculate_expression', dtInt32, 
        [Param('first', dtInt32), Param('second', dtInt32), Param('multiplier', dtInt32)])
        .BeginBlock('naming_demo', 'calculation');
      
      // Get well-named parameters
      LParamA := GetParameter('naming_demo', 'first');
      LParamB := GetParameter('naming_demo', 'second');
      LParamC := GetParameter('naming_demo', 'multiplier');
      
      // Add with descriptive name: generates "add i32 %first, %second" -> %sum
      LSum := Add('naming_demo', LParamA, LParamB, 'sum');
      
      // Multiply the sum with descriptive name: "mul i32 %sum, %multiplier" -> %product
      LProduct := Multiply('naming_demo', LSum, LParamC, 'final_product');
      
      // Return the well-named final result
      ReturnValue('naming_demo', LProduct);
      
      EndBlock('naming_demo')
      .EndFunction('naming_demo');
      
      if ValidateModule('naming_demo') then
      begin
        // Calculate: (5 + 3) * 2 = 16
        TLLUtils.PrintLn('Named operations: (5 + 3) * 2 = %d',
          [ExecuteFunction('naming_demo', 'calculate_expression', [5, 3, 2]).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

end.
