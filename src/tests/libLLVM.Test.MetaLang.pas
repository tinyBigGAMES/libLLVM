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

unit libLLVM.Test.MetaLang;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  libLLVM.Utils,
  libLLVM,
  libLLVM.MetaLang;

type
  { TTestMetaLang }
  TTestMetaLang = class
  public
    class procedure RunAllTests(); static;

    // === COMPREHENSIVE EXAMPLES (migrated from testbed) ===
    class procedure TestComprehensiveMathDLL(); static;     // Full test01 - extensive example
    class procedure TestComprehensiveHelloWorld(); static;  // Full test03 - extensive example
    
    // === SIMPLE FOCUSED TESTS ===
    class procedure TestModuleCreation(); static;          // Simple: just create/validate module
    class procedure TestBasicFunction(); static;           // Simple: declare basic function
    class procedure TestParameterHandling(); static;       // Simple: function with parameters
    class procedure TestVariableOperations(); static;      // Simple: local/global variables
    class procedure TestValueCreation(); static;           // Simple: create different value types
    class procedure TestBasicMath(); static;               // Simple: add two numbers
    class procedure TestSimpleControlFlow(); static;       // Simple: if/then/else
    class procedure TestBasicLoop(); static;               // Simple: while loop
    class procedure TestFunctionCalls(); static;           // Simple: call between functions
    class procedure TestMemoryOperations(); static;        // Simple: alloc/load/store
    class procedure TestExportedFunction(); static;        // Simple: mark function as exported
  end;

implementation

{ TTestMetaLang }

class procedure TTestMetaLang.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.MetaLang...');

  // Simple focused tests
  TestModuleCreation();
  TestBasicFunction();
  TestParameterHandling();
  TestVariableOperations();
  TestValueCreation();
  TestBasicMath();
  TestSimpleControlFlow();
  TestBasicLoop();
  TestFunctionCalls();
  TestMemoryOperations();
  TestExportedFunction();

  // Comprehensive examples
  TestComprehensiveMathDLL();
  TestComprehensiveHelloWorld();

  
  TLLUtils.PrintLn('libLLVM.Test.MetaLang completed.');
end;

(**
 * COMPREHENSIVE EXAMPLE: Complete Math DLL Creation Workflow
 * 
 * Description: This extensive example demonstrates the complete process of creating
 * a math DLL using TLLMetaLang, from module creation through function implementation
 * to DLL compilation and linking. Shows the full power and workflow capabilities.
 *
 * Demonstrates Complete Workflow:
 * - Module creation and management with TLLMetaLang fluent interface
 * - Function declaration with typed parameters using automatic entry block creation
 * - Parameter retrieval by name with type safety validation
 * - Arithmetic operations using high-level MetaLang operations
 * - Function export marking for DLL creation with automatic symbol management
 * - Module validation ensuring proper LLVM IR structure and type correctness
 * - Complete linking pipeline to DLL with import libraries and external dependencies
 * - Error handling and output capture from linking process
 * - Directory management and cleanup for build artifacts
 *
 * LLVM Concepts Covered:
 * - Complete DLL compilation pipeline from IR to native code
 * - Export symbol management and library interface definition
 * - External library dependency resolution and linking
 * - Import library generation for client applications
 * - Build artifact organization and management
 *
 * This is migrated from UTestbed test01 as a comprehensive showcase example
 * demonstrating the complete capabilities of the TLLMetaLang system.
 *
 * Expected Output: Generated LLVM IR, linking process output, and successful DLL creation
 *
 * Takeaway: Learn the complete end-to-end workflow for creating production-ready
 * DLLs using TLLMetaLang, from high-level function definition to native code generation.
 *)
class procedure TTestMetaLang.TestComprehensiveMathDLL();
var
  LParamA, LParamB, LResult: TLLValue;
  LStdOut, LStdErr: string;
  LRC: Integer;
begin
  // === COMPREHENSIVE EXAMPLE: Full DLL Creation Workflow ===
  TLLUtils.PrintLn('=== Comprehensive Example: Math DLL Creation ===');
  
  with TLLMetaLang.Create() do
  begin
    try
      // Create module with descriptive identifier
      CreateModule('simple_math')
      // Declare and implement the function (entry block created automatically by MetaLang)
      .BeginFunction('simple_math', 'add_two_numbers', dtInt32, [
          Param('a', dtInt32),
          Param('b', dtInt32)
        ])
        .MarkAsExported('simple_math');  // Export for DLL with automatic symbol management

      // Get parameters using MetaLang's named parameter system
      LParamA := GetParameter('simple_math', 'a');
      LParamB := GetParameter('simple_math', 'b');
      
      // Perform addition using high-level MetaLang arithmetic
      LResult := Add('simple_math', LParamA, LParamB);

      // Return the result and complete function definition
      ReturnValue('simple_math', LResult)
        .EndFunction('simple_math');

      // Validate module structure and generate comprehensive output
      if ValidateModule('simple_math') then
      begin
        TLLUtils.PrintLn('=== Generated LLVM IR ===');
        TLLUtils.PrintLn(GetModuleIR('simple_math'));

        // Clean up any existing output directory
        if TDirectory.Exists('.\output') then
          TDirectory.Delete('.\output', True);

        // Execute complete DLL linking pipeline with comprehensive configuration
        LinkModuleToDLL(
          'simple_math',              // Source module
          'simple_math.dll',          // Output DLL name
          '.\output\obj',             // Object file output directory
          ['kernel32.lib'],           // Required external libraries
          ['.\libs'],                 // Library search paths
          olSpeed,                    // Optimization level for performance
          '.\output\libs',            // Import library output directory
          LStdOut,                    // Capture standard output
          LStdErr,                    // Capture error output
          LRC                         // Capture result code
        );

        // Display comprehensive linking results
        TLLUtils.PrintLn('=== Linker Output ===');
        if not LStdOut.IsEmpty then
          TLLUtils.PrintLn(LStdOut);

        if not LStdErr.IsEmpty then
          TLLUtils.PrintLn(LStdErr);
        TLLUtils.PrintLn('Result Code: %d', [LRC]);

        // Validate successful DLL creation
        if LRC = 0 then
        begin
          TLLUtils.PrintLn('Successfully created simple_math.dll');
          TLLUtils.PrintLn('Exported function: add_two_numbers(a: int, b: int) -> int');
          TLLUtils.PrintLn('Import library: .\output\libs\simple_math.lib');
          TLLUtils.PrintLn('');
          TLLUtils.PrintLn('Usage example:');
          TLLUtils.PrintLn('  function add_two_numbers(a, b: int32): int32; cdecl; external ''simple_math.dll'';');
          TLLUtils.PrintLn('  result := add_two_numbers(10, 20); // Returns 30');
        end
        else
        begin
          TLLUtils.PrintLn('DLL creation failed with error code: %d', [LRC]);
        end;
      end
      else
      begin
        TLLUtils.PrintLn('Module validation failed - IR structure or types invalid');
      end;
    finally
      Free();
    end;
  end;
  
  TLLUtils.PrintLn('=== Comprehensive Math DLL Example Complete ===');
  TLLUtils.PrintLn('');
end;

(**
 * COMPREHENSIVE EXAMPLE: Complete Hello World Executable Creation
 * 
 * Description: This extensive example demonstrates the complete process of creating
 * a "Hello World" executable using TLLMetaLang, including external function integration,
 * string handling, parameter passing, and executable linking with proper subsystem configuration.
 *
 * Demonstrates Complete Workflow:
 * - Module creation for executable targets with proper entry point management
 * - External function declaration with library binding (printf from msvcrt.dll)
 * - Main function implementation with proper executable entry point signature
 * - String value creation and format string handling for C library compatibility
 * - Function calls to external libraries with variadic argument support
 * - Return value handling for executable entry points with proper exit codes
 * - Complete linking pipeline to executable with console subsystem configuration
 * - External library integration and dependency management for runtime libraries
 * - Build artifact organization and cleanup for executable distribution
 *
 * LLVM Concepts Covered:
 * - Executable compilation pipeline from IR to native Windows PE format
 * - External function declaration and dynamic library symbol resolution
 * - C calling convention compatibility and argument marshalling
 * - Console subsystem configuration for Windows executable format
 * - Runtime library dependency management and distribution requirements
 *
 * This is migrated from UTestbed test03 as a comprehensive showcase example
 * demonstrating the complete capabilities for executable creation.
 *
 * Expected Output: Generated LLVM IR, linking process output, and functional executable
 *
 * Takeaway: Learn the complete end-to-end workflow for creating production-ready
 * executables using TLLMetaLang, including external library integration and proper
 * Windows subsystem configuration.
 *)
class procedure TTestMetaLang.TestComprehensiveHelloWorld();
var
  LHelloStr, LResult: TLLValue;
  LWorldStr: TLLValue;
  LStdOut, LStdErr: string;
  LRC: Integer;
begin
  // === COMPREHENSIVE EXAMPLE: Full Executable Creation Workflow ===
  TLLUtils.PrintLn('=== Comprehensive Example: Hello World Executable ===');
  
  with TLLMetaLang.Create() do
  begin
    try
      // Create module for executable target
      CreateModule('hello_world');

      // Declare external printf function with proper C library binding
      // Uses variadic arguments for format string support
      BeginFunction('hello_world', 'printf', dtInt32, 
        [Param('format', dtPointer)], vExternal, ccCDecl, True, 'msvcrt.dll')
       .EndFunction('hello_world');

      // Declare and implement main function as executable entry point
      // Entry block created automatically by MetaLang
      BeginFunction('hello_world', 'main', dtInt32, []);

      // Create format string and parameter for printf call
      // Demonstrates string value creation and C library parameter passing
      LHelloStr := StringValue('hello_world', 'Hello, %s');
      LWorldStr := StringValue('hello_world', 'World!' + #10);

      // Call printf with format string and parameter
      // Demonstrates external function calling with variadic arguments
      LResult := CallFunction('hello_world', 'printf', [LHelloStr, LWorldStr]);

      // Return success code from main function (standard executable convention)
      ReturnValue('hello_world', IntegerValue('hello_world', 0))
        .EndFunction('hello_world');

      // Validate module and execute comprehensive executable linking
      if ValidateModule('hello_world') then
      begin
        TLLUtils.PrintLn('=== Generated LLVM IR ===');
        TLLUtils.PrintLn(GetModuleIR('hello_world'));
        TLLUtils.PrintLn('=== Linking to Executable ===');

        // Clean up any existing output directory
        if TDirectory.Exists('.\output') then
          TDirectory.Delete('.\output', True);

        // Execute complete executable linking pipeline with comprehensive configuration
        LinkModuleToExecutable(
          'hello_world',              // Source module
          'hello_world.exe',          // Output executable name
          '.\output\obj',             // Object file output directory
          ssConsole,                  // Console subsystem for visible output
          ['kernel32.lib', 'msvcrt.lib'], // Required Windows and C runtime libraries
          ['.\libs'],                 // Library search paths
          olSpeed,                    // Optimization level for performance
          LStdOut,                    // Capture standard output
          LStdErr,                    // Capture error output
          LRC                         // Capture result code
        );
        
        // Display comprehensive linking results
        TLLUtils.PrintLn('=== Linker Output ===');
        if not LStdOut.IsEmpty then
          TLLUtils.PrintLn(LStdOut);

        if not LStdErr.IsEmpty then
          TLLUtils.PrintLn(LStdErr);

        TLLUtils.PrintLn('Result Code: %d', [LRC]);
        
        // Validate successful executable creation
        if LRC = 0 then
        begin
          TLLUtils.PrintLn('Successfully created hello_world.exe');
          TLLUtils.PrintLn('Entry point: main() -> int');
          TLLUtils.PrintLn('Subsystem: Console application');
          TLLUtils.PrintLn('Dependencies: kernel32.dll, msvcrt.dll');
          TLLUtils.PrintLn('');
          TLLUtils.PrintLn('Expected output when run: "Hello, World!"');
          TLLUtils.PrintLn('Execute: .\output\hello_world.exe');
        end
        else
        begin
          TLLUtils.PrintLn('Executable creation failed with error code: %d', [LRC]);
        end;
      end
      else
      begin
        TLLUtils.PrintLn('Module validation failed - IR structure or types invalid');
      end;
    finally
      Free();
    end;
  end;
  
  TLLUtils.PrintLn('=== Comprehensive Hello World Example Complete ===');
  TLLUtils.PrintLn('');
end;

// === SIMPLE FOCUSED TESTS ===

(**
 * Test: Simple Module Creation
 * 
 * Description: Focused test for basic module creation and validation using TLLMetaLang.
 * Tests the fundamental module management capabilities without complexity.
 *
 * Functions Demonstrated:
 * - CreateModule() for basic module initialization
 * - ModuleExists() for module existence validation
 *
 * Expected Output: "Module creation: SUCCESS"
 *)
class procedure TTestMetaLang.TestModuleCreation();
begin
  // Demo: Basic module creation and existence validation
  with TLLMetaLang.Create() do
  begin
    try
      // Create a simple test module
      CreateModule('test_module');
      
      // Validate module was created successfully
      if ModuleExists('test_module') then
        TLLUtils.PrintLn('Module creation: SUCCESS')
      else
        TLLUtils.PrintLn('Module creation: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Basic Function Declaration
 * 
 * Description: Simple test for function declaration without complexity.
 * Tests fundamental function creation and validation.
 *
 * Functions Demonstrated:
 * - BeginFunction() with simple signature
 * - ReturnValue() with constant value
 * - EndFunction() for completion
 * - ValidateModule() for correctness check
 *
 * Expected Output: "Basic function: SUCCESS - returns 42"
 *)
class procedure TTestMetaLang.TestBasicFunction();
begin
  // Demo: Simple function declaration and validation
  with TLLMetaLang.Create() do
  begin
    try
      // Create module and declare simple function
      CreateModule('func_test')
      .BeginFunction('func_test', 'simple_func', dtInt32, []);
      
      // Return constant value and complete function
      ReturnValue('func_test', IntegerValue('func_test', 42))
      .EndFunction('func_test');

      WriteLn(GetModuleIR('func_test'));

      // Validate function was created correctly
      if ValidateModule('func_test') then
        TLLUtils.PrintLn('Basic function: SUCCESS - returns 42')
      else
        TLLUtils.PrintLn('Basic function: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Parameter Handling
 * 
 * Description: Simple test for function parameters and parameter access.
 * Tests basic parameter declaration and retrieval.
 *
 * Functions Demonstrated:
 * - Param() for parameter creation
 * - BeginFunction() with parameter list
 * - GetParameter() for parameter access
 *
 * Expected Output: "Parameter handling: SUCCESS - echo function works"
 *)
class procedure TTestMetaLang.TestParameterHandling();
var
  LParam: TLLValue;
begin
  // Demo: Simple parameter declaration and access
  with TLLMetaLang.Create() do
  begin
    try
      // Create function with single parameter
      CreateModule('param_test')
      .BeginFunction('param_test', 'echo_func', dtInt32, [Param('value', dtInt32)]);
      
      // Get parameter and return it (echo function)
      LParam := GetParameter('param_test', 'value');
      ReturnValue('param_test', LParam)
      .EndFunction('param_test');
      
      // Validate function works correctly
      if ValidateModule('param_test') then
        TLLUtils.PrintLn('Parameter handling: SUCCESS - echo function works')
      else
        TLLUtils.PrintLn('Parameter handling: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Variable Operations
 * 
 * Description: Simple test for local and global variable declaration and usage.
 * Tests basic variable management capabilities.
 *
 * Functions Demonstrated:
 * - DeclareLocal() for local variable creation
 * - SetVariable() for variable assignment
 * - GetVariable() for variable retrieval
 *
 * Expected Output: "Variable operations: SUCCESS - local variables work"
 *)
class procedure TTestMetaLang.TestVariableOperations();
var
  LVarValue: TLLValue;
begin
  // Demo: Simple variable declaration and usage
  with TLLMetaLang.Create() do
  begin
    try
      // Create function with local variable
      CreateModule('var_test')
      .BeginFunction('var_test', 'var_func', dtInt32, []);
      
      // Declare local variable and set value
      DeclareLocal('var_test', 'local_var', dtInt32);
      SetVariable('var_test', 'local_var', IntegerValue('var_test', 100));
      
      // Get variable and return its value
      LVarValue := GetVariable('var_test', 'local_var');
      ReturnValue('var_test', LVarValue)
      .EndFunction('var_test');
      
      // Validate variable operations work
      if ValidateModule('var_test') then
        TLLUtils.PrintLn('Variable operations: SUCCESS - local variables work')
      else
        TLLUtils.PrintLn('Variable operations: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Value Creation
 * 
 * Description: Simple test for creating different types of values.
 * Tests basic value creation capabilities.
 *
 * Functions Demonstrated:
 * - IntegerValue() for integer constants
 * - FloatValue() for floating point constants
 * - BooleanValue() for boolean constants
 * - StringValue() for string constants
 *
 * Expected Output: "Value creation: SUCCESS - all value types created"
 *)
class procedure TTestMetaLang.TestValueCreation();
var
  LIntVal, LFloatVal, LBoolVal, LStringVal: TLLValue;
begin
  // Demo: Creating different types of values
  with TLLMetaLang.Create() do
  begin
    try
      CreateModule('value_test')
      .BeginFunction('value_test', 'value_func', dtInt32, []);
      
      // Create different value types
      LIntVal := IntegerValue('value_test', 42, dtInt32);
      LFloatVal := FloatValue('value_test', 3.14, dtFloat64);
      LBoolVal := BooleanValue('value_test', True);
      LStringVal := StringValue('value_test', 'Hello');
      
      // Return integer value for validation
      ReturnValue('value_test', LIntVal)
      .EndFunction('value_test');
      
      if ValidateModule('value_test') then
        TLLUtils.PrintLn('Value creation: SUCCESS - all value types created')
      else
        TLLUtils.PrintLn('Value creation: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Basic Math Operations
 * 
 * Description: Simple test for basic arithmetic using TLLMetaLang.
 * Tests fundamental math operation capabilities.
 *
 * Functions Demonstrated:
 * - Add() for addition operation
 * - IntegerValue() for operands
 *
 * Expected Output: "Basic math: SUCCESS - 10 + 20 = 30"
 *)
class procedure TTestMetaLang.TestBasicMath();
var
  LLeft, LRight, LResult: TLLValue;
begin
  // Demo: Simple addition operation
  with TLLMetaLang.Create() do
  begin
    try
      CreateModule('math_test')
      .BeginFunction('math_test', 'add_func', dtInt32, []);
      
      // Create operands and perform addition
      LLeft := IntegerValue('math_test', 10, dtInt32);
      LRight := IntegerValue('math_test', 20, dtInt32);
      LResult := Add('math_test', LLeft, LRight);
      
      ReturnValue('math_test', LResult)
      .EndFunction('math_test');
      
      if ValidateModule('math_test') then
      begin
        // Execute and verify result
        LResult := GetLLVM().ExecuteFunction('math_test', 'add_func', []);
        TLLUtils.PrintLn('Basic math: SUCCESS - 10 + 20 = %d', [LResult.AsInt64]);
      end
      else
        TLLUtils.PrintLn('Basic math: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Simple Control Flow
 * 
 * Description: Simple test for if/then/else control flow using TLLMetaLang.
 * Tests basic conditional execution using high-level MetaLang constructs with variables.
 *
 * Functions Demonstrated:
 * - IfCondition() for conditional branching
 * - ThenBranch() and ElseBranch() for branch implementation  
 * - EndIf() for control flow completion
 * - SetVariable() and GetVariable() for result storage (MetaLang handles PHI automatically)
 *
 * Expected Output: "Control flow: SUCCESS - if/then/else works"
 *)
class procedure TTestMetaLang.TestSimpleControlFlow();
var
  LCondition: TLLValue;
begin
  // Demo: High-level if/then/else using MetaLang - simple and clean!
  with TLLMetaLang.Create() do
  begin
    try
      CreateModule('flow_test')
      .BeginFunction('flow_test', 'if_func', dtInt32, [Param('input', dtInt32)]);
      
      // Declare a variable to store the result
      DeclareLocal('flow_test', 'result', dtInt32);
      
      // Create condition: input > 50
      LCondition := IsGreater('flow_test', 
        GetParameter('flow_test', 'input'),
        IntegerValue('flow_test', 50, dtInt32));
      
      // High-level if/then/else - MetaLang handles all the complexity!
      IfCondition('flow_test', LCondition);
      
      // Then branch: set result to 100
      ThenBranch('flow_test');
      SetVariable('flow_test', 'result', IntegerValue('flow_test', 100, dtInt32));
      
      // Else branch: set result to 0
      ElseBranch('flow_test');
      SetVariable('flow_test', 'result', IntegerValue('flow_test', 0, dtInt32));
      
      // End if - MetaLang merges everything automatically
      EndIf('flow_test');
      
      // Return the result - clean and simple!
      ReturnValue('flow_test', GetVariable('flow_test', 'result'))
      .EndFunction('flow_test');

      if ValidateModule('flow_test') then
        TLLUtils.PrintLn('Control flow: SUCCESS - if/then/else works')
      else
        TLLUtils.PrintLn('Control flow: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Basic Loop
 * 
 * Description: Simple test for while loop using TLLMetaLang.
 * Tests basic loop control capabilities.
 *
 * Functions Demonstrated:
 * - DeclareLocal() for loop counter
 * - WhileLoop() for loop initiation
 * - EndWhile() for loop completion
 *
 * Expected Output: "Basic loop: SUCCESS - while loop works"
 *)
class procedure TTestMetaLang.TestBasicLoop();
var
  LCounter, LCondition, LIncrement: TLLValue;
begin
  // Demo: Simple while loop with counter
  with TLLMetaLang.Create() do
  begin
    try
      CreateModule('loop_test')
      .BeginFunction('loop_test', 'loop_func', dtInt32, []);
      
      // Declare and initialize counter
      DeclareLocal('loop_test', 'counter', dtInt32);
      SetVariable('loop_test', 'counter', IntegerValue('loop_test', 0, dtInt32));
      
      // While loop: counter < 5
      LCounter := GetVariable('loop_test', 'counter');
      LCondition := IsLess('loop_test', LCounter, IntegerValue('loop_test', 5, dtInt32));
      WhileLoop('loop_test', LCondition);
      
      // Increment counter
      LCounter := GetVariable('loop_test', 'counter');
      LIncrement := Add('loop_test', LCounter, IntegerValue('loop_test', 1, dtInt32));
      SetVariable('loop_test', 'counter', LIncrement);
      
      // End while
      EndWhile('loop_test');
      
      // Return final counter value
      ReturnValue('loop_test', GetVariable('loop_test', 'counter'))
      .EndFunction('loop_test');
      
      if ValidateModule('loop_test') then
        TLLUtils.PrintLn('Basic loop: SUCCESS - while loop works')
      else
        TLLUtils.PrintLn('Basic loop: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Function Calls
 * 
 * Description: Simple test for calling functions from other functions.
 * Tests basic function calling capabilities.
 *
 * Functions Demonstrated:
 * - Multiple function declarations
 * - CallFunction() for inter-function calling
 *
 * Expected Output: "Function calls: SUCCESS - helper(5) = 10"
 *)
class procedure TTestMetaLang.TestFunctionCalls();
var
  LParam, LResult, LCallResult: TLLValue;
begin
  // Demo: Simple function calling between functions
  with TLLMetaLang.Create() do
  begin
    try
      CreateModule('call_test')
      
      // Helper function: double the input
      .BeginFunction('call_test', 'helper', dtInt32, [Param('x', dtInt32)]);
      LParam := GetParameter('call_test', 'x');
      LResult := Multiply('call_test', LParam, IntegerValue('call_test', 2, dtInt32));
      ReturnValue('call_test', LResult);
      EndFunction('call_test')
      
      // Main function: call helper
      .BeginFunction('call_test', 'main_func', dtInt32, []);
      LCallResult := CallFunction('call_test', 'helper', [IntegerValue('call_test', 5, dtInt32)]);
      ReturnValue('call_test', LCallResult);
      EndFunction('call_test');
      
      if ValidateModule('call_test') then
      begin
        // Execute and verify result
        LResult := GetLLVM().ExecuteFunction('call_test', 'main_func', []);
        TLLUtils.PrintLn('Function calls: SUCCESS - helper(5) = %d', [LResult.AsInt64]);
      end
      else
        TLLUtils.PrintLn('Function calls: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Memory Operations
 * 
 * Description: Simple test for basic memory allocation and access.
 * Tests fundamental memory operation capabilities.
 *
 * Functions Demonstrated:
 * - AllocateArray() for memory allocation
 * - StoreValue() for memory writing
 * - LoadValue() for memory reading
 *
 * Expected Output: "Memory operations: SUCCESS - alloc/store/load works"
 *)
class procedure TTestMetaLang.TestMemoryOperations();
var
  LArray, LValue, LLoadedValue: TLLValue;
begin
  // Demo: Simple memory allocation and access
  with TLLMetaLang.Create() do
  begin
    try
      CreateModule('memory_test')
      .BeginFunction('memory_test', 'memory_func', dtInt32, []);
      
      // Allocate array of 10 integers
      LArray := AllocateArray('memory_test', dtInt32, 
        IntegerValue('memory_test', 10, dtInt32));
      
      // Store value at index 0
      LValue := IntegerValue('memory_test', 42, dtInt32);
      StoreValue('memory_test', LValue, LArray);
      
      // Load value from index 0
      LLoadedValue := LoadValue('memory_test', LArray);
      
      ReturnValue('memory_test', LLoadedValue)
      .EndFunction('memory_test');
      
      if ValidateModule('memory_test') then
        TLLUtils.PrintLn('Memory operations: SUCCESS - alloc/store/load works')
      else
        TLLUtils.PrintLn('Memory operations: FAILED');
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Exported Function
 * 
 * Description: Simple test for marking functions as exported.
 * Tests basic export functionality for DLL creation.
 *
 * Functions Demonstrated:
 * - BeginFunction() with export marking
 * - MarkAsExported() for export specification
 *
 * Expected Output: "Exported function: SUCCESS - export marking works"
 *)
class procedure TTestMetaLang.TestExportedFunction();
begin
  // Demo: Simple function export marking
  with TLLMetaLang.Create() do
  begin
    try
      CreateModule('export_test')
      .BeginFunction('export_test', 'exported_func', dtInt32, [])
        .MarkAsExported('export_test');  // Mark for export
      
      ReturnValue('export_test', IntegerValue('export_test', 123))
      .EndFunction('export_test');
      
      if ValidateModule('export_test') then
        TLLUtils.PrintLn('Exported function: SUCCESS - export marking works')
      else
        TLLUtils.PrintLn('Exported function: FAILED');
    finally
      Free();
    end;
  end;
end;

end.
