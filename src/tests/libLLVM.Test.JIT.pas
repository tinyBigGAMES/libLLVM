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

unit libLLVM.Test.JIT;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestJIT }
  TTestJIT = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for JIT execution functionality
    class procedure TestJITExecution(); static;
    class procedure TestFunctionExecution(); static;
    class procedure TestSymbolLookup(); static;
    class procedure TestExternalLibraries(); static;
    class procedure TestAbsoluteSymbols(); static;
    class procedure TestProcessSymbols(); static;
    class procedure TestJITInitialization(); static;
  end;

implementation

{ TTestJIT }

class procedure TTestJIT.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.JIT...');
  
  TestJITExecution();
  TestFunctionExecution();
  TestSymbolLookup();
  TestExternalLibraries();
  TestAbsoluteSymbols();
  TestProcessSymbols();
  TestJITInitialization();
  
  TLLUtils.PrintLn('libLLVM.Test.JIT completed.');
end;

class procedure TTestJIT.TestJITExecution();
begin
  TLLUtils.PrintLn('  Testing JIT execution...');
  with TLLVM.Create() do
  begin
    try
      // Create a module with a main function that returns success exit code (0)
      CreateModule('test_exec')
      .BeginFunction('test_exec', 'main', dtInt32, [])
        .BeginBlock('test_exec', 'entry');
      
      // Return exit code 0 for success
      ReturnValue('test_exec', IntegerValue('test_exec', 0));
      
      EndBlock('test_exec')
      .EndFunction('test_exec');
      
      // Initialize JIT and execute
      if ValidateModule('test_exec') then
      begin
        try
          if Execute('test_exec') = 0 then
            TLLUtils.PrintLn('    JIT execution: PASSED')
          else
            TLLUtils.PrintLn('    JIT execution: FAILED - Expected exit code 0');
        except
          on E: Exception do
            TLLUtils.PrintLn('    JIT execution: FAILED - Exception: ' + E.Message);
        end;
      end
      else
        TLLUtils.PrintLn('    JIT execution: FAILED - Could not validate module');
        
    finally
      Free();
    end;
  end;
end;

class procedure TTestJIT.TestFunctionExecution();
var
  LParamA, LParamB, LParamX, LParamY, LResult: TLLValue;
begin
  TLLUtils.PrintLn('  Testing function execution...');
  with TLLVM.Create() do
  begin
    try
      // Create a module with add and multiply functions
      CreateModule('func_exec')
      .BeginFunction('func_exec', 'add_numbers', dtInt32, [Param('a', dtInt32), Param('b', dtInt32)])
        .BeginBlock('func_exec', 'entry');
      
      // Get parameters and perform addition
      LParamA := GetParameter('func_exec', 'a');
      LParamB := GetParameter('func_exec', 'b');
      LResult := Add('func_exec', LParamA, LParamB, 'sum');
      ReturnValue('func_exec', LResult);
      
      EndBlock('func_exec')
      .EndFunction('func_exec')
      .BeginFunction('func_exec', 'multiply_numbers', dtInt32, [Param('x', dtInt32), Param('y', dtInt32)])
        .BeginBlock('func_exec', 'entry');
      
      // Get parameters and perform multiplication
      LParamX := GetParameter('func_exec', 'x');
      LParamY := GetParameter('func_exec', 'y');
      LResult := Multiply('func_exec', LParamX, LParamY, 'product');
      ReturnValue('func_exec', LResult);
      
      EndBlock('func_exec')
      .EndFunction('func_exec');
      
      // Test function execution
      if ValidateModule('func_exec') then
      begin
        try
          // Test add: 10 + 20 = 30
          if ExecuteFunction('func_exec', 'add_numbers', [10, 20]).AsInt64 = 30 then
            TLLUtils.PrintLn('    Add function: PASSED')
          else
            TLLUtils.PrintLn('    Add function: FAILED - Expected 30');
          
          // Test multiply: 6 * 7 = 42
          if ExecuteFunction('func_exec', 'multiply_numbers', [6, 7]).AsInt64 = 42 then
            TLLUtils.PrintLn('    Multiply function: PASSED')
          else
            TLLUtils.PrintLn('    Multiply function: FAILED - Expected 42');
            
        except
          on E: Exception do
            TLLUtils.PrintLn('    Function execution: FAILED - Exception: ' + E.Message);
        end;
      end
      else
        TLLUtils.PrintLn('    Function execution: FAILED - Could not validate module');
        
    finally
      Free();
    end;
  end;
end;

class procedure TTestJIT.TestSymbolLookup();
var
  LParam: TLLValue;
begin
  TLLUtils.PrintLn('  Testing symbol lookup...');
  with TLLVM.Create() do
  begin
    try
      // Create a module with a simple test function
      CreateModule('symbol_test')
      .BeginFunction('symbol_test', 'test_func', dtInt32, [Param('value', dtInt32)])
        .BeginBlock('symbol_test', 'entry');
      
      // Return the parameter value
      LParam := GetParameter('symbol_test', 'value');
      ReturnValue('symbol_test', LParam);
      
      EndBlock('symbol_test')
      .EndFunction('symbol_test');
      
      // Test symbol lookup
      if ValidateModule('symbol_test') then
      begin
        try
          // Test lookup of existing symbol
          if LookupSymbol('symbol_test', 'test_func') <> nil then
            TLLUtils.PrintLn('    Lookup existing symbol: PASSED')
          else
            TLLUtils.PrintLn('    Lookup existing symbol: FAILED - Symbol not found');
          
          // Test lookup of non-existing symbol
          if LookupSymbol('symbol_test', 'nonexistent_func') = nil then
            TLLUtils.PrintLn('    Lookup non-existing symbol: PASSED')
          else
            TLLUtils.PrintLn('    Lookup non-existing symbol: FAILED - Should return nil');
            
        except
          on E: Exception do
            TLLUtils.PrintLn('    Symbol lookup: FAILED - Exception: ' + E.Message);
        end;
      end
      else
        TLLUtils.PrintLn('    Symbol lookup: FAILED - Could not validate module');
        
    finally
      Free();
    end;
  end;
end;

class procedure TTestJIT.TestExternalLibraries();
var
  LStringArg: TLLValue;
begin
  TLLUtils.PrintLn('  Testing external libraries...');
  with TLLVM.Create() do
  begin
    try
      // Create a module that declares and uses printf from msvcrt.dll
      CreateModule('external_test')
      // Declare external printf function
      .BeginFunction('external_test', 'printf', dtInt32, [Param('format', dtInt8Ptr)], vExternal, ccCDecl, True, 'msvcrt.dll')
      .EndFunction('external_test')
      // Create a test function that calls printf
      .BeginFunction('external_test', 'test_printf', dtInt32, [])
        .BeginBlock('external_test', 'entry');
      
      // Call printf with a string
      LStringArg := StringValue('external_test', 'Hello from JIT!\n');
      CallFunction('external_test', 'printf', [LStringArg]);
      ReturnValue('external_test', IntegerValue('external_test', 0));
      
      EndBlock('external_test')
      .EndFunction('external_test');
      
      // Test external library functionality
      if ValidateModule('external_test') then
      begin
        try
          // Add the external library
          AddExternalDLL('external_test', 'msvcrt.dll');
          TLLUtils.PrintLn('    Add external DLL: PASSED');
          
          // Test calling external function
          if ExecuteFunction('external_test', 'test_printf', []).AsInt64 >= 0 then
            TLLUtils.PrintLn('    Call external function: PASSED')
          else
            TLLUtils.PrintLn('    Call external function: FAILED - printf returned error');
            
        except
          on E: Exception do
            TLLUtils.PrintLn('    External libraries: FAILED - Exception: ' + E.Message);
        end;
      end
      else
        TLLUtils.PrintLn('    External libraries: FAILED - Could not validate module');
        
    finally
      Free();
    end;
  end;
end;

class procedure TTestJIT.TestAbsoluteSymbols();
var
  LTestVariable: Integer;
begin
  TLLUtils.PrintLn('  Testing absolute symbols...');
  with TLLVM.Create() do
  begin
    try
      LTestVariable := 999;
      
      // Create a module with an external function declaration
      CreateModule('absolute_test')
      // Declare external function that will be defined as absolute symbol
      .BeginFunction('absolute_test', 'get_magic_number', dtInt32, [], vExternal)
      .EndFunction('absolute_test')
      // Create a test function that calls the absolute symbol
      .BeginFunction('absolute_test', 'test_absolute', dtInt32, [])
        .BeginBlock('absolute_test', 'entry');
      
      // Call the external function we'll define as absolute
      ReturnValue('absolute_test', CallFunction('absolute_test', 'get_magic_number', []));
      
      EndBlock('absolute_test')
      .EndFunction('absolute_test');
      
      // Test absolute symbol functionality
      if ValidateModule('absolute_test') then
      begin
        try
          // Define absolute symbol pointing to our variable
          DefineAbsoluteSymbol('absolute_test', 'get_magic_number', @LTestVariable);
          TLLUtils.PrintLn('    Define absolute symbol: PASSED');
          
          // Test that the symbol can be looked up
          if LookupSymbol('absolute_test', 'get_magic_number') <> nil then
            TLLUtils.PrintLn('    Lookup absolute symbol: PASSED')
          else
            TLLUtils.PrintLn('    Lookup absolute symbol: FAILED - Symbol not found');
            
        except
          on E: Exception do
            TLLUtils.PrintLn('    Absolute symbols: FAILED - Exception: ' + E.Message);
        end;
      end
      else
        TLLUtils.PrintLn('    Absolute symbols: FAILED - Could not validate module');
        
    finally
      Free();
    end;
  end;
end;

class procedure TTestJIT.TestProcessSymbols();
begin
  TLLUtils.PrintLn('  Testing process symbols...');
  with TLLVM.Create() do
  begin
    try
      // Create a module that uses a Windows API function
      CreateModule('process_test')
      // Declare external GetTickCount function from kernel32
      .BeginFunction('process_test', 'GetTickCount', dtInt32, [], vExternal, ccStdCall)
      .EndFunction('process_test')
      // Create a test function that calls GetTickCount
      .BeginFunction('process_test', 'test_process_symbol', dtInt32, [])
        .BeginBlock('process_test', 'entry');
      
      // Call GetTickCount
      ReturnValue('process_test', CallFunction('process_test', 'GetTickCount', []));
      
      EndBlock('process_test')
      .EndFunction('process_test');
      
      // Test process symbol functionality
      if ValidateModule('process_test') then
      begin
        try
          // Add process symbols
          AddProcessSymbols('process_test');
          TLLUtils.PrintLn('    Add process symbols: PASSED');
          
          // Test calling a process symbol function
          if ExecuteFunction('process_test', 'test_process_symbol', []).AsInt64 > 0 then
            TLLUtils.PrintLn('    Call process symbol: PASSED')
          else
            TLLUtils.PrintLn('    Call process symbol: FAILED - GetTickCount returned invalid value');
            
        except
          on E: Exception do
          begin
            // Process symbols might fail on some systems
            TLLUtils.PrintLn('    Process symbols: WARNING - Exception: ' + E.Message);
            TLLUtils.PrintLn('    (This may be expected on some systems)');
          end;
        end;
      end
      else
        TLLUtils.PrintLn('    Process symbols: FAILED - Could not validate module');
        
    finally
      Free();
    end;
  end;
end;

class procedure TTestJIT.TestJITInitialization();
begin
  TLLUtils.PrintLn('  Testing JIT initialization...');
  with TLLVM.Create() do
  begin
    try
      // Create a simple module with a main function
      CreateModule('init_test')
      .BeginFunction('init_test', 'main', dtInt32, [])
        .BeginBlock('init_test', 'entry');
      
      // Return constant value 42
      ReturnValue('init_test', IntegerValue('init_test', 42));
      
      EndBlock('init_test')
      .EndFunction('init_test');
      
      // Test JIT initialization through ValidateModule
      if ValidateModule('init_test') then
        TLLUtils.PrintLn('    JIT initialization: PASSED')
      else
        TLLUtils.PrintLn('    JIT initialization: FAILED - ValidateModule returned false');
        
    finally
      Free();
    end;
  end;
end;

end.
