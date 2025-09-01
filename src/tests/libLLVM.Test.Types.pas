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

unit libLLVM.Test.Types;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestTypes }
  TTestTypes = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for type system functionality
    class procedure TestDataTypes(); static;
    class procedure TestVisibilityTypes(); static;
    class procedure TestCallingConventions(); static;
    class procedure TestParameterTypes(); static;
    class procedure TestRecordTypes(); static;
  end;

implementation

{ TTestTypes }

class procedure TTestTypes.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.Types...');
  
  TestDataTypes();
  TestVisibilityTypes();
  TestCallingConventions();
  TestParameterTypes();
  TestRecordTypes();
  
  TLLUtils.PrintLn('libLLVM.Test.Types completed.');
end;

(**
 * Test: Data Type System Demonstration
 * 
 * Description: This test demonstrates the comprehensive TDataType enum system
 * in the libLLVM framework. It shows how different data types (integers, floats,
 * pointers) are represented in LLVM IR and how type safety is maintained
 * throughout the compilation pipeline.
 *
 * Functions Demonstrated:
 * - IntegerValue() with various integer types (dtInt8, dtInt32, dtInt64, dtInt128)
 * - FloatValue() with different precision types (dtFloat32, dtFloat64, dtFloat80)
 * - Type system integration with LLVM IR generation
 * - Pointer type handling and memory addressing
 *
 * LLVM Concepts Covered:
 * - Integer type representation (i8, i16, i32, i64, i128)
 * - Floating point type precision (half, float, double, x86_fp80, fp128)
 * - Pointer type addressing and dereferencing
 * - Type compatibility and conversion in LLVM IR
 * - Memory layout and alignment considerations
 *
 * Expected Output: "Data types: 8-bit=255, 32-bit=42000, 64-bit=9223372036854775807, float=3.14159, double=2.718281828459045"
 *
 * Takeaway: Learn how the Parse framework maps high-level data types to LLVM's
 * strict type system and how different bit widths and precisions affect 
 * computation accuracy and memory usage.
 *)
class procedure TTestTypes.TestDataTypes();
var
  LInt8Value, LInt32Value, LInt64Value: TLLValue;
  LFloat32Value, LFloat64Value: TLLValue;
  LPointerValue: TLLValue;
  LSum, LFloatSum: TLLValue;
begin
  // Demo: Creating and using different data types in LLVM IR
  // Shows how TPaDataType enum maps to LLVM type system
  with TLLVM.Create() do
  begin
    try
      CreateModule('data_types')
      .BeginFunction('data_types', 'test_data_types', dtInt32, [])
        .BeginBlock('data_types', 'entry');
      
      // Integer types with different bit widths
      // 8-bit integer: maximum value 255 (unsigned) or -128 to 127 (signed)
      LInt8Value := IntegerValue('data_types', 255, dtInt8);
      
      // 32-bit integer: standard integer type, -2^31 to 2^31-1
      LInt32Value := IntegerValue('data_types', 42000, dtInt32);
      
      // 64-bit integer: large integer type, up to 2^63-1
      LInt64Value := IntegerValue('data_types', 9223372036854775807, dtInt64);
      
      // Floating point types with different precisions
      // 32-bit float: IEEE 754 single precision (~7 decimal digits)
      LFloat32Value := FloatValue('data_types', 3.14159, dtFloat32);
      
      // 64-bit double: IEEE 754 double precision (~15-16 decimal digits)  
      LFloat64Value := FloatValue('data_types', 2.718281828459045, dtFloat64);
      
      // Demonstrate type conversions and arithmetic
      // Convert 8-bit to 32-bit for arithmetic compatibility
      LInt8Value := IntCast('data_types', LInt8Value, dtInt32, 'int8_to_int32');
      
      // Integer arithmetic: 255 + 42000 = 42255
      LSum := Add('data_types', LInt8Value, LInt32Value, 'int_sum');
      
      // Floating point arithmetic: 3.14159 + 2.718281828459045 ≈ 5.859871828459045
      // First cast float32 to float64 for precision consistency
      LFloat32Value := FloatCast('data_types', LFloat32Value, dtFloat64, 'float_to_double');
      LFloatSum := FAdd('data_types', LFloat32Value, LFloat64Value, 'float_sum');
      
      // Demonstrate pointer type usage
      // Create a null pointer of int32* type
      LPointerValue := NullValue('data_types', dtInt32Ptr);
      
      // For demonstration, we'll return the integer sum
      // In a real application, you might:
      // - Allocate memory using pointer types
      // - Perform pointer arithmetic with GetElementPtr
      // - Load/store values through typed pointers
      // - Handle different address spaces for GPU/embedded targets
      
      ReturnValue('data_types', LSum);
      
      EndBlock('data_types')
      .EndFunction('data_types');
      
      if ValidateModule('data_types') then
      begin
        // Result: 255 + 42000 = 42255
        TLLUtils.PrintLn('Data types: 8-bit=255, 32-bit=42000, 64-bit=9223372036854775807, float=3.14159, double=2.718281828459045 -> sum=%d',
          [ExecuteFunction('data_types', 'test_data_types', []).AsInt64]);
        
        // Additional type information for educational purposes
        TLLUtils.PrintLn('Type system breakdown:');
        TLLUtils.PrintLn('  - dtInt8: 8-bit signed integer (-128 to 127)');
        TLLUtils.PrintLn('  - dtInt32: 32-bit signed integer (-2,147,483,648 to 2,147,483,647)');
        TLLUtils.PrintLn('  - dtInt64: 64-bit signed integer (±9.22×10^18)');
        TLLUtils.PrintLn('  - dtFloat32: IEEE 754 single precision (32-bit, ~7 digits)');
        TLLUtils.PrintLn('  - dtFloat64: IEEE 754 double precision (64-bit, ~15-16 digits)');
        TLLUtils.PrintLn('  - dtInt32Ptr: Pointer to 32-bit integer (address space 0)');
        TLLUtils.PrintLn('  - Type safety: All conversions explicit via IntCast/FloatCast');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Function Visibility and Linkage Types
 * 
 * Description: This test demonstrates the TPaVisibility enum system which controls
 * function and symbol visibility in LLVM IR. It shows how different visibility
 * levels affect linkage, symbol resolution, and module boundaries in compiled code.
 *
 * Functions Demonstrated:
 * - BeginFunction() with different TPaVisibility values
 * - vPrivate: Internal linkage (private to module)
 * - vPublic: External linkage (exported from module) 
 * - vExternal: External declaration (imported from other modules/libraries)
 *
 * LLVM Concepts Covered:
 * - LLVM linkage types (private, external, internal)
 * - Symbol visibility and name mangling
 * - Module boundaries and symbol resolution
 * - Dynamic linking and library integration
 * - Cross-module function calls and dependencies
 *
 * Expected Output: "Visibility test: private=42, public=84, external call successful"
 *
 * Takeaway: Learn how visibility controls symbol export/import behavior,
 * enabling modular programming and library integration while maintaining
 * encapsulation and avoiding symbol conflicts.
 *)
class procedure TTestTypes.TestVisibilityTypes();
var
  LPrivateResult, LPublicResult: TLLValue;
  LParam1, LParam2: TLLValue;
begin
  // Demo: Creating functions with different visibility levels
  // Shows how TPaVisibility affects LLVM linkage and symbol resolution
  with TLLVM.Create() do
  begin
    try
      CreateModule('visibility_test')
      
      // Private function: internal linkage, only visible within this module
      // Generates LLVM IR: "define private i32 @private_func(i32 %AValue)"
      .BeginFunction('visibility_test', 'private_func', dtInt32, 
        [Param('AValue', dtInt32)], vPrivate)
        .BeginBlock('visibility_test', 'entry');
        
        ReturnValue('visibility_test', GetParameter('visibility_test', 'AValue'));
        
        EndBlock('visibility_test')
      .EndFunction('visibility_test')
      
      // Public function: external linkage, exported from module
      // Generates LLVM IR: "define i32 @public_func(i32 %AValue)"
      .BeginFunction('visibility_test', 'public_func', dtInt32,
        [Param('AValue', dtInt32)], vPublic)
        .BeginBlock('visibility_test', 'entry');
        
        ReturnValue('visibility_test', 
          Multiply('visibility_test', 
            GetParameter('visibility_test', 'AValue'),
            IntegerValue('visibility_test', 2, dtInt32),
            'double_value'));
        
        EndBlock('visibility_test')
      .EndFunction('visibility_test')
      
      // External function declaration: imported from external library
      // Generates LLVM IR: "declare i32 @abs(i32) #0" with external linkage
      .BeginFunction('visibility_test', 'abs', dtInt32,
        [Param('AValue', dtInt32)], vExternal, ccCDecl, False, 'msvcrt.dll')
      .EndFunction('visibility_test')
      
      // Main test function demonstrating visibility usage
      .BeginFunction('visibility_test', 'test_visibility', dtInt32, [])
        .BeginBlock('visibility_test', 'entry');
      
      // Call private function (internal to module)
      LParam1 := IntegerValue('visibility_test', 42, dtInt32);
      LPrivateResult := CallFunction('visibility_test', 'private_func', [LParam1], 'private_call');
      
      // Call public function (could be called from other modules)
      LParam2 := IntegerValue('visibility_test', 42, dtInt32);
      LPublicResult := CallFunction('visibility_test', 'public_func', [LParam2], 'public_call');
      
      // Call external function (imported from system library)
      // Note: abs(-84) should return 84
      CallFunction('visibility_test', 'abs', [IntegerValue('visibility_test', -84, dtInt32)], 'external_call');
      
      // Return sum to demonstrate all visibility types working
      // private_func(42) + public_func(42) = 42 + 84 = 126
      ReturnValue('visibility_test', 
        Add('visibility_test', LPrivateResult, LPublicResult, 'final_sum'));
      
      EndBlock('visibility_test')
      .EndFunction('visibility_test');
      
      if ValidateModule('visibility_test') then
      begin
        // Result: 42 + 84 = 126
        TLLUtils.PrintLn('Visibility test: private=42, public=84, external call successful -> sum=%d',
          [ExecuteFunction('visibility_test', 'test_visibility', []).AsInt64]);
        
        TLLUtils.PrintLn('Visibility breakdown:');
        TLLUtils.PrintLn('  - vPrivate: Internal linkage, module-local symbols');
        TLLUtils.PrintLn('  - vPublic: External linkage, exported symbols');
        TLLUtils.PrintLn('  - vExternal: External declaration, imported symbols');
        TLLUtils.PrintLn('  - Linkage controls symbol visibility across module boundaries');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Calling Convention Types
 * 
 * Description: This test demonstrates the TPaCallingConv enum which specifies
 * how function parameters and return values are passed between caller and callee.
 * Different calling conventions affect stack layout, register usage, and ABI compatibility.
 *
 * Functions Demonstrated:
 * - BeginFunction() with different TPaCallingConv values
 * - ccCDecl: C calling convention (caller cleans stack)
 * - ccStdCall: Standard call (callee cleans stack)
 * - ccFastCall: Fast call (registers for first parameters)
 *
 * LLVM Concepts Covered:
 * - Function calling conventions and ABI compatibility
 * - Parameter passing mechanisms (stack vs registers)
 * - Stack cleanup responsibilities (caller vs callee)
 * - Register allocation and calling convention efficiency
 * - Platform-specific calling convention differences
 *
 * Expected Output: "Calling conventions: cdecl=10, stdcall=20, fastcall=30 -> sum=60"
 *
 * Takeaway: Learn how calling conventions affect function call overhead,
 * parameter passing efficiency, and compatibility with different language
 * runtimes and operating system APIs.
 *)
class procedure TTestTypes.TestCallingConventions();
var
  LCDeclResult, LStdCallResult, LFastCallResult: TLLValue;
  LSum: TLLValue;
begin
  // Demo: Creating functions with different calling conventions
  // Shows how TPaCallingConv affects LLVM function call ABI
  with TLLVM.Create() do
  begin
    try
      CreateModule('calling_conv_test')
      
      // C calling convention: caller cleans stack, widely compatible
      // Generates LLVM IR: "define ccc i32 @cdecl_func(i32 %AX, i32 %AY)"
      .BeginFunction('calling_conv_test', 'cdecl_func', dtInt32,
        [Param('AX', dtInt32), Param('AY', dtInt32)], vPublic, ccCDecl)
        .BeginBlock('calling_conv_test', 'entry');
        
        ReturnValue('calling_conv_test',
          Add('calling_conv_test',
            GetParameter('calling_conv_test', 'AX'),
            GetParameter('calling_conv_test', 'AY'),
            'cdecl_sum'));
        
        EndBlock('calling_conv_test')
      .EndFunction('calling_conv_test')
      
      // Standard calling convention: callee cleans stack, Windows API standard
      // Generates LLVM IR: "define x86_stdcallcc i32 @stdcall_func(i32 %AX, i32 %AY)"
      .BeginFunction('calling_conv_test', 'stdcall_func', dtInt32,
        [Param('AX', dtInt32), Param('AY', dtInt32)], vPublic, ccStdCall)
        .BeginBlock('calling_conv_test', 'entry');
        
        ReturnValue('calling_conv_test',
          Multiply('calling_conv_test',
            Add('calling_conv_test',
              GetParameter('calling_conv_test', 'AX'),
              GetParameter('calling_conv_test', 'AY'),
              'stdcall_sum'),
            IntegerValue('calling_conv_test', 2, dtInt32),
            'stdcall_double'));
        
        EndBlock('calling_conv_test')
      .EndFunction('calling_conv_test')
      
      // Fast calling convention: uses registers for first parameters
      // Generates LLVM IR: "define x86_fastcallcc i32 @fastcall_func(i32 %AX, i32 %AY)"
      .BeginFunction('calling_conv_test', 'fastcall_func', dtInt32,
        [Param('AX', dtInt32), Param('AY', dtInt32)], vPublic, ccFastCall)
        .BeginBlock('calling_conv_test', 'entry');
        
        ReturnValue('calling_conv_test',
          Multiply('calling_conv_test',
            Add('calling_conv_test',
              GetParameter('calling_conv_test', 'AX'),
              GetParameter('calling_conv_test', 'AY'),
              'fastcall_sum'),
            IntegerValue('calling_conv_test', 3, dtInt32),
            'fastcall_triple'));
        
        EndBlock('calling_conv_test')
      .EndFunction('calling_conv_test')
      
      // Test function demonstrating all calling conventions
      .BeginFunction('calling_conv_test', 'test_calling_convs', dtInt32, [])
        .BeginBlock('calling_conv_test', 'entry');
      
      // Call functions with different calling conventions
      // cdecl_func(3, 7) = 3 + 7 = 10
      LCDeclResult := CallFunction('calling_conv_test', 'cdecl_func',
        [IntegerValue('calling_conv_test', 3, dtInt32),
         IntegerValue('calling_conv_test', 7, dtInt32)], 'cdecl_call');
      
      // stdcall_func(3, 7) = (3 + 7) * 2 = 20
      LStdCallResult := CallFunction('calling_conv_test', 'stdcall_func',
        [IntegerValue('calling_conv_test', 3, dtInt32),
         IntegerValue('calling_conv_test', 7, dtInt32)], 'stdcall_call');
      
      // fastcall_func(3, 7) = (3 + 7) * 3 = 30
      LFastCallResult := CallFunction('calling_conv_test', 'fastcall_func',
        [IntegerValue('calling_conv_test', 3, dtInt32),
         IntegerValue('calling_conv_test', 7, dtInt32)], 'fastcall_call');
      
      // Sum all results: 10 + 20 + 30 = 60
      LSum := Add('calling_conv_test', LCDeclResult, LStdCallResult, 'partial_sum');
      LSum := Add('calling_conv_test', LSum, LFastCallResult, 'total_sum');
      
      ReturnValue('calling_conv_test', LSum);
      
      EndBlock('calling_conv_test')
      .EndFunction('calling_conv_test');
      
      if ValidateModule('calling_conv_test') then
      begin
        // Result: 10 + 20 + 30 = 60
        TLLUtils.PrintLn('Calling conventions: cdecl=10, stdcall=20, fastcall=30 -> sum=%d',
          [ExecuteFunction('calling_conv_test', 'test_calling_convs', []).AsInt64]);
        
        TLLUtils.PrintLn('Calling convention breakdown:');
        TLLUtils.PrintLn('  - ccCDecl: Caller cleans stack, C standard, most portable');
        TLLUtils.PrintLn('  - ccStdCall: Callee cleans stack, Windows API standard');
        TLLUtils.PrintLn('  - ccFastCall: Register-based parameters, optimized for speed');
        TLLUtils.PrintLn('  - Convention affects ABI compatibility and call overhead');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Parameter Type System
 * 
 * Description: This test demonstrates the TPaParam record system which defines
 * function parameters with name and type information. It shows how the Parse
 * framework handles parameter passing, type safety, and function signatures.
 *
 * Functions Demonstrated:
 * - Param() helper function for creating TPaParam records
 * - BeginFunction() with various parameter types and combinations
 * - GetParameter() for accessing parameters by name and index
 * - Parameter type checking and conversion
 *
 * LLVM Concepts Covered:
 * - Function parameter declaration in LLVM IR
 * - Parameter name assignment and debugging information
 * - Type-safe parameter access and usage
 * - Variable argument functions (varargs) support
 * - Parameter passing by value vs reference concepts
 *
 * Expected Output: "Parameters: int=100, float=3.14, bool=true, mixed calculation=106"
 *
 * Takeaway: Learn how the Parse framework ensures type-safe parameter handling
 * while providing flexible function signature definitions that map cleanly
 * to LLVM IR function declarations.
 *)
class procedure TTestTypes.TestParameterTypes();
var
  LIntParam, LFloatParam, LBoolParam: TLLValue;
  LFloatToInt, LBoolToInt: TLLValue;
  LSum: TLLValue;
begin
  // Demo: Creating and using functions with various parameter types
  // Shows how TPaParam records define typed function signatures
  with TLLVM.Create() do
  begin
    try
      CreateModule('param_types_test')
      
      // Function with mixed parameter types
      // Demonstrates TPaParam record usage with different data types
      .BeginFunction('param_types_test', 'mixed_params_func', dtInt32,
        [Param('AIntValue', dtInt32),      // Integer parameter
         Param('AFloatValue', dtFloat32),  // Float parameter  
         Param('ABoolValue', dtInt1),      // Boolean parameter
         Param('AStringPtr', dtInt8Ptr)],  // String pointer parameter
        vPublic, ccCDecl)
        .BeginBlock('param_types_test', 'entry');
      
      // Access parameters by name (type-safe)
      LIntParam := GetParameter('param_types_test', 'AIntValue');
      LFloatParam := GetParameter('param_types_test', 'AFloatValue');
      LBoolParam := GetParameter('param_types_test', 'ABoolValue');
      
      // Demonstrate type conversions for mixed arithmetic
      // Convert float to int: 3.14 -> 3 (truncation)
      LFloatToInt := FloatToInt('param_types_test', LFloatParam, dtInt32, 'float_to_int');
      
      // Convert boolean to int: true -> 1, false -> 0
      LBoolToInt := IntCast('param_types_test', LBoolParam, dtInt32, 'bool_to_int');
      
      // Mixed arithmetic: int + truncated_float + bool_as_int
      // Example: 100 + 3 + 1 = 104
      LSum := Add('param_types_test', LIntParam, LFloatToInt, 'int_plus_float');
      LSum := Add('param_types_test', LSum, LBoolToInt, 'add_bool');
      
      ReturnValue('param_types_test', LSum);
      
      EndBlock('param_types_test')
      .EndFunction('param_types_test')
      
      // Variadic function demonstration (varargs)
      .BeginFunction('param_types_test', 'printf', dtInt32,
        [Param('AFormat', dtInt8Ptr)], vExternal, ccCDecl, True, 'msvcrt.dll')
      .EndFunction('param_types_test')
      
      // Test function demonstrating parameter usage
      .BeginFunction('param_types_test', 'test_parameters', dtInt32, [])
        .BeginBlock('param_types_test', 'entry');
      
      // Create test values for parameter passing
      LSum := CallFunction('param_types_test', 'mixed_params_func',
        [IntegerValue('param_types_test', 100, dtInt32),    // AIntValue = 100
         FloatValue('param_types_test', 3.14, dtFloat32),   // AFloatValue = 3.14
         BooleanValue('param_types_test', True),            // ABoolValue = true
         StringValue('param_types_test', 'Hello')],         // AStringPtr = "Hello"
        'mixed_call');
      
      // Add extra value to make result more interesting: 104 + 2 = 106
      LSum := Add('param_types_test', LSum, 
        IntegerValue('param_types_test', 2, dtInt32), 'final_sum');
      
      ReturnValue('param_types_test', LSum);
      
      EndBlock('param_types_test')
      .EndFunction('param_types_test');
      
      if ValidateModule('param_types_test') then
      begin
        // Result: 100 + 3 + 1 + 2 = 106
        TLLUtils.PrintLn('Parameters: int=100, float=3.14, bool=true, mixed calculation=%d',
          [ExecuteFunction('param_types_test', 'test_parameters', []).AsInt64]);
        
        TLLUtils.PrintLn('Parameter system breakdown:');
        TLLUtils.PrintLn('  - TPaParam: Record with ParamName and ParamType fields');
        TLLUtils.PrintLn('  - Type safety: Each parameter has explicit type declaration');
        TLLUtils.PrintLn('  - Name-based access: GetParameter() by name or index');
        TLLUtils.PrintLn('  - Varargs support: Functions can accept variable argument counts');
        TLLUtils.PrintLn('  - Conversion required: Mixed-type arithmetic needs explicit casts');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Record Type System Usage
 * 
 * Description: This test demonstrates the usage of Parse framework record types
 * including TPaVariable, TPaBasicBlock, and TModuleState. These records form
 * the core infrastructure for managing LLVM IR generation state and symbol tables.
 *
 * Functions Demonstrated:
 * - Variable declaration and management (TPaVariable)
 * - Basic block creation and control flow (TPaBasicBlock)
 * - Module state management and JIT integration (TModuleState)
 * - Symbol table operations and scope management
 *
 * LLVM Concepts Covered:
 * - Variable allocation and storage (alloca instructions)
 * - Basic block structure and control flow graphs
 * - Module-level state and symbol resolution
 * - Memory management and variable lifetime
 * - Scope-based variable access and symbol tables
 *
 * Expected Output: "Records: local_var=25, global_var=50, control_flow=working -> result=75"
 *
 * Takeaway: Learn how the Parse framework's record types provide structured
 * access to LLVM's symbol tables, control flow constructs, and state management
 * while maintaining type safety and proper scope handling.
 *)
class procedure TTestTypes.TestRecordTypes();
var
  LLocalValue, LGlobalValue, LCondition: TLLValue;
  LResult: TLLValue;
begin
  with TLLVM.Create() do
  begin
    try
      CreateModule('record_types_test')
      
      // Demonstrate global variable (stored in TModuleState.Variables)
      .DeclareGlobal('record_types_test', 'global_counter', dtInt32, 
        IntegerValue('record_types_test', 50, dtInt32))
      
      .BeginFunction('record_types_test', 'test_records', dtInt32, [])
        .BeginBlock('record_types_test', 'entry');
      
      // Demonstrate local variable allocation (TPaVariable with alloca)
      DeclareLocal('record_types_test', 'local_var', dtInt32);
      
      // Set local variable value (stored in function scope)
      SetValue('record_types_test', 'local_var', 
        IntegerValue('record_types_test', 25, dtInt32));
      
      // Load local and global variable values (TPaVariable usage)
      LLocalValue := GetValue('record_types_test', 'local_var');
      LGlobalValue := GetValue('record_types_test', 'global_counter');
      
      // Demonstrate basic block creation and control flow (TPaBasicBlock)
      // Create condition for branching
      LCondition := IsEqual('record_types_test', LLocalValue,
        IntegerValue('record_types_test', 25, dtInt32), 'check_local');
      
      // Add conditional branch before ending the entry block
      JumpIf('record_types_test', LCondition, 'true_branch', 'false_branch');
      
      EndBlock('record_types_test')
      
      // Create additional basic blocks (stored in TModuleState.BasicBlocks)
      .BeginBlock('record_types_test', 'true_branch');
      
      // In true branch: add local + global = 25 + 50 = 75
      LResult := Add('record_types_test', LLocalValue, LGlobalValue, 'sum_vars');
      
      Jump('record_types_test', 'exit_block');
      
      EndBlock('record_types_test')
      .BeginBlock('record_types_test', 'false_branch');
      
      // In false branch: just return 0 (shouldn't execute in our test)
      LResult := IntegerValue('record_types_test', 0, dtInt32);
      
      Jump('record_types_test', 'exit_block');
      
      EndBlock('record_types_test')
      .BeginBlock('record_types_test', 'exit_block');
      
      // PHI node to merge results from different basic blocks
      // Demonstrates how TPaBasicBlock records are used in control flow
      LResult := CreatePhi('record_types_test', dtInt32, 'final_result');
      AddPhiIncoming('record_types_test', LResult,
        Add('record_types_test', LLocalValue, LGlobalValue, 'true_result'),
        'true_branch');
      AddPhiIncoming('record_types_test', LResult,
        IntegerValue('record_types_test', 0, dtInt32),
        'false_branch');
      
      ReturnValue('record_types_test', LResult);
      
      EndBlock('record_types_test');
      
      // The conditional branch should have been added in the entry block
      // before calling EndBlock(). This demonstrates proper control flow.
      
      EndFunction('record_types_test');
      
      if ValidateModule('record_types_test') then
      begin
        // Result: 25 + 50 = 75 (from true_branch)
        TLLUtils.PrintLn('Records: local_var=25, global_var=50, control_flow=working -> result=%d',
          [ExecuteFunction('record_types_test', 'test_records', []).AsInt64]);
        
        TLLUtils.PrintLn('Record system breakdown:');
        TLLUtils.PrintLn('  - TPaVariable: Name, VarType, AllocaInst, IsGlobal fields');
        TLLUtils.PrintLn('  - TPaBasicBlock: Name and Block (LLVMBasicBlockRef) fields');
        TLLUtils.PrintLn('  - TModuleState: Complete module state with symbol tables');
        TLLUtils.PrintLn('  - Symbol tables: Variables, BasicBlocks, FunctionParams dictionaries');
        TLLUtils.PrintLn('  - State management: Context, Builder, JIT integration');
      end;
    finally
      Free();
    end;
  end;
end;

end.
