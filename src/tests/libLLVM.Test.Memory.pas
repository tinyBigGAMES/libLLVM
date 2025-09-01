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

unit libLLVM.Test.Memory;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestMemory }
  TTestMemory = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for memory operations functionality
    class procedure TestArrayAllocation(); static;
    class procedure TestPointerArithmetic(); static;
    class procedure TestMemoryLoading(); static;
    class procedure TestMemoryStoring(); static;
    class procedure TestElementAccess(); static;
    class procedure TestMemoryNaming(); static;
  end;

implementation

{ TTestMemory }

class procedure TTestMemory.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.Memory...');
  
  TestArrayAllocation();
  TestPointerArithmetic();
  TestMemoryLoading();
  TestMemoryStoring();
  TestElementAccess();
  TestMemoryNaming();
  
  TLLUtils.PrintLn('libLLVM.Test.Memory completed.');
end;

class procedure TTestMemory.TestArrayAllocation();
var
  LParse: TLLVM;
  LModuleId: string;
  LArrayPtr: TLLValue;
  LArraySize: TLLValue;
  LIsValid: Boolean;
begin
  TLLUtils.PrintLn('  Testing array allocation...');
  
  LParse := TLLVM.Create();
  try
    LModuleId := 'test_array_alloc';
    
    // Create test module
    LParse.CreateModule(LModuleId);
    
    // Begin a test function
    LParse.BeginFunction(LModuleId, 'test_arrays', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Test 1: Allocate integer array
    LArraySize := LParse.IntegerValue(LModuleId, 10, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt32, LArraySize, 'int_array');
    
    // Test 2: Allocate float array  
    LArraySize := LParse.IntegerValue(LModuleId, 5, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtFloat64, LArraySize, 'float_array');
    
    // Test 3: Allocate byte array
    LArraySize := LParse.IntegerValue(LModuleId, 256, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt8, LArraySize, 'byte_array');
    
    // Test 4: Dynamic size allocation
    LArraySize := LParse.IntegerValue(LModuleId, 42, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt64, LArraySize);
    
    // End function
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Validate module
    LIsValid := LParse.ValidateModule(LModuleId);
    if LIsValid then
      TLLUtils.PrintLn('    ✓ Array allocation tests passed')
    else
      TLLUtils.PrintLn('    ✗ Array allocation validation failed');
    
    // Cleanup
    LParse.DeleteModule(LModuleId);
  finally
    LParse.Free();
  end;
end;

class procedure TTestMemory.TestPointerArithmetic();
var
  LParse: TLLVM;
  LModuleId: string;
  LArrayPtr: TLLValue;
  LArraySize: TLLValue;
  LElementPtr: TLLValue;
  LIndex: TLLValue;
  LIsValid: Boolean;
begin
  TLLUtils.PrintLn('  Testing pointer arithmetic...');
  
  LParse := TLLVM.Create();
  try
    LModuleId := 'test_ptr_arithmetic';
    
    // Create test module
    LParse.CreateModule(LModuleId);
    
    // Begin a test function
    LParse.BeginFunction(LModuleId, 'test_gep', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Create an array to work with
    LArraySize := LParse.IntegerValue(LModuleId, 20, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt32, LArraySize, 'test_array');
    
    // Test 1: Get element at index 0
    LIndex := LParse.IntegerValue(LModuleId, 0, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex], 'elem_0');
    
    // Test 2: Get element at index 5
    LIndex := LParse.IntegerValue(LModuleId, 5, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex], 'elem_5');
    
    // Test 3: Get element at index 19 (last element)
    LIndex := LParse.IntegerValue(LModuleId, 19, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex], 'elem_last');
    
    // Test 4: Multi-dimensional indexing
    LIndex := LParse.IntegerValue(LModuleId, 10, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    
    // End function
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Validate module
    LIsValid := LParse.ValidateModule(LModuleId);
    if LIsValid then
      TLLUtils.PrintLn('    ✓ Pointer arithmetic tests passed')
    else
      TLLUtils.PrintLn('    ✗ Pointer arithmetic validation failed');
    
    // Cleanup
    LParse.DeleteModule(LModuleId);
  finally
    LParse.Free();
  end;
end;

class procedure TTestMemory.TestMemoryLoading();
var
  LParse: TLLVM;
  LModuleId: string;
  LArrayPtr: TLLValue;
  LArraySize: TLLValue;
  LElementPtr: TLLValue;
  LLoadedValue: TLLValue;
  LIndex: TLLValue;
  LIsValid: Boolean;
begin
  TLLUtils.PrintLn('  Testing memory loading...');
  
  LParse := TLLVM.Create();
  try
    LModuleId := 'test_memory_load';
    
    // Create test module
    LParse.CreateModule(LModuleId);
    
    // Begin a test function
    LParse.BeginFunction(LModuleId, 'test_load', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Create an array to work with
    LArraySize := LParse.IntegerValue(LModuleId, 10, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt32, LArraySize, 'load_array');
    
    // Test 1: Load from first element
    LIndex := LParse.IntegerValue(LModuleId, 0, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr, 'loaded_0');
    
    // Test 2: Load from middle element
    LIndex := LParse.IntegerValue(LModuleId, 5, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr, 'loaded_5');
    
    // Test 3: Load from last element
    LIndex := LParse.IntegerValue(LModuleId, 9, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr, 'loaded_last');
    
    // Test 4: Load without custom name
    LIndex := LParse.IntegerValue(LModuleId, 3, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr);
    
    // End function
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Validate module
    LIsValid := LParse.ValidateModule(LModuleId);
    if LIsValid then
      TLLUtils.PrintLn('    ✓ Memory loading tests passed')
    else
      TLLUtils.PrintLn('    ✗ Memory loading validation failed');
    
    // Cleanup
    LParse.DeleteModule(LModuleId);
  finally
    LParse.Free();
  end;
end;

class procedure TTestMemory.TestMemoryStoring();
var
  LParse: TLLVM;
  LModuleId: string;
  LArrayPtr: TLLValue;
  LArraySize: TLLValue;
  LElementPtr: TLLValue;
  LValueToStore: TLLValue;
  LIndex: TLLValue;
  LIsValid: Boolean;
begin
  TLLUtils.PrintLn('  Testing memory storing...');
  
  LParse := TLLVM.Create();
  try
    LModuleId := 'test_memory_store';
    
    // Create test module
    LParse.CreateModule(LModuleId);
    
    // Begin a test function
    LParse.BeginFunction(LModuleId, 'test_store', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Create an array to work with
    LArraySize := LParse.IntegerValue(LModuleId, 10, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt32, LArraySize, 'store_array');
    
    // Test 1: Store integer value at index 0
    LIndex := LParse.IntegerValue(LModuleId, 0, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LValueToStore := LParse.IntegerValue(LModuleId, 42, dtInt32);
    LParse.StoreValue(LModuleId, LValueToStore, LElementPtr);
    
    // Test 2: Store different value at index 5
    LIndex := LParse.IntegerValue(LModuleId, 5, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LValueToStore := LParse.IntegerValue(LModuleId, 123, dtInt32);
    LParse.StoreValue(LModuleId, LValueToStore, LElementPtr);
    
    // Test 3: Store negative value
    LIndex := LParse.IntegerValue(LModuleId, 2, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LValueToStore := LParse.IntegerValue(LModuleId, -999, dtInt32);
    LParse.StoreValue(LModuleId, LValueToStore, LElementPtr);
    
    // Test 4: Store zero value
    LIndex := LParse.IntegerValue(LModuleId, 9, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LValueToStore := LParse.IntegerValue(LModuleId, 0, dtInt32);
    LParse.StoreValue(LModuleId, LValueToStore, LElementPtr);
    
    // End function
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Validate module
    LIsValid := LParse.ValidateModule(LModuleId);
    if LIsValid then
      TLLUtils.PrintLn('    ✓ Memory storing tests passed')
    else
      TLLUtils.PrintLn('    ✗ Memory storing validation failed');
    
    // Cleanup
    LParse.DeleteModule(LModuleId);
  finally
    LParse.Free();
  end;
end;

class procedure TTestMemory.TestElementAccess();
var
  LParse: TLLVM;
  LModuleId: string;
  LArrayPtr: TLLValue;
  LArraySize: TLLValue;
  LElementPtr: TLLValue;
  LValueToStore: TLLValue;
  LLoadedValue: TLLValue;
  LIndex: TLLValue;
  LIsValid: Boolean;
begin
  TLLUtils.PrintLn('  Testing element access...');
  
  LParse := TLLVM.Create();
  try
    LModuleId := 'test_element_access';
    
    // Create test module
    LParse.CreateModule(LModuleId);
    
    // Begin a test function
    LParse.BeginFunction(LModuleId, 'test_access', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Test with different data types
    
    // Test 1: Integer array access
    LArraySize := LParse.IntegerValue(LModuleId, 8, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt32, LArraySize, 'int_access_array');
    
    // Store and load integer values
    LIndex := LParse.IntegerValue(LModuleId, 3, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LValueToStore := LParse.IntegerValue(LModuleId, 777, dtInt32);
    LParse.StoreValue(LModuleId, LValueToStore, LElementPtr);
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr, 'loaded_int');
    
    // Test 2: Byte array access
    LArraySize := LParse.IntegerValue(LModuleId, 16, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt8, LArraySize, 'byte_access_array');
    
    // Store and load byte values
    LIndex := LParse.IntegerValue(LModuleId, 7, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LValueToStore := LParse.IntegerValue(LModuleId, 255, dtInt8);
    LParse.StoreValue(LModuleId, LValueToStore, LElementPtr);
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr, 'loaded_byte');
    
    // Test 3: Sequential access pattern
    LArraySize := LParse.IntegerValue(LModuleId, 5, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt64, LArraySize, 'seq_array');
    
    // Access elements 0, 1, 2, 3, 4 in sequence
    LIndex := LParse.IntegerValue(LModuleId, 0, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LValueToStore := LParse.IntegerValue(LModuleId, 100, dtInt64);
    LParse.StoreValue(LModuleId, LValueToStore, LElementPtr);
    
    LIndex := LParse.IntegerValue(LModuleId, 4, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex]);
    LValueToStore := LParse.IntegerValue(LModuleId, 500, dtInt64);
    LParse.StoreValue(LModuleId, LValueToStore, LElementPtr);
    
    // End function
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Validate module
    LIsValid := LParse.ValidateModule(LModuleId);
    if LIsValid then
      TLLUtils.PrintLn('    ✓ Element access tests passed')
    else
      TLLUtils.PrintLn('    ✗ Element access validation failed');
    
    // Cleanup
    LParse.DeleteModule(LModuleId);
  finally
    LParse.Free();
  end;
end;

class procedure TTestMemory.TestMemoryNaming();
var
  LParse: TLLVM;
  LModuleId: string;
  LArrayPtr: TLLValue;
  LArraySize: TLLValue;
  LElementPtr: TLLValue;
  LLoadedValue: TLLValue;
  LIndex: TLLValue;
  LIR: string;
  LIsValid: Boolean;
begin
  TLLUtils.PrintLn('  Testing memory operation naming...');
  
  LParse := TLLVM.Create();
  try
    LModuleId := 'test_memory_naming';
    
    // Create test module
    LParse.CreateModule(LModuleId);
    
    // Begin a test function
    LParse.BeginFunction(LModuleId, 'test_naming', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Test 1: Named array allocation
    LArraySize := LParse.IntegerValue(LModuleId, 12, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtInt32, LArraySize, 'my_special_array');
    
    // Test 2: Named element pointer
    LIndex := LParse.IntegerValue(LModuleId, 6, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex], 'middle_element_ptr');
    
    // Test 3: Named load operation
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr, 'middle_element_value');
    
    // Test 4: Multiple named operations with descriptive names
    LIndex := LParse.IntegerValue(LModuleId, 0, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex], 'first_element_address');
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr, 'first_element_data');
    
    LIndex := LParse.IntegerValue(LModuleId, 11, dtInt32);
    LElementPtr := LParse.GetElementPtr(LModuleId, LArrayPtr, [LIndex], 'last_element_address');
    LLoadedValue := LParse.LoadValue(LModuleId, LElementPtr, 'last_element_data');
    
    // Test 5: Verify that names appear in IR
    LArraySize := LParse.IntegerValue(LModuleId, 3, dtInt32);
    LArrayPtr := LParse.AllocateArray(LModuleId, dtFloat64, LArraySize, 'test_float_buffer');
    
    // End function
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Validate module
    LIsValid := LParse.ValidateModule(LModuleId);
    
    // Get IR to verify names are present
    LIR := LParse.GetModuleIR(LModuleId);
    
    // Check if our custom names appear in the IR
    if LIsValid and 
       (Pos('my_special_array', LIR) > 0) and
       (Pos('middle_element_ptr', LIR) > 0) and
       (Pos('first_element_address', LIR) > 0) and
       (Pos('test_float_buffer', LIR) > 0) then
      TLLUtils.PrintLn('    ✓ Memory operation naming tests passed')
    else
      TLLUtils.PrintLn('    ✗ Memory operation naming validation failed');
    
    // Cleanup
    LParse.DeleteModule(LModuleId);
  finally
    LParse.Free();
  end;
end;

end.
