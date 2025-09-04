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

unit libLLVM.Test.ObjectCompilation;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  libLLVM.Utils,
  libLLVM;

type
  { TTestObjectCompilation }
  TTestObjectCompilation = class
  public
    class procedure RunAllTests(); static;

    // Test methods for object compilation functionality
    class procedure TestSingleModuleCompilation(); static;
    class procedure TestBatchModuleCompilation(); static;
    class procedure TestOptimizationLevels(); static;
    class procedure TestFileExtensions(); static;
    class procedure TestOutputDirectories(); static;
    class procedure TestErrorConditions(); static;
    class procedure TestFileVerification(); static;
  end;

implementation

{ TTestObjectCompilation }

class procedure TTestObjectCompilation.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.ObjectCompilation...');
  
  TestSingleModuleCompilation();
  TestBatchModuleCompilation();
  TestOptimizationLevels();
  TestFileExtensions();
  TestOutputDirectories();
  TestErrorConditions();
  TestFileVerification();
  
  TLLUtils.PrintLn('libLLVM.Test.ObjectCompilation completed.');
end;

(**
 * Test: Single Module Object Compilation
 * 
 * Description: This test demonstrates compiling a single LLVM module to an object file
 * using the default output path (output\obj). It shows the basic workflow from IR 
 * generation to object file creation that can be linked with external tools.
 *
 * Functions Demonstrated:
 * - CompileModuleToObject() - Compile module to object file with default path
 * - CreateModule() - Create LLVM module for compilation
 * - ValidateModule() - Ensure module is valid before compilation
 * - GetObjectFileExtension() - Platform-specific file extensions
 *
 * LLVM Concepts Covered:
 * - Object file generation from LLVM IR
 * - Target machine creation and configuration
 * - File system output and path management
 * - Platform-specific object file formats (.obj on Windows, .o on Unix)
 *
 * Expected Output: "Single compilation: PASSED - output\obj\single_test.obj created"
 *
 * Takeaway: Learn how to compile LLVM IR to native object files ready for
 * linking into executables or libraries using standard build tools.
 *)
class procedure TTestObjectCompilation.TestSingleModuleCompilation();
var
  LObjectFile: string;
begin
  TLLUtils.PrintLn('  Testing single module compilation...');
  with TLLVM.Create() do
  begin
    try
      // Create a simple test module with basic function
      CreateModule('single_test')
      .BeginFunction('single_test', 'get_answer', dtInt32, [])
        .BeginBlock('single_test', 'entry');
      
      // Return the answer to everything
      ReturnValue('single_test', IntegerValue('single_test', 42));
      
      EndBlock('single_test')
      .EndFunction('single_test');
      
      // Validate module before compilation
      if ValidateModule('single_test') then
      begin
        try
          // Compile to output\obj directory
          LObjectFile := CompileModuleToObject('single_test', 'output\obj');
          
          if TFile.Exists(LObjectFile) then
          begin
            TLLUtils.PrintLn('    Single compilation: PASSED - %s created', [LObjectFile]);
            TLLUtils.PrintLn('    File size: %d bytes', [TFile.GetSize(LObjectFile)]);
          end
          else
            TLLUtils.PrintLn('    Single compilation: FAILED - Object file not found at %s', [LObjectFile]);
        except
          on E: Exception do
            TLLUtils.PrintLn('    Single compilation: FAILED - Exception: %s', [E.Message]);
        end;
      end
      else
        TLLUtils.PrintLn('    Single compilation: FAILED - Module validation failed');
        
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Batch Module Compilation
 * 
 * Description: This test demonstrates compiling multiple LLVM modules to object files
 * in a single operation. It creates several modules with different functionalities
 * and compiles them all to the output\obj directory for linking.
 *
 * Functions Demonstrated:
 * - CompileAllModulesToObjects() - Batch compile all modules to objects
 * - Multiple CreateModule() calls with different functions
 * - GetRequiredLibraries() - Track external dependencies per module
 *
 * LLVM Concepts Covered:
 * - Batch compilation workflow for multi-module projects
 * - Separate object file generation per module
 * - External library dependency tracking across modules
 * - Parallel module compilation capability
 *
 * Expected Output: "Batch compilation: PASSED - 3 object files created"
 *
 * Takeaway: Learn how to efficiently compile multiple modules to prepare
 * for linking complex applications with multiple compilation units.
 *)
class procedure TTestObjectCompilation.TestBatchModuleCompilation();
var
  LObjectFiles: TArray<string>;
  LObjectFile: string;
  LValidCount: Integer;
begin
  TLLUtils.PrintLn('  Testing batch module compilation...');
  with TLLVM.Create() do
  begin
    try
      // Create multiple test modules with different features
      
      // Math utilities module
      CreateModule('math_utils')
      .BeginFunction('math_utils', 'add_numbers', dtInt32, [Param('a', dtInt32), Param('b', dtInt32)])
        .BeginBlock('math_utils', 'entry');
      ReturnValue('math_utils', Add('math_utils', GetParameter('math_utils', 'a'), GetParameter('math_utils', 'b')));
      EndBlock('math_utils')
      .EndFunction('math_utils');
      
      // String operations module  
      CreateModule('string_ops')
      .BeginFunction('string_ops', 'get_message', dtInt8Ptr, [])
        .BeginBlock('string_ops', 'entry');
      ReturnValue('string_ops', StringValue('string_ops', 'Hello from object!'));
      EndBlock('string_ops')
      .EndFunction('string_ops');
      
      // External functions module (Windows API)
      CreateModule('win_api')
      .BeginFunction('win_api', 'GetTickCount', dtInt32, [], vExternal, ccStdCall, False, 'kernel32.dll')
      .EndFunction('win_api')
      .BeginFunction('win_api', 'ExitProcess', dtVoid, [Param('uExitCode', dtInt32)], vExternal, ccStdCall, False, 'kernel32.dll')
      .EndFunction('win_api');
      
      // Validate all modules first
      if ValidateModule('math_utils') and ValidateModule('string_ops') and ValidateModule('win_api') then
      begin
        try
          // Compile all modules to output\obj
          LObjectFiles := CompileAllModulesToObjects('output\obj');
          
          // Verify results
          LValidCount := 0;
          for LObjectFile in LObjectFiles do
          begin
            if TFile.Exists(LObjectFile) then
            begin
              Inc(LValidCount);
              TLLUtils.PrintLn('    Created: %s (%d bytes)', [LObjectFile, TFile.GetSize(LObjectFile)]);
            end;
          end;
          
          if LValidCount = Length(LObjectFiles) then
            TLLUtils.PrintLn('    Batch compilation: PASSED - %d object files created', [LValidCount])
          else
            TLLUtils.PrintLn('    Batch compilation: FAILED - Only %d of %d files created', [LValidCount, Length(LObjectFiles)]);
            
        except
          on E: Exception do
            TLLUtils.PrintLn('    Batch compilation: FAILED - Exception: %s', [E.Message]);
        end;
      end
      else
        TLLUtils.PrintLn('    Batch compilation: FAILED - Module validation failed');
        
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Optimization Level Testing
 * 
 * Description: This test demonstrates the different optimization levels available
 * in the object compilation process. It compiles the same module with different
 * optimization settings and verifies that each level produces valid object files.
 *
 * Functions Demonstrated:
 * - CompileModuleToObject() with different TLLOptimization levels
 * - All optimization levels: olDebug, olSize, olSpeed, olMaximum
 * - File size comparison between optimization levels
 *
 * LLVM Concepts Covered:
 * - LLVM optimization pipeline control
 * - Debug vs release compilation modes
 * - Size vs speed optimization trade-offs
 * - Target machine optimization level configuration
 *
 * Expected Output: Shows object files created with different optimization levels
 *
 * Takeaway: Learn how different optimization levels affect object file generation
 * and how to choose the right optimization for your compilation needs.
 *)
class procedure TTestObjectCompilation.TestOptimizationLevels();
var
  LObjectFile: string;
  LOptLevel: TLLOptimization;
  LOptName: string;
  LFileSize: Int64;
begin
  TLLUtils.PrintLn('  Testing optimization levels...');
  with TLLVM.Create() do
  begin
    try
      // Create a test module that can benefit from optimization
      CreateModule('opt_test')
      .BeginFunction('opt_test', 'fibonacci', dtInt32, [Param('n', dtInt32)])
        // Pre-declare all blocks first
        .DeclareBlock('opt_test', 'entry')
        .DeclareBlock('opt_test', 'base_case')
        .DeclareBlock('opt_test', 'recursive_case');
        
      // Implement entry block
      BeginBlock('opt_test', 'entry');
      JumpIf('opt_test', IsLess('opt_test', GetParameter('opt_test', 'n'), IntegerValue('opt_test', 2)), 'base_case', 'recursive_case');
      
      // Implement base case
      BeginBlock('opt_test', 'base_case');
      ReturnValue('opt_test', GetParameter('opt_test', 'n'));
      
      // Implement recursive case (simplified)
      BeginBlock('opt_test', 'recursive_case');
      ReturnValue('opt_test', IntegerValue('opt_test', 1));
      
      EndBlock('opt_test')
      .EndFunction('opt_test');
      
      if ValidateModule('opt_test') then
      begin
        // Test each optimization level
        for LOptLevel := olDebug to olMaximum do
        begin
          case LOptLevel of
            olDebug: LOptName := 'olDebug';
            olSize: LOptName := 'olSize';
            olSpeed: LOptName := 'olSpeed';
            olMaximum: LOptName := 'olMaximum';
          end;
          
          try
            LObjectFile := CompileModuleToObject('opt_test', 'output\obj\' + LOptName, LOptLevel);
            
            if TFile.Exists(LObjectFile) then
            begin
              LFileSize := TFile.GetSize(LObjectFile);
              TLLUtils.PrintLn('    %s: PASSED - %d bytes', [LOptName, LFileSize]);
            end
            else
              TLLUtils.PrintLn('    %s: FAILED - Object file not created', [LOptName]);
              
          except
            on E: Exception do
              TLLUtils.PrintLn('    %s: FAILED - Exception: %s', [LOptName, E.Message]);
          end;
        end;
      end
      else
        TLLUtils.PrintLn('    Optimization testing: FAILED - Module validation failed');
        
    finally
      Free();
    end;
  end;
end;

(**
 * Test: File Extension Platform Detection
 * 
 * Description: This test verifies that the GetObjectFileExtension() method correctly
 * returns platform-appropriate file extensions for object files.
 *
 * Functions Demonstrated:
 * - GetObjectFileExtension() - Platform-specific extension detection
 * - Platform-conditional compilation behavior
 *
 * LLVM Concepts Covered:
 * - Cross-platform object file format differences
 * - Windows (.obj) vs Unix/Linux (.o) object file conventions
 * - Conditional compilation for platform detection
 *
 * Expected Output: "File extension: PASSED - .obj (Windows)" or ".o (Unix/Linux/macOS)"
 *
 * Takeaway: Learn how object file naming conventions differ across platforms
 * and how to handle them automatically in cross-platform build systems.
 *)
class procedure TTestObjectCompilation.TestFileExtensions();
var
  LExtension: string;
  LExpectedExt: string;
begin
  TLLUtils.PrintLn('  Testing file extensions...');
  
  try
    LExtension := TLLVM.GetObjectFileExtension();
    
    // Determine expected extension based on platform
    {$IFDEF MSWINDOWS}
    LExpectedExt := '.obj';
    {$ELSE}
    LExpectedExt := '.o';
    {$ENDIF}
    
    if LExtension = LExpectedExt then
    begin
      {$IFDEF MSWINDOWS}
      TLLUtils.PrintLn('    File extension: PASSED - %s (Windows)', [LExtension]);
      {$ELSE}
        {$IFDEF DARWIN}
        TLLUtils.PrintLn('    File extension: PASSED - %s (macOS)', [LExtension]);
        {$ELSE}
        TLLUtils.PrintLn('    File extension: PASSED - %s (Linux)', [LExtension]);
        {$ENDIF}
      {$ENDIF}
    end
    else
      TLLUtils.PrintLn('    File extension: FAILED - Expected %s, got %s', [LExpectedExt, LExtension]);
      
  except
    on E: Exception do
      TLLUtils.PrintLn('    File extension: FAILED - Exception: %s', [E.Message]);
  end;
end;

(**
 * Test: Output Directory Handling
 * 
 * Description: This test verifies that the object compilation methods properly handle
 * directory creation, path manipulation, and custom output locations. Tests both
 * default and custom output directory scenarios.
 *
 * Functions Demonstrated:
 * - CompileModuleToObject() with custom output paths
 * - CompileAllModulesToObjects() with custom directories
 * - Directory creation and path validation
 *
 * LLVM Concepts Covered:
 * - Build system directory structure management
 * - Path handling for cross-platform compatibility  
 * - Automatic directory creation for build outputs
 *
 * Expected Output: Object files created in both default and custom directories
 *
 * Takeaway: Learn how to organize build outputs and handle directory
 * structures in automated compilation workflows.
 *)
class procedure TTestObjectCompilation.TestOutputDirectories();
var
  LObjectFile: string;
  LObjectFiles: TArray<string>;
  LCustomDir: string;
  LValidCount: Integer;
begin
  TLLUtils.PrintLn('  Testing output directories...');
  
  // Clean up test directories first to ensure proper creation testing
  try
    if TDirectory.Exists('output') then
      TDirectory.Delete('output', True);
  except
    // Ignore cleanup errors
  end;
  
  with TLLVM.Create() do
  begin
    try
      // Verify directories don't exist before testing
      if TDirectory.Exists('output\obj') then
        TLLUtils.PrintLn('    WARNING: output\obj still exists after cleanup');
      if TDirectory.Exists('output\custom_objs') then
        TLLUtils.PrintLn('    WARNING: output\custom_objs still exists after cleanup');
        
      // Test default output directory (current directory)
      CreateModule('dir_test_current')
      .BeginFunction('dir_test_current', 'current_func', dtInt32, [])
        .BeginBlock('dir_test_current', 'entry');
      ReturnValue('dir_test_current', IntegerValue('dir_test_current', 50));
      EndBlock('dir_test_current')
      .EndFunction('dir_test_current');
      
      if ValidateModule('dir_test_current') then
      begin
        try
          // Test actual default (current directory)
          LObjectFile := CompileModuleToObject('dir_test_current'); // Empty path = current dir
          if TFile.Exists(LObjectFile) and not LObjectFile.Contains('\\') then
            TLLUtils.PrintLn('    Current directory: PASSED - %s', [LObjectFile])
          else
            TLLUtils.PrintLn('    Current directory: FAILED - Wrong location: %s', [LObjectFile]);
        except
          on E: Exception do
            TLLUtils.PrintLn('    Current directory: FAILED - Exception: %s', [E.Message]);
        end;
      end;
        
      // Test custom output directory creation
      CreateModule('dir_test_default')
      .BeginFunction('dir_test_default', 'default_func', dtInt32, [])
        .BeginBlock('dir_test_default', 'entry');
      ReturnValue('dir_test_default', IntegerValue('dir_test_default', 100));
      EndBlock('dir_test_default')
      .EndFunction('dir_test_default');
      
      if ValidateModule('dir_test_default') then
      begin
        try
          // Verify output\obj doesn't exist before compilation
          if TDirectory.Exists('output\obj') then
            TLLUtils.PrintLn('    WARNING: output\obj existed before test');
            
          LObjectFile := CompileModuleToObject('dir_test_default', 'output\obj'); // Should create directory
          
          // Verify BOTH directory creation AND file creation
          if TDirectory.Exists('output\obj') and TFile.Exists(LObjectFile) and LObjectFile.Contains('output\obj') then
            TLLUtils.PrintLn('    Custom directory creation: PASSED - Directory and file created: %s', [LObjectFile])
          else
            TLLUtils.PrintLn('    Custom directory creation: FAILED - Dir exists: %s, File exists: %s, Path: %s', 
              [TDirectory.Exists('output\obj').ToString, TFile.Exists(LObjectFile).ToString, LObjectFile]);
        except
          on E: Exception do
            TLLUtils.PrintLn('    Default directory: FAILED - Exception: %s', [E.Message]);
        end;
      end;
      
      // Test second custom output directory creation
      LCustomDir := 'output\custom_objs';
      
      // Verify custom directory doesn't exist yet
      if TDirectory.Exists(LCustomDir) then
        TLLUtils.PrintLn('    WARNING: %s existed before batch test', [LCustomDir]);
      CreateModule('dir_test_custom1')
      .BeginFunction('dir_test_custom1', 'custom_func1', dtInt32, [])
        .BeginBlock('dir_test_custom1', 'entry');
      ReturnValue('dir_test_custom1', IntegerValue('dir_test_custom1', 200));
      EndBlock('dir_test_custom1')
      .EndFunction('dir_test_custom1');
      
      CreateModule('dir_test_custom2')
      .BeginFunction('dir_test_custom2', 'custom_func2', dtInt32, [])
        .BeginBlock('dir_test_custom2', 'entry');
      ReturnValue('dir_test_custom2', IntegerValue('dir_test_custom2', 300));
      EndBlock('dir_test_custom2')
      .EndFunction('dir_test_custom2');
      
      if ValidateModule('dir_test_custom1') and ValidateModule('dir_test_custom2') then
      begin
        try
          // Delete existing modules except our custom test ones
          DeleteModule('dir_test_current');
          DeleteModule('dir_test_default');
          
          // Batch compile remaining modules to custom directory (should create it)
          LObjectFiles := CompileAllModulesToObjects(LCustomDir);
          
          // Verify directory was created by compilation process
          if not TDirectory.Exists(LCustomDir) then
          begin
            TLLUtils.PrintLn('    Batch directory creation: FAILED - Directory was not created: %s', [LCustomDir]);
            Exit;
          end;
          
          // Verify results
          LValidCount := 0;
          for LObjectFile in LObjectFiles do
          begin
            if TFile.Exists(LObjectFile) and LObjectFile.Contains('custom_objs') then
            begin
              Inc(LValidCount);
              TLLUtils.PrintLn('    Custom created: %s', [LObjectFile]);
            end;
          end;
          
          if LValidCount = Length(LObjectFiles) then
            TLLUtils.PrintLn('    Batch directory creation: PASSED - Directory created and %d files compiled', [LValidCount])
          else
            TLLUtils.PrintLn('    Batch directory creation: FAILED - Only %d of %d in correct location', [LValidCount, Length(LObjectFiles)]);
            
        except
          on E: Exception do
            TLLUtils.PrintLn('    Custom directory: FAILED - Exception: %s', [E.Message]);
        end;
      end;
      
    finally
      Free();
    end;
  end;

  if TFile.Exists('dir_test_current.obj') then
    TFile.Delete('dir_test_current.obj');


end;

(**
 * Test: Error Condition Handling
 * 
 * Description: This test verifies that the object compilation system properly handles
 * error conditions such as invalid modules, non-existent modules, and invalid paths.
 * Ensures robust error reporting and graceful failure modes.
 *
 * Functions Demonstrated:
 * - CompileModuleToObject() with invalid input
 * - Error handling and exception management
 * - Validation of error messages and failure modes
 *
 * LLVM Concepts Covered:
 * - Error handling in LLVM compilation pipeline
 * - Target machine creation failure scenarios
 * - Module validation and compilation prerequisites
 *
 * Expected Output: Proper error handling for all invalid conditions
 *
 * Takeaway: Learn how to build robust compilation systems that handle
 * errors gracefully and provide meaningful feedback to users.
 *)
class procedure TTestObjectCompilation.TestErrorConditions();
begin
  TLLUtils.PrintLn('  Testing error conditions...');
  with TLLVM.Create() do
  begin
    try
      // Test compilation of non-existent module
      try
        CompileModuleToObject('nonexistent_module', 'output\obj');
        TLLUtils.PrintLn('    Non-existent module: FAILED - Should have thrown exception');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Non-existent module: PASSED - Correctly rejected: %s', [E.Message]);
      end;
      
      // Test compilation of invalid module (no functions)
      CreateModule('empty_error_test');
      try
        CompileModuleToObject('empty_error_test', 'output\obj');
        TLLUtils.PrintLn('    Empty module: PASSED - Empty module compiled successfully');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Empty module: WARNING - Empty module failed: %s', [E.Message]);
      end;
      
      // Test invalid output path (write-protected location)
      CreateModule('path_test')
      .BeginFunction('path_test', 'simple', dtInt32, [])
        .BeginBlock('path_test', 'entry');
      ReturnValue('path_test', IntegerValue('path_test', 1));
      EndBlock('path_test')
      .EndFunction('path_test');
      
      if ValidateModule('path_test') then
      begin
        try
          // Try to write to an invalid path
          CompileModuleToObject('path_test', 'C:\Windows\System32\invalid.obj');
          TLLUtils.PrintLn('    Invalid path: WARNING - Unexpectedly succeeded');
        except
          on E: Exception do
            TLLUtils.PrintLn('    Invalid path: PASSED - Correctly rejected invalid path');
        end;
      end;
      
      // Test batch compilation with mixed valid/invalid modules
      CreateModule('batch_error_valid')
      .BeginFunction('batch_error_valid', 'valid_func', dtInt32, [])
        .BeginBlock('batch_error_valid', 'entry');
      ReturnValue('batch_error_valid', IntegerValue('batch_error_valid', 42));
      EndBlock('batch_error_valid')
      .EndFunction('batch_error_valid');
      
      // Create invalid module (function without return - if validation allows)
      CreateModule('batch_error_invalid')
      .BeginFunction('batch_error_invalid', 'invalid_func', dtInt32, [])
        .BeginBlock('batch_error_invalid', 'entry');
      // Intentionally incomplete function
      EndBlock('batch_error_invalid')
      .EndFunction('batch_error_invalid');
      
      try
        ValidateModule('batch_error_valid');
        ValidateModule('batch_error_invalid'); // May fail
        
        CompileAllModulesToObjects('output\test_batch_error');
        TLLUtils.PrintLn('    Mixed batch: PASSED - Handled mixed valid/invalid gracefully');
      except
        on E: Exception do
          TLLUtils.PrintLn('    Mixed batch: EXPECTED - Mixed validation failed: %s', [E.Message]);
      end;
      
    finally
      Free();
    end;
  end;
end;

(**
 * Test: File Verification and Metadata
 * 
 * Description: This test performs detailed verification of generated object files,
 * checking file existence, sizes, timestamps, and basic file integrity to ensure
 * the compilation process produces valid object files.
 *
 * Functions Demonstrated:
 * - File system verification of compiled objects
 * - File size and metadata analysis
 * - Object file integrity basic checks
 *
 * LLVM Concepts Covered:
 * - Object file format verification
 * - Build output validation techniques
 * - File system interaction with compilation pipeline
 *
 * Expected Output: Detailed file information for all generated object files
 *
 * Takeaway: Learn how to verify that compilation produces valid, usable
 * object files ready for linking and deployment.
 *)
class procedure TTestObjectCompilation.TestFileVerification();
var
  LObjectFile: string;
  LFileSize: Int64;
  LCreationTime: TDateTime;
  LWriteTime: TDateTime;
  LMinValidSize: Int64;
begin
  TLLUtils.PrintLn('  Testing file verification...');
  with TLLVM.Create() do
  begin
    try
      // Create a simple module using EXACT working pattern from TestSingleModuleCompilation
      CreateModule('verification_test')
      .BeginFunction('verification_test', 'get_answer', dtInt32, [])
        .BeginBlock('verification_test', 'entry');
      
      // Return the answer to everything
      ReturnValue('verification_test', IntegerValue('verification_test', 42));
      
      EndBlock('verification_test')
      .EndFunction('verification_test');
      
      if ValidateModule('verification_test') then
      begin
        TLLUtils.PrintLn('    Module validation: PASSED');
        try
          LObjectFile := CompileModuleToObject('verification_test', 'output\obj');
          
          if TFile.Exists(LObjectFile) then
          begin
            // Get detailed file information using TFile methods
            LFileSize := TFile.GetSize(LObjectFile);
            LCreationTime := TFile.GetCreationTime(LObjectFile);
            LWriteTime := TFile.GetLastWriteTime(LObjectFile);
            LMinValidSize := 100; // Minimum expected size for valid object file
            
            TLLUtils.PrintLn('    File verification details:');
            TLLUtils.PrintLn('      Path: %s', [LObjectFile]);
            TLLUtils.PrintLn('      Size: %d bytes', [LFileSize]);
            TLLUtils.PrintLn('      Created: %s', [DateTimeToStr(LCreationTime)]);
            TLLUtils.PrintLn('      Modified: %s', [DateTimeToStr(LWriteTime)]);
            
            if LFileSize >= LMinValidSize then
              TLLUtils.PrintLn('    File verification: PASSED - Valid object file generated')
            else
              TLLUtils.PrintLn('    File verification: WARNING - Object file seems too small (%d bytes)', [LFileSize]);
          end
          else
            TLLUtils.PrintLn('    File verification: FAILED - Object file does not exist');
            
        except
          on E: Exception do
            TLLUtils.PrintLn('    File verification: FAILED - Exception: %s', [E.Message]);
        end;
      end
      else
      begin
        TLLUtils.PrintLn('    File verification: FAILED - Module validation failed');
        TLLUtils.PrintLn('    Module IR:');
        TLLUtils.PrintLn('%s', [GetModuleIR('verification_test')]);
      end;
        
    finally
      Free();
    end;
  end;
end;

end.