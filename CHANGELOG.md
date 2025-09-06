# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Repo Update** (2025-09-05 – jarroddavis68)
  - Add TLLMetaLang class, complete Meta-Language wrapper over TLLVM for simplified code generation
  - Fluent interface design with method chaining for readable code construction
  - Automatic basic block management for control flow structures
  - High-level control flow: if/then/else, while loops, for loops with auto-blocks
  - Comprehensive value creation: integers, floats, strings, booleans, null values
  - Full arithmetic operations: math, bitwise, comparisons for int/float types
  - Type conversion system: int/float casting and cross-type conversions
  - Variable management: local/global variables with automatic SSA handling
  - Function system: declaration, parameters, calls, export marking
  - Memory operations: array allocation, load/store, PHI nodes for SSA form
  - Complete linking pipeline: DLL/EXE creation with automatic export management
  - JIT execution support with external library integration
  - Export management: automatic symbol exports with ordinals and custom names
  - Comprehensive test suite with both focused tests and complete workflow examples
  - Full module lifecycle: creation, validation, merging, compilation to objects
  - Subsystem support: console/GUI executables with proper Windows PE configuration
  - Build artifact management with organized output directories and import libraries
  Enables rapid LLVM IR development with high-level programming constructs while
  maintaining full access to low-level LLVM capabilities through GetLLVM().

- **Repo Update** (2025-09-04 – jarroddavis68)
  - Add TLLVM.CompileModuleToObject() method for single module compilation
  - Add TLLVM.CompileAllModulesToObjects() method for batch compilation
  - Add TLLVM.GetObjectFileExtension() class method for platform-specific extensions
  - Add libLLVM.Test.ObjectCompilation unit with comprehensive test coverage
  - Add TestSingleModuleCompilation() test method
  - Add TestBatchModuleCompilation() test method
  - Add TestOptimizationLevels() test method
  - Add TestFileExtensions() test method
  - Add TestOutputDirectories() test method
  - Add TestErrorConditions() test method
  - Add TestFileVerification() test method
  - Modernize all file operations to use TFile/TDirectory/TPath APIs
  - Implement consistent ModuleId + extension filename strategy
  - Add automatic directory creation for output paths

- **Update README.md** (2025-09-02 – jarroddavis68)
  - Update "Projects using libLLVM" section with message that you can also add your project to the list and submit a PR.

- **Repo Update** (2025-08-31 – jarroddavis68)
  - Rename libLLVM.pas to libLLVM.API.pas
  - Added libLLVM.pas, TLLVM class,  a fluent API around LLVAM API
  - Added comprehensive test suite for testing libLLVM framework

- **Create FUNDING.yml** (2025-08-31 – Jarrod Davis)


### Changed
- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-04 – jarroddavis68)

- **Update UTestbed.pas** (2025-09-04 – jarroddavis68)

- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-04 – jarroddavis68)

- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-03 – jarroddavis68)

- **Update libLLVM.pas** (2025-09-03 – jarroddavis68)

- **Update README.md** (2025-09-02 – jarroddavis68)

- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-02 – jarroddavis68)

- **Update README.md** (2025-09-02 – jarroddavis68)
  - Updated project using libLLVM list

- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-01 – jarroddavis68)

- **Update push-to-discussions.yml** (2025-09-01 – jarroddavis68)

- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-01 – jarroddavis68)

- **Update push-to-discussions.yml** (2025-09-01 – jarroddavis68)

- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-01 – jarroddavis68)

- **Repo Update** (2025-09-01 – jarroddavis68)
  - A few misc changes and enhancements

- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-01 – jarroddavis68)

- **Update libLLVM.Test.CodeGen.pas** (2025-09-01 – jarroddavis68)

- **Merge branch 'main' of https://github.com/tinyBigGAMES/libLLVM** (2025-09-01 – jarroddavis68)

- **Update .gitignore** (2025-09-01 – jarroddavis68)

- **Repo Update** (2025-09-01 – jarroddavis68)
  - Moved high level LLD support to libLLVM.LLD unit
  - Updated LLDLink to capture StdOut and StdErr strings

- **Repo Update** (2025-08-31 – jarroddavis68)
  - Include the missing [bin\libs] folder

- **Update LICENSE** (2025-08-31 – jarroddavis68)

- **Repo Update** (2025-08-31 – jarroddavis68)
  Initial commit

- **Initial commit** (2025-08-31 – Jarrod Davis)


### Fixed
- **Repo Update** (2025-09-03 – jarroddavis68)
  - Fix range check error with negative integers in ExtractLLVMValue()


### Removed
- **Remove file from repo and update .gitignore** (2025-09-01 – jarroddavis68)

