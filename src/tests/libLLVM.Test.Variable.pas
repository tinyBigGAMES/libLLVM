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

unit libLLVM.Test.Variable;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestVariable }
  TTestVariable = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for variable management functionality
    class procedure TestGlobalVariables(); static;
    class procedure TestLocalVariables(); static;
    class procedure TestVariableAssignment(); static;
    class procedure TestVariableRetrieval(); static;
    class procedure TestParameterAccess(); static;
    class procedure TestVariableTypes(); static;
  end;

implementation

{ TTestVariable }

class procedure TTestVariable.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.Variable...');
  
  TestGlobalVariables();
  TestLocalVariables();
  TestVariableAssignment();
  TestVariableRetrieval();
  TestParameterAccess();
  TestVariableTypes();
  
  TLLUtils.PrintLn('libLLVM.Test.Variable completed.');
end;

class procedure TTestVariable.TestGlobalVariables();
var
  LParse: TLLVM;
  LValue: TLLValue;
  LModuleId: string;
begin
  LModuleId := 'TestGlobalsModule';
  LParse := TLLVM.Create();
  try
    TLLUtils.PrintLn('  Testing global variable declarations...');
    
    // Create module and test various global variable types
    LParse.CreateModule(LModuleId);
    
    // Test global integer without initial value
    LParse.DeclareGlobal(LModuleId, 'globalInt', dtInt32);
    
    // Test global integer with initial value
    LValue := LParse.IntegerValue(LModuleId, 42);
    LParse.DeclareGlobal(LModuleId, 'globalIntWithValue', dtInt32, LValue);
    
    // Test global float
    LValue := LParse.FloatValue(LModuleId, 3.14159);
    LParse.DeclareGlobal(LModuleId, 'globalFloat', dtFloat64, LValue);
    
    // Test global boolean
    LValue := LParse.BooleanValue(LModuleId, True);
    LParse.DeclareGlobal(LModuleId, 'globalBool', dtInt1, LValue);
    
    // Test global string
    LValue := LParse.StringValue(LModuleId, 'Hello, World!');
    LParse.DeclareGlobal(LModuleId, 'globalString', dtInt8Ptr, LValue);
    
    // Test null value
    LValue := LParse.NullValue(LModuleId, dtPointer);
    LParse.DeclareGlobal(LModuleId, 'globalNull', dtPointer, LValue);
    
    TLLUtils.PrintLn('  ✓ Global variable declarations passed');
  finally
    LParse.Free();
  end;
end;

class procedure TTestVariable.TestLocalVariables();
var
  LParse: TLLVM;
  LModuleId: string;
begin
  LModuleId := 'TestLocalsModule';
  LParse := TLLVM.Create();
  try
    TLLUtils.PrintLn('  Testing local variable declarations...');
    
    LParse.CreateModule(LModuleId);
    
    // Create a function context for local variables
    LParse.BeginFunction(LModuleId, 'testFunction', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Test various local variable types
    LParse.DeclareLocal(LModuleId, 'localInt', dtInt32);
    LParse.DeclareLocal(LModuleId, 'localFloat', dtFloat64);
    LParse.DeclareLocal(LModuleId, 'localBool', dtInt1);
    LParse.DeclareLocal(LModuleId, 'localPtr', dtPointer);
    LParse.DeclareLocal(LModuleId, 'localInt8', dtInt8);
    LParse.DeclareLocal(LModuleId, 'localInt16', dtInt16);
    LParse.DeclareLocal(LModuleId, 'localInt64', dtInt64);
    LParse.DeclareLocal(LModuleId, 'localFloat32', dtFloat32);
    
    LParse.ReturnValue(LModuleId); // void return
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    TLLUtils.PrintLn('  ✓ Local variable declarations passed');
  finally
    LParse.Free();
  end;
end;

class procedure TTestVariable.TestVariableAssignment();
var
  LParse: TLLVM;
  LValue: TLLValue;
  LModuleId: string;
begin
  LModuleId := 'TestAssignModule';
  LParse := TLLVM.Create();
  try
    TLLUtils.PrintLn('  Testing variable assignments...');
    
    LParse.CreateModule(LModuleId);
    
    // Test global variable assignment
    LParse.DeclareGlobal(LModuleId, 'globalVar', dtInt32);
    LValue := LParse.IntegerValue(LModuleId, 123);
    LParse.SetValue(LModuleId, 'globalVar', LValue);
    
    // Test another global assignment with different value
    LValue := LParse.IntegerValue(LModuleId, 456);
    LParse.SetValue(LModuleId, 'globalVar', LValue);
    
    // Test local variable assignment in function context
    LParse.BeginFunction(LModuleId, 'assignmentTest', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    LParse.DeclareLocal(LModuleId, 'localVar', dtInt32);
    LValue := LParse.IntegerValue(LModuleId, 789);
    LParse.SetValue(LModuleId, 'localVar', LValue);
    
    // Test float assignment
    LParse.DeclareLocal(LModuleId, 'localFloat', dtFloat64);
    LValue := LParse.FloatValue(LModuleId, 2.718);
    LParse.SetValue(LModuleId, 'localFloat', LValue);
    
    // Test boolean assignment
    LParse.DeclareLocal(LModuleId, 'localBool', dtInt1);
    LValue := LParse.BooleanValue(LModuleId, False);
    LParse.SetValue(LModuleId, 'localBool', LValue);
    
    // Test reassignment of same variable
    LValue := LParse.IntegerValue(LModuleId, 999);
    LParse.SetValue(LModuleId, 'localVar', LValue);
    
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    TLLUtils.PrintLn('  ✓ Variable assignments passed');
  finally
    LParse.Free();
  end;
end;

class procedure TTestVariable.TestVariableRetrieval();
var
  LParse: TLLVM;
  LValue: TLLValue;
  LRetrievedValue: TLLValue;
  LModuleId: string;
begin
  LModuleId := 'TestRetrievalModule';
  LParse := TLLVM.Create();
  try
    TLLUtils.PrintLn('  Testing variable retrieval...');
    
    LParse.CreateModule(LModuleId);
    
    // Test global variable retrieval
    LValue := LParse.IntegerValue(LModuleId, 789);
    LParse.DeclareGlobal(LModuleId, 'globalForRetrieval', dtInt32, LValue);
    LRetrievedValue := LParse.GetValue(LModuleId, 'globalForRetrieval');
    
    // Test global string retrieval
    LValue := LParse.StringValue(LModuleId, 'Test Global String');
    LParse.DeclareGlobal(LModuleId, 'globalString', dtInt8Ptr, LValue);
    LRetrievedValue := LParse.GetValue(LModuleId, 'globalString');
    
    // Test local variable retrieval
    LParse.BeginFunction(LModuleId, 'retrievalTest', dtInt32, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    LParse.DeclareLocal(LModuleId, 'localForRetrieval', dtInt32);
    LValue := LParse.IntegerValue(LModuleId, 321);
    LParse.SetValue(LModuleId, 'localForRetrieval', LValue);
    
    LRetrievedValue := LParse.GetValue(LModuleId, 'localForRetrieval');
    LParse.ReturnValue(LModuleId, LRetrievedValue);
    
    // Test float retrieval
    LParse.DeclareLocal(LModuleId, 'localFloat', dtFloat64);
    LValue := LParse.FloatValue(LModuleId, 1.618);
    LParse.SetValue(LModuleId, 'localFloat', LValue);
    LRetrievedValue := LParse.GetValue(LModuleId, 'localFloat');
    
    // Test boolean retrieval
    LParse.DeclareLocal(LModuleId, 'localBool', dtInt1);
    LValue := LParse.BooleanValue(LModuleId, True);
    LParse.SetValue(LModuleId, 'localBool', LValue);
    LRetrievedValue := LParse.GetValue(LModuleId, 'localBool');
    
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    TLLUtils.PrintLn('  ✓ Variable retrieval passed');
  finally
    LParse.Free();
  end;
end;

class procedure TTestVariable.TestParameterAccess();
var
  LParse: TLLVM;
  LParamValue: TLLValue;
  LModuleId: string;
begin
  LModuleId := 'TestParamModule';
  LParse := TLLVM.Create();
  try
    TLLUtils.PrintLn('  Testing parameter access...');
    
    LParse.CreateModule(LModuleId);
    
    // Test parameter access by name and index
    LParse.BeginFunction(LModuleId, 'paramTest', dtInt32, [
      LParse.Param('param1', dtInt32),
      LParse.Param('param2', dtFloat64),
      LParse.Param('param3', dtInt1)
    ]);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Test parameter access by name
    LParamValue := LParse.GetParameter(LModuleId, 'param1');
    LParamValue := LParse.GetParameter(LModuleId, 'param2');
    LParamValue := LParse.GetParameter(LModuleId, 'param3');
    
    // Test parameter access by index
    LParamValue := LParse.GetParameter(LModuleId, 0); // param1
    LParamValue := LParse.GetParameter(LModuleId, 1); // param2
    LParamValue := LParse.GetParameter(LModuleId, 2); // param3
    
    // Test using parameters in operations
    LParamValue := LParse.Add(LModuleId, 
      LParse.GetParameter(LModuleId, 'param1'), 
      LParse.IntegerValue(LModuleId, 10));
    
    LParse.ReturnValue(LModuleId, LParse.GetParameter(LModuleId, 0));
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    // Test function with more parameters
    LParse.BeginFunction(LModuleId, 'multiParamTest', dtVoid, [
      LParse.Param('intParam', dtInt32),
      LParse.Param('floatParam', dtFloat64),
      LParse.Param('boolParam', dtInt1),
      LParse.Param('ptrParam', dtPointer),
      LParse.Param('int8Param', dtInt8)
    ]);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Access all parameters by index
    LParamValue := LParse.GetParameter(LModuleId, 0);
    LParamValue := LParse.GetParameter(LModuleId, 1);
    LParamValue := LParse.GetParameter(LModuleId, 2);
    LParamValue := LParse.GetParameter(LModuleId, 3);
    LParamValue := LParse.GetParameter(LModuleId, 4);
    
    // Access all parameters by name
    LParamValue := LParse.GetParameter(LModuleId, 'intParam');
    LParamValue := LParse.GetParameter(LModuleId, 'floatParam');
    LParamValue := LParse.GetParameter(LModuleId, 'boolParam');
    LParamValue := LParse.GetParameter(LModuleId, 'ptrParam');
    LParamValue := LParse.GetParameter(LModuleId, 'int8Param');
    
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    TLLUtils.PrintLn('  ✓ Parameter access passed');
  finally
    LParse.Free();
  end;
end;

class procedure TTestVariable.TestVariableTypes();
var
  LParse: TLLVM;
  LValue: TLLValue;
  LModuleId: string;
begin
  LModuleId := 'TestTypesModule';
  LParse := TLLVM.Create();
  try
    TLLUtils.PrintLn('  Testing variable types...');
    
    LParse.CreateModule(LModuleId);
    
    // Test different integer types
    LParse.DeclareGlobal(LModuleId, 'varInt1', dtInt1, LParse.BooleanValue(LModuleId, True));
    LParse.DeclareGlobal(LModuleId, 'varInt8', dtInt8, LParse.IntegerValue(LModuleId, 127, dtInt8));
    LParse.DeclareGlobal(LModuleId, 'varInt16', dtInt16, LParse.IntegerValue(LModuleId, 32767, dtInt16));
    LParse.DeclareGlobal(LModuleId, 'varInt32', dtInt32, LParse.IntegerValue(LModuleId, 2147483647, dtInt32));
    LParse.DeclareGlobal(LModuleId, 'varInt64', dtInt64, LParse.IntegerValue(LModuleId, 1234567890123456, dtInt64));
    
    // Test different float types
    LParse.DeclareGlobal(LModuleId, 'varFloat32', dtFloat32, LParse.FloatValue(LModuleId, 3.14159, dtFloat32));
    LParse.DeclareGlobal(LModuleId, 'varFloat64', dtFloat64, LParse.FloatValue(LModuleId, 2.718281828, dtFloat64));
    
    // Test pointer types
    LParse.DeclareGlobal(LModuleId, 'varPointer', dtPointer, LParse.NullValue(LModuleId, dtPointer));
    LParse.DeclareGlobal(LModuleId, 'varInt8Ptr', dtInt8Ptr, LParse.NullValue(LModuleId, dtInt8Ptr));
    LParse.DeclareGlobal(LModuleId, 'varVoidPtr', dtVoidPtr, LParse.NullValue(LModuleId, dtVoidPtr));
    LParse.DeclareGlobal(LModuleId, 'varInt32Ptr', dtInt32Ptr, LParse.NullValue(LModuleId, dtInt32Ptr));
    
    // Test string as char pointer
    LValue := LParse.StringValue(LModuleId, 'Test String for Types');
    LParse.DeclareGlobal(LModuleId, 'varString', dtInt8Ptr, LValue);
    
    // Test special string with escape sequences
    LValue := LParse.StringValue(LModuleId, 'Line 1\nLine 2\tTabbed\0Null terminated');
    LParse.DeclareGlobal(LModuleId, 'varStringWithEscapes', dtInt8Ptr, LValue);
    
    // Test empty string
    LValue := LParse.StringValue(LModuleId, '');
    LParse.DeclareGlobal(LModuleId, 'varEmptyString', dtInt8Ptr, LValue);
    
    // Test mixed types in function context
    LParse.BeginFunction(LModuleId, 'typeTestFunction', dtVoid, []);
    LParse.BeginBlock(LModuleId, 'entry');
    
    // Test local variables of different types
    LParse.DeclareLocal(LModuleId, 'localInt1', dtInt1);
    LParse.DeclareLocal(LModuleId, 'localInt8', dtInt8);
    LParse.DeclareLocal(LModuleId, 'localInt16', dtInt16);
    LParse.DeclareLocal(LModuleId, 'localInt32', dtInt32);
    LParse.DeclareLocal(LModuleId, 'localInt64', dtInt64);
    LParse.DeclareLocal(LModuleId, 'localFloat32', dtFloat32);
    LParse.DeclareLocal(LModuleId, 'localFloat64', dtFloat64);
    LParse.DeclareLocal(LModuleId, 'localPointer', dtPointer);
    
    // Assign values to local variables
    LParse.SetValue(LModuleId, 'localInt1', LParse.BooleanValue(LModuleId, False));
    LParse.SetValue(LModuleId, 'localInt8', LParse.IntegerValue(LModuleId, 42, dtInt8));
    LParse.SetValue(LModuleId, 'localInt16', LParse.IntegerValue(LModuleId, 1234, dtInt16));
    LParse.SetValue(LModuleId, 'localInt32', LParse.IntegerValue(LModuleId, 987654321, dtInt32));
    LParse.SetValue(LModuleId, 'localInt64', LParse.IntegerValue(LModuleId, 9876543210123456, dtInt64));
    LParse.SetValue(LModuleId, 'localFloat32', LParse.FloatValue(LModuleId, 1.23456, dtFloat32));
    LParse.SetValue(LModuleId, 'localFloat64', LParse.FloatValue(LModuleId, 9.87654321, dtFloat64));
    LParse.SetValue(LModuleId, 'localPointer', LParse.NullValue(LModuleId, dtPointer));
    
    // Test retrieval of different typed values
    LValue := LParse.GetValue(LModuleId, 'localInt1');
    LValue := LParse.GetValue(LModuleId, 'localInt8');
    LValue := LParse.GetValue(LModuleId, 'localInt16');
    LValue := LParse.GetValue(LModuleId, 'localInt32');
    LValue := LParse.GetValue(LModuleId, 'localInt64');
    LValue := LParse.GetValue(LModuleId, 'localFloat32');
    LValue := LParse.GetValue(LModuleId, 'localFloat64');
    LValue := LParse.GetValue(LModuleId, 'localPointer');
    
    LParse.ReturnValue(LModuleId);
    LParse.EndBlock(LModuleId);
    LParse.EndFunction(LModuleId);
    
    TLLUtils.PrintLn('  ✓ Variable types passed');
  finally
    LParse.Free();
  end;
end;

end.
