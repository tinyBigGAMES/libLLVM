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

unit libLLVM.Test.Module;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestModule }
  TTestModule = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for module lifecycle functionality
    class procedure TestModuleCreation(); static;
    class procedure TestModuleDeletion(); static;
    class procedure TestModuleExistence(); static;
    class procedure TestModuleMerging(); static;
    class procedure TestModuleIRGeneration(); static;
    class procedure TestModuleValidation(); static;
    class procedure TestRequiredLibraries(); static;
    class procedure TestTargetPlatform(); static;
  end;

implementation

{ TTestModule }

class procedure TTestModule.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.Module...');
  
  TestModuleCreation();
  TestModuleDeletion();
  TestModuleExistence();
  TestModuleMerging();
  TestModuleIRGeneration();
  TestModuleValidation();
  TestRequiredLibraries();
  TestTargetPlatform();
  
  TLLUtils.PrintLn('libLLVM.Test.Module completed.');
end;

class procedure TTestModule.TestModuleCreation();
begin
  TLLUtils.PrintLn('  Testing module creation...');
  with TLLVM.Create() do
  begin
    try
      // Test basic module creation
      try
        CreateModule('test_create_basic');
        if ModuleExists('test_create_basic') then
          TLLUtils.PrintLn('    Basic module creation: PASSED')
        else
          TLLUtils.PrintLn('    Basic module creation: FAILED - Module not found after creation');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Basic module creation: FAILED - Exception: ' + E.Message);
      end;
      
      // Test context sharing module creation
      try
        CreateModule('test_create_shared', 'test_create_basic');
        if ModuleExists('test_create_shared') then
          TLLUtils.PrintLn('    Context sharing creation: PASSED')
        else
          TLLUtils.PrintLn('    Context sharing creation: FAILED - Shared module not found');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Context sharing creation: FAILED - Exception: ' + E.Message);
      end;
      
      // Test duplicate module creation (should fail)
      try
        CreateModule('test_create_basic'); // Duplicate
        TLLUtils.PrintLn('    Duplicate module prevention: FAILED - Should have thrown exception');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Duplicate module prevention: PASSED - Correctly prevented duplicate');
      end;
      
      // Test empty module name
      try
        CreateModule('');
        TLLUtils.PrintLn('    Empty name handling: FAILED - Should reject empty names');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Empty name handling: PASSED - Correctly rejected empty name');
      end;
      
      // Test invalid shared context reference
      try
        CreateModule('test_invalid_shared', 'nonexistent_module');
        if ModuleExists('test_invalid_shared') then
          TLLUtils.PrintLn('    Invalid context sharing: PASSED - Created with new context')
        else
          TLLUtils.PrintLn('    Invalid context sharing: FAILED - Should create with new context');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Invalid context sharing: WARNING - Exception: ' + E.Message);
      end;
      
    finally
      Free();
    end;
  end;
end;

class procedure TTestModule.TestModuleDeletion();
begin
  TLLUtils.PrintLn('  Testing module deletion...');
  with TLLVM.Create() do
  begin
    try
      // Create test modules
      CreateModule('test_delete_1');
      CreateModule('test_delete_2');
      
      // Test successful deletion
      try
        DeleteModule('test_delete_1');
        if not ModuleExists('test_delete_1') then
          TLLUtils.PrintLn('    Module deletion: PASSED')
        else
          TLLUtils.PrintLn('    Module deletion: FAILED - Module still exists after deletion');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Module deletion: FAILED - Exception: ' + E.Message);
      end;
      
      // Test deletion of non-existent module (should not crash)
      try
        DeleteModule('nonexistent_module');
        TLLUtils.PrintLn('    Non-existent deletion: PASSED - Handled gracefully');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Non-existent deletion: WARNING - Exception: ' + E.Message);
      end;
      
      // Verify other modules still exist
      if ModuleExists('test_delete_2') then
        TLLUtils.PrintLn('    Selective deletion: PASSED - Other modules preserved')
      else
        TLLUtils.PrintLn('    Selective deletion: FAILED - Other modules affected');
      
    finally
      Free();
    end;
  end;
end;

class procedure TTestModule.TestModuleExistence();
begin
  TLLUtils.PrintLn('  Testing module existence checks...');
  with TLLVM.Create() do
  begin
    try
      // Test non-existent module
      if not ModuleExists('does_not_exist') then
        TLLUtils.PrintLn('    Non-existent check: PASSED')
      else
        TLLUtils.PrintLn('    Non-existent check: FAILED - Reported non-existent module as existing');
      
      // Create and test existing module
      CreateModule('test_exists');
      if ModuleExists('test_exists') then
        TLLUtils.PrintLn('    Existing module check: PASSED')
      else
        TLLUtils.PrintLn('    Existing module check: FAILED - Could not find existing module');
      
      // Test empty name check
      if not ModuleExists('') then
        TLLUtils.PrintLn('    Empty name check: PASSED')
      else
        TLLUtils.PrintLn('    Empty name check: FAILED - Should not find empty named modules');
      
      // Test case sensitivity (assuming case-sensitive names)
      CreateModule('CaseSensitive');
      if ModuleExists('CaseSensitive') and not ModuleExists('casesensitive') then
        TLLUtils.PrintLn('    Case sensitivity: PASSED')
      else
        TLLUtils.PrintLn('    Case sensitivity: WARNING - May not be case-sensitive or failed');
      
    finally
      Free();
    end;
  end;
end;

class procedure TTestModule.TestModuleMerging();
var
  LRequiredLibs: TArray<string>;
  LFound: Boolean;
  LLibName: string;
begin
  TLLUtils.PrintLn('  Testing module merging...');
  with TLLVM.Create() do
  begin
    try
      // Create test modules with content
      CreateModule('merge_target')
      .BeginFunction('merge_target', 'target_func', dtInt32, [])
        .BeginBlock('merge_target', 'entry');
      ReturnValue('merge_target', IntegerValue('merge_target', 42));
      EndBlock('merge_target')
      .EndFunction('merge_target');
      
      CreateModule('merge_source1')
      .BeginFunction('merge_source1', 'source1_func', dtInt32, [])
        .BeginBlock('merge_source1', 'entry');
      ReturnValue('merge_source1', IntegerValue('merge_source1', 100));
      EndBlock('merge_source1')
      .EndFunction('merge_source1');
      
      CreateModule('merge_source2')
      .BeginFunction('merge_source2', 'source2_func', dtInt32, [], vExternal, ccCDecl, False, 'kernel32.dll')
      .EndFunction('merge_source2');
      
      // Test successful merge
      try
        MergeModules('merge_target', ['merge_source1', 'merge_source2']);
        TLLUtils.PrintLn('    Module merging: PASSED');
        
        // Verify source modules are deleted after merge
        if not ModuleExists('merge_source1') and not ModuleExists('merge_source2') then
          TLLUtils.PrintLn('    Source cleanup: PASSED')
        else
          TLLUtils.PrintLn('    Source cleanup: FAILED - Source modules still exist');
        
        // Verify target still exists
        if ModuleExists('merge_target') then
          TLLUtils.PrintLn('    Target preservation: PASSED')
        else
          TLLUtils.PrintLn('    Target preservation: FAILED - Target module missing');
        
        // Test library dependency merging
        LRequiredLibs := GetRequiredLibraries('merge_target');
        LFound := False;
        for LLibName in LRequiredLibs do
        begin
          if LLibName = 'kernel32.dll' then
          begin
            LFound := True;
            Break;
          end;
        end;
        
        if LFound then
          TLLUtils.PrintLn('    Library merge: PASSED')
        else
          TLLUtils.PrintLn('    Library merge: FAILED - External library not merged');
        
      except
        on E: Exception do
          TLLUtils.PrintLn('    Module merging: FAILED - Exception: ' + E.Message);
      end;
      
      // Test merge with non-existent target
      try
        MergeModules('nonexistent_target', ['merge_target']);
        TLLUtils.PrintLn('    Invalid target merge: FAILED - Should have thrown exception');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Invalid target merge: PASSED - Correctly rejected invalid target');
      end;
      
      // Test merge with non-existent source
      CreateModule('merge_test_target2');
      try
        MergeModules('merge_test_target2', ['nonexistent_source']);
        TLLUtils.PrintLn('    Invalid source merge: FAILED - Should have thrown exception');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Invalid source merge: PASSED - Correctly rejected invalid source');
      end;
      
    finally
      Free();
    end;
  end;
end;

class procedure TTestModule.TestModuleIRGeneration();
var
  LIR: string;
begin
  TLLUtils.PrintLn('  Testing module IR generation...');
  with TLLVM.Create() do
  begin
    try
      // Create module with simple function
      CreateModule('ir_test')
      .BeginFunction('ir_test', 'simple_func', dtInt32, [])
        .BeginBlock('ir_test', 'entry');
      ReturnValue('ir_test', IntegerValue('ir_test', 123));
      EndBlock('ir_test')
      .EndFunction('ir_test');
      
      // Test IR generation
      try
        LIR := GetModuleIR('ir_test');
        if (LIR <> '') and (Pos('simple_func', LIR) > 0) then
          TLLUtils.PrintLn('    IR generation: PASSED')
        else
          TLLUtils.PrintLn('    IR generation: FAILED - Empty or invalid IR');
      except
        on E: Exception do
          TLLUtils.PrintLn('    IR generation: FAILED - Exception: ' + E.Message);
      end;
      
      // Test IR generation for non-existent module
      try
        LIR := GetModuleIR('nonexistent_module');
        TLLUtils.PrintLn('    Invalid module IR: FAILED - Should have thrown exception');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Invalid module IR: PASSED - Correctly rejected invalid module');
      end;
      
      // Test empty module IR
      CreateModule('empty_module');
      try
        LIR := GetModuleIR('empty_module');
        if LIR <> '' then
          TLLUtils.PrintLn('    Empty module IR: PASSED - Generated basic IR structure')
        else
          TLLUtils.PrintLn('    Empty module IR: WARNING - Empty IR for empty module');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Empty module IR: FAILED - Exception: ' + E.Message);
      end;
      
    finally
      Free();
    end;
  end;
end;

class procedure TTestModule.TestModuleValidation();
begin
  TLLUtils.PrintLn('  Testing module validation...');
  with TLLVM.Create() do
  begin
    try
      // Test validation of valid module
      CreateModule('valid_module')
      .BeginFunction('valid_module', 'valid_func', dtInt32, [])
        .BeginBlock('valid_module', 'entry');
      ReturnValue('valid_module', IntegerValue('valid_module', 456));
      EndBlock('valid_module')
      .EndFunction('valid_module');
      
      try
        if ValidateModule('valid_module') then
          TLLUtils.PrintLn('    Valid module validation: PASSED')
        else
          TLLUtils.PrintLn('    Valid module validation: FAILED - Valid module rejected');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Valid module validation: FAILED - Exception: ' + E.Message);
      end;
      
      // Test validation of incomplete module (function without return)
      CreateModule('incomplete_module')
      .BeginFunction('incomplete_module', 'incomplete_func', dtInt32, [])
        .BeginBlock('incomplete_module', 'entry');
      // Intentionally missing return statement
      EndBlock('incomplete_module')
      .EndFunction('incomplete_module');
      
      try
        if not ValidateModule('incomplete_module') then
          TLLUtils.PrintLn('    Invalid module validation: PASSED - Correctly rejected invalid module')
        else
          TLLUtils.PrintLn('    Invalid module validation: WARNING - Invalid module passed validation');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Invalid module validation: PASSED - Exception caught: ' + E.Message);
      end;
      
      // Test validation of non-existent module
      try
        ValidateModule('nonexistent_module');
        TLLUtils.PrintLn('    Non-existent validation: FAILED - Should have thrown exception');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Non-existent validation: PASSED - Correctly rejected non-existent module');
      end;
      
      // Test empty module validation
      CreateModule('empty_validation_test');
      try
        if ValidateModule('empty_validation_test') then
          TLLUtils.PrintLn('    Empty module validation: PASSED - Empty module is valid')
        else
          TLLUtils.PrintLn('    Empty module validation: WARNING - Empty module failed validation');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Empty module validation: FAILED - Exception: ' + E.Message);
      end;
      
    finally
      Free();
    end;
  end;
end;

class procedure TTestModule.TestRequiredLibraries();
var
  LRequiredLibs: TArray<string>;
  LFound1, LFound2: Boolean;
  LLibName: string;
begin
  TLLUtils.PrintLn('  Testing required libraries...');
  with TLLVM.Create() do
  begin
    try
      // Test module with no external libraries
      CreateModule('no_libs_module')
      .BeginFunction('no_libs_module', 'internal_func', dtInt32, [])
        .BeginBlock('no_libs_module', 'entry');
      ReturnValue('no_libs_module', IntegerValue('no_libs_module', 0));
      EndBlock('no_libs_module')
      .EndFunction('no_libs_module');
      
      LRequiredLibs := GetRequiredLibraries('no_libs_module');
      if Length(LRequiredLibs) = 0 then
        TLLUtils.PrintLn('    No libraries test: PASSED')
      else
        TLLUtils.PrintLn('    No libraries test: FAILED - Found unexpected libraries');
      
      // Test module with external libraries
      CreateModule('libs_module')
      .BeginFunction('libs_module', 'printf', dtInt32, [Param('format', dtInt8Ptr)], vExternal, ccCDecl, True, 'msvcrt.dll')
      .EndFunction('libs_module')
      .BeginFunction('libs_module', 'GetTickCount', dtInt32, [], vExternal, ccStdCall, False, 'kernel32.dll')
      .EndFunction('libs_module');
      
      LRequiredLibs := GetRequiredLibraries('libs_module');
      
      // Check for expected libraries
      LFound1 := False;
      LFound2 := False;
      for LLibName in LRequiredLibs do
      begin
        if LLibName = 'msvcrt.dll' then
          LFound1 := True
        else if LLibName = 'kernel32.dll' then
          LFound2 := True;
      end;
      
      if LFound1 and LFound2 then
        TLLUtils.PrintLn('    External libraries test: PASSED')
      else
        TLLUtils.PrintLn('    External libraries test: FAILED - Expected libraries not found');
      
      // Test non-existent module
      try
        LRequiredLibs := GetRequiredLibraries('nonexistent_module');
        if Length(LRequiredLibs) = 0 then
          TLLUtils.PrintLn('    Non-existent libraries: PASSED - Empty array returned')
        else
          TLLUtils.PrintLn('    Non-existent libraries: WARNING - Unexpected libraries found');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Non-existent libraries: PASSED - Exception: ' + E.Message);
      end;
      
      // Test library inheritance after module merge
      CreateModule('merge_lib_target');
      CreateModule('merge_lib_source')
      .BeginFunction('merge_lib_source', 'MessageBoxA', dtInt32, [
        Param('hWnd', dtPointer), 
        Param('lpText', dtInt8Ptr), 
        Param('lpCaption', dtInt8Ptr), 
        Param('uType', dtInt32)
      ], vExternal, ccStdCall, False, 'user32.dll')
      .EndFunction('merge_lib_source');
      
      // Merge and check if library is inherited
      try
        MergeModules('merge_lib_target', ['merge_lib_source']);
        LRequiredLibs := GetRequiredLibraries('merge_lib_target');
        
        LFound1 := False;
        for LLibName in LRequiredLibs do
        begin
          if LLibName = 'user32.dll' then
          begin
            LFound1 := True;
            Break;
          end;
        end;
        
        if LFound1 then
          TLLUtils.PrintLn('    Library inheritance: PASSED')
        else
          TLLUtils.PrintLn('    Library inheritance: FAILED - Library not inherited after merge');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Library inheritance: FAILED - Exception: ' + E.Message);
      end;
      
    finally
      Free();
    end;
  end;
end;

class procedure TTestModule.TestTargetPlatform();
var
  LIR: string;
begin
  TLLUtils.PrintLn('  Testing target platform settings...');
  with TLLVM.Create() do
  begin
    try
      // Test setting target platform
      try
        SetTargetPlatform('x86_64-pc-windows-msvc', 'e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128');
        TLLUtils.PrintLn('    Target platform setting: PASSED');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Target platform setting: FAILED - Exception: ' + E.Message);
      end;
      
      // Create module after setting platform and verify it's applied
      CreateModule('platform_test')
      .BeginFunction('platform_test', 'platform_func', dtInt32, [])
        .BeginBlock('platform_test', 'entry');
      ReturnValue('platform_test', IntegerValue('platform_test', 789));
      EndBlock('platform_test')
      .EndFunction('platform_test');
      
      try
        LIR := GetModuleIR('platform_test');
        if (Pos('x86_64-pc-windows-msvc', LIR) > 0) or (Pos('target triple', LIR) > 0) then
          TLLUtils.PrintLn('    Platform application: PASSED')
        else
          TLLUtils.PrintLn('    Platform application: WARNING - Platform info not visible in IR');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Platform application: FAILED - Exception: ' + E.Message);
      end;
      
      // Test validation still works with custom platform
      try
        if ValidateModule('platform_test') then
          TLLUtils.PrintLn('    Platform validation: PASSED')
        else
          TLLUtils.PrintLn('    Platform validation: WARNING - Custom platform failed validation');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Platform validation: FAILED - Exception: ' + E.Message);
      end;
      
      // Test empty platform settings
      try
        SetTargetPlatform('', '');
        TLLUtils.PrintLn('    Empty platform setting: PASSED - No exception thrown');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Empty platform setting: WARNING - Exception: ' + E.Message);
      end;
      
      // Test invalid platform settings
      try
        SetTargetPlatform('invalid-triple-format', 'invalid-datalayout');
        CreateModule('invalid_platform_test');
        
        // This might not fail immediately, but could cause issues later
        if ValidateModule('invalid_platform_test') then
          TLLUtils.PrintLn('    Invalid platform handling: PASSED - Handled gracefully')
        else
          TLLUtils.PrintLn('    Invalid platform handling: WARNING - Invalid platform caused validation failure');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Invalid platform handling: WARNING - Exception: ' + E.Message);
      end;
      
    finally
      Free();
    end;
  end;
end;

end.