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

unit libLLVM.LLD;

{$I libLLVM.Defines.inc}

interface

/// <summary>
/// Invokes the LLD linker (via the combined LLVM-C + LLD DLL) with the given command-line
/// arguments and linker <c>AFlavor</c>, returning LLD’s process-style exit code and whether
/// the linker may be safely called again within the same process.
/// </summary>
///
/// <param name="AArgs">
/// Command-line tokens to forward to LLD as <c>argv</c>. This should mirror what you would
/// pass to the command-line tools (e.g., <c>lld-link</c>, <c>ld.lld</c>, <c>ld64.lld</c>, <c>wasm-ld</c>).
/// <para>
/// If the first element is missing or starts with <c>-</c>/<c>/</c>, the wrapper inserts a suitable
/// tool token for <c>AFlavor</c> as <c>argv[0]</c>. Valid defaults are:
/// <list type="bullet">
///   <item><description><c>coff</c> → <c>lld-link</c></description></item>
////   <item><description><c>elf</c>  → <c>ld.lld</c></description></item>
///   <item><description><c>macho</c>/<c>darwin</c> → <c>ld64.lld</c></description></item>
///   <item><description><c>wasm</c> → <c>wasm-ld</c></description></item>
///   <item><description><c>mingw</c> → <c>ld.lld</c></description></item>
/// </list>
/// </para>
/// <para>
/// All tokens are marshaled as UTF-8 and passed verbatim to LLD. Include your object files,
/// libraries, and options (e.g., <c>/out:app.exe</c>, <c>/subsystem:console</c>,
/// <c>/libpath:...</c>, <c>kernel32.lib</c>, <c>ucrt.lib</c>, <c>vcruntime.lib</c>,
/// <c>legacy_stdio_definitions.lib</c>, etc.).
/// </para>
/// </param>
///
/// <param name="AFlavor">
/// Linker “driver” to invoke: <c>coff</c>, <c>elf</c>, <c>macho</c>, <c>wasm</c>, or <c>mingw</c>
/// (case-insensitive). If empty, LLD auto-detects based on <c>argv[0]</c> and inputs.
/// </param>
///
/// <param name="AStdOut">
/// Captured standard output from LLD during the call (UTF-8).
/// </param>
///
/// <param name="AStdErr">
/// Captured standard error from LLD during the call (UTF-8).
/// </param>
///
/// <param name="ACanRunAgain">
/// <c>True</c> if LLD reports it is safe to call again in the same process; <c>False</c> otherwise.
/// </param>
///
/// <returns>
/// LLD’s exit code (0 = success; non-zero = failure).
/// </returns>
function LLDLink(const AArgs: array of string; const AFlavor: string;
  out AStdOut, AStdErr: string; out ACanRunAgain: Boolean): Integer;

implementation

uses
  WinApi.Windows,
  System.SysUtils,
  System.Classes,
  libLLVM.API;

type
  TPipeReader = class(TThread)
  private
    FPipeRead: THandle;
    FBuf: TBytes;
    FOut: TBytesStream;
  protected
    procedure Execute; override;
  public
    constructor Create(APipeRead: THandle);
    destructor Destroy; override;
    function AsUtf8String: string;
  end;

var
  GLldCaptureCS: TRTLCriticalSection;

{ ===== MSVCRT fd helpers ===== }

function _open_osfhandle(AOSHandle: NativeInt; AFlags: Integer): Integer; cdecl; external 'msvcrt.dll' name '_open_osfhandle';
function _dup(AFD: Integer): Integer; cdecl; external 'msvcrt.dll' name '_dup';
function _dup2(AFD, AFD2: Integer): Integer; cdecl; external 'msvcrt.dll' name '_dup2';
function _close(AFD: Integer): Integer; cdecl; external 'msvcrt.dll' name '_close';
function _setmode(AFD: Integer; AMode: Integer): Integer; cdecl; external 'msvcrt.dll' name '_setmode';
function fflush(Stream: Pointer): Integer; cdecl; external 'msvcrt.dll' name 'fflush';

const
  FD_STDOUT = 1;
  FD_STDERR = 2;
  _O_TEXT   = $4000;

procedure RestoreStdCRT(const AOldOutFD, AOldErrFD: Integer);
begin
  if AOldOutFD >= 0 then
  begin
    _dup2(AOldOutFD, FD_STDOUT);
    _close(AOldOutFD);
  end;
  if AOldErrFD >= 0 then
  begin
    _dup2(AOldErrFD, FD_STDERR);
    _close(AOldErrFD);
  end;
end;

procedure RedirectStdToPipes(const AWriteOut, AWriteErr: THandle; out AOldOutFD, AOldErrFD: Integer);
var
  DupOut, DupErr: THandle;
  NewOutFD, NewErrFD: Integer;
begin
  // Save current CRT fds (Delphi-side CRT)
  AOldOutFD := _dup(FD_STDOUT);
  AOldErrFD := _dup(FD_STDERR);

  // Duplicate OS handles so CRT takes ownership of the duplicates, not the originals.
  if not DuplicateHandle(GetCurrentProcess, AWriteOut, GetCurrentProcess, @DupOut, 0, False, DUPLICATE_SAME_ACCESS) then
    raise Exception.Create('DuplicateHandle(stdout) failed');
  if not DuplicateHandle(GetCurrentProcess, AWriteErr, GetCurrentProcess, @DupErr, 0, False, DUPLICATE_SAME_ACCESS) then
    raise Exception.Create('DuplicateHandle(stderr) failed');

  // Map duplicated OS handles into CRT fds and swap into fd 1/2.
  NewOutFD := _open_osfhandle(NativeInt(DupOut), 0);
  NewErrFD := _open_osfhandle(NativeInt(DupErr), 0);
  if NewOutFD < 0 then raise Exception.Create('_open_osfhandle(stdout) failed');
  if NewErrFD < 0 then raise Exception.Create('_open_osfhandle(stderr) failed');

  _dup2(NewOutFD, FD_STDOUT);
  _dup2(NewErrFD, FD_STDERR);

  // Close the temporary fds; fd 1/2 now own the OS handles.
  _close(NewOutFD);
  _close(NewErrFD);

  _setmode(FD_STDOUT, _O_TEXT);
  _setmode(FD_STDERR, _O_TEXT);
end;

{ ===== Pipe reader thread ===== }

constructor TPipeReader.Create(APipeRead: THandle);
begin
  // Start running immediately (no Start call later → avoids "cannot start on a suspended thread")
  inherited Create(False);
  FPipeRead := APipeRead;
  SetLength(FBuf, 8192);
  FOut := TBytesStream.Create;
  FreeOnTerminate := False;
end;

destructor TPipeReader.Destroy;
begin
  FOut.Free;
  inherited;
end;

procedure TPipeReader.Execute;
var
  Read: DWORD;
  OK: BOOL;
begin
  // Blocking read until writer closes or pipe breaks
  while not Terminated do
  begin
    OK := ReadFile(FPipeRead, FBuf[0], Length(FBuf), Read, nil);
    if not OK then
    begin
      if GetLastError = ERROR_BROKEN_PIPE then Break;
      Break;
    end;
    if Read = 0 then Break;
    FOut.WriteBuffer(FBuf[0], Read);
  end;
end;

function TPipeReader.AsUtf8String: string;
begin
  Result := TEncoding.UTF8.GetString(FOut.Bytes, 0, FOut.Size);
end;

{ ===== Core ===== }

function MakePipePair(out AReadH, AWriteH: THandle): Boolean;
var
  SA: TSecurityAttributes;
begin
  ZeroMemory(@SA, SizeOf(SA));
  SA.nLength := SizeOf(SA);
  SA.lpSecurityDescriptor := nil;
  SA.bInheritHandle := True;
  Result := CreatePipe(AReadH, AWriteH, @SA, 0);
  if Result then
    SetHandleInformation(AReadH, HANDLE_FLAG_INHERIT, 0);
end;

function LLDLink(const AArgs: array of string; const AFlavor: string;
  out AStdOut, AStdErr: string; out ACanRunAgain: Boolean): Integer;
var
  Utf8Args: TArray<UTF8String>;
  Argv: TArray<PAnsiChar>;
  FlavorUTF8: UTF8String;
  CanRunAgainInt: Integer;
  I: Integer;
  NeedArg0: Boolean;
  Arg0: UTF8String;

  OutRead, OutWrite: THandle;
  ErrRead, ErrWrite: THandle;
  OldStdOutFD, OldStdErrFD: Integer;
  ReaderOut, ReaderErr: TPipeReader;
  SavedStdOut, SavedStdErr: THandle;
begin
  EnterCriticalSection(GLldCaptureCS);
  try
    AStdOut := '';
    AStdErr := '';
    ACanRunAgain := False;

    if not MakePipePair(OutRead, OutWrite) then
      raise Exception.Create('CreatePipe(stdout) failed');
    if not MakePipePair(ErrRead, ErrWrite) then
    begin
      CloseHandle(OutRead);
      CloseHandle(OutWrite);
      raise Exception.Create('CreatePipe(stderr) failed');
    end;

    // Save OS std handles and point them to our pipe write ends
    SavedStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
    SavedStdErr := GetStdHandle(STD_ERROR_HANDLE);
    SetStdHandle(STD_OUTPUT_HANDLE, OutWrite);
    SetStdHandle(STD_ERROR_HANDLE,  ErrWrite);

    // Redirect Delphi-side CRT fd(1/2) to the pipe write ends (using duplicates)
    RedirectStdToPipes(OutWrite, ErrWrite, OldStdOutFD, OldStdErrFD);

    try
      // Start readers (blocking)
      ReaderOut := TPipeReader.Create(OutRead);
      ReaderErr := TPipeReader.Create(ErrRead);
      try
        // argv[0] handling if needed
        NeedArg0 := (Length(AArgs) = 0) or
                    ((Length(AArgs) > 0) and ((AArgs[0] = '') or (CharInSet(AArgs[0][1], ['-','/']))));

        if NeedArg0 then
        begin
          if SameText(AFlavor, 'elf') then Arg0 := UTF8String('ld.lld')
          else if SameText(AFlavor, 'macho') or SameText(AFlavor, 'darwin') then Arg0 := UTF8String('ld64.lld')
          else if SameText(AFlavor, 'wasm') then Arg0 := UTF8String('wasm-ld')
          else if SameText(AFlavor, 'mingw') then Arg0 := UTF8String('ld.lld')
          else Arg0 := UTF8String('lld-link');
        end;

        SetLength(Utf8Args, Length(AArgs) + Ord(NeedArg0));
        SetLength(Argv, Length(Utf8Args));
        I := 0;
        if NeedArg0 then
        begin
          Utf8Args[0] := Arg0;
          Argv[0] := PAnsiChar(Utf8Args[0]);
          I := 1;
        end;
        while I < Length(Utf8Args) do
        begin
          Utf8Args[I] := UTF8String(AArgs[I - Ord(NeedArg0)]);
          Argv[I] := PAnsiChar(Utf8Args[I]);
          Inc(I);
        end;

        if AFlavor <> '' then
          FlavorUTF8 := UTF8String(AFlavor)
        else
          FlavorUTF8 := UTF8String('');

        CanRunAgainInt := 0;

        // Call into your combined DLL (declared in libLLVM.API)
        Result := LLD_Link(Length(Argv), @Argv[0], PAnsiChar(FlavorUTF8), @CanRunAgainInt);
        ACanRunAgain := (CanRunAgainInt <> 0);

        // Flush CRT buffers so everything hits the pipes before teardown
        fflush(nil);
      finally
        // Restore CRT and OS std handles before closing read ends
        RestoreStdCRT(OldStdOutFD, OldStdErrFD);
        SetStdHandle(STD_OUTPUT_HANDLE, SavedStdOut);
        SetStdHandle(STD_ERROR_HANDLE,  SavedStdErr);

        // Close write ends so readers see EOF and exit
        CloseHandle(OutWrite);
        CloseHandle(ErrWrite);

        // Wait for reader threads, collect output, then free them
        ReaderOut.WaitFor;
        ReaderErr.WaitFor;

        AStdOut := ReaderOut.AsUtf8String;
        AStdErr := ReaderErr.AsUtf8String;

        ReaderOut.Free;
        ReaderErr.Free;

        // Close read ends
        CloseHandle(OutRead);
        CloseHandle(ErrRead);
      end;
    except
      on E: Exception do
      begin
        // Best-effort restore on error
        RestoreStdCRT(OldStdOutFD, OldStdErrFD);
        SetStdHandle(STD_OUTPUT_HANDLE, SavedStdOut);
        SetStdHandle(STD_ERROR_HANDLE,  SavedStdErr);
        CloseHandle(OutWrite);
        CloseHandle(ErrWrite);
        CloseHandle(OutRead);
        CloseHandle(ErrRead);
        raise;
      end;
    end;
  finally
    LeaveCriticalSection(GLldCaptureCS);
  end;
end;

initialization
  InitializeCriticalSection(GLldCaptureCS);

finalization
  DeleteCriticalSection(GLldCaptureCS);

end.

