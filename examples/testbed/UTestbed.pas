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

unit UTestbed;

interface

procedure RunTests();

implementation

uses
  WinApi.Windows,
  System.SysUtils,
  System.AnsiStrings,
  System.IOUtils,
  libLLVM;

procedure BuildAndLink();
var
  // Version info
  LMajor: Cardinal;
  LMinor: Cardinal;
  LPatch: Cardinal;

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

  // String conversion helpers
  LStrLen: Cardinal;
  LStr: Pointer;
  FMarshaller: TMarshaller;

  function AsUTF8(const AValue: string; ALength: PCardinal=nil): Pointer;
  begin
    Result := FMarshaller.AsUtf8(AValue).ToPointer;
    if Assigned(ALength) then
      ALength^ := System.AnsiStrings.StrLen(PAnsiChar(Result));
  end;

  procedure FailIf(const Cond: Boolean; const Msg: string; const AArgs: array of const);
  begin
    if Cond then
      raise Exception.CreateFmt(Msg, AArgs);
  end;

begin
  // === LLVM Version ===
  LMajor := 0;
  LMinor := 0;
  LPatch := 0;
  LLVMGetVersion(@LMajor, @LMinor, @LPatch);

  WriteLn(Format('=== libLLVM v%s ===', [libLLVM_VERSION]));
  WriteLn(Format('Running LLVM v%d.%d.%d', [LMajor, LMinor, LPatch]));

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
  LLVMInitializeX86TargetInfo();
  LLVMInitializeX86Target();
  LLVMInitializeX86TargetMC();
  LLVMInitializeX86AsmPrinter();

  // === Context and Module Creation ===
  LCtx := LLVMContextCreate();
  LMod := nil;
  LTM := nil;

  try
    // Parse IR from memory buffer
    LStr := AsUTF8(LIR, @LStrLen);
    LBuf := LLVMCreateMemoryBufferWithMemoryRangeCopy(LStr, LStrLen, AsUTF8('hello.ll'));

    LMsg := nil;
    FailIf(LLVMParseIRInContext(LCtx, LBuf, @LMod, @LMsg) <> 0,
           'Parse IR failed: %s', [string(LMsg)]);

    // === Target Setup ===
    LTripleHeap := LLVMGetDefaultTargetTriple();
    try
      // Force Windows MSVC target for COFF compatibility
      LTripleStr := 'x86_64-pc-windows-msvc';
      LCPU := 'x86-64';
      LFeatures := '';

      LErr := nil;
      FailIf(LLVMGetTargetFromTriple(AsUTF8(LTripleStr), @LTarget, @LErr) <> 0,
             'GetTarget failed: %s', [string(LErr)]);

      LTM := LLVMCreateTargetMachine(LTarget, AsUTF8(LTripleStr), AsUTF8(LCPU),
                                     AsUTF8(LFeatures), LLVMCodeGenLevelDefault,
                                     LLVMRelocDefault, LLVMCodeModelDefault);
    finally
      if LTripleHeap <> nil then
        LLVMDisposeMessage(LTripleHeap);
    end;

    // === Module Configuration ===
    LLVMSetTarget(LMod, AsUTF8(LTripleStr));
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
    FailIf(LLVMTargetMachineEmitToFile(LTM, LMod, AsUTF8(LObjFile), LLVMObjectFile, @LEmitErr) <> 0,
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

  LRC := LLDLink(LArgs, 'coff', LCan);

  // === Results ===
  Writeln(Format('LLD rc=%d canRunAgain=%s', [LRC, BoolToStr(LCan, True)]));
  Writeln('LL file:  ' + LLLFile);
  Writeln('OBJ file: ' + LObjFile);
  Writeln('EXE file: ' + LExeFile);
end;


procedure RunTests();
begin
  try
    BuildAndLink();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  WriteLn;
  Write('Press ENTER to continue...');
  ReadLn;
  WriteLn;
end;

end.
