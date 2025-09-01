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

unit libLLVM.Utils;

{$I libLLVM.Defines.inc}

interface

uses
  WinAPI.Windows,
  System.SysUtils,
  System.AnsiStrings;

type

  { TLLUtils }
  TLLUtils = class
  private class var
    FMarshaller: TMarshaller;
  private
    class function  EnableVirtualTerminalProcessing(): Boolean; static;
    class procedure InitConsole(); static;

  public
    class procedure FailIf(const Cond: Boolean; const Msg: string; const AArgs: array of const);

    class function  GetTickCount(): DWORD; static;
    class function  GetTickCount64(): UInt64; static;

    class function  CallI64(AFunction: Pointer; const AArgs: array of const): UInt64; static;
    class function  CallF32(AFunction: Pointer; const AArgs: array of const): Single; static;
    class function  CallF64(AFunction: Pointer; const AArgs: array of const): Double; static;

    class function  HasConsole(): Boolean; static;
    class procedure ClearToEOL(); static;
    class function  Print(): string; overload; static;
    class function  PrintLn(): string; overload; static;
    class function  Print(const AText: string): string; overload; static;
    class function  Print(const AText: string; const AArgs: array of const): string; overload; static;
    class function  PrintLn(const AText: string): string; overload; static;
    class function  PrintLn(const AText: string; const AArgs: array of const): string; overload; static;
    class procedure Pause(); static;

    class function  AsUTF8(const AValue: string; ALength: PCardinal=nil): Pointer; static;
  end;

implementation

{$IF DEFINED(MSWINDOWS) AND DEFINED(CPUX64)}
function ffi_call_win64_i64(AFunction: Pointer; AArgs: PUInt64; AArgCount: Cardinal): UInt64; assembler;
asm
  // Prologue with only RBX saved; compute aligned stack space so that
  // RSP is 16-byte aligned at the CALL site.
  push rbp
  mov  rbp, rsp
  push rbx

  // Volatile locals
  mov  r11, rcx        // AFunction
  mov  r10, rdx        // AArgs
  mov  eax, r8d        // AArgCount -> EAX

  // k = max(0, ArgCount-4)
  mov  ecx, eax
  sub  ecx, 4
  xor  edx, edx
  cmp  ecx, 0
  jle  @no_stack
  mov  edx, ecx
  shl  edx, 3          // edx = k * 8
@no_stack:
  // s = 32 + 8*k ; ensure s ≡ 8 (mod 16) because we've pushed RBX
  lea  ebx, [rdx + 32] // ebx = base space
  test ecx, 1          // if k even, add +8; if k odd, already ≡ 8
  jnz  @have_s
  add  ebx, 8
@have_s:
  sub  rsp, rbx        // allocate

  // Copy stack args (5..N) to [rsp+32]
  mov  ecx, eax
  cmp  ecx, 4
  jle  @load_regs
  sub  ecx, 4
  lea  rsi, [r10 + 32]   // src
  lea  rdi, [rsp + 32]   // dst
  rep  movsq

@load_regs:
  // Dual-load first 4 slots
  test eax, eax
  jz   @do_call
  mov  rcx, [r10]
  movsd xmm0, qword ptr [r10]

  cmp  eax, 1
  jle  @do_call
  mov  rdx, [r10 + 8]
  movsd xmm1, qword ptr [r10 + 8]

  cmp  eax, 2
  jle  @do_call
  mov  r8,  [r10 + 16]
  movsd xmm2, qword ptr [r10 + 16]

  cmp  eax, 3
  jle  @do_call
  mov  r9,  [r10 + 24]
  movsd xmm3, qword ptr [r10 + 24]

@do_call:
  call r11

  // Epilogue
  add  rsp, rbx
  pop  rbx
  pop  rbp
  ret
end;

procedure ffi_call_win64_f32(AFunction: Pointer; AArgs: PUInt64; AArgCount: Cardinal; AResult: PSingle); assembler;
asm
  push rbp
  mov  rbp, rsp
  push rbx

  mov  r11, rcx        // AFunction
  mov  r10, rdx        // AArgs
  mov  eax, r8d        // AArgCount
  mov  r9,  r9         // AResult already in R9 (keep)

  // k = max(0, ArgCount-4)
  mov  ecx, eax
  sub  ecx, 4
  xor  edx, edx
  cmp  ecx, 0
  jle  @no_stack
  mov  edx, ecx
  shl  edx, 3
@no_stack:
  // s = 32 + 8*k ; adjust for RBX push parity
  lea  ebx, [rdx + 32]
  test ecx, 1
  jnz  @have_s
  add  ebx, 8
@have_s:
  sub  rsp, rbx

  // Copy stack args
  mov  ecx, eax
  cmp  ecx, 4
  jle  @load_regs
  sub  ecx, 4
  lea  rsi, [r10 + 32]
  lea  rdi, [rsp + 32]
  rep  movsq

@load_regs:
  test eax, eax
  jz   @do_call
  mov  rcx, [r10]
  // For float params the low 32 bits contain the value; movsd is fine (callee reads low 32)
  movsd xmm0, qword ptr [r10]

  cmp  eax, 1
  jle  @do_call
  mov  rdx, [r10 + 8]
  movsd xmm1, qword ptr [r10 + 8]

  cmp  eax, 2
  jle  @do_call
  mov  r8,  [r10 + 16]
  movsd xmm2, qword ptr [r10 + 16]

  cmp  eax, 3
  jle  @do_call
  mov  r9,  [r10 + 24]
  movsd xmm3, qword ptr [r10 + 24]

@do_call:
  call r11

  // Store float result
  test r9, r9
  jz   @done
  movss dword ptr [r9], xmm0
@done:
  add  rsp, rbx
  pop  rbx
  pop  rbp
  ret
end;

procedure ffi_call_win64_f64(AFunction: Pointer; AArgs: PUInt64; AArgCount: Cardinal; AResult: PDouble); assembler;
asm
  push rbp
  mov  rbp, rsp
  push rbx

  mov  r11, rcx        // AFunction
  mov  r10, rdx        // AArgs
  mov  eax, r8d        // AArgCount
  mov  r9,  r9         // AResult already in R9

  // k = max(0, ArgCount-4)
  mov  ecx, eax
  sub  ecx, 4
  xor  edx, edx
  cmp  ecx, 0
  jle  @no_stack
  mov  edx, ecx
  shl  edx, 3
@no_stack:
  // s = 32 + 8*k ; adjust for RBX push parity
  lea  ebx, [rdx + 32]
  test ecx, 1
  jnz  @have_s
  add  ebx, 8
@have_s:
  sub  rsp, rbx

  // Copy stack args
  mov  ecx, eax
  cmp  ecx, 4
  jle  @load_regs
  sub  ecx, 4
  lea  rsi, [r10 + 32]
  lea  rdi, [rsp + 32]
  rep  movsq

@load_regs:
  test eax, eax
  jz   @do_call
  mov  rcx, [r10]
  movsd xmm0, qword ptr [r10]

  cmp  eax, 1
  jle  @do_call
  mov  rdx, [r10 + 8]
  movsd xmm1, qword ptr [r10 + 8]

  cmp  eax, 2
  jle  @do_call
  mov  r8,  [r10 + 16]
  movsd xmm2, qword ptr [r10 + 16]

  cmp  eax, 3
  jle  @do_call
  mov  r9,  [r10 + 24]
  movsd xmm3, qword ptr [r10 + 24]

@do_call:
  call r11

  // Store double result
  test r9, r9
  jz   @done
  movsd qword ptr [r9], xmm0
@done:
  add  rsp, rbx
  pop  rbx
  pop  rbp
  ret
end;
{$ENDIF}

{ TLLUtils }
class function TLLUtils.EnableVirtualTerminalProcessing(): Boolean;
var
  HOut: THandle;
  LMode: DWORD;
begin
  Result := False;

  HOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if HOut = INVALID_HANDLE_VALUE then Exit;
  if not GetConsoleMode(HOut, LMode) then Exit;

  LMode := LMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING;
  if not SetConsoleMode(HOut, LMode) then Exit;

  Result := True;
end;

class procedure TLLUtils.InitConsole();
begin
  {$IF DEFINED(MSWINDOWS) AND DEFINED(CPUX64)}
    EnableVirtualTerminalProcessing();
    SetConsoleCP(CP_UTF8);
    SetConsoleOutputCP(CP_UTF8);
  {$ENDIF}
end;

type
  TUInt64Array = array of UInt64;

class function TLLUtils.CallI64(AFunction: Pointer; const AArgs: array of const): UInt64;
var
  LSlots: TUInt64Array;
  I: Integer;
  L: UInt64;
begin
  SetLength(LSlots, Length(AArgs));
  for I := 0 to High(AArgs) do
  begin
    L := 0;
    case AArgs[I].VType of
      vtInteger:       L := UInt64(Int64(AArgs[I].VInteger));
      vtInt64:         L := UInt64(PInt64(AArgs[I].VInt64)^);
      vtBoolean:       L := Ord(AArgs[I].VBoolean);
      vtPointer:       L := UInt64(NativeUInt(AArgs[I].VPointer));
      vtPChar:         L := UInt64(NativeUInt(AArgs[I].VPChar));
      vtPWideChar:     L := UInt64(NativeUInt(AArgs[I].VPWideChar));
      vtClass:         L := UInt64(NativeUInt(AArgs[I].VClass));
      vtObject:        L := UInt64(NativeUInt(AArgs[I].VObject));
      vtWideChar:      L := UInt64(Ord(AArgs[I].VWideChar));
      vtChar:          L := UInt64(Ord(AArgs[I].VChar));
      vtAnsiString:    L := UInt64(NativeUInt(AArgs[I].VAnsiString));      // pointer to Ansi data
      vtUnicodeString: L := UInt64(NativeUInt(AArgs[I].VUnicodeString));   // pointer to UTF-16 data
      vtExtended:      Move(PExtended(AArgs[I].VExtended)^, L, 8);         // pass as double bits
      vtCurrency:      Move(PCurrency(AArgs[I].VCurrency)^, L, 8);
      vtVariant:       L := UInt64(NativeUInt(AArgs[I].VVariant));         // pointer to Variant
    else
      L := 0;
    end;
    LSlots[I] := L;
  end;

  if Length(LSlots) = 0 then
    Result := ffi_call_win64_i64(AFunction, nil, 0)
  else
    Result := ffi_call_win64_i64(AFunction, @LSlots[0], Length(LSlots));
end;

class function TLLUtils.CallF32(AFunction: Pointer; const AArgs: array of const): Single;
var
  LSlots: TUInt64Array;
  I: Integer;
  L: UInt64;
  S: Single;
begin
  SetLength(LSlots, Length(AArgs));
  for I := 0 to High(AArgs) do
  begin
    L := 0;
    case AArgs[I].VType of
      vtExtended:      begin S := Single(PExtended(AArgs[I].VExtended)^); Move(S, L, 4); end;
      vtInteger:       L := UInt64(Int64(AArgs[I].VInteger));
      vtInt64:         L := UInt64(PInt64(AArgs[I].VInt64)^);
      vtBoolean:       L := Ord(AArgs[I].VBoolean);
      vtPointer:       L := UInt64(NativeUInt(AArgs[I].VPointer));
      vtPChar:         L := UInt64(NativeUInt(AArgs[I].VPChar));
      vtPWideChar:     L := UInt64(NativeUInt(AArgs[I].VPWideChar));
      vtChar:          L := UInt64(Ord(AArgs[I].VChar));
      vtWideChar:      L := UInt64(Ord(AArgs[I].VWideChar));
      vtAnsiString:    L := UInt64(NativeUInt(AArgs[I].VAnsiString));
      vtUnicodeString: L := UInt64(NativeUInt(AArgs[I].VUnicodeString));
      vtCurrency:      Move(PCurrency(AArgs[I].VCurrency)^, L, 8);
      vtVariant:       L := UInt64(NativeUInt(AArgs[I].VVariant));
    else
      L := 0;
    end;
    LSlots[I] := L;
  end;

  if Length(LSlots) = 0 then
    ffi_call_win64_f32(AFunction, nil, 0, @Result)
  else
    ffi_call_win64_f32(AFunction, @LSlots[0], Length(LSlots), @Result);
end;

class function TLLUtils.CallF64(AFunction: Pointer; const AArgs: array of const): Double;
var
  LSlots: TUInt64Array;
  I: Integer;
  L: UInt64;
  D: Double;
begin
  SetLength(LSlots, Length(AArgs));
  for I := 0 to High(AArgs) do
  begin
    L := 0;
    case AArgs[I].VType of
      vtExtended:      begin D := Double(PExtended(AArgs[I].VExtended)^); Move(D, L, 8); end;
      vtInteger:       L := UInt64(Int64(AArgs[I].VInteger));
      vtInt64:         L := UInt64(PInt64(AArgs[I].VInt64)^);
      vtBoolean:       L := Ord(AArgs[I].VBoolean);
      vtPointer:       L := UInt64(NativeUInt(AArgs[I].VPointer));
      vtPChar:         L := UInt64(NativeUInt(AArgs[I].VPChar));
      vtPWideChar:     L := UInt64(NativeUInt(AArgs[I].VPWideChar));
      vtChar:          L := UInt64(Ord(AArgs[I].VChar));
      vtWideChar:      L := UInt64(Ord(AArgs[I].VWideChar));
      vtAnsiString:    L := UInt64(NativeUInt(AArgs[I].VAnsiString));
      vtUnicodeString: L := UInt64(NativeUInt(AArgs[I].VUnicodeString));
      vtCurrency:      Move(PCurrency(AArgs[I].VCurrency)^, L, 8);
      vtVariant:       L := UInt64(NativeUInt(AArgs[I].VVariant));
    else
      L := 0;
    end;
    LSlots[I] := L;
  end;

  if Length(LSlots) = 0 then
    ffi_call_win64_f64(AFunction, nil, 0, @Result)
  else
    ffi_call_win64_f64(AFunction, @LSlots[0], Length(LSlots), @Result);
end;

class procedure TLLUtils.FailIf(const Cond: Boolean; const Msg: string; const AArgs: array of const);
  begin
    if Cond then
      raise Exception.CreateFmt(Msg, AArgs);
  end;

class function TLLUtils.GetTickCount(): DWORD;
begin
  {$IF DEFINED(MSWINDOWS) AND DEFINED(CPUX64)}
  Result := WinApi.Windows.GetTickCount();
  {$ENDIF}
end;

class function TLLUtils.GetTickCount64(): UInt64;
begin
  {$IF DEFINED(MSWINDOWS) AND DEFINED(CPUX64)}
  Result := WinApi.Windows.GetTickCount64();
  {$ENDIF}
end;

class function TLLUtils.HasConsole(): Boolean;
begin
  {$IF DEFINED(MSWINDOWS) AND DEFINED(CPUX64)}
  Result := Boolean(GetConsoleWindow() <> 0);
  {$ENDIF}
end;

class procedure TLLUtils.ClearToEOL();
begin
  if not HasConsole() then Exit;
  Write(#27'[0K');
end;

class function  TLLUtils.Print(): string;
begin
  Print('');
end;

class function  TLLUtils.PrintLn(): string;
begin
  PrintLn('');
end;

class function TLLUtils.Print(const AText: string): string;
begin
  if not HasConsole() then Exit;
  Result := AText;
  Write(Result);
end;

class function TLLUtils.Print(const AText: string; const AArgs: array of const): string;
begin
  if not HasConsole() then Exit;
  Result := Format(AText, AArgs);
  Write(Result);
end;

class function TLLUtils.PrintLn(const AText: string): string;
begin
  if not HasConsole() then Exit;
  Result := AText;
  WriteLn(Result);
end;

class function  TLLUtils.PrintLn(const AText: string; const AArgs: array of const): string;
begin
  if not HasConsole() then Exit;
  Result := Format(AText, AArgs);
  WriteLn(Result);
end;

class procedure TLLUtils.Pause();
begin
  PrintLn('');
  Print('Press ENTER to continue...');
  ReadLn;
  PrintLn('');
end;

class function TLLUtils.AsUTF8(const AValue: string; ALength: PCardinal): Pointer;
begin
  Result := FMarshaller.AsUtf8(AValue).ToPointer;
  if Assigned(ALength) then
    ALength^ := System.AnsiStrings.StrLen(PAnsiChar(Result));
end;

initialization
begin
  TLLUtils.InitConsole();
end;

finalization
begin

end;

end.
