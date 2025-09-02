![libLLVM](media/libllvm.png)
[![Chat on Discord](https://img.shields.io/discord/754884471324672040?style=for-the-badge)](https://discord.gg/tinyBigGAMES) [![Follow on Bluesky](https://img.shields.io/badge/Bluesky-tinyBigGAMES-blue?style=for-the-badge&logo=bluesky)](https://bsky.app/profile/tinybiggames.com)  
> 🚧 **libLLVM is Work in Progress**
>
> libLLVM is currently under active development and evolving quickly. Some features described in this documentation may be incomplete, experimental, or subject to significant changes as the project matures.
>
> We welcome your feedback, ideas, and issue reports – your input will directly influence the direction and quality of libLLVM as we strive to build the ultimate LLVM integration for Delphi.

## LLVM Power, Delphi Simplicity

libLLVM brings the full power of **LLVM's compilation infrastructure directly to Delphi**, providing native bindings for code generation, optimization, and linking with clean, Pascal-style integration.

### Why libLLVM?

- **🚀 Native LLVM Integration** - Direct access to LLVM's world-class compilation and optimization engine
- **🔗 Built-in LLD Support** - Integrated linking with LLVM's modern linker for all target platforms
- **📖 Delphi-Native Design** - Clean Pascal syntax with proper resource management and UTF-8 handling
- **⚡ Zero-Copy Interop** - Efficient string marshalling and memory management for high-performance compilation
- **🔧 Production Ready** - Robust error handling, proper cleanup, and battle-tested integration patterns

## Quick Example

```pascal
procedure CompileAndLink();
var
  LArgs: TArray<string>;
  LRC: Integer;
  LCanRunAgain: Boolean;
begin
  // Generate LLVM IR and compile to object file
  GenerateIRAndCompile('HelloWorld.ll', 'HelloWorld.obj');
  
  // Link with LLD
  LArgs := [
    'lld-link',
    '/nologo',
    '/subsystem:console',
    '/entry:main',
    '/out:HelloWorld.exe',
    'HelloWorld.obj',
    'kernel32.lib',
    'msvcrt.lib',
    'legacy_stdio_definitions.lib'
  ];
  
  LRC := LLDLink(LArgs, 'coff', LCanRunAgain);
  
  if LRC = 0 then
    Writeln('✅ Compilation successful!')
  else
    Writeln('❌ Compilation failed with code: ', LRC);
end;
```

## Key Features

### 🎯 **Complete LLVM Bindings**
- Full LLVM-C API coverage for contexts, modules, and IR generation
- Target machine support for all LLVM-supported architectures
- Memory buffer management with automatic cleanup
- Comprehensive error handling with proper Pascal exceptions

### 🔗 **Integrated LLD Linking**
```pascal
function LLDLink(const AArgs: array of string; const AFlavor: string; 
                 out ACanRunAgain: Boolean): Integer;
var
  LUTF8Args: TArray<UTF8String>;
  LArgv: TArray<PUTF8Char>;
begin
  // Robust UTF-8 string handling
  SetLength(LUTF8Args, Length(AArgs));
  SetLength(LArgv, Length(AArgs) + 1);
  
  // Convert and null-terminate for C interop
  for LIdx := 0 to High(AArgs) do
  begin
    LUTF8Args[LIdx] := UTF8String(AArgs[LIdx]);
    LArgv[LIdx] := PUTF8Char(LUTF8Args[LIdx]);
  end;
  LArgv[High(LArgv)] := nil;
  
  Result := LLD_Link(Length(LUTF8Args), @LArgv[0], 
                     PUTF8Char(UTF8String(AFlavor)), @LCan);
end;
```

### ⚙️ **Resource Management**
```pascal
// Automatic cleanup with proper try/finally blocks
LCtx := LLVMContextCreate();
LMod := nil;
LTM := nil;
try
  // LLVM operations...
  LMod := LLVMModuleCreateWithNameInContext(AsUTF8('hello'), LCtx);
  LTM := LLVMCreateTargetMachine(/* ... */);
  
  // Code generation...
  
finally
  if LTM <> nil then LLVMDisposeTargetMachine(LTM);
  if LMod <> nil then LLVMDisposeModule(LMod);
  if LCtx <> nil then LLVMContextDispose(LCtx);
end;
```

### 🏗️ **Modern Architecture Support**
```pascal
// Multi-target compilation
LLVMInitializeX86TargetInfo();    // x86/x64
LLVMInitializeARMTargetInfo();    // ARM/ARM64  
LLVMInitializeWebAssemblyTarget(); // WebAssembly

// Flexible target specification
LTripleStr := 'x86_64-pc-windows-msvc';  // Windows
LTripleStr := 'x86_64-unknown-linux-gnu'; // Linux
LTripleStr := 'aarch64-apple-darwin';      // macOS ARM64
```

### 📦 **Cross-Platform Linking**
```pascal
// Windows COFF linking
LRC := LLDLink(LWindowsArgs, 'coff', LCanRunAgain);

// Linux ELF linking  
LRC := LLDLink(LLinuxArgs, 'elf', LCanRunAgain);

// macOS Mach-O linking
LRC := LLDLink(LMacArgs, 'darwin', LCanRunAgain);

// WebAssembly linking
LRC := LLDLink(LWasmArgs, 'wasm', LCanRunAgain);
```

## Getting Started

1. **Include the LLVM headers** in your Delphi project
2. **Initialize target architectures** you plan to support
3. **Create LLVM contexts and modules** for your compilation units
4. **Generate IR or parse existing LLVM IR** files
5. **Compile to object files** using target machines
6. **Link with LLD** for final executable generation

## Projects using libLLVM  
Here’s a list of projects built with libLLVM. Want yours featured? Add it and submit a PR, or get in touch! And don’t forget to share what you’re working on in <a href="https://github.com/tinyBigGAMES/libLLVM/discussions/categories/show-and-tell" target="_blank">Show and tell</a>. 
- [LLVM-Simple-Calculator](https://github.com/hsauro/LLVM-Simple-Calculator)  
- [LLVM-Simple-Calculator-Using-TLLVM](https://github.com/hsauro/LLVM-Simple-Calculator-Using-TLLVM)

---

<div align="center">

**Built with ❤️ by [tinyBigGAMES](https://tinybiggames.com)**

*"Where LLVM meets Pascal"*

</div>