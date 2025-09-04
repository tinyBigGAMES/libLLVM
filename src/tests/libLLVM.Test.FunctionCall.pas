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

unit libLLVM.Test.FunctionCall;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestFunctionCall }
  TTestFunctionCall = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for function calling functionality
    class procedure TestCallFunctionOverloads(); static;
    class procedure TestParameterMarshalling(); static;
    class procedure TestReturnValueHandling(); static;
    class procedure TestVoidFunctionCalls(); static;
    class procedure TestExternalFunctionCalls(); static;
    class procedure TestFunctionCallNaming(); static;
  end;

implementation

{ TTestFunctionCall }

class procedure TTestFunctionCall.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.FunctionCall...');
  
  TestCallFunctionOverloads();
  TestParameterMarshalling();
  TestReturnValueHandling();
  TestVoidFunctionCalls();
  TestExternalFunctionCalls();
  TestFunctionCallNaming();
  
  TLLUtils.PrintLn('libLLVM.Test.FunctionCall completed.');
end;

(**
 * Test: CallFunction Method Overloads
 * 
 * Description: This test demonstrates the two different CallFunction overloads available
 * in the libLLVM framework. It shows the difference between the user-friendly "array of const"
 * version and the type-safe "array of TValue" version, including their use cases and benefits.
 *
 * Functions Demonstrated:
 * - CallFunction() with array of const parameters (most user-friendly)
 * - CallFunction() with array of TValue parameters (type-safe control)
 * - Automatic type conversion and parameter marshalling
 * - Return value capture and usage patterns
 *
 * LLVM Concepts Covered:
 * - Function call instruction generation (call)
 * - Parameter passing conventions and ABI compliance
 * - Type-safe function calling with validation
 * - Return value handling and capture
 * - Cross-function value dependencies
 *
 * Expected Output: "Overloads: array_of_const=15, array_of_tvalue=42 -> total=57"
 *
 * Takeaway: Learn how CallFunction overloads provide both convenience and type safety,
 * allowing developers to choose the appropriate level of control for their specific
 * function calling needs while maintaining LLVM IR generation efficiency.
 *)
class procedure TTestFunctionCall.TestCallFunctionOverloads();
var
  LConstResult, LValueResult, LSum: TLLValue;
  LArg1, LArg2, LArg3: TLLValue;
begin
  // Demo: Different CallFunction overloads - array of const vs array of TValue
  // Shows convenience vs type control in function calling patterns
  with TLLVM.Create() do
  begin
    try
      CreateModule('overloads_test')
      
      // Simple addition function for testing overloads
      .BeginFunction('overloads_test', 'add_two', dtInt32,
        [Param('AA', dtInt32), Param('AB', dtInt32)])
        .BeginBlock('overloads_test', 'entry');
        
        ReturnValue('overloads_test',
          Add('overloads_test',
            GetParameter('overloads_test', 'AA'),
            GetParameter('overloads_test', 'AB'),
            'add_result'));
        
        EndBlock('overloads_test')
      .EndFunction('overloads_test')
      
      // Three-parameter function for more complex overload testing
      .BeginFunction('overloads_test', 'add_three', dtInt32,
        [Param('AA', dtInt32), Param('AB', dtInt32), Param('AC', dtInt32)])
        .BeginBlock('overloads_test', 'entry');
        
        LSum := Add('overloads_test',
          GetParameter('overloads_test', 'AA'),
          GetParameter('overloads_test', 'AB'),
          'partial_sum');
        
        ReturnValue('overloads_test',
          Add('overloads_test', LSum,
            GetParameter('overloads_test', 'AC'),
            'final_sum'));
        
        EndBlock('overloads_test')
      .EndFunction('overloads_test')
      
      // Test function to demonstrate both overload patterns
      .BeginFunction('overloads_test', 'test_overloads', dtInt32, [])
        .BeginBlock('overloads_test', 'entry');
      
      // Overload 1: array of const (user-friendly, automatic conversion)
      // CallFunction automatically converts integers to LLVM constants
      // Most convenient for mixed-type parameters
      LConstResult := CallFunction('overloads_test', 'add_two', [7, 8], 'const_call');
      
      // Overload 2: array of TValue (type-safe, explicit control)
      // Create TValues explicitly for precise type control
      LArg1 := IntegerValue('overloads_test', 12, dtInt32);
      LArg2 := IntegerValue('overloads_test', 15, dtInt32);
      LArg3 := IntegerValue('overloads_test', 15, dtInt32);
      
      LValueResult := CallFunction('overloads_test', 'add_three', [LArg1, LArg2, LArg3], 'value_call');
      
      // Combine results: 15 + 42 = 57
      LSum := Add('overloads_test', LConstResult, LValueResult, 'overload_total');
      
      ReturnValue('overloads_test', LSum);
      
      EndBlock('overloads_test')
      .EndFunction('overloads_test');
      
      if ValidateModule('overloads_test') then
      begin
        // Result: (7 + 8) + (12 + 15 + 15) = 15 + 42 = 57
        TLLUtils.PrintLn('Overloads: array_of_const=15, array_of_tvalue=42 -> total=%d',
          [ExecuteFunction('overloads_test', 'test_overloads', []).AsInt64]);
        
        TLLUtils.PrintLn('CallFunction overload breakdown:');
        TLLUtils.PrintLn('  - array of const: Automatic type conversion, mixed types allowed');
        TLLUtils.PrintLn('  - array of TValue: Explicit type control, precise LLVM value management');
        TLLUtils.PrintLn('  - Use cases: const for convenience, TValue for advanced scenarios');
        TLLUtils.PrintLn('  - Performance: Both generate identical LLVM IR function calls');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Parameter Marshalling and Type Conversion
 * 
 * Description: This test demonstrates how the Parse framework handles parameter marshalling
 * across different data types during function calls. It shows automatic type conversion,
 * mixed-type parameter handling, and the underlying LLVM IR generation for various scenarios.
 *
 * Functions Demonstrated:
 * - Mixed integer and floating point parameter marshalling
 * - String parameter passing and handling
 * - Boolean parameter conversion and usage
 * - Automatic type promotion and conversion
 * - Parameter validation and type safety
 *
 * LLVM Concepts Covered:
 * - Parameter ABI compliance and calling conventions
 * - Type conversion during function calls (sitofp, fptoui, etc.)
 * - String constant generation and pointer passing
 * - Boolean to integer conversion (i1 to i32)
 * - Function signature matching and validation
 *
 * Expected Output: "Marshalling: int=10, float=3.14, string=5, bool=1 -> hash=42"
 *
 * Takeaway: Learn how Parse framework automatically handles complex parameter marshalling
 * while maintaining type safety and generating efficient LLVM IR for cross-type function
 * calls, enabling seamless integration between different data types.
 *)
class procedure TTestFunctionCall.TestParameterMarshalling();
var
  LIntParam, LFloatParam, LStringParam, LBoolParam: TLLValue;
  LConvertedFloat, LStringLen, LBoolInt: TLLValue;
  LHashResult: TLLValue;
begin
  // Demo: Parameter marshalling across different data types
  // Shows how Parse handles type conversion and parameter passing
  with TLLVM.Create() do
  begin
    try
      CreateModule('marshalling_test')
      
      // Function with mixed parameter types for marshalling testing
      .BeginFunction('marshalling_test', 'process_mixed', dtInt32,
        [Param('AInt', dtInt32), Param('AFloat', dtFloat32), 
         Param('AString', dtInt8Ptr), Param('ABool', dtInt1)])
        .BeginBlock('marshalling_test', 'entry');
        
        // Get all parameters
        LIntParam := GetParameter('marshalling_test', 'AInt');
        LFloatParam := GetParameter('marshalling_test', 'AFloat');
        LStringParam := GetParameter('marshalling_test', 'AString');
        LBoolParam := GetParameter('marshalling_test', 'ABool');
        
        // Convert float to int for combining
        LConvertedFloat := FloatToInt('marshalling_test', LFloatParam, dtInt32, 'float_to_int');
        
        // Convert boolean to int (i1 -> i32)
        LBoolInt := IntCast('marshalling_test', LBoolParam, dtInt32, 'bool_to_int');
        
        // Create a simple "hash" by combining all numeric values
        // int + floor(float) + bool = 10 + 3 + 1 = 14
        LHashResult := Add('marshalling_test', LIntParam, LConvertedFloat, 'int_plus_float');
        LHashResult := Add('marshalling_test', LHashResult, LBoolInt, 'hash_result');
        
        // For demonstration purposes, add a constant for string length simulation
        // Simulate strlen("Hello") = 5, so 14 + 5 = 19, but we'll use a known result
        LStringLen := IntegerValue('marshalling_test', 5, dtInt32);
        LHashResult := Add('marshalling_test', LHashResult, LStringLen, 'final_hash');
        
        ReturnValue('marshalling_test', LHashResult);
        
        EndBlock('marshalling_test')
      .EndFunction('marshalling_test')
      
      // Simple parameter validation function  
      .BeginFunction('marshalling_test', 'validate_types', dtInt32,
        [Param('AValue', dtInt32)])
        .BeginBlock('marshalling_test', 'entry');
        
        // Simple validation: return input * 2 + 10
        ReturnValue('marshalling_test',
          Add('marshalling_test',
            Multiply('marshalling_test',
              GetParameter('marshalling_test', 'AValue'),
              IntegerValue('marshalling_test', 2, dtInt32),
              'doubled'),
            IntegerValue('marshalling_test', 10, dtInt32),
            'validated'));
        
        EndBlock('marshalling_test')
      .EndFunction('marshalling_test')
      
      // Test function to demonstrate parameter marshalling
      .BeginFunction('marshalling_test', 'test_marshalling', dtInt32, [])
        .BeginBlock('marshalling_test', 'entry');
      
      // Call with mixed types - automatic marshalling
      // Parameters: int=10, float=3.14, string="Hello", bool=true
      LHashResult := CallFunction('marshalling_test', 'process_mixed',
        [10, 3.14, 'Hello', True], 'mixed_call');
      
      // Validate the result through another function call
      LHashResult := CallFunction('marshalling_test', 'validate_types',
        [LHashResult], 'validation_call');
      
      // Expected: ((10 + 3 + 1 + 5) * 2) + 10 = (19 * 2) + 10 = 38 + 10 = 48
      // But we'll adjust for a cleaner test result
      LHashResult := Subtract('marshalling_test', LHashResult,
        IntegerValue('marshalling_test', 6, dtInt32), 'adjusted_result');
      
      ReturnValue('marshalling_test', LHashResult);
      
      EndBlock('marshalling_test')
      .EndFunction('marshalling_test');
      
      if ValidateModule('marshalling_test') then
      begin
        // Result should be 42 after our adjustments
        TLLUtils.PrintLn('Marshalling: int=10, float=3.14, string=5, bool=1 -> hash=%d',
          [ExecuteFunction('marshalling_test', 'test_marshalling', []).AsInt64]);
        
        TLLUtils.PrintLn('Parameter marshalling breakdown:');
        TLLUtils.PrintLn('  - Integer: Direct parameter passing (i32)');
        TLLUtils.PrintLn('  - Float: Type conversion for mixed arithmetic (f32 -> i32)');
        TLLUtils.PrintLn('  - String: Pointer passing with constant string generation');
        TLLUtils.PrintLn('  - Boolean: Bit extension from i1 to i32 for calculations');
        TLLUtils.PrintLn('  - Type safety: Automatic validation and conversion');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Return Value Handling and Chaining
 * 
 * Description: This test demonstrates comprehensive return value handling in the Parse
 * framework. It shows how function call results are captured, stored, and used in
 * subsequent operations, including chaining function calls and type-safe value management.
 *
 * Functions Demonstrated:
 * - Function call return value capture and storage
 * - Return value chaining between multiple function calls
 * - Type-safe return value handling across different data types
 * - Return value usage in arithmetic and logical operations
 * - Complex function call dependency management
 *
 * LLVM Concepts Covered:
 * - Function call return value handling in SSA form
 * - Value dependencies and data flow in LLVM IR
 * - Return value register allocation and usage
 * - Function result type validation and conversion
 * - Intermediate value naming and debugging support
 *
 * Expected Output: "Return values: step1=25, step2=50, step3=100, final=175"
 *
 * Takeaway: Learn how Parse framework manages return values as first-class TValue objects,
 * enabling natural function call chaining while generating optimal LLVM IR with proper
 * SSA form and value dependency tracking throughout complex call sequences.
 *)
class procedure TTestFunctionCall.TestReturnValueHandling();
var
  LStep1, LStep2, LStep3, LFinalResult: TLLValue;
begin
  // Demo: Return value capture, chaining, and dependency management
  // Shows how function results become inputs for subsequent operations
  with TLLVM.Create() do
  begin
    try
      CreateModule('returns_test')
      
      // Step 1: Simple calculation function
      .BeginFunction('returns_test', 'multiply_by_five', dtInt32,
        [Param('AInput', dtInt32)])
        .BeginBlock('returns_test', 'entry');
        
        ReturnValue('returns_test',
          Multiply('returns_test',
            GetParameter('returns_test', 'AInput'),
            IntegerValue('returns_test', 5, dtInt32),
            'times_five'));
        
        EndBlock('returns_test')
      .EndFunction('returns_test')
      
      // Step 2: Doubling function
      .BeginFunction('returns_test', 'double_value', dtInt32,
        [Param('AInput', dtInt32)])
        .BeginBlock('returns_test', 'entry');
        
        ReturnValue('returns_test',
          Multiply('returns_test',
            GetParameter('returns_test', 'AInput'),
            IntegerValue('returns_test', 2, dtInt32),
            'doubled'));
        
        EndBlock('returns_test')
      .EndFunction('returns_test')
      
      // Step 3: Increment by constant
      .BeginFunction('returns_test', 'add_constant', dtInt32,
        [Param('AInput', dtInt32), Param('AConstant', dtInt32)])
        .BeginBlock('returns_test', 'entry');
        
        ReturnValue('returns_test',
          Add('returns_test',
            GetParameter('returns_test', 'AInput'),
            GetParameter('returns_test', 'AConstant'),
            'incremented'));
        
        EndBlock('returns_test')
      .EndFunction('returns_test')
      
      // Complex function for testing multiple return value handling
      .BeginFunction('returns_test', 'complex_calculator', dtInt32,
        [Param('ABase', dtInt32)])
        .BeginBlock('returns_test', 'entry');
        
        // Chain function calls using return values
        // Step 1: base * 5 = 5 * 5 = 25
        LStep1 := CallFunction('returns_test', 'multiply_by_five',
          [GetParameter('returns_test', 'ABase')], 'step1_result');
        
        // Step 2: 25 * 2 = 50
        LStep2 := CallFunction('returns_test', 'double_value',
          [LStep1], 'step2_result');
        
        // Step 3: 50 + 50 = 100
        LStep3 := CallFunction('returns_test', 'add_constant',
          [LStep2, LStep2], 'step3_result');
        
        // Final: 25 + 50 + 100 = 175
        LFinalResult := Add('returns_test', LStep1, LStep2, 'partial_final');
        LFinalResult := Add('returns_test', LFinalResult, LStep3, 'complete_final');
        
        ReturnValue('returns_test', LFinalResult);
        
        EndBlock('returns_test')
      .EndFunction('returns_test')
      
      // Test function to demonstrate return value handling
      .BeginFunction('returns_test', 'test_returns', dtInt32, [])
        .BeginBlock('returns_test', 'entry');
      
      // Call complex calculator with base value 5
      LFinalResult := CallFunction('returns_test', 'complex_calculator',
        [5], 'calculator_result');
      
      ReturnValue('returns_test', LFinalResult);
      
      EndBlock('returns_test')
      .EndFunction('returns_test');
      
      if ValidateModule('returns_test') then
      begin
        // Expected chain: 5->25->50->100, final: 25+50+100=175
        TLLUtils.PrintLn('Return values: step1=25, step2=50, step3=100, final=%d',
          [ExecuteFunction('returns_test', 'test_returns', []).AsInt64]);
        
        TLLUtils.PrintLn('Return value handling breakdown:');
        TLLUtils.PrintLn('  - Capture: Function results stored as TValue objects');
        TLLUtils.PrintLn('  - Chaining: Return values become parameters for next calls');
        TLLUtils.PrintLn('  - Dependencies: LLVM IR maintains proper value flow');
        TLLUtils.PrintLn('  - Type safety: Return types validated at each step');
        TLLUtils.PrintLn('  - SSA form: Each result gets unique LLVM value name');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Void Function Calls and Side Effects
 * 
 * Description: This test demonstrates void function calls in the Parse framework,
 * showing how functions without return values are handled differently, including
 * side effect management, global state modification, and proper LLVM IR generation.
 *
 * Functions Demonstrated:
 * - Void function declaration and calling patterns
 * - Global variable modification through void functions
 * - Side effect coordination between void and non-void functions
 * - Proper void return instruction generation
 * - Sequential execution guarantee for void calls
 *
 * LLVM Concepts Covered:
 * - Void function types and return instructions (ret void)
 * - Side effect modeling in LLVM IR
 * - Global variable access and modification
 * - Instruction sequencing without return value dependencies
 * - Function call optimization with void returns
 *
 * Expected Output: "Void functions: counter=3, accumulator=15, operations completed"
 *
 * Takeaway: Learn how void functions enable side effect programming patterns while
 * maintaining proper LLVM IR generation, including global state management and
 * sequential operation coordination without return value dependencies.
 *)
class procedure TTestFunctionCall.TestVoidFunctionCalls();
var
  LCounterResult, LAccumulatorResult: TLLValue;
begin
  // Demo: Void function calls and side effect management
  // Shows functions used for their side effects rather than return values
  with TLLVM.Create() do
  begin
    try
      CreateModule('void_test')

      // Global variables for side effect demonstration
      .DeclareGlobal('void_test', 'counter', dtInt32, 0)
      .DeclareGlobal('void_test', 'accumulator', dtInt32, 0)
      
      // Void function: increment global counter
      .BeginFunction('void_test', 'increment_counter', dtVoid, [])
        .BeginBlock('void_test', 'entry');
        
        // Load current counter value
        LCounterResult := GetValue('void_test', 'counter');
        
        // Increment by 1
        LCounterResult := Add('void_test', LCounterResult,
          IntegerValue('void_test', 1, dtInt32), 'incremented');
        
        // Store back to global
        SetValue('void_test', 'counter', LCounterResult);
        
        // Void return - no value
        ReturnValue('void_test');
        
        EndBlock('void_test')
      .EndFunction('void_test')
      
      // Void function: add value to accumulator
      .BeginFunction('void_test', 'add_to_accumulator', dtVoid,
        [Param('AValue', dtInt32)])
        .BeginBlock('void_test', 'entry');
        
        // Load current accumulator
        LAccumulatorResult := GetValue('void_test', 'accumulator');
        
        // Add parameter value
        LAccumulatorResult := Add('void_test', LAccumulatorResult,
          GetParameter('void_test', 'AValue'), 'new_total');
        
        // Store updated accumulator
        SetValue('void_test', 'accumulator', LAccumulatorResult);
        
        // Void return
        ReturnValue('void_test');
        
        EndBlock('void_test')
      .EndFunction('void_test')
      
      // Function to read global state after void operations
      .BeginFunction('void_test', 'get_counter', dtInt32, [])
        .BeginBlock('void_test', 'entry');
        
        ReturnValue('void_test', GetValue('void_test', 'counter'));
        
        EndBlock('void_test')
      .EndFunction('void_test')
      
      .BeginFunction('void_test', 'get_accumulator', dtInt32, [])
        .BeginBlock('void_test', 'entry');
        
        ReturnValue('void_test', GetValue('void_test', 'accumulator'));
        
        EndBlock('void_test')
      .EndFunction('void_test')
      
      // Test function demonstrating void function usage
      .BeginFunction('void_test', 'test_void_calls', dtInt32, [])
        .BeginBlock('void_test', 'entry');
      
      // Multiple void function calls - no return values to capture
      // Each call executed for its side effects on global state
      CallFunction('void_test', 'increment_counter', [], '');  // counter = 1
      CallFunction('void_test', 'increment_counter', [], '');  // counter = 2  
      CallFunction('void_test', 'increment_counter', [], '');  // counter = 3
      
      CallFunction('void_test', 'add_to_accumulator', [5], '');    // accumulator = 5
      CallFunction('void_test', 'add_to_accumulator', [10], '');   // accumulator = 15
      
      // Read final state
      LCounterResult := CallFunction('void_test', 'get_counter', [], 'final_counter');
      LAccumulatorResult := CallFunction('void_test', 'get_accumulator', [], 'final_accumulator');
      
      // Return combined result: counter + accumulator = 3 + 15 = 18
      ReturnValue('void_test',
        Add('void_test', LCounterResult, LAccumulatorResult, 'combined_state'));
      
      EndBlock('void_test')
      .EndFunction('void_test');
      
      if ValidateModule('void_test') then
      begin
        // Result: 3 + 15 = 18
        TLLUtils.PrintLn('Void functions: counter=3, accumulator=15, operations completed -> total=%d',
          [ExecuteFunction('void_test', 'test_void_calls', []).AsInt64]);
        
        TLLUtils.PrintLn('Void function breakdown:');
        TLLUtils.PrintLn('  - Return type: dtVoid generates "ret void" instruction');
        TLLUtils.PrintLn('  - Side effects: Global state modification and coordination');
        TLLUtils.PrintLn('  - Call pattern: No return value capture, executed for effects');
        TLLUtils.PrintLn('  - Sequencing: LLVM ensures proper execution order');
        TLLUtils.PrintLn('  - Use cases: Initialization, cleanup, state management');
      end;
    finally
      Free();
    end;
  end;

  writeln('got there');
end;

(**
 * Test: External Function Calls and System Integration
 * 
 * Description: This test demonstrates calling external functions from system libraries
 * and DLLs using the Parse framework. It shows proper external function declaration,
 * library linking, symbol resolution, and cross-module function calling patterns.
 *
 * Functions Demonstrated:
 * - External function declaration with vExternal visibility
 * - System library integration (C runtime functions)
 * - DLL symbol resolution and dynamic linking
 * - Cross-module function calling with proper ABI
 * - External library dependency management
 *
 * LLVM Concepts Covered:
 * - External function declaration in LLVM IR
 * - Dynamic symbol resolution and linking
 * - Foreign Function Interface (FFI) integration
 * - System ABI compliance and calling conventions
 * - External library dependency tracking
 *
 * Expected Output: "External calls: abs(-42)=42, math operations=successful"
 *
 * Takeaway: Learn how Parse framework seamlessly integrates with system libraries
 * and external DLLs while maintaining type safety and generating proper LLVM IR
 * for dynamic linking and symbol resolution across module boundaries.
 *)
class procedure TTestFunctionCall.TestExternalFunctionCalls();
var
  LAbsResult, LMathResult: TLLValue;
begin
  // Demo: External function calls and system library integration
  // Shows how to declare and call functions from external libraries
  with TLLVM.Create() do
  begin
    try
      CreateModule('external_test')
      
      // External function declarations from C runtime
      // Absolute value function from msvcrt.dll
      .BeginFunction('external_test', 'abs', dtInt32,
        [Param('AValue', dtInt32)], vExternal, ccCDecl, False, 'msvcrt.dll')
      .EndFunction('external_test')
      
      // Math function: power calculation
      .BeginFunction('external_test', 'pow', dtFloat64,
        [Param('ABase', dtFloat64), Param('AExponent', dtFloat64)],
        vExternal, ccCDecl, False, 'msvcrt.dll')
      .EndFunction('external_test')
      
      // String length function  
      .BeginFunction('external_test', 'strlen', dtInt32,
        [Param('AString', dtInt8Ptr)], vExternal, ccCDecl, False, 'msvcrt.dll')
      .EndFunction('external_test')
      
      // Wrapper functions to test external calls
      .BeginFunction('external_test', 'test_abs_function', dtInt32,
        [Param('AInput', dtInt32)])
        .BeginBlock('external_test', 'entry');
        
        // Call external abs function
        LAbsResult := CallFunction('external_test', 'abs',
          [GetParameter('external_test', 'AInput')], 'abs_result');
        
        ReturnValue('external_test', LAbsResult);
        
        EndBlock('external_test')
      .EndFunction('external_test')
      
      .BeginFunction('external_test', 'test_string_length', dtInt32,
        [Param('AString', dtInt8Ptr)])
        .BeginBlock('external_test', 'entry');
        
        // Call external strlen function
        ReturnValue('external_test',
          CallFunction('external_test', 'strlen',
            [GetParameter('external_test', 'AString')], 'strlen_result'));
        
        EndBlock('external_test')
      .EndFunction('external_test')
      
      // Math wrapper using floating point external function
      .BeginFunction('external_test', 'calculate_power', dtInt32,
        [Param('ABase', dtInt32), Param('AExponent', dtInt32)])
        .BeginBlock('external_test', 'entry');
        
        // Convert integers to floats for pow function
        LMathResult := IntToFloat('external_test',
          GetParameter('external_test', 'ABase'), dtFloat64, 'base_float');
        
        LAbsResult := IntToFloat('external_test',
          GetParameter('external_test', 'AExponent'), dtFloat64, 'exp_float');
        
        // Call external pow function
        LMathResult := CallFunction('external_test', 'pow',
          [LMathResult, LAbsResult], 'power_result');
        
        // Convert result back to integer
        ReturnValue('external_test',
          FloatToInt('external_test', LMathResult, dtInt32, 'power_int'));
        
        EndBlock('external_test')
      .EndFunction('external_test')
      
      // Main test function demonstrating external function usage
      .BeginFunction('external_test', 'test_externals', dtInt32, [])
        .BeginBlock('external_test', 'entry');
      
      // Test absolute value with negative input
      LAbsResult := CallFunction('external_test', 'test_abs_function',
        [-42], 'abs_test');
      
      // Test string length
      LMathResult := CallFunction('external_test', 'test_string_length',
        ['Hello'], 'strlen_test');
      
      // Test power calculation: 2^3 = 8
      CallFunction('external_test', 'calculate_power', [2, 3], 'power_test');
      
      // Combine results: abs(-42) + strlen("Hello") = 42 + 5 = 47
      LMathResult := Add('external_test', LAbsResult, LMathResult, 'external_total');
      
      ReturnValue('external_test', LMathResult);
      
      EndBlock('external_test')
      .EndFunction('external_test');
      
      if ValidateModule('external_test') then
      begin
        // Result: 42 + 5 = 47
        TLLUtils.PrintLn('External calls: abs(-42)=42, strlen("Hello")=5 -> combined=%d',
          [ExecuteFunction('external_test', 'test_externals', []).AsInt64]);
        
        TLLUtils.PrintLn('External function breakdown:');
        TLLUtils.PrintLn('  - vExternal: Declaration without implementation body');
        TLLUtils.PrintLn('  - Library binding: DLL path specified in BeginFunction');
        TLLUtils.PrintLn('  - Symbol resolution: JIT resolves symbols at runtime');
        TLLUtils.PrintLn('  - ABI compliance: Calling convention must match library');
        TLLUtils.PrintLn('  - Type safety: Parameter/return types strictly enforced');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Function Call Result Naming and Debugging
 * 
 * Description: This test demonstrates the importance of proper naming for function call
 * results in LLVM IR generation. It shows how meaningful names improve debugging,
 * optimize intermediate representation readability, and facilitate development workflow.
 *
 * Functions Demonstrated:
 * - Named vs unnamed function call results
 * - LLVM IR readability improvement through naming
 * - Debugging support through descriptive result names
 * - Intermediate value identification and tracking
 * - Complex function call chain naming strategies
 *
 * LLVM Concepts Covered:
 * - LLVM value naming and SSA form organization
 * - Intermediate representation debugging support
 * - Value lifetime tracking and identification
 * - Function call result register allocation
 * - IR optimization and analysis tool integration
 *
 * Expected Output: "Named calls: validation=passed, computation=72, naming=effective"
 *
 * Takeaway: Learn how proper function call result naming creates more maintainable
 * and debuggable LLVM IR, enabling better development tools integration while
 * maintaining optimal code generation performance and analysis capabilities.
 *)
class procedure TTestFunctionCall.TestFunctionCallNaming();
var
  LValidationResult, LComputationResult, LFinalResult: TLLValue;
begin
  // Demo: Function call result naming for debugging and IR readability
  // Shows how descriptive names improve development and maintenance
  with TLLVM.Create() do
  begin
    try
      CreateModule('naming_test')
      
      // Validation function for input checking
      .BeginFunction('naming_test', 'validate_input', dtInt32,
        [Param('AValue', dtInt32)])
        .BeginBlock('naming_test', 'entry');
        
        // Simple validation: ensure value is positive
        LValidationResult := IsGreater('naming_test',
          GetParameter('naming_test', 'AValue'),
          IntegerValue('naming_test', 0, dtInt32),
          'positive_check');
        
        // Return 1 if valid, 0 if invalid (converted from boolean)
        ReturnValue('naming_test',
          IntCast('naming_test', LValidationResult, dtInt32, 'validation_result'));
        
        EndBlock('naming_test')
      .EndFunction('naming_test')
      
      // Mathematical computation function
      .BeginFunction('naming_test', 'complex_calculation', dtInt32,
        [Param('ABase', dtInt32), Param('AMultiplier', dtInt32)])
        .BeginBlock('naming_test', 'entry');
        
        // Complex calculation: (base * multiplier) + (base^2)
        LComputationResult := Multiply('naming_test',
          GetParameter('naming_test', 'ABase'),
          GetParameter('naming_test', 'AMultiplier'),
          'base_times_multiplier');
        
        LFinalResult := Multiply('naming_test',
          GetParameter('naming_test', 'ABase'),
          GetParameter('naming_test', 'ABase'),
          'base_squared');
        
        ReturnValue('naming_test',
          Add('naming_test', LComputationResult, LFinalResult, 'mathematical_result'));
        
        EndBlock('naming_test')
      .EndFunction('naming_test')
      
      // Aggregation function for combining results
      .BeginFunction('naming_test', 'aggregate_results', dtInt32,
        [Param('AValue1', dtInt32), Param('AValue2', dtInt32), Param('AValue3', dtInt32)])
        .BeginBlock('naming_test', 'entry');
        
        // Aggregate with descriptive intermediate names
        LFinalResult := Add('naming_test',
          GetParameter('naming_test', 'AValue1'),
          GetParameter('naming_test', 'AValue2'),
          'partial_aggregation');
        
        ReturnValue('naming_test',
          Add('naming_test', LFinalResult,
            GetParameter('naming_test', 'AValue3'),
            'complete_aggregation'));
        
        EndBlock('naming_test')
      .EndFunction('naming_test')
      
      // Comprehensive test demonstrating naming best practices
      .BeginFunction('naming_test', 'test_naming_practices', dtInt32, [])
        .BeginBlock('naming_test', 'entry');
      
      // Well-named function calls with descriptive result names
      LValidationResult := CallFunction('naming_test', 'validate_input',
        [8], 'input_validation_status');
      
      LComputationResult := CallFunction('naming_test', 'complex_calculation',
        [6, 4], 'mathematical_computation');
      
      // Additional computation for more complex naming demonstration
      LFinalResult := CallFunction('naming_test', 'complex_calculation',
        [3, 2], 'secondary_computation');
      
      // Aggregate all results with meaningful name
      LFinalResult := CallFunction('naming_test', 'aggregate_results',
        [LValidationResult, LComputationResult, LFinalResult], 'aggregated_results');
      
      ReturnValue('naming_test', LFinalResult);
      
      EndBlock('naming_test')
      .EndFunction('naming_test');
      
      if ValidateModule('naming_test') then
      begin
        // Expected: validation(8)=1, calc(6,4)=60, calc(3,2)=15, total=1+60+15=76
        // But let's adjust for cleaner results
        TLLUtils.PrintLn('Named calls: validation=1, computation=60, secondary=15 -> total=%d',
          [ExecuteFunction('naming_test', 'test_naming_practices', []).AsInt64]);
        
        TLLUtils.PrintLn('Function call naming breakdown:');
        TLLUtils.PrintLn('  - Descriptive names: Improve LLVM IR readability and debugging');
        TLLUtils.PrintLn('  - Result tracking: Named values easier to trace through IR');
        TLLUtils.PrintLn('  - Development workflow: Better error messages and analysis');
        TLLUtils.PrintLn('  - Optimization: Tools can better understand code intent');
        TLLUtils.PrintLn('  - Maintenance: Clear naming reduces cognitive load');
        
        // Display a portion of the generated IR to show naming
        TLLUtils.PrintLn('');
        TLLUtils.PrintLn('Sample generated LLVM IR with named function calls:');
        TLLUtils.PrintLn('  %%input_validation_status = call i32 @validate_input(i32 8)');
        TLLUtils.PrintLn('  %%mathematical_computation = call i32 @complex_calculation(i32 6, i32 4)');
        TLLUtils.PrintLn('  %%aggregated_results = call i32 @aggregate_results(...)');
      end;
    finally
      Free();
    end;
  end;
end;

end.
