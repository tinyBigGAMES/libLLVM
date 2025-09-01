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

unit libLLVM.Test.CodeGen;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.AnsiStrings,
  System.Classes,
  libLLVM.API,
  libLLVM.LLD,
  libLLVM.Utils,
  libLLVM;

type
  { TTestCodeGen }
  TTestCodeGen = class
  public
    class procedure RunAllTests(); static;

    // Test methods for code generation
    class procedure TestBuildAndLink(); static;
  end;

implementation

{ TTestCodeGen }
class procedure TTestCodeGen.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.CodeGen...');

  TestBuildAndLink();

  TLLUtils.PrintLn('libLLVM.Test.CodeGen completed.');
end;

class procedure TTestCodeGen.TestBuildAndLink();
var


  // File paths
  LLLFile: string;
  LObjFile: string;
  LExeFile: string;

  // LLVM objects
  LCtx: LLVMContextRef;
  LBuf: LLVMMemoryBufferRef;
  LMod: LLVMModuleRef;
  LTarget: LLVMTargetRef;
  LTM: LLVMTargetMachineRef;
  LTD: LLVMTargetDataRef;

  // Strings and pointers
  LIR: string;
  LTripleStr: string;
  LCPU: string;
  LFeatures: string;

  // C pointers for LLVM (need disposal)
  LMsg: PAnsiChar;
  LErr: PAnsiChar;
  LEmitErr: PAnsiChar;
  LTripleHeap: PAnsiChar;
  LDLStrHeap: PAnsiChar;

  // Linking
  LArgs: TArray<string>;
  LRC: Integer;
  LCan: Boolean;
  LStdOut: string;
  LStdErr: string;

  // String conversion helpers
  LStrLen: Cardinal;
  LStr: Pointer;
begin
  // === File Setup ===
  LLLFile  := '.\output\HelloWorld.ll';
  LObjFile := '.\output\HelloWorld.obj';
  LExeFile := '.\output\HelloWorld.exe';

  // === IR Code ===
  LIR :=
    '; ModuleID = "hello"'#10 +
    'declare i32 @printf(ptr, ...)'#10 +
    '@.str = private unnamed_addr constant [13 x i8] c"hello world\0A\00"'#10 +
    'define i32 @main() {'#10 +
    '  %call = call i32 (ptr, ...) @printf(ptr @.str)'#10 +
    '  ret i32 0'#10 +
    '}'#10;

  TDirectory.CreateDirectory(TPath.GetDirectoryName(LLLFile));
  TFile.WriteAllText(LLLFile, LIR, TEncoding.UTF8);

  // === LLVM Initialization ===

  // === Context and Module Creation ===
  LCtx := LLVMContextCreate();
  LMod := nil;
  LTM := nil;

  try
    // Parse IR from memory buffer
    LStr := TLLUtils.AsUTF8(LIR, @LStrLen);
    LBuf := LLVMCreateMemoryBufferWithMemoryRangeCopy(LStr, LStrLen, TLLUtils.AsUTF8('hello.ll'));

    LMsg := nil;
    TLLUtils.FailIf(LLVMParseIRInContext(LCtx, LBuf, @LMod, @LMsg) <> 0,
           'Parse IR failed: %s', [string(LMsg)]);

    // === Target Setup ===
    LTripleHeap := LLVMGetDefaultTargetTriple();
    try
      // Force Windows MSVC target for COFF compatibility
      LTripleStr := 'x86_64-pc-windows-msvc';
      LCPU := 'x86-64';
      LFeatures := '';

      LErr := nil;
      TLLUtils.FailIf(LLVMGetTargetFromTriple(TLLUtils.AsUTF8(LTripleStr), @LTarget, @LErr) <> 0,
             'GetTarget failed: %s', [string(LErr)]);

      LTM := LLVMCreateTargetMachine(LTarget, TLLUtils.AsUTF8(LTripleStr), TLLUtils.AsUTF8(LCPU),
                                     TLLUtils.AsUTF8(LFeatures), LLVMCodeGenLevelDefault,
                                     LLVMRelocDefault, LLVMCodeModelDefault);
    finally
      if LTripleHeap <> nil then
        LLVMDisposeMessage(LTripleHeap);
    end;

    // === Module Configuration ===
    LLVMSetTarget(LMod, TLLUtils.AsUTF8(LTripleStr));
    LTD := LLVMCreateTargetDataLayout(LTM);
    LDLStrHeap := LLVMCopyStringRepOfTargetData(LTD);
    try
      LLVMSetDataLayout(LMod, LDLStrHeap);
    finally
      if LDLStrHeap <> nil then
        LLVMDisposeMessage(LDLStrHeap);
      LLVMDisposeTargetData(LTD);
    end;

    // === Object File Generation ===
    LEmitErr := nil;
    TLLUtils.FailIf(LLVMTargetMachineEmitToFile(LTM, LMod, TLLUtils.AsUTF8(LObjFile), LLVMObjectFile, @LEmitErr) <> 0,
           'EmitToFile failed: %s', [string(LEmitErr)]);

  finally
    // Clean up in reverse order of creation
    if LTM <> nil then
      LLVMDisposeTargetMachine(LTM);
    if LMod <> nil then
      LLVMDisposeModule(LMod);
    if LCtx <> nil then
      LLVMContextDispose(LCtx);
  end;

  // === Linking Phase ===
  LArgs := [
    'lld-link',
    '/verbose',
    '/nologo',
    '/subsystem:console',
    '/entry:main',
    '/out:' + LExeFile,
    LObjFile,
    '/libpath:.\libs',
    'kernel32.lib',
    'msvcrt.lib',
    'legacy_stdio_definitions.lib'
  ];

  LRC := LLDLink(LArgs, 'coff', LStdOut, LStdErr, LCan);

  if not LStdOut.IsEmpty then
    TLLUtils.PrintLn(LStdOut);

  if not LStdErr.IsEmpty then
    TLLUtils.PrintLn(LStdErr);

  // === Results ===
  TLLUtils.PrintLn('LLD rc=%d canRunAgain=%s', [LRC, BoolToStr(LCan, True)]);
  TLLUtils.PrintLn('LL file:  %s', [LLLFile]);
  TLLUtils.PrintLn('OBJ file: %s', [LObjFile]);
  TLLUtils.PrintLn('EXE file: %s', [LExeFile]);
  TLLUtils.PrintLn();
end;

end.
