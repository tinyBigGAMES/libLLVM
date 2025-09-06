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

{
 Universal Meta-Language IR - High-level language constructs for any programming
 language targeting LLVM. This layer provides language-agnostic programming
 constructs that automatically handle low-level details like basic block
 management.
}

unit libLLVM.MetaLang;

{$I libLLVM.Defines.inc}

interface

uses
  WinApi.Windows,
  System.Types,
  System.SysUtils,
  System.AnsiStrings,
  System.TypInfo,
  System.Classes,
  System.Rtti,
  System.Math,
  System.IOUtils,
  System.Generics.Collections,
  libLLVM.API,
  libLLVM,
  libLLVM.LLD;

type
  { TLLSubsystem }
  TLLSubsystem = (
    ssConsole,      // Console application (shows console window)
    ssGUI           // GUI application (no console window)
  );

  { TLLExportSpec }
  TLLExportSpec = record
    IsExported: Boolean;
    ExportName: string;        // Custom export name (empty = use function name)
    ExportOrdinal: Integer;    // Export by ordinal (0 = no ordinal)
    FunctionName: string;      // Original function name
  end;

  { TLLControlFlowFrame }
  TLLControlFlowFrame = record
    FrameType: string;         // 'if', 'while', 'for', etc.
    ThenLabel: string;         // If: then block
    ElseLabel: string;         // If: else block  
    EndLabel: string;          // If: end block / Loop: exit block
    HeaderLabel: string;       // Loop: header block
    BodyLabel: string;         // Loop: body block
    IteratorName: string;      // For loop: iterator variable name
  end;

  { TLLMetaLang }
  TLLMetaLang = class
  private
    FLLVM: TLLVM;
    FControlStack: TStack<TLLControlFlowFrame>;
    FCurrentFunction: string;  // Track current function being declared
    FExportedFunctions: TDictionary<string, TArray<TLLExportSpec>>;  // ModuleId -> Exported functions
    
    function GenerateUniqueLabel(const APrefix: string): string;
    procedure PushControlFlow(const AFrameType: string);
    procedure PopControlFlow();
    function GetCurrentControlFlow(): TLLControlFlowFrame;
    function GetExportedFunctionsForModule(const AModuleId: string): TArray<TLLExportSpec>;

    // DLL entry point management
    function HasDllMain(const AModuleId: string): Boolean;
    procedure EnsureDllMain(const AModuleId: string);

  public
    constructor Create();
    destructor Destroy(); override;

    //=== MODULE MANAGEMENT ===================================================
    function CreateModule(const AModuleId: string; const AShareContextWith: string = ''): TLLMetaLang;
    function DeleteModule(const AModuleId: string): TLLMetaLang;
    function ModuleExists(const AModuleId: string): Boolean;
    function MergeModules(const ATargetId: string; const ASourceIds: array of string): TLLMetaLang;
    function ValidateModule(const AModuleId: string): Boolean;
    function GetModuleIR(const AModuleId: string): string;
    function CompileModuleToObject(const AModuleId: string; const AOutputPath: string = ''; const AOptLevel: TLLOptimization = olSpeed): string;

    //=== FUNCTION DECLARATION ================================================
    function BeginFunction(const AModuleId: string; const AFunctionName: string; const AReturnType: TLLDataType;
      const AParams: array of TLLParam; const AVisibility: TLLVisibility = vPublic;
      const ACallingConv: TLLCallingConv = ccCDecl; const AIsVarArgs: Boolean = False;
      const AExternalLib: string = ''): TLLMetaLang;
    function Param(const AParamName: string; const AParamType: TLLDataType): TLLParam;
    function EndFunction(const AModuleId: string): TLLMetaLang;
    function MarkAsExported(const AModuleId: string; const ACustomName: string = ''; const AOrdinal: Integer = 0): TLLMetaLang;

    //=== VARIABLES ===========================================================
     function DeclareGlobal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType;
      const AInitialValue: TValue): TLLMetaLang; overload;
    function DeclareGlobal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType): TLLMetaLang; overload;
    function DeclareLocal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType): TLLMetaLang;
    function GetVariable(const AModuleId: string; const AVarName: string): TValue;
    function SetVariable(const AModuleId: string; const AVarName: string; const AValue: TValue): TLLMetaLang;
    function GetParameter(const AModuleId: string; const AParameterName: string): TValue;

    // VALUE CREATION
    function IntegerValue(const AModuleId: string; const AValue: Int64; const ABitWidth: TLLDataType = dtInt32): TValue;
    function FloatValue(const AModuleId: string; const AValue: Double; const AFloatType: TLLDataType = dtFloat64): TValue;
    function StringValue(const AModuleId: string; const AText: string): TValue;
    function BooleanValue(const AModuleId: string; const AValue: Boolean): TValue;
    function NullValue(const AModuleId: string; const ANullType: TLLDataType): TValue;

    // MATH OPERATIONS
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

    // Comparisons
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

    //=== CONTROL FLOW ========================================================
    function ReturnValue(const AModuleId: string; const AValue: TValue): TLLMetaLang; overload;
    function ReturnValue(const AModuleId: string): TLLMetaLang; overload;

    // If statements - auto-creates and manages blocks
    function IfCondition(const AModuleId: string; const ACondition: TValue): TLLMetaLang;
    function ThenBranch(const AModuleId: string): TLLMetaLang;
    function ElseBranch(const AModuleId: string): TLLMetaLang;
    function EndIf(const AModuleId: string): TLLMetaLang;

    // While loops - auto-creates and manages blocks
    function WhileLoop(const AModuleId: string; const ACondition: TValue): TLLMetaLang;
    function EndWhile(const AModuleId: string): TLLMetaLang;

    // For loops - auto-creates iterator variable and manages blocks
    function ForLoop(const AModuleId: string; const AIteratorName: string; const AStart: TValue; const AEnd: TValue; const AStep: TValue): TLLMetaLang; overload;
    function ForLoop(const AModuleId: string; const AIteratorName: string; const AStart: TValue; const AEnd: TValue): TLLMetaLang; overload;
    function EndFor(const AModuleId: string): TLLMetaLang;

    // Loop control
    function BreakLoop(const AModuleId: string): TLLMetaLang;
    function ContinueLoop(const AModuleId: string): TLLMetaLang;

    // Manual block control (when needed)
    function BeginBlock(const AModuleId: string; const ABlockLabel: string): TLLMetaLang;
    function DeclareBlock(const AModuleId: string; const ABlockLabel: string): TLLMetaLang;
    function EndBlock(const AModuleId: string): TLLMetaLang;
    function Jump(const AModuleId: string; const ABlockLabel: string): TLLMetaLang;
    function JumpIf(const AModuleId: string; const ACondition: TValue; const ATrueBlock: string; const AFalseBlock: string): TLLMetaLang;

    //=== FUNCTION CALLS ======================================================
    function CallFunction(const AModuleId: string; const AFunctionName: string; const AArgs: array of const;
      const AValueName: string = ''): TValue; overload;
    function CallFunction(const AModuleId: string; const AFunctionName: string; const AArgs: array of TValue;
      const AValueName: string = ''): TValue; overload;
    function HasFunction(const AModuleId: string; const AFunctionName: string): Boolean;

    //=== MEMORY OPERATIONS ===================================================
    function AllocateArray(const AModuleId: string; const AElementType: TLLDataType; const ASize: TValue; const AValueName: string = ''): TValue;
    function GetElementPtr(const AModuleId: string; const APtr: TValue; const AIndices: array of TValue; const AValueName: string = ''): TValue;
    function LoadValue(const AModuleId: string; const APtr: TValue; const AValueName: string = ''): TValue;
    function StoreValue(const AModuleId: string; const AValue: TValue; const APtr: TValue): TLLMetaLang;

    // PHI nodes for SSA form
    function CreatePhi(const AModuleId: string; const AType: TLLDataType; const AValueName: string = ''): TValue;
    function AddPhiIncoming(const AModuleId: string; const APhi: TValue; const AValue: TValue; const ABlock: string): TLLMetaLang;

    //=== JIT EXECUTION =======================================================
    function Execute(const AModuleId: string): Integer;
    function ExecuteFunction(const AModuleId, AFunctionName: string; const AParams: array of const): TValue;
    function AddProcessSymbols(const AModuleId: string): TLLMetaLang;
    function AddExternalDLL(const AModuleId: string; const ADllPath: string): TLLMetaLang;
    function DefineAbsoluteSymbol(const AModuleId: string; const ASymbol: AnsiString; AAddress: Pointer): TLLMetaLang;
    function LookupSymbol(const AModuleId: string; const ASymbol: AnsiString): Pointer;

    //=== LINKING METHODS =====================================================
    // Object file linking
    function LinkToDLL(
      const AObjectFiles: array of string;
      const AOutputDLL: string;
      const AObjOutputPath: string;
      const AExternalLibs: array of string;
      const ALibraryPaths: array of string;
      const AOptLevel: TLLOptimization;
      const AImportLibPath: string;
      out AStdOut: string;
      out AStdErr: string;
      out AResult: Integer
    ): TLLMetaLang;

    function LinkToExecutable(
      const AObjectFiles: array of string; 
      const AOutputExe: string; 
      const AObjOutputPath: string;
      const AEntryPoint: string;
      const ASubsystem: TLLSubsystem;
      const AExternalLibs: array of string;
      const ALibraryPaths: array of string;
      const AOptLevel: TLLOptimization;
      out AStdOut: string;
      out AStdErr: string;
      out AResult: Integer
    ): TLLMetaLang;

    // Directory-based linking
    function LinkObjectDirectory(
      const ADirectoryPath: string;
      const AOutputPath: string;
      const AObjOutputPath: string;
      const AIsDLL: Boolean;
      const ASubsystem: TLLSubsystem;
      const AExternalLibs: array of string;
      const ALibraryPaths: array of string;
      const AOptLevel: TLLOptimization;
      const AImportLibPath: string;
      out AStdOut: string;
      out AStdErr: string;
      out AResult: Integer
    ): TLLMetaLang;

    // Module-based linking (automatically uses exported functions)
    function LinkModuleToDLL(
      const AModuleId: string; 
      const AOutputDLL: string; 
      const AObjOutputPath: string;
      const AExternalLibs: array of string;
      const ALibraryPaths: array of string;
      const AOptLevel: TLLOptimization;
      const AImportLibPath: string;
      out AStdOut: string;
      out AStdErr: string;
      out AResult: Integer
    ): TLLMetaLang;

    function LinkModuleToExecutable(
      const AModuleId: string;
      const AOutputExe: string;
      const AObjOutputPath: string;
      const ASubsystem: TLLSubsystem;
      const AExternalLibs: array of string;
      const ALibraryPaths: array of string;
      const AOptLevel: TLLOptimization;
      out AStdOut: string;
      out AStdErr: string;
      out AResult: Integer
    ): TLLMetaLang;

    // Multi-module linking (automatically uses exported functions)
    function LinkAllModulesToExecutable(
      const AObjectOutputDir: string;
      const AOutputExe: string;
      const AObjOutputPath: string;
      const ASubsystem: TLLSubsystem;
      const AExternalLibs: array of string;
      const ALibraryPaths: array of string;
      const AOptLevel: TLLOptimization;
      out AStdOut: string;
      out AStdErr: string;
      out AResult: Integer
    ): TLLMetaLang;
    
    function LinkAllModulesToDLL(
      const AObjectOutputDir: string;
      const AOutputDLL: string;
      const AObjOutputPath: string;
      const AExternalLibs: array of string;
      const ALibraryPaths: array of string;
      const AOptLevel: TLLOptimization;
      const AImportLibPath: string;
      out AStdOut: string;
      out AStdErr: string;
      out AResult: Integer
    ): TLLMetaLang;
    
    //=== UTILITY METHODS =====================================================

    function GetLLVM(): TLLVM;
  end;

implementation

{ TLLMetaLang }
constructor TLLMetaLang.Create();
begin
  inherited Create();
  FLLVM := TLLVM.Create();
  FControlStack := TStack<TLLControlFlowFrame>.Create();
  FExportedFunctions := TDictionary<string, TArray<TLLExportSpec>>.Create();
  FCurrentFunction := '';
end;

destructor TLLMetaLang.Destroy();
begin
  // Clean up control flow stack
  while FControlStack.Count > 0 do
    FControlStack.Pop();
  FControlStack.Free();
  
  FExportedFunctions.Free();
  
  // Clean up internal TLLVM instance
  FLLVM.Free();
  
  inherited Destroy();
end;

function TLLMetaLang.GenerateUniqueLabel(const APrefix: string): string;
begin
  Result := Format('%s_%d', [APrefix, Random(999999)]);
end;

procedure TLLMetaLang.PushControlFlow(const AFrameType: string);
var
  LFrame: TLLControlFlowFrame;
begin
  LFrame.FrameType := AFrameType;
  LFrame.ThenLabel := '';
  LFrame.ElseLabel := '';
  LFrame.EndLabel := '';
  LFrame.HeaderLabel := '';
  LFrame.BodyLabel := '';
  LFrame.IteratorName := '';
  FControlStack.Push(LFrame);
end;

procedure TLLMetaLang.PopControlFlow();
begin
  if FControlStack.Count = 0 then
    raise Exception.Create('Cannot pop control flow - control stack is empty');
  FControlStack.Pop();
end;

function TLLMetaLang.GetCurrentControlFlow(): TLLControlFlowFrame;
begin
  if FControlStack.Count = 0 then
    raise Exception.Create('No current control flow available');
  Result := FControlStack.Peek();
end;

function TLLMetaLang.GetExportedFunctionsForModule(const AModuleId: string): TArray<TLLExportSpec>;
begin
  if not FExportedFunctions.TryGetValue(AModuleId, Result) then
    SetLength(Result, 0);
end;

function TLLMetaLang.HasDllMain(const AModuleId: string): Boolean;
begin
  Result := FLLVM.HasFunction(AModuleId, 'DllMain');
end;

procedure TLLMetaLang.EnsureDllMain(const AModuleId: string);
var
  LParams: array of TLLParam;
begin
  // Only inject DllMain if it doesn't already exist
  if not HasDllMain(AModuleId) then
  begin
    // Create parameters for DllMain(HINSTANCE hinst, DWORD reason, LPVOID reserved)
    SetLength(LParams, 3);
    LParams[0] := FLLVM.Param('hinst', dtPointer);     // HINSTANCE
    LParams[1] := FLLVM.Param('reason', dtInt32);      // DWORD
    LParams[2] := FLLVM.Param('reserved', dtPointer);  // LPVOID
    
    // Declare and implement minimal DllMain
    FLLVM.BeginFunction(AModuleId, 'DllMain', dtInt32, LParams, vPublic, ccCDecl);
    FLLVM.DeclareBlock(AModuleId, 'entry');
    FLLVM.BeginBlock(AModuleId, 'entry');
    FLLVM.ReturnValue(AModuleId, FLLVM.IntegerValue(AModuleId, 1)); // Always return 1 (success)
    FLLVM.EndFunction(AModuleId);
  end;
end;

//=== MODULE MANAGEMENT =======================================================
function TLLMetaLang.CreateModule(const AModuleId: string; const AShareContextWith: string): TLLMetaLang;
begin
  FLLVM.CreateModule(AModuleId, AShareContextWith);
  Result := Self;
end;

function TLLMetaLang.DeleteModule(const AModuleId: string): TLLMetaLang;
begin
  FLLVM.DeleteModule(AModuleId);
  Result := Self;
end;

function TLLMetaLang.ModuleExists(const AModuleId: string): Boolean;
begin
  Result := FLLVM.ModuleExists(AModuleId);
end;

function TLLMetaLang.MergeModules(const ATargetId: string; const ASourceIds: array of string): TLLMetaLang;
begin
  FLLVM.MergeModules(ATargetId, ASourceIds);
  Result := Self;
end;

function TLLMetaLang.ValidateModule(const AModuleId: string): Boolean;
begin
  Result := FLLVM.ValidateModule(AModuleId);
end;

function TLLMetaLang.GetModuleIR(const AModuleId: string): string;
begin
  Result := FLLVM.GetModuleIR(AModuleId);
end;

function TLLMetaLang.CompileModuleToObject(const AModuleId: string; const AOutputPath: string; const AOptLevel: TLLOptimization): string;
begin
  Result := FLLVM.CompileModuleToObject(AModuleId, AOutputPath, AOptLevel);
end;

//=== FUNCTION DECLARATION ====================================================
function TLLMetaLang.BeginFunction(const AModuleId: string; const AFunctionName: string; const AReturnType: TLLDataType;
  const AParams: array of TLLParam; const AVisibility: TLLVisibility; const ACallingConv: TLLCallingConv;
  const AIsVarArgs: Boolean; const AExternalLib: string): TLLMetaLang;
begin
  // Use TLLVM to declare the function
  FLLVM.BeginFunction(AModuleId, AFunctionName, AReturnType, AParams, AVisibility, ACallingConv, AIsVarArgs, AExternalLib);
  
  // For non-external functions, auto-create and begin entry block
  if AVisibility <> vExternal then
  begin
    FLLVM.DeclareBlock(AModuleId, 'entry');
    FLLVM.BeginBlock(AModuleId, 'entry');
  end;
  
  // Track current function for potential export marking
  FCurrentFunction := AFunctionName;
  
  Result := Self;
end;

function TLLMetaLang.Param(const AParamName: string; const AParamType: TLLDataType): TLLParam;
begin
  Result := FLLVM.Param(AParamName, AParamType);
end;

function TLLMetaLang.EndFunction(const AModuleId: string): TLLMetaLang;
begin
  FLLVM.EndFunction(AModuleId);
  
  // Clear current function tracking
  FCurrentFunction := '';
  
  Result := Self;
end;

function TLLMetaLang.MarkAsExported(const AModuleId: string; const ACustomName: string; const AOrdinal: Integer): TLLMetaLang;
var
  LExportSpec: TLLExportSpec;
  LExports: TArray<TLLExportSpec>;
begin
  if FCurrentFunction = '' then
    raise Exception.Create('MarkAsExported can only be called within a function declaration');
  
  // Create export specification
  LExportSpec.IsExported := True;
  LExportSpec.FunctionName := FCurrentFunction;
  LExportSpec.ExportName := ACustomName;
  LExportSpec.ExportOrdinal := AOrdinal;
  
  // Get existing exports for this module
  if not FExportedFunctions.TryGetValue(AModuleId, LExports) then
    SetLength(LExports, 0);
  
  // Add this export
  SetLength(LExports, Length(LExports) + 1);
  LExports[High(LExports)] := LExportSpec;
  
  // Update the dictionary
  FExportedFunctions.AddOrSetValue(AModuleId, LExports);
  
  Result := Self;
end;

//=== VARIABLES ===============================================================
function TLLMetaLang.DeclareGlobal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType; const AInitialValue: TValue): TLLMetaLang;
begin
  FLLVM.DeclareGlobal(AModuleId, AVarName, AVarType, AInitialValue);
  Result := Self;
end;

function TLLMetaLang.DeclareGlobal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType): TLLMetaLang;
begin
  FLLVM.DeclareGlobal(AModuleId, AVarName, AVarType);
  Result := Self;
end;

function TLLMetaLang.DeclareLocal(const AModuleId: string; const AVarName: string; const AVarType: TLLDataType): TLLMetaLang;
begin
  FLLVM.DeclareLocal(AModuleId, AVarName, AVarType);
  Result := Self;
end;

function TLLMetaLang.GetVariable(const AModuleId: string; const AVarName: string): TValue;
begin
  Result := FLLVM.GetValue(AModuleId, AVarName);
end;

function TLLMetaLang.SetVariable(const AModuleId: string; const AVarName: string; const AValue: TValue): TLLMetaLang;
begin
  FLLVM.SetValue(AModuleId, AVarName, AValue);
  Result := Self;
end;

function TLLMetaLang.GetParameter(const AModuleId: string; const AParameterName: string): TValue;
begin
  Result := FLLVM.GetParameter(AModuleId, AParameterName);
end;

//=== VALUE CREATION ==========================================================
function TLLMetaLang.IntegerValue(const AModuleId: string; const AValue: Int64; const ABitWidth: TLLDataType): TValue;
begin
  Result := FLLVM.IntegerValue(AModuleId, AValue, ABitWidth);
end;

function TLLMetaLang.FloatValue(const AModuleId: string; const AValue: Double; const AFloatType: TLLDataType): TValue;
begin
  Result := FLLVM.FloatValue(AModuleId, AValue, AFloatType);
end;

function TLLMetaLang.StringValue(const AModuleId: string; const AText: string): TValue;
begin
  Result := FLLVM.StringValue(AModuleId, AText);
end;

function TLLMetaLang.BooleanValue(const AModuleId: string; const AValue: Boolean): TValue;
begin
  Result := FLLVM.BooleanValue(AModuleId, AValue);
end;

function TLLMetaLang.NullValue(const AModuleId: string; const ANullType: TLLDataType): TValue;
begin
  Result := FLLVM.NullValue(AModuleId, ANullType);
end;

//=== MATH OPERATIONS =========================================================
function TLLMetaLang.Add(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.Add(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.Subtract(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.Subtract(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.Multiply(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.Multiply(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.Divide(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.Divide(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.Modulo(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.Modulo(AModuleId, ALeft, ARight, AValueName);
end;

// Floating point operations
function TLLMetaLang.FAdd(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FAdd(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.FSub(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FSub(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.FMul(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FMul(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.FDiv(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FDiv(AModuleId, ALeft, ARight, AValueName);
end;

// Bitwise operations
function TLLMetaLang.BitwiseAnd(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.BitwiseAnd(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.BitwiseOr(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.BitwiseOr(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.BitwiseXor(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.BitwiseXor(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.BitwiseNot(const AModuleId: string; const AValue: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.BitwiseNot(AModuleId, AValue, AValueName);
end;

function TLLMetaLang.ShiftLeft(const AModuleId: string; const AValue: TValue; const AShift: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.ShiftLeft(AModuleId, AValue, AShift, AValueName);
end;

function TLLMetaLang.ShiftRight(const AModuleId: string; const AValue: TValue; const AShift: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.ShiftRight(AModuleId, AValue, AShift, AValueName);
end;

// Comparisons
function TLLMetaLang.IsEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.IsEqual(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.IsNotEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.IsNotEqual(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.IsLess(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.IsLess(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.IsLessEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.IsLessEqual(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.IsGreater(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.IsGreater(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.IsGreaterEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.IsGreaterEqual(AModuleId, ALeft, ARight, AValueName);
end;

// Floating point comparisons
function TLLMetaLang.FIsEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FIsEqual(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.FIsNotEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FIsNotEqual(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.FIsLess(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FIsLess(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.FIsLessEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FIsLessEqual(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.FIsGreater(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FIsGreater(AModuleId, ALeft, ARight, AValueName);
end;

function TLLMetaLang.FIsGreaterEqual(const AModuleId: string; const ALeft: TValue; const ARight: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.FIsGreaterEqual(AModuleId, ALeft, ARight, AValueName);
end;

// Type conversions
function TLLMetaLang.IntCast(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string): TValue;
begin
  Result := FLLVM.IntCast(AModuleId, AValue, ATargetType, AValueName);
end;

function TLLMetaLang.FloatCast(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string): TValue;
begin
  Result := FLLVM.FloatCast(AModuleId, AValue, ATargetType, AValueName);
end;

function TLLMetaLang.IntToFloat(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string): TValue;
begin
  Result := FLLVM.IntToFloat(AModuleId, AValue, ATargetType, AValueName);
end;

function TLLMetaLang.FloatToInt(const AModuleId: string; const AValue: TValue; const ATargetType: TLLDataType; const AValueName: string): TValue;
begin
  Result := FLLVM.FloatToInt(AModuleId, AValue, ATargetType, AValueName);
end;

//=== CONTROL FLOW ============================================================
function TLLMetaLang.ReturnValue(const AModuleId: string; const AValue: TValue): TLLMetaLang;
begin
  FLLVM.ReturnValue(AModuleId, AValue);
  Result := Self;
end;

function TLLMetaLang.ReturnValue(const AModuleId: string): TLLMetaLang;
begin
  FLLVM.ReturnValue(AModuleId);
  Result := Self;
end;

// If statements - auto-creates and manages blocks
function TLLMetaLang.IfCondition(const AModuleId: string; const ACondition: TValue): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
begin
  // Create new control flow frame
  PushControlFlow('if');
  LFrame := FControlStack.Peek();
  
  // Generate unique labels
  LFrame.ThenLabel := GenerateUniqueLabel('if_then');
  LFrame.ElseLabel := GenerateUniqueLabel('if_else');
  LFrame.EndLabel := GenerateUniqueLabel('if_end');
  
  // Update the frame on the stack
  FControlStack.Pop();
  FControlStack.Push(LFrame);
  
  // Declare all blocks
  FLLVM.DeclareBlock(AModuleId, LFrame.ThenLabel);
  FLLVM.DeclareBlock(AModuleId, LFrame.ElseLabel);
  FLLVM.DeclareBlock(AModuleId, LFrame.EndLabel);
  
  // Conditional jump
  FLLVM.JumpIf(AModuleId, ACondition, LFrame.ThenLabel, LFrame.ElseLabel);
  
  Result := Self;
end;

function TLLMetaLang.ThenBranch(const AModuleId: string): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
begin
  LFrame := GetCurrentControlFlow();
  
  if LFrame.FrameType <> 'if' then
    raise Exception.Create('ThenBranch called but current control flow is not an if statement');
  
  // Begin then block
  FLLVM.BeginBlock(AModuleId, LFrame.ThenLabel);
  
  Result := Self;
end;

function TLLMetaLang.ElseBranch(const AModuleId: string): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
begin
  LFrame := GetCurrentControlFlow();
  
  if LFrame.FrameType <> 'if' then
    raise Exception.Create('ElseBranch called but current control flow is not an if statement');
  
  // Jump to end from then branch
  FLLVM.Jump(AModuleId, LFrame.EndLabel);
  
  // Begin else block
  FLLVM.BeginBlock(AModuleId, LFrame.ElseLabel);
  
  Result := Self;
end;

function TLLMetaLang.EndIf(const AModuleId: string): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
begin
  LFrame := GetCurrentControlFlow();
  
  if LFrame.FrameType <> 'if' then
    raise Exception.Create('EndIf called but current control flow is not an if statement');
  
  // Jump to end (in case we're ending a then branch without else)
  FLLVM.Jump(AModuleId, LFrame.EndLabel);
  
  // Begin end block
  FLLVM.BeginBlock(AModuleId, LFrame.EndLabel);
  
  // Clean up control flow
  PopControlFlow();
  
  Result := Self;
end;

// While loops - auto-creates and manages blocks
function TLLMetaLang.WhileLoop(const AModuleId: string; const ACondition: TValue): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
begin
  // Create new control flow frame
  PushControlFlow('while');
  LFrame := FControlStack.Peek();
  
  // Generate unique labels
  LFrame.HeaderLabel := GenerateUniqueLabel('while_header');
  LFrame.BodyLabel := GenerateUniqueLabel('while_body');
  LFrame.EndLabel := GenerateUniqueLabel('while_exit');
  
  // Update the frame on the stack
  FControlStack.Pop();
  FControlStack.Push(LFrame);
  
  // Declare blocks
  FLLVM.DeclareBlock(AModuleId, LFrame.HeaderLabel);
  FLLVM.DeclareBlock(AModuleId, LFrame.BodyLabel);
  FLLVM.DeclareBlock(AModuleId, LFrame.EndLabel);
  
  // Jump to header to start loop
  FLLVM.Jump(AModuleId, LFrame.HeaderLabel);
  
  // Begin header block - check condition
  FLLVM.BeginBlock(AModuleId, LFrame.HeaderLabel);
  FLLVM.JumpIf(AModuleId, ACondition, LFrame.BodyLabel, LFrame.EndLabel);
  
  // Begin body block
  FLLVM.BeginBlock(AModuleId, LFrame.BodyLabel);
  
  Result := Self;
end;

function TLLMetaLang.EndWhile(const AModuleId: string): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
begin
  LFrame := GetCurrentControlFlow();
  
  if LFrame.FrameType <> 'while' then
    raise Exception.Create('EndWhile called but current control flow is not a while loop');
  
  // Jump back to header to check condition again
  FLLVM.Jump(AModuleId, LFrame.HeaderLabel);
  
  // Begin exit block
  FLLVM.BeginBlock(AModuleId, LFrame.EndLabel);
  
  // Clean up control flow
  PopControlFlow();
  
  Result := Self;
end;

// For loops - auto-creates iterator variable and manages blocks
function TLLMetaLang.ForLoop(const AModuleId: string; const AIteratorName: string; const AStart: TValue; const AEnd: TValue; const AStep: TValue): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
  LIteratorValue: TValue;
  LCondition: TValue;
begin
  // Create new control flow frame
  PushControlFlow('for');
  LFrame := FControlStack.Peek();
  
  // Generate unique labels
  LFrame.HeaderLabel := GenerateUniqueLabel('for_header');
  LFrame.BodyLabel := GenerateUniqueLabel('for_body');
  LFrame.EndLabel := GenerateUniqueLabel('for_exit');
  LFrame.IteratorName := AIteratorName;
  
  // Update the frame on the stack
  FControlStack.Pop();
  FControlStack.Push(LFrame);
  
  // Declare blocks
  FLLVM.DeclareBlock(AModuleId, LFrame.HeaderLabel);
  FLLVM.DeclareBlock(AModuleId, LFrame.BodyLabel);
  FLLVM.DeclareBlock(AModuleId, LFrame.EndLabel);
  
  // Create and initialize iterator variable
  FLLVM.DeclareLocal(AModuleId, AIteratorName, dtInt32);
  FLLVM.SetValue(AModuleId, AIteratorName, AStart);
  
  // Jump to header to start loop
  FLLVM.Jump(AModuleId, LFrame.HeaderLabel);
  
  // Begin header block - check condition (iterator < end)
  FLLVM.BeginBlock(AModuleId, LFrame.HeaderLabel);
  LIteratorValue := FLLVM.GetValue(AModuleId, AIteratorName);
  LCondition := FLLVM.IsLess(AModuleId, LIteratorValue, AEnd);
  FLLVM.JumpIf(AModuleId, LCondition, LFrame.BodyLabel, LFrame.EndLabel);
  
  // Begin body block
  FLLVM.BeginBlock(AModuleId, LFrame.BodyLabel);
  
  Result := Self;
end;

function TLLMetaLang.ForLoop(const AModuleId: string; const AIteratorName: string; const AStart: TValue; const AEnd: TValue): TLLMetaLang;
begin
  Result := ForLoop(AModuleId, AIteratorName, AStart, AEnd, FLLVM.IntegerValue(AModuleId, 1));
end;

function TLLMetaLang.EndFor(const AModuleId: string): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
  LIteratorValue: TValue;
  LStepValue: TValue;
  LNewValue: TValue;
begin
  LFrame := GetCurrentControlFlow();
  
  if LFrame.FrameType <> 'for' then
    raise Exception.Create('EndFor called but current control flow is not a for loop');
  
  // Increment iterator (add step value)
  LIteratorValue := FLLVM.GetValue(AModuleId, LFrame.IteratorName);
  LStepValue := FLLVM.IntegerValue(AModuleId, 1); // Default step
  LNewValue := FLLVM.Add(AModuleId, LIteratorValue, LStepValue);
  FLLVM.SetValue(AModuleId, LFrame.IteratorName, LNewValue);
  
  // Jump back to header to check condition again
  FLLVM.Jump(AModuleId, LFrame.HeaderLabel);
  
  // Begin exit block
  FLLVM.BeginBlock(AModuleId, LFrame.EndLabel);
  
  // Clean up control flow
  PopControlFlow();
  
  Result := Self;
end;

// Loop control
function TLLMetaLang.BreakLoop(const AModuleId: string): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
begin
  LFrame := GetCurrentControlFlow();
  
  if (LFrame.FrameType <> 'while') and (LFrame.FrameType <> 'for') then
    raise Exception.Create('BreakLoop can only be called within a loop');
  
  // Jump to loop exit
  FLLVM.Jump(AModuleId, LFrame.EndLabel);
  
  Result := Self;
end;

function TLLMetaLang.ContinueLoop(const AModuleId: string): TLLMetaLang;
var
  LFrame: TLLControlFlowFrame;
begin
  LFrame := GetCurrentControlFlow();
  
  if (LFrame.FrameType <> 'while') and (LFrame.FrameType <> 'for') then
    raise Exception.Create('ContinueLoop can only be called within a loop');
  
  // Jump to loop header to continue with next iteration
  FLLVM.Jump(AModuleId, LFrame.HeaderLabel);
  
  Result := Self;
end;

// Manual block control (when needed) - Direct delegation to TLLVM
function TLLMetaLang.BeginBlock(const AModuleId: string; const ABlockLabel: string): TLLMetaLang;
begin
  FLLVM.BeginBlock(AModuleId, ABlockLabel);
  Result := Self;
end;

function TLLMetaLang.DeclareBlock(const AModuleId: string; const ABlockLabel: string): TLLMetaLang;
begin
  FLLVM.DeclareBlock(AModuleId, ABlockLabel);
  Result := Self;
end;

function TLLMetaLang.EndBlock(const AModuleId: string): TLLMetaLang;
begin
  FLLVM.EndBlock(AModuleId);
  Result := Self;
end;

function TLLMetaLang.Jump(const AModuleId: string; const ABlockLabel: string): TLLMetaLang;
begin
  FLLVM.Jump(AModuleId, ABlockLabel);
  Result := Self;
end;

function TLLMetaLang.JumpIf(const AModuleId: string; const ACondition: TValue; const ATrueBlock: string; const AFalseBlock: string): TLLMetaLang;
begin
  FLLVM.JumpIf(AModuleId, ACondition, ATrueBlock, AFalseBlock);
  Result := Self;
end;

//=== FUNCTION CALLS ==========================================================
function TLLMetaLang.CallFunction(const AModuleId: string; const AFunctionName: string; const AArgs: array of const; const AValueName: string): TValue;
begin
  Result := FLLVM.CallFunction(AModuleId, AFunctionName, AArgs, AValueName);
end;

function TLLMetaLang.CallFunction(const AModuleId: string; const AFunctionName: string; const AArgs: array of TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.CallFunction(AModuleId, AFunctionName, AArgs, AValueName);
end;

function TLLMetaLang.HasFunction(const AModuleId: string; const AFunctionName: string): Boolean;
begin
  Result := FLLVM.HasFunction(AModuleId, AFunctionName);
end;

//=== MEMORY OPERATIONS =======================================================
function TLLMetaLang.AllocateArray(const AModuleId: string; const AElementType: TLLDataType; const ASize: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.AllocateArray(AModuleId, AElementType, ASize, AValueName);
end;

function TLLMetaLang.GetElementPtr(const AModuleId: string; const APtr: TValue; const AIndices: array of TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.GetElementPtr(AModuleId, APtr, AIndices, AValueName);
end;

function TLLMetaLang.LoadValue(const AModuleId: string; const APtr: TValue; const AValueName: string): TValue;
begin
  Result := FLLVM.LoadValue(AModuleId, APtr, AValueName);
end;

function TLLMetaLang.StoreValue(const AModuleId: string; const AValue: TValue; const APtr: TValue): TLLMetaLang;
begin
  FLLVM.StoreValue(AModuleId, AValue, APtr);
  Result := Self;
end;

// PHI nodes for SSA form
function TLLMetaLang.CreatePhi(const AModuleId: string; const AType: TLLDataType; const AValueName: string): TValue;
begin
  Result := FLLVM.CreatePhi(AModuleId, AType, AValueName);
end;

function TLLMetaLang.AddPhiIncoming(const AModuleId: string; const APhi: TValue; const AValue: TValue; const ABlock: string): TLLMetaLang;
begin
  FLLVM.AddPhiIncoming(AModuleId, APhi, AValue, ABlock);
  Result := Self;
end;

//=== JIT EXECUTION ===========================================================
function TLLMetaLang.Execute(const AModuleId: string): Integer;
begin
  Result := FLLVM.Execute(AModuleId);
end;

function TLLMetaLang.ExecuteFunction(const AModuleId, AFunctionName: string; const AParams: array of const): TValue;
begin
  Result := FLLVM.ExecuteFunction(AModuleId, AFunctionName, AParams);
end;

function TLLMetaLang.AddProcessSymbols(const AModuleId: string): TLLMetaLang;
begin
  FLLVM.AddProcessSymbols(AModuleId);
  Result := Self;
end;

function TLLMetaLang.AddExternalDLL(const AModuleId: string; const ADllPath: string): TLLMetaLang;
begin
  FLLVM.AddExternalDLL(AModuleId, ADllPath);
  Result := Self;
end;

function TLLMetaLang.DefineAbsoluteSymbol(const AModuleId: string; const ASymbol: AnsiString; AAddress: Pointer): TLLMetaLang;
begin
  FLLVM.DefineAbsoluteSymbol(AModuleId, ASymbol, AAddress);
  Result := Self;
end;

function TLLMetaLang.LookupSymbol(const AModuleId: string; const ASymbol: AnsiString): Pointer;
begin
  Result := FLLVM.LookupSymbol(AModuleId, ASymbol);
end;

//=== LINKING =================================================================

// Object file linking
function TLLMetaLang.LinkToDLL(
  const AObjectFiles: array of string; 
  const AOutputDLL: string; 
  const AObjOutputPath: string;
  const AExternalLibs: array of string;
  const ALibraryPaths: array of string;
  const AOptLevel: TLLOptimization;
  const AImportLibPath: string;
  out AStdOut: string;
  out AStdErr: string;
  out AResult: Integer
): TLLMetaLang;
var
  LArgs: TArray<string>;
  LObjectFile: string;
  LLibraryPath: string;
  LExternalLib: string;
  LCan: Boolean;
begin
  // Build LLD arguments for DLL creation
  SetLength(LArgs, 0);
  
  // Add linker and basic flags
  LArgs := LArgs + ['lld-link'];
  LArgs := LArgs + ['/verbose'];
  LArgs := LArgs + ['/nologo'];
  LArgs := LArgs + ['/DLL'];
  LArgs := LArgs + ['/OUT:' + AOutputDLL];
  
  // Add object files
  for LObjectFile in AObjectFiles do
    LArgs := LArgs + [LObjectFile];
  
  // Add library search paths
  for LLibraryPath in ALibraryPaths do
    LArgs := LArgs + ['/LIBPATH:' + LLibraryPath];
  
  // Add external libraries
  for LExternalLib in AExternalLibs do
    LArgs := LArgs + ['/DEFAULTLIB:' + LExternalLib];
  
  // Add import library path if specified
  if AImportLibPath <> '' then
  begin
    // Ensure directory exists for import library
    TDirectory.CreateDirectory(AImportLibPath);
    // Create full import library path: path + dllname.lib
    LArgs := LArgs + ['/IMPLIB:' + TPath.Combine(AImportLibPath, TPath.ChangeExtension(TPath.GetFileName(AOutputDLL), '.lib'))];
  end;
  
  // Add optimization flags based on AOptLevel
  case AOptLevel of
    olDebug: LArgs := LArgs + ['/DEBUG', '/OPT:NOREF', '/OPT:NOICF'];
    olSize: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF'];
    olSpeed: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF'];
    olMaximum: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF', '/LTCG'];
  end;
  
  // Call LLD linker
  LCan := False;
  AResult := LLDLink(LArgs, 'coff', AStdOut, AStdErr, LCan);
  
  // Reset JIT after linking to clear LLD's persistent state
  //FLLVM.ResetJIT(AModuleId);
  
  Result := Self;
end;

function TLLMetaLang.LinkToExecutable(
  const AObjectFiles: array of string; 
  const AOutputExe: string; 
  const AObjOutputPath: string;
  const AEntryPoint: string;
  const ASubsystem: TLLSubsystem;
  const AExternalLibs: array of string;
  const ALibraryPaths: array of string;
  const AOptLevel: TLLOptimization;
  out AStdOut: string;
  out AStdErr: string;
  out AResult: Integer
): TLLMetaLang;
var
  LArgs: TArray<string>;
  LObjectFile: string;
  LLibraryPath: string;
  LExternalLib: string;
  LSubsystemFlag: string;
  LCan: Boolean;
begin
  // Build LLD arguments for executable creation
  SetLength(LArgs, 0);
  
  // Convert subsystem enum to linker flag
  case ASubsystem of
    ssConsole: LSubsystemFlag := '/SUBSYSTEM:CONSOLE';
    ssGUI: LSubsystemFlag := '/SUBSYSTEM:WINDOWS';
  end;
  
  // Add linker and basic flags
  LArgs := LArgs + ['lld-link'];
  LArgs := LArgs + ['/verbose'];
  LArgs := LArgs + ['/nologo'];
  LArgs := LArgs + ['/OUT:' + AOutputExe];
  LArgs := LArgs + ['/ENTRY:' + AEntryPoint];
  LArgs := LArgs + [LSubsystemFlag];
  
  // Add object files
  for LObjectFile in AObjectFiles do
    LArgs := LArgs + [LObjectFile];
  
  // Add library search paths
  for LLibraryPath in ALibraryPaths do
    LArgs := LArgs + ['/LIBPATH:' + LLibraryPath];
  
  // Add external libraries
  for LExternalLib in AExternalLibs do
    LArgs := LArgs + ['/DEFAULTLIB:' + LExternalLib];
  
  // Add optimization flags based on AOptLevel
  case AOptLevel of
    olDebug: LArgs := LArgs + ['/DEBUG', '/OPT:NOREF', '/OPT:NOICF'];
    olSize: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF'];
    olSpeed: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF'];
    olMaximum: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF', '/LTCG'];
  end;
  
  // Call LLD linker
  LCan := False;
  AResult := LLDLink(LArgs, 'coff', AStdOut, AStdErr, LCan);

  writeln(LCan);

  Result := Self;
end;

// Directory-based linking
function TLLMetaLang.LinkObjectDirectory(
  const ADirectoryPath: string; 
  const AOutputPath: string;
  const AObjOutputPath: string;
  const AIsDLL: Boolean;
  const ASubsystem: TLLSubsystem;
  const AExternalLibs: array of string;
  const ALibraryPaths: array of string;
  const AOptLevel: TLLOptimization;
  const AImportLibPath: string;
  out AStdOut: string;
  out AStdErr: string;
  out AResult: Integer
): TLLMetaLang;
var
  LObjectFiles: TArray<string>;
  LFiles: TStringDynArray;
begin
  // Find all .obj files in directory
  LFiles := TDirectory.GetFiles(ADirectoryPath, '*.obj');
  SetLength(LObjectFiles, Length(LFiles));
  for var LIndex := 0 to High(LFiles) do
    LObjectFiles[LIndex] := LFiles[LIndex];
  
  // Link based on type
  if AIsDLL then
    LinkToDLL(LObjectFiles, AOutputPath, AObjOutputPath, AExternalLibs, ALibraryPaths, AOptLevel, AImportLibPath, AStdOut, AStdErr, AResult)
  else
    LinkToExecutable(LObjectFiles, AOutputPath, AObjOutputPath, 'main', ASubsystem, AExternalLibs, ALibraryPaths, AOptLevel, AStdOut, AStdErr, AResult);
  
  Result := Self;
end;

// Module-based linking
function TLLMetaLang.LinkModuleToDLL(
  const AModuleId: string; 
  const AOutputDLL: string; 
  const AObjOutputPath: string;
  const AExternalLibs: array of string;
  const ALibraryPaths: array of string;
  const AOptLevel: TLLOptimization;
  const AImportLibPath: string;
  out AStdOut: string;
  out AStdErr: string;
  out AResult: Integer
): TLLMetaLang;
var
  LObjectPath: string;
  LArgs: TArray<string>;
  LLibraryPath: string;
  LExternalLib: string;
  LExports: TArray<TLLExportSpec>;
  LExport: TLLExportSpec;
  LExportName: string;
  LCan: Boolean;
begin
  // Ensure DllMain exists before compiling
  EnsureDllMain(AModuleId);

  // Compile module to object
  LObjectPath := FLLVM.CompileModuleToObject(AModuleId, AObjOutputPath, AOptLevel);
  
  // Build LLD arguments for DLL creation with automatic exports
  SetLength(LArgs, 0);
  
  // Add linker and basic flags
  LArgs := LArgs + ['lld-link'];
  LArgs := LArgs + ['/verbose'];
  LArgs := LArgs + ['/nologo'];
  LArgs := LArgs + ['/entry:DllMain'];
  LArgs := LArgs + ['/DLL'];
  LArgs := LArgs + ['/OUT:' + AOutputDLL];
  
  // Add object file
  LArgs := LArgs + [LObjectPath];
  
  // Add library search paths
  for LLibraryPath in ALibraryPaths do
    LArgs := LArgs + ['/LIBPATH:' + LLibraryPath];
  
  // Add exported functions from this module
  LExports := GetExportedFunctionsForModule(AModuleId);
  for LExport in LExports do
  begin
    if LExport.ExportName <> '' then
      LExportName := LExport.ExportName
    else
      LExportName := LExport.FunctionName;
    
    if LExport.ExportOrdinal > 0 then
      LArgs := LArgs + [Format('/EXPORT:%s,@%d', [LExportName, LExport.ExportOrdinal])]
    else
      LArgs := LArgs + ['/EXPORT:' + LExportName];
  end;
  
  // Add external libraries
  for LExternalLib in AExternalLibs do
    LArgs := LArgs + [LExternalLib];

  // Add import library path if specified
  if AImportLibPath <> '' then
  begin
    // Ensure directory exists for import library
    TDirectory.CreateDirectory(AImportLibPath);
    // Create full import library path: path + dllname.lib
    LArgs := LArgs + ['/IMPLIB:' + TPath.Combine(AImportLibPath, TPath.ChangeExtension(TPath.GetFileName(AOutputDLL), '.lib'))];
  end;

  // Add optimization flags based on AOptLevel
  case AOptLevel of
    olDebug: LArgs := LArgs + ['/DEBUG', '/OPT:NOREF', '/OPT:NOICF'];
    olSize: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF'];
    olSpeed: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF'];
    olMaximum: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF', '/LTCG'];
  end;

  // Call LLD linker
  LCan := False;
  AResult := LLDLink(LArgs, 'coff', AStdOut, AStdErr, LCan);
  
  Result := Self;
end;

function TLLMetaLang.LinkModuleToExecutable(
  const AModuleId: string;
  const AOutputExe: string;
  const AObjOutputPath: string;
  const ASubsystem: TLLSubsystem;
  const AExternalLibs: array of string;
  const ALibraryPaths: array of string;
  const AOptLevel: TLLOptimization;
  out AStdOut: string;
  out AStdErr: string;
  out AResult: Integer
): TLLMetaLang;
var
  LObjectPath: string;
  LObjectFiles: TArray<string>;
begin
  // Compile module to object first
  LObjectPath := FLLVM.CompileModuleToObject(AModuleId, AObjOutputPath, AOptLevel);
  
  // Create array with single object file
  SetLength(LObjectFiles, 1);
  LObjectFiles[0] := LObjectPath;

  // Link to executable
  LinkToExecutable(LObjectFiles, AOutputExe, AObjOutputPath, 'main', ASubsystem, AExternalLibs, ALibraryPaths, AOptLevel, AStdOut, AStdErr, AResult);

  Result := Self;
end;

// Multi-module linking
function TLLMetaLang.LinkAllModulesToExecutable(
  const AObjectOutputDir: string;
  const AOutputExe: string;
  const AObjOutputPath: string;
  const ASubsystem: TLLSubsystem;
  const AExternalLibs: array of string;
  const ALibraryPaths: array of string;
  const AOptLevel: TLLOptimization;
  out AStdOut: string;
  out AStdErr: string;
  out AResult: Integer
): TLLMetaLang;
var
  LObjectFiles: TArray<string>;
begin
  // Compile all modules to objects
  LObjectFiles := FLLVM.CompileAllModulesToObjects(AObjOutputPath, AOptLevel);
  
  // Link all objects to executable
  LinkToExecutable(LObjectFiles, AOutputExe, AObjOutputPath, 'main', ASubsystem, AExternalLibs, ALibraryPaths, AOptLevel, AStdOut, AStdErr, AResult);
  
  Result := Self;
end;

function TLLMetaLang.LinkAllModulesToDLL(
  const AObjectOutputDir: string;
  const AOutputDLL: string;
  const AObjOutputPath: string;
  const AExternalLibs: array of string;
  const ALibraryPaths: array of string;
  const AOptLevel: TLLOptimization;
  const AImportLibPath: string;
  out AStdOut: string;
  out AStdErr: string;
  out AResult: Integer
): TLLMetaLang;
var
  LObjectFiles: TArray<string>;
  LArgs: TArray<string>;
  LObjectFile: string;
  LLibraryPath: string;
  LExternalLib: string;
  LModuleIds: TArray<string>;
  LModuleId: string;
  LExports: TArray<TLLExportSpec>;
  LExport: TLLExportSpec;
  LExportName: string;
  LCan: Boolean;
begin
  // Get all module IDs
  SetLength(LModuleIds, FExportedFunctions.Count);
  var LIndex := 0;
  for LModuleId in FExportedFunctions.Keys do
  begin
    LModuleIds[LIndex] := LModuleId;
    Inc(LIndex);
  end;
  
  // Add DllMain to just the last module processed
  if Length(LModuleIds) > 0 then
    EnsureDllMain(LModuleIds[High(LModuleIds)]);
  
  // Compile all modules to objects
  LObjectFiles := FLLVM.CompileAllModulesToObjects(AObjOutputPath, AOptLevel);
  
  // Build LLD arguments for DLL creation with exports from all modules
  SetLength(LArgs, 0);
  
  // Add linker and basic flags
  LArgs := LArgs + ['lld-link'];
  LArgs := LArgs + ['/verbose'];
  LArgs := LArgs + ['/nologo'];
  LArgs := LArgs + ['/entry:DllMain'];
  LArgs := LArgs + ['/DLL'];
  LArgs := LArgs + ['/OUT:' + AOutputDLL];
  
  // Add all object files
  for LObjectFile in LObjectFiles do
    LArgs := LArgs + [LObjectFile];
  
  // Add library search paths
  for LLibraryPath in ALibraryPaths do
    LArgs := LArgs + ['/LIBPATH:' + LLibraryPath];
  
  // Add exported functions from all modules (using previously collected module IDs)
  for LModuleId in LModuleIds do
  begin
    LExports := GetExportedFunctionsForModule(LModuleId);
    for LExport in LExports do
    begin
      if LExport.ExportName <> '' then
        LExportName := LExport.ExportName
      else
        LExportName := LExport.FunctionName;
      
      if LExport.ExportOrdinal > 0 then
        LArgs := LArgs + [Format('/EXPORT:%s,@%d', [LExportName, LExport.ExportOrdinal])]
      else
        LArgs := LArgs + ['/EXPORT:' + LExportName];
    end;
  end;
  
  // Add external libraries
  for LExternalLib in AExternalLibs do
    LArgs := LArgs + ['/DEFAULTLIB:' + LExternalLib];
  
  // Add import library path if specified
  if AImportLibPath <> '' then
  begin
    // Ensure directory exists for import library
    TDirectory.CreateDirectory(AImportLibPath);
    // Create full import library path: path + dllname.lib
    LArgs := LArgs + ['/IMPLIB:' + TPath.Combine(AImportLibPath, TPath.ChangeExtension(TPath.GetFileName(AOutputDLL), '.lib'))];
  end;
  
  // Add optimization flags based on AOptLevel
  case AOptLevel of
    olDebug: LArgs := LArgs + ['/DEBUG', '/OPT:NOREF', '/OPT:NOICF'];
    olSize: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF'];
    olSpeed: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF'];
    olMaximum: LArgs := LArgs + ['/OPT:REF', '/OPT:ICF', '/LTCG'];
  end;
  
  // Call LLD linker
  LCan := False;
  AResult := LLDLink(LArgs, 'coff', AStdOut, AStdErr, LCan);
  
  Result := Self;
end;

//=== UTILITY =================================================================
function TLLMetaLang.GetLLVM(): TLLVM;
begin
  Result := FLLVM;
end;

end.