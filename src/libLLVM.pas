{===============================================================================
      _ _ _    _    _ __   ____  __ ™
     | (_) |__| |  | |\ \ / /  \/  |
     | | | '_ \ |__| |_\ V /| |\/| |
     |_|_|_.__/____|____\_/ |_|  |_|
  LLVM Compiler Infrastructure for Delphi

 Copyright © 2025-present tinyBigGAMES™ LLC
 All Rights Reserved.

 https://github.com/tinyBigGAMES/libLLVM

 BSD 3-Clause License

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 3. Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 ------------------------------------------------------------------------------

 This library uses the following open-source libraries:
   * Dlluminator - https://github.com/tinyBigGAMES/Dlluminator
   * LLVM        - https://github.com/llvm/llvm-project

===============================================================================}

unit libLLVM;

{$I libLLVM.Defines.inc}

interface

uses
  System.Types,
  System.SysUtils,
  System.AnsiStrings,
  System.TypInfo,
  System.Classes,
  System.Rtti,
  System.Math,
  System.Generics.Collections,
  libLLVM.API,
  libLLVM.Utils;

type
  { TLLValue }
  TLLValue = TValue;

  { TLLDataType }
  TLLDataType = (
    // Void
    dtVoid,

    // Integer types
    dtInt1,         // i1 (boolean)
    dtInt8,         // i8
    dtInt16,        // i16
    dtInt32,        // i32
    dtInt64,        // i64
    dtInt128,       // i128

    // Floating point types
    dtFloat16,      // half
    dtFloat32,      // float
    dtFloat64,      // double
    dtFloat80,      // x86_fp80 (extended precision)
    dtFloat128,     // fp128 (quad precision)

    // Pointer types (commonly used ones)
    dtPointer,      // Generic pointer
    dtInt8Ptr,      // i8* (char*)
    dtInt32Ptr,     // i32*
    dtVoidPtr,      // void*

    // Other basic types
    dtLabel,        // label (for basic blocks)
    dtMetadata      // metadata
  );

  { TLLVisibility }
  TLLVisibility = (
    vPrivate,       // Internal to module only
    vPublic,        // Exported from module
    vExternal       // External declaration (no body)
  );

  { TLLCallingConv }
  TLLCallingConv = (
    ccCDecl,        // LLVMCCallConv
    ccStdCall,      // LLVMX86StdcallCallConv
    ccFastCall      // LLVMX86FastcallCallConv
  );

  { TLLParam }
  TLLParam = record
    ParamName: string;
    ParamType: TLLDataType;
  end;

  { TLLVariable }
  TLLVariable = record
    Name: string;
    VarType: TLLDataType;
    AllocaInst: LLVMValueRef;
    IsGlobal: Boolean;
  end;

  { TLLBasicBlock }
  TLLBasicBlock = record
    Name: string;
    Block: LLVMBasicBlockRef;
  end;

  { TLLModuleState }
  TLLModuleState = record
    Context: LLVMContextRef;        // Original IR building context
    Module: LLVMModuleRef;
    Builder: LLVMBuilderRef;
    CurrentFunction: LLVMValueRef;
    CurrentBlock: LLVMBasicBlockRef;
    Variables: TDictionary<string, TLLVariable>;
    BasicBlocks: TDictionary<string, TLLBasicBlock>;
    FunctionParams: TDictionary<string, TLLVariable>;
    
    // JIT capabilities
    JITContext: LLVMContextRef;     // Separate JIT context (like TPaJIT)
    ThreadSafeContext: LLVMOrcThreadSafeContextRef;
    LLJIT: LLVMOrcLLJITRef;
    IsJITInitialized: Boolean;
    LastError: string;
  end;

  { TLLVM }
  TLLVM = class
  private class var
    FTargetTriple: string;
    FDataLayout: string;
  private
    FModules: TDictionary<string, TLLModuleState>;
    FModuleLibraries: TDictionary<string, TDictionary<string, Boolean>>;
    function GetModule(const AModuleId: string): LLVMModuleRef;
    function GetModuleState(const AModuleId: string): TLLModuleState;
    function GetBasicType(const ABasicType: TLLDataType; const AContext: LLVMContextRef): LLVMTypeRef;
    function GetLLVMCallingConv(const ACallingConv: TLLCallingConv): LLVMCallConv;
    function GetLLVMLinkage(const AVisibility: TLLVisibility): LLVMLinkage;
    {$HINTS OFF}
    function LLVMTypeToBasicType(ALLVMType: LLVMTypeRef): TLLDataType;
    {$HINTS ON}
    function ExtractLLVMValue(const AModuleId: string; const AValue: TValue): LLVMValueRef;
    function CreateTValue(const ALLVMValue: LLVMValueRef): TValue;
    procedure AddLibraryToModule(const AModuleId: string; const ALibraryName: string);
    procedure SetModuleState(const AModuleId: string; const AState: TLLModuleState);
    function FindBasicBlock(const AModuleState: TLLModuleState; const ABlockName: string): LLVMBasicBlockRef;

    // JIT helper methods
    procedure EnsureJITReady(const AModuleId: string);
    function InitializeJITForModule(var AModuleState: TLLModuleState): Boolean;
    function AddModuleToJITInternal(var AModuleState: TLLModuleState): Boolean;
    procedure RegisterExternalLibrariesWithJIT(const AModuleId: string);
    function LookupSymbolFast(const AModuleState: TLLModuleState; const ASymbol: AnsiString): Pointer;
    function CreateLLJITForModule(var AModuleState: TLLModuleState): Boolean;

    class procedure Initialize(); static;
    class procedure Finalize; static;

  public
    constructor Create();
    destructor Destroy(); override;

    class function GetVersionStr(): string; static;
    class function GetLLVMVersionStr(): string; static;

    // Global configuration (applies to all modules)
    function SetTargetPlatform(const ATriple: string; const ADataLayout: string): TLLVM;

    // Module lifecycle
    function CreateModule(const AModuleId: string; const AShareContextWith: string = ''): TLLVM;
    function DeleteModule(const AModuleId: string): TLLVM;
    function ModuleExists(const AModuleId: string): Boolean;
    function MergeModules(const ATargetId: string; const ASourceIds: array of string): TLLVM;
    function GetModuleIR(const AModuleId: string): string;
    function ValidateModule(const AModuleId: string): Boolean;
    function GetRequiredLibraries(const AModuleId: string): TArray<string>;
    
    // Function declaration
    function BeginFunction(const AModuleId: string; const AFunctionName: string; const AReturnType: TLLDataType;
      const AParams: array of TLLParam; const AVisibility: TLLVisibility = vPublic;
      const ACallingConv: TLLCallingConv = ccCDecl; const AIsVarArgs: Boolean = false;
      const AExternalLib: string = ''): TLLVM;
    function Param(const AParamName: string; const AParamType: TLLDataType): TLLParam;
    function EndFunction(const AModuleId: string): TLLVM;
    
    // Basic blocks
    function BeginBlock(const AModuleId: string; const ABlockLabel: string): TLLVM;
    function DeclareBlock(const AModuleId: string; const ABlockLabel: string): TLLVM;
    function EndBlock(const AModuleId: string): TLLVM;
    
    // Variables
    function DeclareGlobal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType;
      const AInitialValue: TValue): TLLVM; overload;
    function DeclareGlobal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType): TLLVM; overload;
    function DeclareLocal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType): TLLVM;
    
    // Value creation (returns TValue - much simpler!)
    function IntegerValue(const AModuleId: string; const AValue: Int64; const ABitWidth: TLLDataType = dtInt32): TValue;
    function FloatValue(const AModuleId: string; const AValue: Double; const AFloatType: TLLDataType = dtFloat64): TValue;
    function StringValue(const AModuleId: string; const AText: string): TValue;
    function BooleanValue(const AModuleId: string; const AValue: Boolean): TValue;
    function NullValue(const AModuleId: string; const ANullType: TLLDataType): TValue;
    
    // Math operations (use TValue - much cleaner!)
    function Add(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function Subtract(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function Multiply(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function Divide(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function Modulo(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    
    // Floating point operations
    function FAdd(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function FSub(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function FMul(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function FDiv(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    
    // Bitwise operations
    function BitwiseAnd(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function BitwiseOr(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function BitwiseXor(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function BitwiseNot(const AModuleId: string; const AValue: TValue; const AValueName: string = ''): TValue;
    function ShiftLeft(const AModuleId: string; const AValue: TValue; const AShift: TValue; const AValueName: string = ''): TValue;
    function ShiftRight(const AModuleId: string; const AValue: TValue; const AShift: TValue; const AValueName: string = ''): TValue;
    
    // Comparisons (use TValue - natural!)
    function IsEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function IsNotEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function IsLess(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function IsLessEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function IsGreater(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function IsGreaterEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    
    // Floating point comparisons
    function FIsEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function FIsNotEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function FIsLess(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function FIsLessEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function FIsGreater(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    function FIsGreaterEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string = ''): TValue;
    
    // Type conversions
    function IntCast(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string = ''): TValue;
    function FloatCast(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string = ''): TValue;
    function IntToFloat(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string = ''): TValue;
    function FloatToInt(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string = ''): TValue;
    
    // Control flow (use TValue - clean!)
    function ReturnValue(const AModuleId: string; const AValue: TValue): TValue; overload;
    function ReturnValue(const AModuleId: string): TValue; overload;  // void return
    function Jump(const AModuleId: string; const ABlockLabel: string): TLLVM;
    function JumpIf(const AModuleId: string; const ACondition: TValue; 
      const ATrueBlock: string; const AFalseBlock: string): TLLVM;
    
    // Function calls (clean TValue API)
    function CallFunction(const AModuleId: string; const AFunctionName: string; const AArgs: array of const; 
      const AValueName: string = ''): TValue; overload;  // Most user-friendly
    function CallFunction(const AModuleId: string; const AFunctionName: string; const AArgs: array of TValue; 
      const AValueName: string = ''): TValue; overload;  // Type control
      
    // Memory operations (use TValue - simple!)
    function SetValue(const AModuleId: string; const AVarName: string; const AValue: TValue): TLLVM;
    function GetValue(const AModuleId: string; const AVarName: string): TValue;
    function GetParameter(const AModuleId: string; const AParamName: string): TValue; overload;
    function GetParameter(const AModuleId: string; const AParamIndex: Integer): TValue; overload;
    
    // Pointer operations
    function AllocateArray(const AModuleId: string; const AElementType: TLLDataType; const ASize: TValue; const AValueName: string = ''): TValue;
    function GetElementPtr(const AModuleId: string; const APtr: TValue; const AIndices: array of TValue; const AValueName: string = ''): TValue;
    function LoadValue(const AModuleId: string; const APtr: TValue; const AValueName: string = ''): TValue;
    function StoreValue(const AModuleId: string; const AValue: TValue; const APtr: TValue): TLLVM;
    
    // PHI nodes for SSA form
    function CreatePhi(const AModuleId: string; const AType: TLLDataType; const AValueName: string = ''): TValue;
    function AddPhiIncoming(const AModuleId: string; const APhi: TValue; const AValue: TValue; const ABlock: string): TLLVM;
    
    // JIT execution methods
    function Execute(const AModuleId: string): Integer;
    function ExecuteFunction(const AModuleId, AFunctionName: string; const AParams: array of const): TValue;
    function AddProcessSymbols(const AModuleId: string): TLLVM;
    function AddExternalDLL(const AModuleId: string; const ADllPath: string): TLLVM;
    function DefineAbsoluteSymbol(const AModuleId: string; const ASymbol: AnsiString; AAddress: Pointer): TLLVM;
    function LookupSymbol(const AModuleId: string; const ASymbol: AnsiString): Pointer;
  end;

implementation

{ TLLVM }
class procedure TLLVM.Initialize();
var
  LContext: LLVMContextRef;
  LModule: LLVMModuleRef;
  LEngine: LLVMExecutionEngineRef;
  LTargetMachine: LLVMTargetMachineRef;
  LTargetTriple: PAnsiChar;
  LTargetData: LLVMTargetDataRef;
  LLayoutStr: PAnsiChar;
  LError: PAnsiChar;
begin
  ReportMemoryLeaksOnShutdown := True;

  {$IF DEFINED(MSWINDOWS) AND DEFINED(CPUX64)}
  // === X86 ===
  LLVMInitializeX86TargetInfo();
  LLVMInitializeX86Target();
  LLVMInitializeX86TargetMC();
  LLVMInitializeX86AsmPrinter();
  LLVMInitializeX86AsmParser();
  LLVMInitializeX86Disassembler();
  {$ENDIF}

  (*
  // === AArch64 ===
  LLVMInitializeAArch64TargetInfo();
  LLVMInitializeAArch64Target();
  LLVMInitializeAArch64TargetMC();
  LLVMInitializeAArch64AsmPrinter();
  LLVMInitializeAArch64AsmParser();
  LLVMInitializeAArch64Disassembler();

  // === ARM ===
  LLVMInitializeARMTargetInfo();
  LLVMInitializeARMTarget();
  LLVMInitializeARMTargetMC();
  LLVMInitializeARMAsmPrinter();
  LLVMInitializeARMAsmParser();
  LLVMInitializeARMDisassembler();

  // === BPF ===
  LLVMInitializeBPFTargetInfo();
  LLVMInitializeBPFTarget();
  LLVMInitializeBPFTargetMC();
  LLVMInitializeBPFAsmPrinter();
  LLVMInitializeBPFAsmParser();
  LLVMInitializeBPFDisassembler();

  // === WebAssembly ===
  LLVMInitializeWebAssemblyTargetInfo();
  LLVMInitializeWebAssemblyTarget();
  LLVMInitializeWebAssemblyTargetMC();
  LLVMInitializeWebAssemblyAsmPrinter();
  LLVMInitializeWebAssemblyAsmParser();
  LLVMInitializeWebAssemblyDisassembler();

  // === RISCV ===
  LLVMInitializeRISCVTargetInfo();
  LLVMInitializeRISCVTarget();
  LLVMInitializeRISCVTargetMC();
  LLVMInitializeRISCVAsmPrinter();
  LLVMInitializeRISCVAsmParser();
  LLVMInitializeRISCVDisassembler();

  // === NVPTX === (no parser/disassembler in wrapper)
  LLVMInitializeNVPTXTargetInfo();
  LLVMInitializeNVPTXTarget();
  LLVMInitializeNVPTXTargetMC();
  LLVMInitializeNVPTXAsmPrinter();
  *)

  LContext := LLVMContextCreate();
  LModule := LLVMModuleCreateWithNameInContext('Dummy', LContext);

  if LLVMCreateExecutionEngineForModule(@LEngine, LModule, @LError) <> 0 then
    raise Exception.CreateFmt('LLVM JIT init failed: %s', [string(AnsiString(LError))]);

  LTargetMachine := LLVMGetExecutionEngineTargetMachine(LEngine);
  if LTargetMachine = nil then
    raise Exception.Create('LLVM target machine is nil');

  LTargetTriple := LLVMGetTargetMachineTriple(LTargetMachine);
  FTargetTriple := string(UTF8String(LTargetTriple));
  LLVMDisposeMessage(LTargetTriple);

  LTargetData := LLVMCreateTargetDataLayout(LTargetMachine);
  LLayoutStr := LLVMCopyStringRepOfTargetData(LTargetData);
  FDataLayout := string(UTF8String(LLayoutStr));
  LLVMDisposeMessage(LLayoutStr);

  LLVMDisposeTargetData(LTargetData);
  LLVMDisposeExecutionEngine(LEngine);
  LLVMContextDispose(LContext);
end;

class procedure TLLVM.Finalize();
begin
  LLVMShutdown();
end;

constructor TLLVM.Create;
begin
  inherited Create();
  Randomize; 
  FModules := TDictionary<string, TLLModuleState>.Create();
  FModuleLibraries := TDictionary<string, TDictionary<string, Boolean>>.Create();
end;

destructor TLLVM.Destroy;
var
  LModuleState: TLLModuleState;
  LLibDict: TDictionary<string, Boolean>;
  LContexts: TList<LLVMContextRef>;
  LContext: LLVMContextRef;
begin
  LContexts := TList<LLVMContextRef>.Create();
  try
    for LModuleState in FModules.Values do
    begin
      // JIT cleanup
      if Assigned(LModuleState.LLJIT) then
        LLVMOrcDisposeLLJIT(LModuleState.LLJIT);
      if Assigned(LModuleState.ThreadSafeContext) then
        LLVMOrcDisposeThreadSafeContext(LModuleState.ThreadSafeContext);
      if Assigned(LModuleState.JITContext) then
        LLVMContextDispose(LModuleState.JITContext);

      if Assigned(LModuleState.Variables) then
        LModuleState.Variables.Free();
      if Assigned(LModuleState.BasicBlocks) then
        LModuleState.BasicBlocks.Free();
      if Assigned(LModuleState.FunctionParams) then
        LModuleState.FunctionParams.Free();
      if Assigned(LModuleState.Builder) then
        LLVMDisposeBuilder(LModuleState.Builder);
      if Assigned(LModuleState.Module) then
        LLVMDisposeModule(LModuleState.Module);

      if Assigned(LModuleState.Context) and (LContexts.IndexOf(LModuleState.Context) = -1) then
        LContexts.Add(LModuleState.Context);
    end;
    
    for LContext in LContexts do
      LLVMContextDispose(LContext);
  finally
    LContexts.Free();
  end;
  
  FModules.Free();
  
  for LLibDict in FModuleLibraries.Values do
    LLibDict.Free();
  FModuleLibraries.Free();
    
  inherited Destroy();
end;

class function TLLVM.GetVersionStr(): string;
begin
  Result := Format('%d.%d.%d', [libLLVM_MAJOR, libLLVM_MINOR, libLLVM_PATCH])
end;

class function TLLVM.GetLLVMVersionStr(): string;
var
  LMajor: Cardinal;
  LMinor: Cardinal;
  LPatch: Cardinal;
begin
  LMajor := 0;
  LMinor := 0;
  LPatch := 0;
  LLVMGetVersion(@LMajor, @LMinor, @LPatch);
  Result := Format('%d.%d.%d', [LMajor, LMinor, LPatch]);
end;

function TLLVM.SetTargetPlatform(const ATriple: string; const ADataLayout: string): TLLVM;
begin
  FTargetTriple := ATriple;
  FDataLayout := ADataLayout;
  Result := Self;
end;

function TLLVM.GetModule(const AModuleId: string): LLVMModuleRef;
var
  LModuleState: TLLModuleState;
begin
  if not FModules.TryGetValue(AModuleId, LModuleState) then
    raise Exception.CreateFmt('Module "%s" not found', [AModuleId]);
  Result := LModuleState.Module;
end;

function TLLVM.GetModuleState(const AModuleId: string): TLLModuleState;
begin
  if not FModules.TryGetValue(AModuleId, Result) then
    raise Exception.CreateFmt('Module "%s" not found', [AModuleId]);
end;

procedure TLLVM.SetModuleState(const AModuleId: string; const AState: TLLModuleState);
begin
  FModules.AddOrSetValue(AModuleId, AState);
end;

function TLLVM.GetBasicType(const ABasicType: TLLDataType; const AContext: LLVMContextRef): LLVMTypeRef;
begin
  case ABasicType of
    dtVoid: Result := LLVMVoidTypeInContext(AContext);
    dtInt1: Result := LLVMInt1TypeInContext(AContext);
    dtInt8: Result := LLVMInt8TypeInContext(AContext);
    dtInt16: Result := LLVMInt16TypeInContext(AContext);
    dtInt32: Result := LLVMInt32TypeInContext(AContext);
    dtInt64: Result := LLVMInt64TypeInContext(AContext);
    dtInt128: Result := LLVMInt128TypeInContext(AContext);
    dtFloat16: Result := LLVMHalfTypeInContext(AContext);
    dtFloat32: Result := LLVMFloatTypeInContext(AContext);
    dtFloat64: Result := LLVMDoubleTypeInContext(AContext);
    dtFloat80: Result := LLVMX86FP80TypeInContext(AContext);
    dtFloat128: Result := LLVMFP128TypeInContext(AContext);
    dtPointer: Result := LLVMPointerTypeInContext(AContext, 0);
    dtInt8Ptr: Result := LLVMPointerTypeInContext(AContext, 0);
    dtInt32Ptr: Result := LLVMPointerTypeInContext(AContext, 0);
    dtVoidPtr: Result := LLVMPointerTypeInContext(AContext, 0);
    dtLabel: Result := LLVMLabelTypeInContext(AContext);
    dtMetadata: Result := LLVMMetadataTypeInContext(AContext);
  else
    raise Exception.CreateFmt('Unsupported basic type: %d', [Ord(ABasicType)]);
  end;
end;

function TLLVM.GetLLVMCallingConv(const ACallingConv: TLLCallingConv): LLVMCallConv;
begin
  case ACallingConv of
    ccCDecl: Result := LLVMCCallConv;
    ccStdCall: Result := LLVMX86StdcallCallConv;
    ccFastCall: Result := LLVMX86FastcallCallConv;
  else
    Result := LLVMCCallConv;
  end;
end;

function TLLVM.GetLLVMLinkage(const AVisibility: TLLVisibility): LLVMLinkage;
begin
  case AVisibility of
    vPrivate: Result := LLVMPrivateLinkage;
    vPublic: Result := LLVMExternalLinkage;
    vExternal: Result := LLVMExternalLinkage;
  else
    Result := LLVMExternalLinkage;
  end;
end;

function TLLVM.LLVMTypeToBasicType(ALLVMType: LLVMTypeRef): TLLDataType;
var
  LKind: LLVMTypeKind;
  LBitWidth: Cardinal;
begin
  LKind := LLVMGetTypeKind(ALLVMType);
  
  case LKind of
    LLVMVoidTypeKind: Result := dtVoid;
    LLVMIntegerTypeKind:
      begin
        LBitWidth := LLVMGetIntTypeWidth(ALLVMType);
        case LBitWidth of
          1: Result := dtInt1;
          8: Result := dtInt8;
          16: Result := dtInt16;
          32: Result := dtInt32;
          64: Result := dtInt64;
          128: Result := dtInt128;
        else
          Result := dtInt32; // Default
        end;
      end;
    LLVMHalfTypeKind: Result := dtFloat16;
    LLVMFloatTypeKind: Result := dtFloat32;
    LLVMDoubleTypeKind: Result := dtFloat64;
    LLVMX86_FP80TypeKind: Result := dtFloat80;
    LLVMFP128TypeKind: Result := dtFloat128;
    LLVMPointerTypeKind: Result := dtPointer;
    LLVMLabelTypeKind: Result := dtLabel;
    LLVMMetadataTypeKind: Result := dtMetadata;
  else
    Result := dtVoid; // Default for unsupported types
  end;
end;

// Direct TValue <-> LLVM conversion (NO TPaValue!)
function TLLVM.ExtractLLVMValue(const AModuleId: string; const AValue: TValue): LLVMValueRef;
var
  LModuleState: TLLModuleState;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if AValue.IsEmpty then
    raise Exception.Create('Cannot convert empty TValue to LLVM value')
  else if AValue.IsType<LLVMValueRef> then
    Result := AValue.AsType<LLVMValueRef>  // Already an LLVM value
  else if AValue.IsType<string> then
    Result := ExtractLLVMValue(AModuleId, StringValue(AModuleId, AValue.AsString))
  else if AValue.IsType<Integer> then
    Result := LLVMConstInt(GetBasicType(dtInt32, LModuleState.Context), AValue.AsInteger, 1)
  else if AValue.IsType<Int64> then
    Result := LLVMConstInt(GetBasicType(dtInt64, LModuleState.Context), AValue.AsInt64, 1)
  else if AValue.IsType<Boolean> then
    Result := LLVMConstInt(GetBasicType(dtInt1, LModuleState.Context), Ord(AValue.AsBoolean), 0)
  else if AValue.IsType<Double> then
    Result := LLVMConstReal(GetBasicType(dtFloat64, LModuleState.Context), AValue.AsExtended)
  else if AValue.IsType<Single> then
    Result := LLVMConstReal(GetBasicType(dtFloat32, LModuleState.Context), AValue.AsExtended)
  else
    raise Exception.CreateFmt('Unsupported TValue type: %s', [AValue.TypeInfo.Name]);
end;

function TLLVM.CreateTValue(const ALLVMValue: LLVMValueRef): TValue;
begin
  // Store LLVM value directly in TValue
  Result := TValue.From<LLVMValueRef>(ALLVMValue);
end;

function TLLVM.FindBasicBlock(const AModuleState: TLLModuleState; const ABlockName: string): LLVMBasicBlockRef;
var
  LBlock: TLLBasicBlock;
begin
  if AModuleState.BasicBlocks.TryGetValue(ABlockName, LBlock) then
    Result := LBlock.Block
  else
    Result := nil;
end;

procedure TLLVM.AddLibraryToModule(const AModuleId: string; const ALibraryName: string);
var
  LLibDict: TDictionary<string, Boolean>;
begin
  if not FModuleLibraries.TryGetValue(AModuleId, LLibDict) then
  begin
    LLibDict := TDictionary<string, Boolean>.Create();
    FModuleLibraries.Add(AModuleId, LLibDict);
  end;
  LLibDict.AddOrSetValue(ALibraryName, True);
end;

// Module lifecycle
function TLLVM.CreateModule(const AModuleId: string; const AShareContextWith: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LSourceModule: TLLModuleState;
begin
  if FModules.ContainsKey(AModuleId) then
    raise Exception.CreateFmt('Module "%s" already exists', [AModuleId]);
    
  if (AShareContextWith <> '') and FModules.TryGetValue(AShareContextWith, LSourceModule) then
    LModuleState.Context := LSourceModule.Context
  else
    LModuleState.Context := LLVMContextCreate();

  LModuleState.LLJIT := nil;
  LModuleState.IsJITInitialized := False;
  LModuleState.JITContext := nil;
  LModuleState.ThreadSafeContext := nil;

  LModuleState.Module := LLVMModuleCreateWithNameInContext(PAnsiChar(AnsiString(AModuleId)), LModuleState.Context);
  LModuleState.Builder := LLVMCreateBuilderInContext(LModuleState.Context);
  LModuleState.CurrentFunction := nil;
  LModuleState.CurrentBlock := nil;
  LModuleState.Variables := TDictionary<string, TLLVariable>.Create();
  LModuleState.BasicBlocks := TDictionary<string, TLLBasicBlock>.Create();
  LModuleState.FunctionParams := TDictionary<string, TLLVariable>.Create();

  if FTargetTriple <> '' then
    LLVMSetTarget(LModuleState.Module, PAnsiChar(AnsiString(FTargetTriple)));
  if FDataLayout <> '' then
    LLVMSetDataLayout(LModuleState.Module, PAnsiChar(AnsiString(FDataLayout)));
    
  FModules.Add(AModuleId, LModuleState);
  Result := Self;
end;

function TLLVM.DeleteModule(const AModuleId: string): TLLVM;
var
  LModuleState: TLLModuleState;
begin
  if FModules.TryGetValue(AModuleId, LModuleState) then
  begin
    if Assigned(LModuleState.Variables) then
      LModuleState.Variables.Free();
    if Assigned(LModuleState.BasicBlocks) then
      LModuleState.BasicBlocks.Free();
    if Assigned(LModuleState.FunctionParams) then
      LModuleState.FunctionParams.Free();
    if Assigned(LModuleState.Builder) then
      LLVMDisposeBuilder(LModuleState.Builder);
    if Assigned(LModuleState.Module) then
      LLVMDisposeModule(LModuleState.Module);
    
    FModules.Remove(AModuleId);
  end;
  Result := Self;
end;

function TLLVM.ModuleExists(const AModuleId: string): Boolean;
begin
  Result := FModules.ContainsKey(AModuleId);
end;

function TLLVM.MergeModules(const ATargetId: string; const ASourceIds: array of string): TLLVM;
var
  LTargetModule: LLVMModuleRef;
  LSourceModule: LLVMModuleRef;
  LSourceId: string;
  LError: PAnsiChar;
  LLibName: string;
  LModuleState: TLLModuleState;
begin
  LTargetModule := GetModule(ATargetId);

  for LSourceId in ASourceIds do
  begin
    LSourceModule := GetModule(LSourceId);

    if LLVMLinkModules2(LTargetModule, LSourceModule) <> 0 then
    begin
      LError := LLVMGetErrorMessage(LLVMCreateStringError(PAnsiChar('Module linking failed')));
      try
        raise Exception.CreateFmt('Failed to merge module "%s": %s', [LSourceId, string(LError)]);
      finally
        LLVMDisposeErrorMessage(LError);
      end;
    end
    else
    begin
      // Merge library dependencies from source to target
      if FModuleLibraries.ContainsKey(LSourceId) then
      begin
        // Ensure target has a library dictionary
        if not FModuleLibraries.ContainsKey(ATargetId) then
        begin
          FModuleLibraries.Add(ATargetId, TDictionary<string, Boolean>.Create());
        end;

        // Copy all libraries from source to target
        for LLibName in FModuleLibraries[LSourceId].Keys do
        begin
          FModuleLibraries[ATargetId].AddOrSetValue(LLibName, True);
        end;
      end;

      // Now safe to delete the source module

      if FModules.TryGetValue(LSourceId, LModuleState) then
      begin
        // Set Module's reference to nil to prevent crash since its not been
        // merged and not longer valid
        LModuleState.Module := nil;
        FModules.AddOrSetValue(LSourceId, LModuleState);
      end;
      DeleteModule(LSourceId);
    end;
  end;

  Result := Self;
end;

function TLLVM.GetModuleIR(const AModuleId: string): string;
var
  LModule: LLVMModuleRef;
  LModuleStr: PAnsiChar;
begin
  LModule := GetModule(AModuleId);
  LModuleStr := LLVMPrintModuleToString(LModule);
  try
    Result := string(LModuleStr);
  finally
    LLVMDisposeMessage(LModuleStr);
  end;
end;

function TLLVM.ValidateModule(const AModuleId: string): Boolean;
var
  LModule: LLVMModuleRef;
  LError: PAnsiChar;
  LErrorMsg: string;
begin
  LModule := GetModule(AModuleId);
  Result := LLVMVerifyModule(LModule, LLVMReturnStatusAction, @LError) = 0;
  
  if not Result then
  begin
    if LError <> nil then
    begin
      LErrorMsg := string(UTF8String(LError));
      LLVMDisposeMessage(LError);
    end;
  end;
    
  // Initialize JIT after successful validation (ONE TIME ONLY!)
  if Result then
  begin
    EnsureJITReady(AModuleId);
  end
  else
  begin
    // Force JIT initialization even if validation failed (for external functions)
    EnsureJITReady(AModuleId);
  end;
end;

function TLLVM.GetRequiredLibraries(const AModuleId: string): TArray<string>;
var
  LLibDict: TDictionary<string, Boolean>;
  LLibName: string;
  LIndex: Integer;
begin
  if FModuleLibraries.TryGetValue(AModuleId, LLibDict) then
  begin
    SetLength(Result, LLibDict.Count);
    LIndex := 0;
    for LLibName in LLibDict.Keys do
    begin
      Result[LIndex] := LLibName;
      Inc(LIndex);
    end;
  end
  else
    SetLength(Result, 0);
end;

// Function declaration
function TLLVM.BeginFunction(const AModuleId: string; const AFunctionName: string; const AReturnType: TLLDataType;
  const AParams: array of TLLParam; const AVisibility: TLLVisibility; const ACallingConv: TLLCallingConv;
  const AIsVarArgs: Boolean; const AExternalLib: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LParamTypes: array of LLVMTypeRef;
  LFunctionType: LLVMTypeRef;
  LFunction: LLVMValueRef;
  LParam: TLLParam;
  LIndex: Integer;
  LVariable: TLLVariable;
  LParamValue: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  // Build parameter types
  SetLength(LParamTypes, Length(AParams));
  for LIndex := 0 to High(AParams) do
    LParamTypes[LIndex] := GetBasicType(AParams[LIndex].ParamType, LModuleState.Context);
  
  // Create function type
  if Length(AParams) > 0 then
    LFunctionType := LLVMFunctionType(
      GetBasicType(AReturnType, LModuleState.Context),
      @LParamTypes[0],
      Length(LParamTypes),
      Ord(AIsVarArgs)
    )
  else
    LFunctionType := LLVMFunctionType(
      GetBasicType(AReturnType, LModuleState.Context),
      nil,
      0,
      Ord(AIsVarArgs)
    );
  
  // Create function
  LFunction := LLVMAddFunction(LModuleState.Module, PAnsiChar(AnsiString(AFunctionName)), LFunctionType);
  LLVMSetFunctionCallConv(LFunction, Ord(GetLLVMCallingConv(ACallingConv)));
  LLVMSetLinkage(LFunction, GetLLVMLinkage(AVisibility));
  
  LModuleState.CurrentFunction := LFunction;
  
  // Clear function parameters and add new ones
  LModuleState.FunctionParams.Clear();
  
  // Set parameter names and store in FunctionParams
  for LIndex := 0 to High(AParams) do
  begin
    LParam := AParams[LIndex];
    LParamValue := LLVMGetParam(LFunction, LIndex);
    LLVMSetValueName2(LParamValue, PAnsiChar(AnsiString(LParam.ParamName)), Length(AnsiString(LParam.ParamName)));
    
    LVariable.Name := LParam.ParamName;
    LVariable.VarType := LParam.ParamType;
    LVariable.AllocaInst := LParamValue;
    LVariable.IsGlobal := False;
    
    LModuleState.FunctionParams.AddOrSetValue(LParam.ParamName, LVariable);
  end;
  
  // If external library specified, add it to dependencies
  if AExternalLib <> '' then
    AddLibraryToModule(AModuleId, AExternalLib);
  
  SetModuleState(AModuleId, LModuleState);
  Result := Self;
end;

function TLLVM.Param(const AParamName: string; const AParamType: TLLDataType): TLLParam;
begin
  Result.ParamName := AParamName;
  Result.ParamType := AParamType;
end;

function TLLVM.EndFunction(const AModuleId: string): TLLVM;
var
  LModuleState: TLLModuleState;
begin
  LModuleState := GetModuleState(AModuleId);
  LModuleState.CurrentFunction := nil;
  LModuleState.CurrentBlock := nil;
  LModuleState.BasicBlocks.Clear();
  LModuleState.FunctionParams.Clear();
  SetModuleState(AModuleId, LModuleState);
  Result := Self;
end;

// Basic blocks
function TLLVM.BeginBlock(const AModuleId: string; const ABlockLabel: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LBasicBlock: LLVMBasicBlockRef;
  LBlockRecord: TLLBasicBlock;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not Assigned(LModuleState.CurrentFunction) then
    raise Exception.Create('No current function to add basic block to');
  
  // Check if block was pre-declared
  if LModuleState.BasicBlocks.TryGetValue(ABlockLabel, LBlockRecord) then
  begin
    // Use existing pre-declared block
    LBasicBlock := LBlockRecord.Block;
  end
  else
  begin
    // Create new block (backward compatibility)
    LBasicBlock := LLVMAppendBasicBlockInContext(LModuleState.Context, LModuleState.CurrentFunction, PAnsiChar(AnsiString(ABlockLabel)));
    
    LBlockRecord.Name := ABlockLabel;
    LBlockRecord.Block := LBasicBlock;
    LModuleState.BasicBlocks.AddOrSetValue(ABlockLabel, LBlockRecord);
  end;
  
  // Position builder at the block (this is what makes it "active")
  LLVMPositionBuilderAtEnd(LModuleState.Builder, LBasicBlock);
  LModuleState.CurrentBlock := LBasicBlock;
  
  SetModuleState(AModuleId, LModuleState);
  Result := Self;
end;

function TLLVM.DeclareBlock(const AModuleId: string; const ABlockLabel: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LBasicBlock: LLVMBasicBlockRef;
  LBlockRecord: TLLBasicBlock;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not Assigned(LModuleState.CurrentFunction) then
    raise Exception.Create('No current function to add basic block to');
  
  // Check if block already exists
  if LModuleState.BasicBlocks.ContainsKey(ABlockLabel) then
    raise Exception.CreateFmt('Basic block "%s" already declared', [ABlockLabel]);
  
  // Create the basic block but do NOT position builder there yet
  LBasicBlock := LLVMAppendBasicBlockInContext(LModuleState.Context, LModuleState.CurrentFunction, PAnsiChar(AnsiString(ABlockLabel)));
  
  // Register the block for later Jump() resolution
  LBlockRecord.Name := ABlockLabel;
  LBlockRecord.Block := LBasicBlock;
  LModuleState.BasicBlocks.AddOrSetValue(ABlockLabel, LBlockRecord);
  
  SetModuleState(AModuleId, LModuleState);
  Result := Self;
end;

function TLLVM.EndBlock(const AModuleId: string): TLLVM;
var
  LModuleState: TLLModuleState;
begin
  LModuleState := GetModuleState(AModuleId);
  LModuleState.CurrentBlock := nil;
  SetModuleState(AModuleId, LModuleState);
  Result := Self;
end;

// Variables
function TLLVM.DeclareGlobal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType;
  const AInitialValue: TValue): TLLVM;
var
  LModuleState: TLLModuleState;
  LVariable: TLLVariable;
  LGlobal: LLVMValueRef;
  LInitValue: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LGlobal := LLVMAddGlobal(LModuleState.Module, GetBasicType(AVarType, LModuleState.Context), PAnsiChar(AnsiString(AVarName)));
  
  if not AInitialValue.IsEmpty then
  begin
    LInitValue := ExtractLLVMValue(AModuleId, AInitialValue);
    LLVMSetInitializer(LGlobal, LInitValue);
  end;
  
  LVariable.Name := AVarName;
  LVariable.VarType := AVarType;
  LVariable.AllocaInst := LGlobal;
  LVariable.IsGlobal := True;
  
  LModuleState.Variables.AddOrSetValue(AVarName, LVariable);
  SetModuleState(AModuleId, LModuleState);
  Result := Self;
end;

function TLLVM.DeclareGlobal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType): TLLVM;
begin
  Result := DeclareGlobal(AModuleId, AVarName, AVarType, TValue.Empty);
end;

function TLLVM.DeclareLocal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType): TLLVM;
var
  LModuleState: TLLModuleState;
  LVariable: TLLVariable;
  LAlloca: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not Assigned(LModuleState.CurrentFunction) then
    raise Exception.Create('Cannot declare local variable outside of function');
  
  LAlloca := LLVMBuildAlloca(LModuleState.Builder, GetBasicType(AVarType, LModuleState.Context), PAnsiChar(AnsiString(AVarName)));
  
  LVariable.Name := AVarName;
  LVariable.VarType := AVarType;
  LVariable.AllocaInst := LAlloca;
  LVariable.IsGlobal := False;
  
  LModuleState.Variables.AddOrSetValue(AVarName, LVariable);
  SetModuleState(AModuleId, LModuleState);
  Result := Self;
end;

// Value creation - Now returns TValue directly with LLVM values inside
function TLLVM.IntegerValue(const AModuleId: string; const AValue: Int64; const ABitWidth: TLLDataType): TValue;
var
  LModuleState: TLLModuleState;
  LLLVMValue: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  LLLVMValue := LLVMConstInt(GetBasicType(ABitWidth, LModuleState.Context), UInt64(AValue), 1);
  Result := CreateTValue(LLLVMValue);
end;

function TLLVM.FloatValue(const AModuleId: string; const AValue: Double; const AFloatType: TLLDataType): TValue;
var
  LModuleState: TLLModuleState;
  LLLVMValue: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  LLLVMValue := LLVMConstReal(GetBasicType(AFloatType, LModuleState.Context), AValue);
  Result := CreateTValue(LLLVMValue);
end;

// Helper function to process string escape sequences
function ProcessStringEscapes(const AText: string): string;
var
  LIndex: Integer;
  LChar: Char;
begin
  Result := '';
  LIndex := 1;
  while LIndex <= Length(AText) do
  begin
    LChar := AText[LIndex];
    if (LChar = '\') and (LIndex < Length(AText)) then
    begin
      Inc(LIndex);
      case AText[LIndex] of
        'n': Result := Result + #10;   // Newline
        't': Result := Result + #9;    // Tab
        'r': Result := Result + #13;   // Carriage return
        '\': Result := Result + '\';  // Backslash
        '"': Result := Result + '"';  // Quote
        '''': Result := Result + ''''; // Single quote
        '0': Result := Result + #0;    // Null character
        'a': Result := Result + #7;    // Bell
        'b': Result := Result + #8;    // Backspace
        'f': Result := Result + #12;   // Form feed
        'v': Result := Result + #11;   // Vertical tab
      else
        // Unknown escape, keep both characters
        Result := Result + '\' + AText[LIndex];
      end;
    end
    else
      Result := Result + LChar;
    Inc(LIndex);
  end;
end;

// Helper function to generate a hash-based unique name for strings
function GenerateStringHash(const AText: string): string;
begin
  Result := Format('str.%x', [AText.GetHashCode and $FFFFFFFF]);
end;

function TLLVM.StringValue(const AModuleId: string; const AText: string): TValue;
var
  LModuleState: TLLModuleState;
  LProcessedText: string;
  LAnsiText: AnsiString;
  LStringConstant: LLVMValueRef;
  LGlobalString: LLVMValueRef;
  LStringName: string;
  LIndices: array[0..1] of LLVMValueRef;
  LStringPtr: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  // Process escape sequences
  LProcessedText := ProcessStringEscapes(AText);
  LAnsiText := AnsiString(LProcessedText);
  
  // Generate unique hash-based name to avoid collisions
  LStringName := GenerateStringHash(LProcessedText);
  
  LStringConstant := LLVMConstStringInContext(LModuleState.Context, PAnsiChar(LAnsiText), Length(LAnsiText), 0);
  
  LGlobalString := LLVMAddGlobal(LModuleState.Module, LLVMTypeOf(LStringConstant), PAnsiChar(AnsiString(LStringName)));
  LLVMSetLinkage(LGlobalString, LLVMPrivateLinkage);
  LLVMSetInitializer(LGlobalString, LStringConstant);
  LLVMSetGlobalConstant(LGlobalString, 1);
  
  LIndices[0] := LLVMConstInt(LLVMInt32TypeInContext(LModuleState.Context), 0, 0);
  LIndices[1] := LLVMConstInt(LLVMInt32TypeInContext(LModuleState.Context), 0, 0);
  LStringPtr := LLVMConstInBoundsGEP2(LLVMTypeOf(LStringConstant), LGlobalString, @LIndices[0], 2);
  
  Result := CreateTValue(LStringPtr);
end;

function TLLVM.BooleanValue(const AModuleId: string; const AValue: Boolean): TValue;
var
  LModuleState: TLLModuleState;
  LLLVMValue: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  LLLVMValue := LLVMConstInt(GetBasicType(dtInt1, LModuleState.Context), Ord(AValue), 0);
  Result := CreateTValue(LLLVMValue);
end;

function TLLVM.NullValue(const AModuleId: string; const ANullType: TLLDataType): TValue;
var
  LModuleState: TLLModuleState;
  LLLVMValue: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  LLLVMValue := LLVMConstNull(GetBasicType(ANullType, LModuleState.Context));
  Result := CreateTValue(LLLVMValue);
end;

// Math operations - Simple and clean!
function TLLVM.Add(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'add_tmp';
    
  LResult := LLVMBuildAdd(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.Subtract(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'sub_tmp';
    
  LResult := LLVMBuildSub(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.Multiply(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'mul_tmp';
    
  LResult := LLVMBuildMul(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.Divide(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'div_tmp';
    
  LResult := LLVMBuildSDiv(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.Modulo(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'mod_tmp';
    
  LResult := LLVMBuildSRem(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

// Floating point operations
function TLLVM.FAdd(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fadd_tmp';
    
  LResult := LLVMBuildFAdd(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FSub(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fsub_tmp';
    
  LResult := LLVMBuildFSub(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FMul(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fmul_tmp';
    
  LResult := LLVMBuildFMul(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FDiv(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fdiv_tmp';
    
  LResult := LLVMBuildFDiv(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

// Bitwise operations
function TLLVM.BitwiseAnd(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'and_tmp';
    
  LResult := LLVMBuildAnd(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.BitwiseOr(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'or_tmp';
    
  LResult := LLVMBuildOr(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.BitwiseXor(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'xor_tmp';
    
  LResult := LLVMBuildXor(LModuleState.Builder, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.BitwiseNot(const AModuleId: string; const AValue: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'not_tmp';
    
  LResult := LLVMBuildNot(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.ShiftLeft(const AModuleId: string; const AValue: TValue; const AShift: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'shl_tmp';
    
  LResult := LLVMBuildShl(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), ExtractLLVMValue(AModuleId, AShift), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.ShiftRight(const AModuleId: string; const AValue: TValue; const AShift: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'shr_tmp';
    
  LResult := LLVMBuildAShr(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), ExtractLLVMValue(AModuleId, AShift), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

// Comparisons
function TLLVM.IsEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'eq_tmp';
    
  LResult := LLVMBuildICmp(LModuleState.Builder, LLVMIntEQ, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.IsNotEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'ne_tmp';
    
  LResult := LLVMBuildICmp(LModuleState.Builder, LLVMIntNE, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.IsLess(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'lt_tmp';
    
  LResult := LLVMBuildICmp(LModuleState.Builder, LLVMIntSLT, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.IsLessEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'le_tmp';
    
  LResult := LLVMBuildICmp(LModuleState.Builder, LLVMIntSLE, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.IsGreater(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'gt_tmp';
    
  LResult := LLVMBuildICmp(LModuleState.Builder, LLVMIntSGT, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.IsGreaterEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'ge_tmp';
    
  LResult := LLVMBuildICmp(LModuleState.Builder, LLVMIntSGE, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

// Floating point comparisons
function TLLVM.FIsEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'feq_tmp';
    
  LResult := LLVMBuildFCmp(LModuleState.Builder, LLVMRealOEQ, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FIsNotEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fne_tmp';
    
  LResult := LLVMBuildFCmp(LModuleState.Builder, LLVMRealONE, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FIsLess(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'flt_tmp';
    
  LResult := LLVMBuildFCmp(LModuleState.Builder, LLVMRealOLT, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FIsLessEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fle_tmp';
    
  LResult := LLVMBuildFCmp(LModuleState.Builder, LLVMRealOLE, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FIsGreater(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fgt_tmp';
    
  LResult := LLVMBuildFCmp(LModuleState.Builder, LLVMRealOGT, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FIsGreaterEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fge_tmp';
    
  LResult := LLVMBuildFCmp(LModuleState.Builder, LLVMRealOGE, ExtractLLVMValue(AModuleId, ALeft), ExtractLLVMValue(AModuleId, ARight), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

// Type conversions
function TLLVM.IntCast(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'cast_tmp';
    
  LResult := LLVMBuildIntCast2(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), GetBasicType(ATargetType, LModuleState.Context), 1, PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FloatCast(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'fcast_tmp';
    
  LResult := LLVMBuildFPCast(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), GetBasicType(ATargetType, LModuleState.Context), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.IntToFloat(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'itof_tmp';
    
  LResult := LLVMBuildSIToFP(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), GetBasicType(ATargetType, LModuleState.Context), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.FloatToInt(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'ftoi_tmp';
    
  LResult := LLVMBuildFPToSI(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), GetBasicType(ATargetType, LModuleState.Context), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

// Control flow
function TLLVM.ReturnValue(const AModuleId: string; const AValue: TValue): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LResult := LLVMBuildRet(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue));
  Result := CreateTValue(LResult);
end;

function TLLVM.ReturnValue(const AModuleId: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LResult := LLVMBuildRetVoid(LModuleState.Builder);
  Result := CreateTValue(LResult);
end;

function TLLVM.Jump(const AModuleId: string; const ABlockLabel: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LTargetBlock: LLVMBasicBlockRef;
begin
  LModuleState := GetModuleState(AModuleId);
  LTargetBlock := FindBasicBlock(LModuleState, ABlockLabel);
  
  if not Assigned(LTargetBlock) then
    raise Exception.CreateFmt('Basic block "%s" not found', [ABlockLabel]);
  
  LLVMBuildBr(LModuleState.Builder, LTargetBlock);
  Result := Self;
end;

function TLLVM.JumpIf(const AModuleId: string; const ACondition: TValue; const ATrueBlock: string; const AFalseBlock: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LTrueBlock, LFalseBlock: LLVMBasicBlockRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LTrueBlock := FindBasicBlock(LModuleState, ATrueBlock);
  LFalseBlock := FindBasicBlock(LModuleState, AFalseBlock);
  
  if not Assigned(LTrueBlock) then
    raise Exception.CreateFmt('True basic block "%s" not found', [ATrueBlock]);
  if not Assigned(LFalseBlock) then
    raise Exception.CreateFmt('False basic block "%s" not found', [AFalseBlock]);
  
  LLVMBuildCondBr(LModuleState.Builder, ExtractLLVMValue(AModuleId, ACondition), LTrueBlock, LFalseBlock);
  Result := Self;
end;

// Function calls
function TLLVM.CallFunction(const AModuleId: string; const AFunctionName: string; const AArgs: array of const; const AValueName: string): TValue;
var
  LValues: array of TValue;
  LIndex: Integer;
begin
  SetLength(LValues, Length(AArgs));
  
  for LIndex := 0 to High(AArgs) do
  begin
    case AArgs[LIndex].VType of
      vtInteger: LValues[LIndex] := TValue.From(AArgs[LIndex].VInteger);
      vtInt64: LValues[LIndex] := TValue.From(AArgs[LIndex].VInt64^);
      vtExtended: LValues[LIndex] := TValue.From(AArgs[LIndex].VExtended^);
      vtString: LValues[LIndex] := TValue.From(string(AArgs[LIndex].VString^));
      vtAnsiString: LValues[LIndex] := TValue.From(string(AnsiString(AArgs[LIndex].VAnsiString)));
      vtUnicodeString: LValues[LIndex] := TValue.From(string(AArgs[LIndex].VUnicodeString));
      vtBoolean: LValues[LIndex] := TValue.From(AArgs[LIndex].VBoolean);
    else
      raise Exception.CreateFmt('Unsupported argument type at index %d', [LIndex]);
    end;
  end;
  
  Result := CallFunction(AModuleId, AFunctionName, LValues, AValueName);
end;

function TLLVM.CallFunction(const AModuleId: string; const AFunctionName: string; const AArgs: array of TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LFunction: LLVMValueRef;
  LArgValues: array of LLVMValueRef;
  LIndex: Integer;
  LResult: LLVMValueRef;
  LName: AnsiString;
  LFunctionType: LLVMTypeRef;
  LReturnType: LLVMTypeRef;
  LIsVoid: Boolean;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LFunction := LLVMGetNamedFunction(LModuleState.Module, PAnsiChar(AnsiString(AFunctionName)));
  if not Assigned(LFunction) then
    raise Exception.CreateFmt('Function "%s" not found', [AFunctionName]);
  
  SetLength(LArgValues, Length(AArgs));
  for LIndex := 0 to High(AArgs) do
    LArgValues[LIndex] := ExtractLLVMValue(AModuleId, AArgs[LIndex]);
  
  LFunctionType := LLVMGlobalGetValueType(LFunction);
  LReturnType := LLVMGetReturnType(LFunctionType);
  LIsVoid := LLVMGetTypeKind(LReturnType) = LLVMVoidTypeKind;
  
  // Only assign names to non-void function calls
  if LIsVoid then
  begin
    if Length(AArgs) > 0 then
      LResult := LLVMBuildCall2(LModuleState.Builder, LFunctionType, LFunction, @LArgValues[0], Length(LArgValues), '')
    else
      LResult := LLVMBuildCall2(LModuleState.Builder, LFunctionType, LFunction, nil, 0, '');
  end
  else
  begin
    LName := AnsiString(AValueName);
    if LName = '' then
      LName := 'call_tmp';
    
    if Length(AArgs) > 0 then
      LResult := LLVMBuildCall2(LModuleState.Builder, LFunctionType, LFunction, @LArgValues[0], Length(LArgValues), PAnsiChar(LName))
    else
      LResult := LLVMBuildCall2(LModuleState.Builder, LFunctionType, LFunction, nil, 0, PAnsiChar(LName));
  end;
  
  Result := CreateTValue(LResult);
end;

// Memory operations
function TLLVM.SetValue(const AModuleId: string; const AVarName: string; const AValue: TValue): TLLVM;
var
  LModuleState: TLLModuleState;
  LVariable: TLLVariable;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not (LModuleState.Variables.TryGetValue(AVarName, LVariable) or 
          LModuleState.FunctionParams.TryGetValue(AVarName, LVariable)) then
    raise Exception.CreateFmt('Variable "%s" not found', [AVarName]);
  
  if LVariable.IsGlobal then
    LLVMSetInitializer(LVariable.AllocaInst, ExtractLLVMValue(AModuleId, AValue))
  else
    LLVMBuildStore(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), LVariable.AllocaInst);
  
  Result := Self;
end;

function TLLVM.GetValue(const AModuleId: string; const AVarName: string): TValue;
var
  LModuleState: TLLModuleState;
  LVariable: TLLVariable;
  LResult: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not (LModuleState.Variables.TryGetValue(AVarName, LVariable) or 
          LModuleState.FunctionParams.TryGetValue(AVarName, LVariable)) then
    raise Exception.CreateFmt('Variable "%s" not found', [AVarName]);
  
  if LVariable.IsGlobal then
    LResult := LVariable.AllocaInst
  else
    LResult := LLVMBuildLoad2(LModuleState.Builder, GetBasicType(LVariable.VarType, LModuleState.Context), LVariable.AllocaInst, PAnsiChar(AnsiString(AVarName + '_load')));
  
  Result := CreateTValue(LResult);
end;

function TLLVM.GetParameter(const AModuleId: string; const AParamName: string): TValue;
var
  LModuleState: TLLModuleState;
  LVariable: TLLVariable;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not LModuleState.FunctionParams.TryGetValue(AParamName, LVariable) then
    raise Exception.CreateFmt('Parameter "%s" not found', [AParamName]);
  
  Result := CreateTValue(LVariable.AllocaInst);
end;

function TLLVM.GetParameter(const AModuleId: string; const AParamIndex: Integer): TValue;
var
  LModuleState: TLLModuleState;
  LParamValue: LLVMValueRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not Assigned(LModuleState.CurrentFunction) then
    raise Exception.Create('No current function context');
  
  if (AParamIndex < 0) or (AParamIndex >= Integer(LLVMCountParams(LModuleState.CurrentFunction))) then
    raise Exception.CreateFmt('Parameter index %d out of range', [AParamIndex]);
  
  LParamValue := LLVMGetParam(LModuleState.CurrentFunction, AParamIndex);
  Result := CreateTValue(LParamValue);
end;

// Pointer operations
function TLLVM.AllocateArray(const AModuleId: string; const AElementType: TLLDataType; const ASize: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'array_tmp';
    
  LResult := LLVMBuildArrayAlloca(LModuleState.Builder, GetBasicType(AElementType, LModuleState.Context), ExtractLLVMValue(AModuleId, ASize), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.GetElementPtr(const AModuleId: string; const APtr: TValue; const AIndices: array of TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LIndexValues: array of LLVMValueRef;
  LIndex: Integer;
  LResult: LLVMValueRef;
  LName: AnsiString;
  LElementType: LLVMTypeRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  SetLength(LIndexValues, Length(AIndices));
  for LIndex := 0 to High(AIndices) do
    LIndexValues[LIndex] := ExtractLLVMValue(AModuleId, AIndices[LIndex]);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'gep_tmp';
  
  LElementType := LLVMInt8TypeInContext(LModuleState.Context); // Default to i8 for generic pointer math
  if Length(AIndices) > 0 then
    LResult := LLVMBuildInBoundsGEP2(LModuleState.Builder, LElementType, ExtractLLVMValue(AModuleId, APtr), @LIndexValues[0], Length(LIndexValues), PAnsiChar(LName))
  else
    LResult := LLVMBuildInBoundsGEP2(LModuleState.Builder, LElementType, ExtractLLVMValue(AModuleId, APtr), nil, 0, PAnsiChar(LName));
  
  Result := CreateTValue(LResult);
end;

function TLLVM.LoadValue(const AModuleId: string; const APtr: TValue; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
  LElementType: LLVMTypeRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'load_tmp';
  
  LElementType := LLVMInt32TypeInContext(LModuleState.Context); // Default to i32
  LResult := LLVMBuildLoad2(LModuleState.Builder, LElementType, ExtractLLVMValue(AModuleId, APtr), PAnsiChar(LName));
  
  Result := CreateTValue(LResult);
end;

function TLLVM.StoreValue(const AModuleId: string; const AValue: TValue; const APtr: TValue): TLLVM;
var
  LModuleState: TLLModuleState;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LLVMBuildStore(LModuleState.Builder, ExtractLLVMValue(AModuleId, AValue), ExtractLLVMValue(AModuleId, APtr));
  Result := Self;
end;

// PHI nodes for SSA form
function TLLVM.CreatePhi(const AModuleId: string; const AType: TLLDataType; const AValueName: string): TValue;
var
  LModuleState: TLLModuleState;
  LResult: LLVMValueRef;
  LName: AnsiString;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LName := AnsiString(AValueName);
  if LName = '' then
    LName := 'phi_tmp';
    
  LResult := LLVMBuildPhi(LModuleState.Builder, GetBasicType(AType, LModuleState.Context), PAnsiChar(LName));
  Result := CreateTValue(LResult);
end;

function TLLVM.AddPhiIncoming(const AModuleId: string; const APhi: TValue; const AValue: TValue; const ABlock: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LBlock: LLVMBasicBlockRef;
  LValues: array[0..0] of LLVMValueRef;
  LBlocks: array[0..0] of LLVMBasicBlockRef;
begin
  LModuleState := GetModuleState(AModuleId);
  
  LBlock := FindBasicBlock(LModuleState, ABlock);
  if not Assigned(LBlock) then
    raise Exception.CreateFmt('Basic block "%s" not found', [ABlock]);
  
  LValues[0] := ExtractLLVMValue(AModuleId, AValue);
  LBlocks[0] := LBlock;
  
  LLVMAddIncoming(ExtractLLVMValue(AModuleId, APhi), @LValues[0], @LBlocks[0], 1);
  Result := Self;
end;

// ============================================================================
// JIT Implementation Methods
// ============================================================================

procedure TLLVM.EnsureJITReady(const AModuleId: string);
var
  LModuleState: TLLModuleState;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if LModuleState.IsJITInitialized then
    Exit; // Already ready!
  
  // One-time initialization
  if not InitializeJITForModule(LModuleState) then
    raise Exception.CreateFmt('Failed to initialize JIT for module %s: %s', [AModuleId, LModuleState.LastError]);
    
  if not AddModuleToJITInternal(LModuleState) then
    raise Exception.CreateFmt('Failed to add module %s to JIT: %s', [AModuleId, LModuleState.LastError]);
    
  // Mark JIT as initialized and save state BEFORE registering libraries
  LModuleState.IsJITInitialized := True;
  SetModuleState(AModuleId, LModuleState);
  
  // Register all collected external libraries with JIT
  RegisterExternalLibrariesWithJIT(AModuleId);
end;

function TLLVM.InitializeJITForModule(var AModuleState: TLLModuleState): Boolean;
begin
  AModuleState.LastError := '';
  
  // Create LLJIT instance first
  Result := CreateLLJITForModule(AModuleState);
end;

function TLLVM.CreateLLJITForModule(var AModuleState: TLLModuleState): Boolean;
var
  LError: LLVMErrorRef;
  LBuilder: LLVMOrcLLJITBuilderRef;
  LTargetMachineBuilder: LLVMOrcJITTargetMachineBuilderRef;
  LMsg: PAnsiChar;
begin
  Result := False;
  AModuleState.LastError := '';
  
  try
    // Create LLJIT builder for configuration
    LBuilder := LLVMOrcCreateLLJITBuilder();
    if LBuilder = nil then
    begin
      AModuleState.LastError := 'Failed to create LLJIT builder';
      Exit;
    end;
    
    // Create target machine builder for native target
    LTargetMachineBuilder := LLVMOrcJITTargetMachineBuilderCreateFromTargetMachine(
      LLVMCreateTargetMachine(
        LLVMGetFirstTarget(),
        LLVMGetDefaultTargetTriple(),
        LLVMGetHostCPUName(),
        LLVMGetHostCPUFeatures(),
        LLVMCodeGenLevelDefault,
        LLVMRelocDefault,
        LLVMCodeModelDefault
      )
    );
    
    if LTargetMachineBuilder = nil then
    begin
      AModuleState.LastError := 'Failed to create target machine builder';
      LLVMOrcDisposeLLJITBuilder(LBuilder);
      Exit;
    end;
    
    // Set target machine builder in LLJIT builder
    LLVMOrcLLJITBuilderSetJITTargetMachineBuilder(LBuilder, LTargetMachineBuilder);
    
    // Create LLJIT instance
    LError := LLVMOrcCreateLLJIT(@AModuleState.LLJIT, LBuilder);
    if LError <> nil then
    begin
      LMsg := LLVMGetErrorMessage(LError);
      if Assigned(LMsg) then
      begin
        AModuleState.LastError := string(UTF8String(LMsg));
        LLVMDisposeMessage(LMsg);
      end;
      LLVMConsumeError(LError);
      Exit;
    end;
    
    Result := True;
  except
    on E: Exception do
    begin
      AModuleState.LastError := Format('Exception creating LLJIT: %s', [E.Message]);
      Result := False;
    end;
  end;
end;

function TLLVM.AddModuleToJITInternal(var AModuleState: TLLModuleState): Boolean;
var
  LError: LLVMErrorRef;
  LThreadSafeModule: LLVMOrcThreadSafeModuleRef;
  LMainJITDylib: LLVMOrcJITDylibRef;
  LMsg: PAnsiChar;
  LJITModule: LLVMModuleRef;
begin
  Result := False;
  AModuleState.LastError := '';
  
  if AModuleState.LLJIT = nil then
  begin
    AModuleState.LastError := 'LLJIT not initialized';
    Exit;
  end;
  
  if AModuleState.Module = nil then
  begin
    AModuleState.LastError := 'Module is nil';
    Exit;
  end;
  
  try
    // Create separate JIT context (like TPaJIT class)
    AModuleState.JITContext := LLVMContextCreate();
    if AModuleState.JITContext = nil then
    begin
      AModuleState.LastError := 'Failed to create JIT context';
      Exit;
    end;
    
    // Clone module to JIT context
    LJITModule := LLVMCloneModule(AModuleState.Module);
    if LJITModule = nil then
    begin
      AModuleState.LastError := 'Failed to clone module for JIT';
      LLVMContextDispose(AModuleState.JITContext);
      AModuleState.JITContext := nil;
      Exit;
    end;
    
    // Create thread-safe context for the JIT
    AModuleState.ThreadSafeContext := LLVMOrcCreateNewThreadSafeContext();
    if AModuleState.ThreadSafeContext = nil then
    begin
      AModuleState.LastError := 'Failed to create thread-safe context';
      LLVMDisposeModule(LJITModule);
      LLVMContextDispose(AModuleState.JITContext);
      AModuleState.JITContext := nil;
      Exit;
    end;
    
    // Wrap JIT module in thread-safe wrapper
    LThreadSafeModule := LLVMOrcCreateNewThreadSafeModule(LJITModule, AModuleState.ThreadSafeContext);
    if LThreadSafeModule = nil then
    begin
      AModuleState.LastError := 'Failed to create thread-safe module';
      LLVMDisposeModule(LJITModule);
      LLVMContextDispose(AModuleState.JITContext);
      AModuleState.JITContext := nil;
      Exit;
    end;
    
    // Get main JITDylib (the default dylib for symbol resolution)
    LMainJITDylib := LLVMOrcLLJITGetMainJITDylib(AModuleState.LLJIT);
    if LMainJITDylib = nil then
    begin
      AModuleState.LastError := 'Failed to get main JITDylib';
      LLVMOrcDisposeThreadSafeModule(LThreadSafeModule);
      LLVMContextDispose(AModuleState.JITContext);
      AModuleState.JITContext := nil;
      Exit;
    end;
    
    // Add JIT module to LLJIT (this triggers compilation)
    LError := LLVMOrcLLJITAddLLVMIRModule(AModuleState.LLJIT, LMainJITDylib, LThreadSafeModule);
    if LError <> nil then
    begin
      LMsg := LLVMGetErrorMessage(LError);
      if Assigned(LMsg) then
      begin
        AModuleState.LastError := string(UTF8String(LMsg));
        LLVMDisposeMessage(LMsg);
      end;
      LLVMConsumeError(LError);
      Exit;
    end;
    
    // JIT now owns the cloned module - original module stays with us for IR building
    Result := True;
  except
    on E: Exception do
    begin
      AModuleState.LastError := Format('Exception adding module to JIT: %s', [E.Message]);
      Result := False;
    end;
  end;
end;

procedure TLLVM.RegisterExternalLibrariesWithJIT(const AModuleId: string);
var
  LLibDict: TDictionary<string, Boolean>;
  LLibName: string;
begin
  if FModuleLibraries.TryGetValue(AModuleId, LLibDict) then
  begin
    for LLibName in LLibDict.Keys do
    begin
      // Now JIT is ready, so AddExternalDLL will work
      AddExternalDLL(AModuleId, LLibName);
    end;
  end;
end;

function TLLVM.LookupSymbolFast(const AModuleState: TLLModuleState; const ASymbol: AnsiString): Pointer;
var
  LError: LLVMErrorRef;
  LAddr: LLVMOrcExecutorAddress;
begin
  Result := nil;
  
  if AModuleState.LLJIT = nil then
    Exit;
    
  if ASymbol = '' then
    Exit;
  
  LError := LLVMOrcLLJITLookup(AModuleState.LLJIT, @LAddr, PAnsiChar(ASymbol));
  if LError <> nil then
  begin
    LLVMConsumeError(LError);
    Exit;
  end;

  if LAddr <> 0 then
    Result := Pointer(NativeUInt(LAddr));
end;

function TLLVM.Execute(const AModuleId: string): Integer;
var
  LModuleState: TLLModuleState;
  LMainPtr: Pointer;
  LMainFunction: function(): Integer; cdecl;
begin
  LModuleState := GetModuleState(AModuleId);
  
  // JIT should already be ready - just check
  if not LModuleState.IsJITInitialized then
    raise Exception.CreateFmt('Module %s JIT not initialized - call ValidateModule first', [AModuleId]);
  
  // Fast lookup for main function
  LMainPtr := LookupSymbolFast(LModuleState, 'main');
  if LMainPtr = nil then
    raise Exception.CreateFmt('main function not found in module %s', [AModuleId]);
  
  // Call main function
  LMainFunction := LMainPtr;
  Result := LMainFunction();
end;

function TLLVM.ExecuteFunction(const AModuleId, AFunctionName: string; const AParams: array of const): TValue;
var
  LModuleState: TLLModuleState;
  LFuncPtr: Pointer;
  LFunction: LLVMValueRef;
  LFunctionType: LLVMTypeRef;
  LReturnType: LLVMTypeRef;
  LReturnTypeKind: LLVMTypeKind;
  LResult: UInt64;
  LFloatResult: Single;
  LDoubleResult: Double;
begin
  LModuleState := GetModuleState(AModuleId);
  
  // JIT should already be ready - just check
  if not LModuleState.IsJITInitialized then
    raise Exception.CreateFmt('Module %s JIT not initialized - call ValidateModule first', [AModuleId]);
  
  // Fast lookup - no initialization overhead!
  LFuncPtr := LookupSymbolFast(LModuleState, AnsiString(AFunctionName));
  if LFuncPtr = nil then
    raise Exception.CreateFmt('Function %s not found in module %s', [AFunctionName, AModuleId]);
  
  // Get function metadata to determine return type
  LFunction := LLVMGetNamedFunction(LModuleState.Module, PAnsiChar(AnsiString(AFunctionName)));
  if not Assigned(LFunction) then
    raise Exception.CreateFmt('Function metadata "%s" not found', [AFunctionName]);
    
  LFunctionType := LLVMGlobalGetValueType(LFunction);
  LReturnType := LLVMGetReturnType(LFunctionType);
  LReturnTypeKind := LLVMGetTypeKind(LReturnType);
  
  // Call using appropriate CallXX function based on return type
  case LReturnTypeKind of
    LLVMVoidTypeKind: 
      begin
        TLLUtils.CallI64(LFuncPtr, AParams); // Call but ignore return value
        Result := TValue.Empty;
      end;
    LLVMIntegerTypeKind:
      begin
        LResult := TLLUtils.CallI64(LFuncPtr, AParams);
        Result := TValue.From<UInt64>(LResult);
      end;
    LLVMFloatTypeKind:
      begin
        LFloatResult := TLLUtils.CallF32(LFuncPtr, AParams);
        Result := TValue.From<Single>(LFloatResult);
      end;
    LLVMDoubleTypeKind:
      begin
        LDoubleResult := TLLUtils.CallF64(LFuncPtr, AParams);
        Result := TValue.From<Double>(LDoubleResult);
      end;
  else
    // Default to integer for unknown types
    LResult := TLLUtils.CallI64(LFuncPtr, AParams);
    Result := TValue.From<UInt64>(LResult);
  end;
end;

function TLLVM.AddProcessSymbols(const AModuleId: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LErr: LLVMErrorRef;
  LGen: LLVMOrcDefinitionGeneratorRef;
  LJD: LLVMOrcJITDylibRef;
  LGP: AnsiChar;
  LMsg: PAnsiChar;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not LModuleState.IsJITInitialized then
  begin
    Result := Self;
    Exit;
  end;

  LGP := LLVMOrcLLJITGetGlobalPrefix(LModuleState.LLJIT);
  LErr := LLVMOrcCreateDynamicLibrarySearchGeneratorForProcess(@LGen, LGP, nil, nil);
  if LErr <> nil then
  begin
    LMsg := LLVMGetErrorMessage(LErr);
    if Assigned(LMsg) then
      LLVMDisposeMessage(LMsg);
    LLVMConsumeError(LErr);
    Result := Self;
    Exit;
  end;
  
  LJD := LLVMOrcLLJITGetMainJITDylib(LModuleState.LLJIT);
  LLVMOrcJITDylibAddGenerator(LJD, LGen);
  Result := Self;
end;

function TLLVM.AddExternalDLL(const AModuleId: string; const ADllPath: string): TLLVM;
var
  LModuleState: TLLModuleState;
  LErr: LLVMErrorRef;
  LGen: LLVMOrcDefinitionGeneratorRef;
  LJD: LLVMOrcJITDylibRef;
  LGP: AnsiChar;
  LMsg: PAnsiChar;
begin
  // Add to module's library list (existing functionality)
  AddLibraryToModule(AModuleId, ADllPath);
  
  LModuleState := GetModuleState(AModuleId);
  
  if not LModuleState.IsJITInitialized then
  begin
    Result := Self;
    Exit;
  end;
  
  if ADllPath = '' then
  begin
    Result := Self;
    Exit;
  end;

  LGP := LLVMOrcLLJITGetGlobalPrefix(LModuleState.LLJIT);
  LErr := LLVMOrcCreateDynamicLibrarySearchGeneratorForPath(
            @LGen,
            PAnsiChar(UTF8String(ADllPath)),
            LGP,
            nil,
            nil);
  if LErr <> nil then
  begin
    LMsg := LLVMGetErrorMessage(LErr);
    if Assigned(LMsg) then
    begin
      LLVMDisposeMessage(LMsg);
    end;

    LLVMConsumeError(LErr);
    Result := Self;
    Exit;
  end;
  
  LJD := LLVMOrcLLJITGetMainJITDylib(LModuleState.LLJIT);
  LLVMOrcJITDylibAddGenerator(LJD, LGen);
  Result := Self;
end;

function TLLVM.DefineAbsoluteSymbol(const AModuleId: string; const ASymbol: AnsiString; AAddress: Pointer): TLLVM;
var
  LModuleState: TLLModuleState;
  LName: LLVMOrcSymbolStringPoolEntryRef;
  LFlags: LLVMJITSymbolFlags;
  LEval: LLVMJITEvaluatedSymbol;
  LPair: LLVMOrcCSymbolMapPair;
  LMap: LLVMOrcCSymbolMapPairs;
  LMu: LLVMOrcMaterializationUnitRef;
  LJD: LLVMOrcJITDylibRef;
  LErr: LLVMErrorRef;
  LMsg: PAnsiChar;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if (not LModuleState.IsJITInitialized) or (AAddress = nil) or (ASymbol = '') then
  begin
    Result := Self;
    Exit;
  end;
  
  LName := LLVMOrcLLJITMangleAndIntern(LModuleState.LLJIT, PAnsiChar(ASymbol));
  
  LFlags.GenericFlags := Ord(LLVMJITSymbolGenericFlagsExported) or Ord(LLVMJITSymbolGenericFlagsCallable);
  LFlags.TargetFlags := 0;
  
  LEval.Address := LLVMOrcExecutorAddress(NativeUInt(AAddress));
  LEval.Flags := LFlags;
  
  LPair.Name := LName;
  LPair.Sym := LEval;
  LMap := @LPair;
  
  LMu := LLVMOrcAbsoluteSymbols(LMap, 1);
  LJD := LLVMOrcLLJITGetMainJITDylib(LModuleState.LLJIT);
  
  LErr := LLVMOrcJITDylibDefine(LJD, LMu);
  if LErr <> nil then
  begin
    LMsg := LLVMGetErrorMessage(LErr);
    if Assigned(LMsg) then
      LLVMDisposeMessage(LMsg);
    LLVMConsumeError(LErr);
  end;
  
  Result := Self;
end;

function TLLVM.LookupSymbol(const AModuleId: string; const ASymbol: AnsiString): Pointer;
var
  LModuleState: TLLModuleState;
begin
  LModuleState := GetModuleState(AModuleId);
  
  if not LModuleState.IsJITInitialized then
  begin
    Result := nil;
    Exit;
  end;
  
  Result := LookupSymbolFast(LModuleState, ASymbol);
end;

initialization
  TLLVM.Initialize();

finalization
  TLLVM.Finalize();
end.