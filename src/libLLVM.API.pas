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

unit libLLVM.API;

{$I libLLVM.Defines.inc}

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.Classes,
  Dlluminator;

const
  libLLVM_MAJOR   = 0;
  libLLVM_MINOR   = 1;
  libLLVM_PATCH   = 0;

const
  LLVM_DEFAULT_TARGET_TRIPLE = 'x86_64-pc-windows-msvc';
  LLVM_ENABLE_THREADS = 1;
  LLVM_HAS_ATOMICS = 1;
  LLVM_HOST_TRIPLE = 'x86_64-pc-windows-msvc';
  LLVM_USE_INTEL_JITEVENTS = 0;
  LLVM_USE_OPROFILE = 0;
  LLVM_USE_PERF = 0;
  LLVM_VERSION_MAJOR = 21;
  LLVM_VERSION_MINOR = 1;
  LLVM_VERSION_PATCH = 0;
  LLVM_VERSION_STRING = '21.1.0';
  LLVM_FORCE_ENABLE_STATS = 0;
  LLVM_ENABLE_ZLIB = 0;
  LLVM_ENABLE_ZSTD = 0;
  LLVM_UNREACHABLE_OPTIMIZE = 1;
  LLVM_ENABLE_DIA_SDK = 0;
  LLVM_ENABLE_TELEMETRY = 1;
  LLVM_ENABLE_DEBUGLOC_TRACKING_COVERAGE = 0;
  LLVM_ENABLE_DEBUGLOC_TRACKING_ORIGIN = 0;
  LLVMDisassembler_VariantKind_None = 0;
  LLVMDisassembler_VariantKind_ARM_HI16 = 1;
  LLVMDisassembler_VariantKind_ARM_LO16 = 2;
  LLVMDisassembler_VariantKind_ARM64_PAGE = 1;
  LLVMDisassembler_VariantKind_ARM64_PAGEOFF = 2;
  LLVMDisassembler_VariantKind_ARM64_GOTPAGE = 3;
  LLVMDisassembler_VariantKind_ARM64_GOTPAGEOFF = 4;
  LLVMDisassembler_VariantKind_ARM64_TLVP = 5;
  LLVMDisassembler_VariantKind_ARM64_TLVOFF = 6;
  LLVMDisassembler_ReferenceType_InOut_None = 0;
  LLVMDisassembler_ReferenceType_In_Branch = 1;
  LLVMDisassembler_ReferenceType_In_PCrel_Load = 2;
  LLVMDisassembler_ReferenceType_In_ARM64_ADRP = $100000001;
  LLVMDisassembler_ReferenceType_In_ARM64_ADDXri = $100000002;
  LLVMDisassembler_ReferenceType_In_ARM64_LDRXui = $100000003;
  LLVMDisassembler_ReferenceType_In_ARM64_LDRXl = $100000004;
  LLVMDisassembler_ReferenceType_In_ARM64_ADR = $100000005;
  LLVMDisassembler_ReferenceType_Out_SymbolStub = 1;
  LLVMDisassembler_ReferenceType_Out_LitPool_SymAddr = 2;
  LLVMDisassembler_ReferenceType_Out_LitPool_CstrAddr = 3;
  LLVMDisassembler_ReferenceType_Out_Objc_CFString_Ref = 4;
  LLVMDisassembler_ReferenceType_Out_Objc_Message = 5;
  LLVMDisassembler_ReferenceType_Out_Objc_Message_Ref = 6;
  LLVMDisassembler_ReferenceType_Out_Objc_Selector_Ref = 7;
  LLVMDisassembler_ReferenceType_Out_Objc_Class_Ref = 8;
  LLVMDisassembler_ReferenceType_DeMangled_Name = 9;
  LLVMDisassembler_Option_UseMarkup = 1;
  LLVMDisassembler_Option_PrintImmHex = 2;
  LLVMDisassembler_Option_AsmPrinterVariant = 4;
  LLVMDisassembler_Option_SetInstrComments = 8;
  LLVMDisassembler_Option_PrintLatency = 16;
  LLVMDisassembler_Option_Color = 32;
  LLVMErrorSuccess = 0;
  REMARKS_API_VERSION = 1;

type
  // Forward declarations
  PPUTF8Char = ^PUTF8Char;
  PNativeUInt = ^NativeUInt;
  PUInt8 = ^UInt8;
  PUInt64 = ^UInt64;
  PLLVMOpaqueMemoryBuffer = Pointer;
  PPLLVMOpaqueMemoryBuffer = ^PLLVMOpaqueMemoryBuffer;
  PLLVMOpaqueContext = Pointer;
  PPLLVMOpaqueContext = ^PLLVMOpaqueContext;
  PLLVMOpaqueModule = Pointer;
  PPLLVMOpaqueModule = ^PLLVMOpaqueModule;
  PLLVMOpaqueType = Pointer;
  PPLLVMOpaqueType = ^PLLVMOpaqueType;
  PLLVMOpaqueValue = Pointer;
  PPLLVMOpaqueValue = ^PLLVMOpaqueValue;
  PLLVMOpaqueBasicBlock = Pointer;
  PPLLVMOpaqueBasicBlock = ^PLLVMOpaqueBasicBlock;
  PLLVMOpaqueMetadata = Pointer;
  PPLLVMOpaqueMetadata = ^PLLVMOpaqueMetadata;
  PLLVMOpaqueNamedMDNode = Pointer;
  PPLLVMOpaqueNamedMDNode = ^PLLVMOpaqueNamedMDNode;
  PLLVMOpaqueValueMetadataEntry = Pointer;
  PPLLVMOpaqueValueMetadataEntry = ^PLLVMOpaqueValueMetadataEntry;
  PLLVMOpaqueBuilder = Pointer;
  PPLLVMOpaqueBuilder = ^PLLVMOpaqueBuilder;
  PLLVMOpaqueDIBuilder = Pointer;
  PPLLVMOpaqueDIBuilder = ^PLLVMOpaqueDIBuilder;
  PLLVMOpaqueModuleProvider = Pointer;
  PPLLVMOpaqueModuleProvider = ^PLLVMOpaqueModuleProvider;
  PLLVMOpaquePassManager = Pointer;
  PPLLVMOpaquePassManager = ^PLLVMOpaquePassManager;
  PLLVMOpaqueUse = Pointer;
  PPLLVMOpaqueUse = ^PLLVMOpaqueUse;
  PLLVMOpaqueOperandBundle = Pointer;
  PPLLVMOpaqueOperandBundle = ^PLLVMOpaqueOperandBundle;
  PLLVMOpaqueAttributeRef = Pointer;
  PPLLVMOpaqueAttributeRef = ^PLLVMOpaqueAttributeRef;
  PLLVMOpaqueDiagnosticInfo = Pointer;
  PPLLVMOpaqueDiagnosticInfo = ^PLLVMOpaqueDiagnosticInfo;
  PLLVMComdat = Pointer;
  PPLLVMComdat = ^PLLVMComdat;
  PLLVMOpaqueModuleFlagEntry = Pointer;
  PPLLVMOpaqueModuleFlagEntry = ^PLLVMOpaqueModuleFlagEntry;
  PLLVMOpaqueJITEventListener = Pointer;
  PPLLVMOpaqueJITEventListener = ^PLLVMOpaqueJITEventListener;
  PLLVMOpaqueBinary = Pointer;
  PPLLVMOpaqueBinary = ^PLLVMOpaqueBinary;
  PLLVMOpaqueDbgRecord = Pointer;
  PPLLVMOpaqueDbgRecord = ^PLLVMOpaqueDbgRecord;
  PLLVMOpaqueError = Pointer;
  PPLLVMOpaqueError = ^PLLVMOpaqueError;
  PLLVMOpaqueTargetData = Pointer;
  PPLLVMOpaqueTargetData = ^PLLVMOpaqueTargetData;
  PLLVMOpaqueTargetLibraryInfotData = Pointer;
  PPLLVMOpaqueTargetLibraryInfotData = ^PLLVMOpaqueTargetLibraryInfotData;
  PLLVMOpaqueTargetMachineOptions = Pointer;
  PPLLVMOpaqueTargetMachineOptions = ^PLLVMOpaqueTargetMachineOptions;
  PLLVMOpaqueTargetMachine = Pointer;
  PPLLVMOpaqueTargetMachine = ^PLLVMOpaqueTargetMachine;
  PLLVMTarget = Pointer;
  PPLLVMTarget = ^PLLVMTarget;
  PLLVMOpaqueGenericValue = Pointer;
  PPLLVMOpaqueGenericValue = ^PLLVMOpaqueGenericValue;
  PLLVMOpaqueExecutionEngine = Pointer;
  PPLLVMOpaqueExecutionEngine = ^PLLVMOpaqueExecutionEngine;
  PLLVMOpaqueMCJITMemoryManager = Pointer;
  PPLLVMOpaqueMCJITMemoryManager = ^PLLVMOpaqueMCJITMemoryManager;
  PLLVMOrcOpaqueExecutionSession = Pointer;
  PPLLVMOrcOpaqueExecutionSession = ^PLLVMOrcOpaqueExecutionSession;
  PLLVMOrcOpaqueSymbolStringPool = Pointer;
  PPLLVMOrcOpaqueSymbolStringPool = ^PLLVMOrcOpaqueSymbolStringPool;
  PLLVMOrcOpaqueSymbolStringPoolEntry = Pointer;
  PPLLVMOrcOpaqueSymbolStringPoolEntry = ^PLLVMOrcOpaqueSymbolStringPoolEntry;
  PLLVMOrcOpaqueJITDylib = Pointer;
  PPLLVMOrcOpaqueJITDylib = ^PLLVMOrcOpaqueJITDylib;
  PLLVMOrcOpaqueMaterializationUnit = Pointer;
  PPLLVMOrcOpaqueMaterializationUnit = ^PLLVMOrcOpaqueMaterializationUnit;
  PLLVMOrcOpaqueMaterializationResponsibility = Pointer;
  PPLLVMOrcOpaqueMaterializationResponsibility = ^PLLVMOrcOpaqueMaterializationResponsibility;
  PLLVMOrcOpaqueResourceTracker = Pointer;
  PPLLVMOrcOpaqueResourceTracker = ^PLLVMOrcOpaqueResourceTracker;
  PLLVMOrcOpaqueDefinitionGenerator = Pointer;
  PPLLVMOrcOpaqueDefinitionGenerator = ^PLLVMOrcOpaqueDefinitionGenerator;
  PLLVMOrcOpaqueLookupState = Pointer;
  PPLLVMOrcOpaqueLookupState = ^PLLVMOrcOpaqueLookupState;
  PLLVMOrcOpaqueThreadSafeContext = Pointer;
  PPLLVMOrcOpaqueThreadSafeContext = ^PLLVMOrcOpaqueThreadSafeContext;
  PLLVMOrcOpaqueThreadSafeModule = Pointer;
  PPLLVMOrcOpaqueThreadSafeModule = ^PLLVMOrcOpaqueThreadSafeModule;
  PLLVMOrcOpaqueJITTargetMachineBuilder = Pointer;
  PPLLVMOrcOpaqueJITTargetMachineBuilder = ^PLLVMOrcOpaqueJITTargetMachineBuilder;
  PLLVMOrcOpaqueObjectLayer = Pointer;
  PPLLVMOrcOpaqueObjectLayer = ^PLLVMOrcOpaqueObjectLayer;
  PLLVMOrcOpaqueObjectLinkingLayer = Pointer;
  PPLLVMOrcOpaqueObjectLinkingLayer = ^PLLVMOrcOpaqueObjectLinkingLayer;
  PLLVMOrcOpaqueIRTransformLayer = Pointer;
  PPLLVMOrcOpaqueIRTransformLayer = ^PLLVMOrcOpaqueIRTransformLayer;
  PLLVMOrcOpaqueObjectTransformLayer = Pointer;
  PPLLVMOrcOpaqueObjectTransformLayer = ^PLLVMOrcOpaqueObjectTransformLayer;
  PLLVMOrcOpaqueIndirectStubsManager = Pointer;
  PPLLVMOrcOpaqueIndirectStubsManager = ^PLLVMOrcOpaqueIndirectStubsManager;
  PLLVMOrcOpaqueLazyCallThroughManager = Pointer;
  PPLLVMOrcOpaqueLazyCallThroughManager = ^PLLVMOrcOpaqueLazyCallThroughManager;
  PLLVMOrcOpaqueDumpObjects = Pointer;
  PPLLVMOrcOpaqueDumpObjects = ^PLLVMOrcOpaqueDumpObjects;
  PLLVMOrcOpaqueLLJITBuilder = Pointer;
  PPLLVMOrcOpaqueLLJITBuilder = ^PLLVMOrcOpaqueLLJITBuilder;
  PLLVMOrcOpaqueLLJIT = Pointer;
  PPLLVMOrcOpaqueLLJIT = ^PLLVMOrcOpaqueLLJIT;
  PLLVMOpaqueSectionIterator = Pointer;
  PPLLVMOpaqueSectionIterator = ^PLLVMOpaqueSectionIterator;
  PLLVMOpaqueSymbolIterator = Pointer;
  PPLLVMOpaqueSymbolIterator = ^PLLVMOpaqueSymbolIterator;
  PLLVMOpaqueRelocationIterator = Pointer;
  PPLLVMOpaqueRelocationIterator = ^PLLVMOpaqueRelocationIterator;
  PLLVMOpaqueObjectFile = Pointer;
  PPLLVMOpaqueObjectFile = ^PLLVMOpaqueObjectFile;
  PLLVMRemarkOpaqueString = Pointer;
  PPLLVMRemarkOpaqueString = ^PLLVMRemarkOpaqueString;
  PLLVMRemarkOpaqueDebugLoc = Pointer;
  PPLLVMRemarkOpaqueDebugLoc = ^PLLVMRemarkOpaqueDebugLoc;
  PLLVMRemarkOpaqueArg = Pointer;
  PPLLVMRemarkOpaqueArg = ^PLLVMRemarkOpaqueArg;
  PLLVMRemarkOpaqueEntry = Pointer;
  PPLLVMRemarkOpaqueEntry = ^PLLVMRemarkOpaqueEntry;
  PLLVMRemarkOpaqueParser = Pointer;
  PPLLVMRemarkOpaqueParser = ^PLLVMRemarkOpaqueParser;
  PLLVMOpaquePassBuilderOptions = Pointer;
  PPLLVMOpaquePassBuilderOptions = ^PLLVMOpaquePassBuilderOptions;
  PLLVMOpInfoSymbol1 = ^LLVMOpInfoSymbol1;
  PLLVMOpInfo1 = ^LLVMOpInfo1;
  PLLVMMCJITCompilerOptions = ^LLVMMCJITCompilerOptions;
  PLLVMJITSymbolFlags = ^LLVMJITSymbolFlags;
  PLLVMJITEvaluatedSymbol = ^LLVMJITEvaluatedSymbol;
  PLLVMOrcCSymbolFlagsMapPair = ^LLVMOrcCSymbolFlagsMapPair;
  PLLVMOrcCSymbolMapPair = ^LLVMOrcCSymbolMapPair;
  PLLVMOrcCSymbolAliasMapEntry = ^LLVMOrcCSymbolAliasMapEntry;
  PLLVMOrcCSymbolAliasMapPair = ^LLVMOrcCSymbolAliasMapPair;
  PLLVMOrcCSymbolsList = ^LLVMOrcCSymbolsList;
  PLLVMOrcCDependenceMapPair = ^LLVMOrcCDependenceMapPair;
  PLLVMOrcCSymbolDependenceGroup = ^LLVMOrcCSymbolDependenceGroup;
  PLLVMOrcCJITDylibSearchOrderElement = ^LLVMOrcCJITDylibSearchOrderElement;
  PLLVMOrcCLookupSetElement = ^LLVMOrcCLookupSetElement;

  ssize_t = Int64;
  LLVMBool = Integer;
  PLLVMBool = ^LLVMBool;
  LLVMMemoryBufferRef = Pointer;
  PLLVMMemoryBufferRef = ^LLVMMemoryBufferRef;
  LLVMContextRef = Pointer;
  PLLVMContextRef = ^LLVMContextRef;
  LLVMModuleRef = Pointer;
  PLLVMModuleRef = ^LLVMModuleRef;
  LLVMTypeRef = Pointer;
  PLLVMTypeRef = ^LLVMTypeRef;
  LLVMValueRef = Pointer;
  PLLVMValueRef = ^LLVMValueRef;
  LLVMBasicBlockRef = Pointer;
  PLLVMBasicBlockRef = ^LLVMBasicBlockRef;
  LLVMMetadataRef = Pointer;
  PLLVMMetadataRef = ^LLVMMetadataRef;
  LLVMNamedMDNodeRef = Pointer;
  PLLVMNamedMDNodeRef = ^LLVMNamedMDNodeRef;
  PLLVMValueMetadataEntry = Pointer;
  PPLLVMValueMetadataEntry = ^PLLVMValueMetadataEntry;
  LLVMBuilderRef = Pointer;
  PLLVMBuilderRef = ^LLVMBuilderRef;
  LLVMDIBuilderRef = Pointer;
  PLLVMDIBuilderRef = ^LLVMDIBuilderRef;
  LLVMModuleProviderRef = Pointer;
  PLLVMModuleProviderRef = ^LLVMModuleProviderRef;
  LLVMPassManagerRef = Pointer;
  PLLVMPassManagerRef = ^LLVMPassManagerRef;
  LLVMUseRef = Pointer;
  PLLVMUseRef = ^LLVMUseRef;
  LLVMOperandBundleRef = Pointer;
  PLLVMOperandBundleRef = ^LLVMOperandBundleRef;
  LLVMAttributeRef = Pointer;
  PLLVMAttributeRef = ^LLVMAttributeRef;
  LLVMDiagnosticInfoRef = Pointer;
  PLLVMDiagnosticInfoRef = ^LLVMDiagnosticInfoRef;
  LLVMComdatRef = Pointer;
  PLLVMComdatRef = ^LLVMComdatRef;
  PLLVMModuleFlagEntry = Pointer;
  PPLLVMModuleFlagEntry = ^PLLVMModuleFlagEntry;
  LLVMJITEventListenerRef = Pointer;
  PLLVMJITEventListenerRef = ^LLVMJITEventListenerRef;
  LLVMBinaryRef = Pointer;
  PLLVMBinaryRef = ^LLVMBinaryRef;
  LLVMDbgRecordRef = Pointer;
  PLLVMDbgRecordRef = ^LLVMDbgRecordRef;

  LLVMVerifierFailureAction = (
    LLVMAbortProcessAction = 0,
    LLVMPrintMessageAction = 1,
    LLVMReturnStatusAction = 2);
  PLLVMVerifierFailureAction = ^LLVMVerifierFailureAction;

  LLVMComdatSelectionKind = (
    LLVMAnyComdatSelectionKind = 0,
    LLVMExactMatchComdatSelectionKind = 1,
    LLVMLargestComdatSelectionKind = 2,
    LLVMNoDeduplicateComdatSelectionKind = 3,
    LLVMSameSizeComdatSelectionKind = 4);
  PLLVMComdatSelectionKind = ^LLVMComdatSelectionKind;

  LLVMFatalErrorHandler = procedure(const Reason: PUTF8Char); cdecl;

  LLVMOpcode = (
    LLVMRet = 1,
    LLVMBr = 2,
    LLVMSwitch = 3,
    LLVMIndirectBr = 4,
    LLVMInvoke = 5,
    LLVMUnreachable = 7,
    LLVMCallBr = 67,
    LLVMFNeg = 66,
    LLVMAdd = 8,
    LLVMFAdd = 9,
    LLVMSub = 10,
    LLVMFSub = 11,
    LLVMMul = 12,
    LLVMFMul = 13,
    LLVMUDiv = 14,
    LLVMSDiv = 15,
    LLVMFDiv = 16,
    LLVMURem = 17,
    LLVMSRem = 18,
    LLVMFRem = 19,
    LLVMShl = 20,
    LLVMLShr = 21,
    LLVMAShr = 22,
    LLVMAnd = 23,
    LLVMOr = 24,
    LLVMXor = 25,
    LLVMAlloca = 26,
    LLVMLoad = 27,
    LLVMStore = 28,
    LLVMGetElementPtr = 29,
    LLVMTrunc = 30,
    LLVMZExt = 31,
    LLVMSExt = 32,
    LLVMFPToUI = 33,
    LLVMFPToSI = 34,
    LLVMUIToFP = 35,
    LLVMSIToFP = 36,
    LLVMFPTrunc = 37,
    LLVMFPExt = 38,
    LLVMPtrToInt = 39,
    LLVMIntToPtr = 40,
    LLVMBitCast = 41,
    LLVMAddrSpaceCast = 60,
    LLVMICmp = 42,
    LLVMFCmp = 43,
    LLVMPHI = 44,
    LLVMCall = 45,
    LLVMSelect = 46,
    LLVMUserOp1 = 47,
    LLVMUserOp2 = 48,
    LLVMVAArg = 49,
    LLVMExtractElement = 50,
    LLVMInsertElement = 51,
    LLVMShuffleVector = 52,
    LLVMExtractValue = 53,
    LLVMInsertValue = 54,
    LLVMFreeze = 68,
    LLVMFence = 55,
    LLVMAtomicCmpXchg = 56,
    LLVMAtomicRMW = 57,
    LLVMResume = 58,
    LLVMLandingPad = 59,
    LLVMCleanupRet = 61,
    LLVMCatchRet = 62,
    LLVMCatchPad = 63,
    LLVMCleanupPad = 64,
    LLVMCatchSwitch = 65);
  PLLVMOpcode = ^LLVMOpcode;

  LLVMTypeKind = (
    LLVMVoidTypeKind = 0,
    LLVMHalfTypeKind = 1,
    LLVMFloatTypeKind = 2,
    LLVMDoubleTypeKind = 3,
    LLVMX86_FP80TypeKind = 4,
    LLVMFP128TypeKind = 5,
    LLVMPPC_FP128TypeKind = 6,
    LLVMLabelTypeKind = 7,
    LLVMIntegerTypeKind = 8,
    LLVMFunctionTypeKind = 9,
    LLVMStructTypeKind = 10,
    LLVMArrayTypeKind = 11,
    LLVMPointerTypeKind = 12,
    LLVMVectorTypeKind = 13,
    LLVMMetadataTypeKind = 14,
    LLVMTokenTypeKind = 16,
    LLVMScalableVectorTypeKind = 17,
    LLVMBFloatTypeKind = 18,
    LLVMX86_AMXTypeKind = 19,
    LLVMTargetExtTypeKind = 20);
  PLLVMTypeKind = ^LLVMTypeKind;

  LLVMLinkage = (
    LLVMExternalLinkage = 0,
    LLVMAvailableExternallyLinkage = 1,
    LLVMLinkOnceAnyLinkage = 2,
    LLVMLinkOnceODRLinkage = 3,
    LLVMLinkOnceODRAutoHideLinkage = 4,
    LLVMWeakAnyLinkage = 5,
    LLVMWeakODRLinkage = 6,
    LLVMAppendingLinkage = 7,
    LLVMInternalLinkage = 8,
    LLVMPrivateLinkage = 9,
    LLVMDLLImportLinkage = 10,
    LLVMDLLExportLinkage = 11,
    LLVMExternalWeakLinkage = 12,
    LLVMGhostLinkage = 13,
    LLVMCommonLinkage = 14,
    LLVMLinkerPrivateLinkage = 15,
    LLVMLinkerPrivateWeakLinkage = 16);
  PLLVMLinkage = ^LLVMLinkage;

  LLVMVisibility = (
    LLVMDefaultVisibility = 0,
    LLVMHiddenVisibility = 1,
    LLVMProtectedVisibility = 2);
  PLLVMVisibility = ^LLVMVisibility;

  LLVMUnnamedAddr = (
    LLVMNoUnnamedAddr = 0,
    LLVMLocalUnnamedAddr = 1,
    LLVMGlobalUnnamedAddr = 2);
  PLLVMUnnamedAddr = ^LLVMUnnamedAddr;

  LLVMDLLStorageClass = (
    LLVMDefaultStorageClass = 0,
    LLVMDLLImportStorageClass = 1,
    LLVMDLLExportStorageClass = 2);
  PLLVMDLLStorageClass = ^LLVMDLLStorageClass;

  LLVMCallConv = (
    LLVMCCallConv = 0,
    LLVMFastCallConv = 8,
    LLVMColdCallConv = 9,
    LLVMGHCCallConv = 10,
    LLVMHiPECallConv = 11,
    LLVMAnyRegCallConv = 13,
    LLVMPreserveMostCallConv = 14,
    LLVMPreserveAllCallConv = 15,
    LLVMSwiftCallConv = 16,
    LLVMCXXFASTTLSCallConv = 17,
    LLVMX86StdcallCallConv = 64,
    LLVMX86FastcallCallConv = 65,
    LLVMARMAPCSCallConv = 66,
    LLVMARMAAPCSCallConv = 67,
    LLVMARMAAPCSVFPCallConv = 68,
    LLVMMSP430INTRCallConv = 69,
    LLVMX86ThisCallCallConv = 70,
    LLVMPTXKernelCallConv = 71,
    LLVMPTXDeviceCallConv = 72,
    LLVMSPIRFUNCCallConv = 75,
    LLVMSPIRKERNELCallConv = 76,
    LLVMIntelOCLBICallConv = 77,
    LLVMX8664SysVCallConv = 78,
    LLVMWin64CallConv = 79,
    LLVMX86VectorCallCallConv = 80,
    LLVMHHVMCallConv = 81,
    LLVMHHVMCCallConv = 82,
    LLVMX86INTRCallConv = 83,
    LLVMAVRINTRCallConv = 84,
    LLVMAVRSIGNALCallConv = 85,
    LLVMAVRBUILTINCallConv = 86,
    LLVMAMDGPUVSCallConv = 87,
    LLVMAMDGPUGSCallConv = 88,
    LLVMAMDGPUPSCallConv = 89,
    LLVMAMDGPUCSCallConv = 90,
    LLVMAMDGPUKERNELCallConv = 91,
    LLVMX86RegCallCallConv = 92,
    LLVMAMDGPUHSCallConv = 93,
    LLVMMSP430BUILTINCallConv = 94,
    LLVMAMDGPULSCallConv = 95,
    LLVMAMDGPUESCallConv = 96);
  PLLVMCallConv = ^LLVMCallConv;

  LLVMValueKind = (
    LLVMArgumentValueKind = 0,
    LLVMBasicBlockValueKind = 1,
    LLVMMemoryUseValueKind = 2,
    LLVMMemoryDefValueKind = 3,
    LLVMMemoryPhiValueKind = 4,
    LLVMFunctionValueKind = 5,
    LLVMGlobalAliasValueKind = 6,
    LLVMGlobalIFuncValueKind = 7,
    LLVMGlobalVariableValueKind = 8,
    LLVMBlockAddressValueKind = 9,
    LLVMConstantExprValueKind = 10,
    LLVMConstantArrayValueKind = 11,
    LLVMConstantStructValueKind = 12,
    LLVMConstantVectorValueKind = 13,
    LLVMUndefValueValueKind = 14,
    LLVMConstantAggregateZeroValueKind = 15,
    LLVMConstantDataArrayValueKind = 16,
    LLVMConstantDataVectorValueKind = 17,
    LLVMConstantIntValueKind = 18,
    LLVMConstantFPValueKind = 19,
    LLVMConstantPointerNullValueKind = 20,
    LLVMConstantTokenNoneValueKind = 21,
    LLVMMetadataAsValueValueKind = 22,
    LLVMInlineAsmValueKind = 23,
    LLVMInstructionValueKind = 24,
    LLVMPoisonValueValueKind = 25,
    LLVMConstantTargetNoneValueKind = 26,
    LLVMConstantPtrAuthValueKind = 27);
  PLLVMValueKind = ^LLVMValueKind;

  LLVMIntPredicate = (
    LLVMIntEQ = 32,
    LLVMIntNE = 33,
    LLVMIntUGT = 34,
    LLVMIntUGE = 35,
    LLVMIntULT = 36,
    LLVMIntULE = 37,
    LLVMIntSGT = 38,
    LLVMIntSGE = 39,
    LLVMIntSLT = 40,
    LLVMIntSLE = 41);
  PLLVMIntPredicate = ^LLVMIntPredicate;

  LLVMRealPredicate = (
    LLVMRealPredicateFalse = 0,
    LLVMRealOEQ = 1,
    LLVMRealOGT = 2,
    LLVMRealOGE = 3,
    LLVMRealOLT = 4,
    LLVMRealOLE = 5,
    LLVMRealONE = 6,
    LLVMRealORD = 7,
    LLVMRealUNO = 8,
    LLVMRealUEQ = 9,
    LLVMRealUGT = 10,
    LLVMRealUGE = 11,
    LLVMRealULT = 12,
    LLVMRealULE = 13,
    LLVMRealUNE = 14,
    LLVMRealPredicateTrue = 15);
  PLLVMRealPredicate = ^LLVMRealPredicate;

  LLVMThreadLocalMode = (
    LLVMNotThreadLocal = 0,
    LLVMGeneralDynamicTLSModel = 1,
    LLVMLocalDynamicTLSModel = 2,
    LLVMInitialExecTLSModel = 3,
    LLVMLocalExecTLSModel = 4);
  PLLVMThreadLocalMode = ^LLVMThreadLocalMode;

  LLVMAtomicOrdering = (
    LLVMAtomicOrderingNotAtomic = 0,
    LLVMAtomicOrderingUnordered = 1,
    LLVMAtomicOrderingMonotonic = 2,
    LLVMAtomicOrderingAcquire = 4,
    LLVMAtomicOrderingRelease = 5,
    LLVMAtomicOrderingAcquireRelease = 6,
    LLVMAtomicOrderingSequentiallyConsistent = 7);
  PLLVMAtomicOrdering = ^LLVMAtomicOrdering;

  LLVMAtomicRMWBinOp = (
    LLVMAtomicRMWBinOpXchg = 0,
    LLVMAtomicRMWBinOpAdd = 1,
    LLVMAtomicRMWBinOpSub = 2,
    LLVMAtomicRMWBinOpAnd = 3,
    LLVMAtomicRMWBinOpNand = 4,
    LLVMAtomicRMWBinOpOr = 5,
    LLVMAtomicRMWBinOpXor = 6,
    LLVMAtomicRMWBinOpMax = 7,
    LLVMAtomicRMWBinOpMin = 8,
    LLVMAtomicRMWBinOpUMax = 9,
    LLVMAtomicRMWBinOpUMin = 10,
    LLVMAtomicRMWBinOpFAdd = 11,
    LLVMAtomicRMWBinOpFSub = 12,
    LLVMAtomicRMWBinOpFMax = 13,
    LLVMAtomicRMWBinOpFMin = 14,
    LLVMAtomicRMWBinOpUIncWrap = 15,
    LLVMAtomicRMWBinOpUDecWrap = 16,
    LLVMAtomicRMWBinOpUSubCond = 17,
    LLVMAtomicRMWBinOpUSubSat = 18,
    LLVMAtomicRMWBinOpFMaximum = 19,
    LLVMAtomicRMWBinOpFMinimum = 20);
  PLLVMAtomicRMWBinOp = ^LLVMAtomicRMWBinOp;

  LLVMDiagnosticSeverity = (
    LLVMDSError = 0,
    LLVMDSWarning = 1,
    LLVMDSRemark = 2,
    LLVMDSNote = 3);
  PLLVMDiagnosticSeverity = ^LLVMDiagnosticSeverity;

  LLVMInlineAsmDialect = (
    LLVMInlineAsmDialectATT = 0,
    LLVMInlineAsmDialectIntel = 1);
  PLLVMInlineAsmDialect = ^LLVMInlineAsmDialect;

  LLVMModuleFlagBehavior = (
    LLVMModuleFlagBehaviorError = 0,
    LLVMModuleFlagBehaviorWarning = 1,
    LLVMModuleFlagBehaviorRequire = 2,
    LLVMModuleFlagBehaviorOverride = 3,
    LLVMModuleFlagBehaviorAppend = 4,
    LLVMModuleFlagBehaviorAppendUnique = 5);
  PLLVMModuleFlagBehavior = ^LLVMModuleFlagBehavior;

  _anonymous_type_1 = (
    LLVMAttributeReturnIndex = 0,
    LLVMAttributeFunctionIndex = -1);
  P_anonymous_type_1 = ^_anonymous_type_1;
  LLVMAttributeIndex = Cardinal;

  LLVMTailCallKind = (
    LLVMTailCallKindNone = 0,
    LLVMTailCallKindTail = 1,
    LLVMTailCallKindMustTail = 2,
    LLVMTailCallKindNoTail = 3);
  PLLVMTailCallKind = ^LLVMTailCallKind;

  _anonymous_type_2 = (
    LLVMFastMathAllowReassoc = 1,
    LLVMFastMathNoNaNs = 2,
    LLVMFastMathNoInfs = 4,
    LLVMFastMathNoSignedZeros = 8,
    LLVMFastMathAllowReciprocal = 16,
    LLVMFastMathAllowContract = 32,
    LLVMFastMathApproxFunc = 64,
    LLVMFastMathNone = 0,
    LLVMFastMathAll = 127);
  P_anonymous_type_2 = ^_anonymous_type_2;
  LLVMFastMathFlags = Cardinal;

  _anonymous_type_3 = (
    LLVMGEPFlagInBounds = 1,
    LLVMGEPFlagNUSW = 2,
    LLVMGEPFlagNUW = 4);
  P_anonymous_type_3 = ^_anonymous_type_3;
  LLVMGEPNoWrapFlags = Cardinal;

  LLVMDiagnosticHandler = procedure(p1: LLVMDiagnosticInfoRef; p2: Pointer); cdecl;

  LLVMYieldCallback = procedure(p1: LLVMContextRef; p2: Pointer); cdecl;

  LLVMDIFlags = (
    LLVMDIFlagZero = 0,
    LLVMDIFlagPrivate = 1,
    LLVMDIFlagProtected = 2,
    LLVMDIFlagPublic = 3,
    LLVMDIFlagFwdDecl = 4,
    LLVMDIFlagAppleBlock = 8,
    LLVMDIFlagReservedBit4 = 16,
    LLVMDIFlagVirtual = 32,
    LLVMDIFlagArtificial = 64,
    LLVMDIFlagExplicit = 128,
    LLVMDIFlagPrototyped = 256,
    LLVMDIFlagObjcClassComplete = 512,
    LLVMDIFlagObjectPointer = 1024,
    LLVMDIFlagVector = 2048,
    LLVMDIFlagStaticMember = 4096,
    LLVMDIFlagLValueReference = 8192,
    LLVMDIFlagRValueReference = 16384,
    LLVMDIFlagReserved = 32768,
    LLVMDIFlagSingleInheritance = 65536,
    LLVMDIFlagMultipleInheritance = 131072,
    LLVMDIFlagVirtualInheritance = 196608,
    LLVMDIFlagIntroducedVirtual = 262144,
    LLVMDIFlagBitField = 524288,
    LLVMDIFlagNoReturn = 1048576,
    LLVMDIFlagTypePassByValue = 4194304,
    LLVMDIFlagTypePassByReference = 8388608,
    LLVMDIFlagEnumClass = 16777216,
    LLVMDIFlagFixedEnum = 16777216,
    LLVMDIFlagThunk = 33554432,
    LLVMDIFlagNonTrivial = 67108864,
    LLVMDIFlagBigEndian = 134217728,
    LLVMDIFlagLittleEndian = 268435456,
    LLVMDIFlagIndirectVirtualBase = 36,
    LLVMDIFlagAccessibility = 3,
    LLVMDIFlagPtrToMemberRep = 196608);
  PLLVMDIFlags = ^LLVMDIFlags;

  LLVMDWARFSourceLanguage = (
    LLVMDWARFSourceLanguageC89 = 0,
    LLVMDWARFSourceLanguageC = 1,
    LLVMDWARFSourceLanguageAda83 = 2,
    LLVMDWARFSourceLanguageC_plus_plus = 3,
    LLVMDWARFSourceLanguageCobol74 = 4,
    LLVMDWARFSourceLanguageCobol85 = 5,
    LLVMDWARFSourceLanguageFortran77 = 6,
    LLVMDWARFSourceLanguageFortran90 = 7,
    LLVMDWARFSourceLanguagePascal83 = 8,
    LLVMDWARFSourceLanguageModula2 = 9,
    LLVMDWARFSourceLanguageJava = 10,
    LLVMDWARFSourceLanguageC99 = 11,
    LLVMDWARFSourceLanguageAda95 = 12,
    LLVMDWARFSourceLanguageFortran95 = 13,
    LLVMDWARFSourceLanguagePLI = 14,
    LLVMDWARFSourceLanguageObjC = 15,
    LLVMDWARFSourceLanguageObjC_plus_plus = 16,
    LLVMDWARFSourceLanguageUPC = 17,
    LLVMDWARFSourceLanguageD = 18,
    LLVMDWARFSourceLanguagePython = 19,
    LLVMDWARFSourceLanguageOpenCL = 20,
    LLVMDWARFSourceLanguageGo = 21,
    LLVMDWARFSourceLanguageModula3 = 22,
    LLVMDWARFSourceLanguageHaskell = 23,
    LLVMDWARFSourceLanguageC_plus_plus_03 = 24,
    LLVMDWARFSourceLanguageC_plus_plus_11 = 25,
    LLVMDWARFSourceLanguageOCaml = 26,
    LLVMDWARFSourceLanguageRust = 27,
    LLVMDWARFSourceLanguageC11 = 28,
    LLVMDWARFSourceLanguageSwift = 29,
    LLVMDWARFSourceLanguageJulia = 30,
    LLVMDWARFSourceLanguageDylan = 31,
    LLVMDWARFSourceLanguageC_plus_plus_14 = 32,
    LLVMDWARFSourceLanguageFortran03 = 33,
    LLVMDWARFSourceLanguageFortran08 = 34,
    LLVMDWARFSourceLanguageRenderScript = 35,
    LLVMDWARFSourceLanguageBLISS = 36,
    LLVMDWARFSourceLanguageKotlin = 37,
    LLVMDWARFSourceLanguageZig = 38,
    LLVMDWARFSourceLanguageCrystal = 39,
    LLVMDWARFSourceLanguageC_plus_plus_17 = 40,
    LLVMDWARFSourceLanguageC_plus_plus_20 = 41,
    LLVMDWARFSourceLanguageC17 = 42,
    LLVMDWARFSourceLanguageFortran18 = 43,
    LLVMDWARFSourceLanguageAda2005 = 44,
    LLVMDWARFSourceLanguageAda2012 = 45,
    LLVMDWARFSourceLanguageHIP = 46,
    LLVMDWARFSourceLanguageAssembly = 47,
    LLVMDWARFSourceLanguageC_sharp = 48,
    LLVMDWARFSourceLanguageMojo = 49,
    LLVMDWARFSourceLanguageGLSL = 50,
    LLVMDWARFSourceLanguageGLSL_ES = 51,
    LLVMDWARFSourceLanguageHLSL = 52,
    LLVMDWARFSourceLanguageOpenCL_CPP = 53,
    LLVMDWARFSourceLanguageCPP_for_OpenCL = 54,
    LLVMDWARFSourceLanguageSYCL = 55,
    LLVMDWARFSourceLanguageRuby = 56,
    LLVMDWARFSourceLanguageMove = 57,
    LLVMDWARFSourceLanguageHylo = 58,
    LLVMDWARFSourceLanguageMetal = 59,
    LLVMDWARFSourceLanguageMips_Assembler = 60,
    LLVMDWARFSourceLanguageGOOGLE_RenderScript = 61,
    LLVMDWARFSourceLanguageBORLAND_Delphi = 62);
  PLLVMDWARFSourceLanguage = ^LLVMDWARFSourceLanguage;

  LLVMDWARFEmissionKind = (
    LLVMDWARFEmissionNone = 0,
    LLVMDWARFEmissionFull = 1,
    LLVMDWARFEmissionLineTablesOnly = 2);
  PLLVMDWARFEmissionKind = ^LLVMDWARFEmissionKind;

  _anonymous_type_4 = (
    LLVMMDStringMetadataKind = 0,
    LLVMConstantAsMetadataMetadataKind = 1,
    LLVMLocalAsMetadataMetadataKind = 2,
    LLVMDistinctMDOperandPlaceholderMetadataKind = 3,
    LLVMMDTupleMetadataKind = 4,
    LLVMDILocationMetadataKind = 5,
    LLVMDIExpressionMetadataKind = 6,
    LLVMDIGlobalVariableExpressionMetadataKind = 7,
    LLVMGenericDINodeMetadataKind = 8,
    LLVMDISubrangeMetadataKind = 9,
    LLVMDIEnumeratorMetadataKind = 10,
    LLVMDIBasicTypeMetadataKind = 11,
    LLVMDIDerivedTypeMetadataKind = 12,
    LLVMDICompositeTypeMetadataKind = 13,
    LLVMDISubroutineTypeMetadataKind = 14,
    LLVMDIFileMetadataKind = 15,
    LLVMDICompileUnitMetadataKind = 16,
    LLVMDISubprogramMetadataKind = 17,
    LLVMDILexicalBlockMetadataKind = 18,
    LLVMDILexicalBlockFileMetadataKind = 19,
    LLVMDINamespaceMetadataKind = 20,
    LLVMDIModuleMetadataKind = 21,
    LLVMDITemplateTypeParameterMetadataKind = 22,
    LLVMDITemplateValueParameterMetadataKind = 23,
    LLVMDIGlobalVariableMetadataKind = 24,
    LLVMDILocalVariableMetadataKind = 25,
    LLVMDILabelMetadataKind = 26,
    LLVMDIObjCPropertyMetadataKind = 27,
    LLVMDIImportedEntityMetadataKind = 28,
    LLVMDIMacroMetadataKind = 29,
    LLVMDIMacroFileMetadataKind = 30,
    LLVMDICommonBlockMetadataKind = 31,
    LLVMDIStringTypeMetadataKind = 32,
    LLVMDIGenericSubrangeMetadataKind = 33,
    LLVMDIArgListMetadataKind = 34,
    LLVMDIAssignIDMetadataKind = 35,
    LLVMDISubrangeTypeMetadataKind = 36,
    LLVMDIFixedPointTypeMetadataKind = 37);
  P_anonymous_type_4 = ^_anonymous_type_4;
  LLVMMetadataKind = Cardinal;
  LLVMDWARFTypeEncoding = Cardinal;

  LLVMDWARFMacinfoRecordType = (
    LLVMDWARFMacinfoRecordTypeDefine = 1,
    LLVMDWARFMacinfoRecordTypeMacro = 2,
    LLVMDWARFMacinfoRecordTypeStartFile = 3,
    LLVMDWARFMacinfoRecordTypeEndFile = 4,
    LLVMDWARFMacinfoRecordTypeVendorExt = 255);
  PLLVMDWARFMacinfoRecordType = ^LLVMDWARFMacinfoRecordType;
  LLVMDisasmContextRef = Pointer;

  LLVMOpInfoCallback = function(DisInfo: Pointer; PC: UInt64; Offset: UInt64; OpSize: UInt64; InstSize: UInt64; TagType: Integer; TagBuf: Pointer): Integer; cdecl;

  LLVMOpInfoSymbol1 = record
    Present: UInt64;
    Name: PUTF8Char;
    Value: UInt64;
  end;

  LLVMOpInfo1 = record
    AddSymbol: LLVMOpInfoSymbol1;
    SubtractSymbol: LLVMOpInfoSymbol1;
    Value: UInt64;
    VariantKind: UInt64;
  end;

  LLVMSymbolLookupCallback = function(DisInfo: Pointer; ReferenceValue: UInt64; ReferenceType: PUInt64; ReferencePC: UInt64; ReferenceName: PPUTF8Char): PUTF8Char; cdecl;
  LLVMErrorRef = Pointer;
  PLLVMErrorRef = ^LLVMErrorRef;
  LLVMErrorTypeId = Pointer;

  LLVMByteOrdering = (
    LLVMBigEndian = 0,
    LLVMLittleEndian = 1);
  PLLVMByteOrdering = ^LLVMByteOrdering;
  LLVMTargetDataRef = Pointer;
  PLLVMTargetDataRef = ^LLVMTargetDataRef;
  LLVMTargetLibraryInfoRef = Pointer;
  PLLVMTargetLibraryInfoRef = ^LLVMTargetLibraryInfoRef;
  LLVMTargetMachineOptionsRef = Pointer;
  PLLVMTargetMachineOptionsRef = ^LLVMTargetMachineOptionsRef;
  LLVMTargetMachineRef = Pointer;
  PLLVMTargetMachineRef = ^LLVMTargetMachineRef;
  LLVMTargetRef = Pointer;
  PLLVMTargetRef = ^LLVMTargetRef;

  LLVMCodeGenOptLevel = (
    LLVMCodeGenLevelNone = 0,
    LLVMCodeGenLevelLess = 1,
    LLVMCodeGenLevelDefault = 2,
    LLVMCodeGenLevelAggressive = 3);
  PLLVMCodeGenOptLevel = ^LLVMCodeGenOptLevel;

  LLVMRelocMode = (
    LLVMRelocDefault = 0,
    LLVMRelocStatic = 1,
    LLVMRelocPIC = 2,
    LLVMRelocDynamicNoPic = 3,
    LLVMRelocROPI = 4,
    LLVMRelocRWPI = 5,
    LLVMRelocROPI_RWPI = 6);
  PLLVMRelocMode = ^LLVMRelocMode;

  LLVMCodeModel = (
    LLVMCodeModelDefault = 0,
    LLVMCodeModelJITDefault = 1,
    LLVMCodeModelTiny = 2,
    LLVMCodeModelSmall = 3,
    LLVMCodeModelKernel = 4,
    LLVMCodeModelMedium = 5,
    LLVMCodeModelLarge = 6);
  PLLVMCodeModel = ^LLVMCodeModel;

  LLVMCodeGenFileType = (
    LLVMAssemblyFile = 0,
    LLVMObjectFile = 1);
  PLLVMCodeGenFileType = ^LLVMCodeGenFileType;

  LLVMGlobalISelAbortMode = (
    LLVMGlobalISelAbortEnable = 0,
    LLVMGlobalISelAbortDisable = 1,
    LLVMGlobalISelAbortDisableWithDiag = 2);
  PLLVMGlobalISelAbortMode = ^LLVMGlobalISelAbortMode;
  LLVMGenericValueRef = Pointer;
  PLLVMGenericValueRef = ^LLVMGenericValueRef;
  LLVMExecutionEngineRef = Pointer;
  PLLVMExecutionEngineRef = ^LLVMExecutionEngineRef;
  LLVMMCJITMemoryManagerRef = Pointer;
  PLLVMMCJITMemoryManagerRef = ^LLVMMCJITMemoryManagerRef;

  LLVMMCJITCompilerOptions = record
    OptLevel: Cardinal;
    CodeModel: LLVMCodeModel;
    NoFramePointerElim: LLVMBool;
    EnableFastISel: LLVMBool;
    MCJMM: LLVMMCJITMemoryManagerRef;
  end;

  LLVMMemoryManagerAllocateCodeSectionCallback = function(Opaque: Pointer; Size: UIntPtr; Alignment: Cardinal; SectionID: Cardinal; const SectionName: PUTF8Char): PUInt8; cdecl;

  LLVMMemoryManagerAllocateDataSectionCallback = function(Opaque: Pointer; Size: UIntPtr; Alignment: Cardinal; SectionID: Cardinal; const SectionName: PUTF8Char; IsReadOnly: LLVMBool): PUInt8; cdecl;

  LLVMMemoryManagerFinalizeMemoryCallback = function(Opaque: Pointer; ErrMsg: PPUTF8Char): LLVMBool; cdecl;

  LLVMMemoryManagerDestroyCallback = procedure(Opaque: Pointer); cdecl;

  LLVMLinkerMode = (
    LLVMLinkerDestroySource = 0,
    LLVMLinkerPreserveSource_Removed = 1);
  PLLVMLinkerMode = ^LLVMLinkerMode;
  LLVMOrcJITTargetAddress = UInt64;
  LLVMOrcExecutorAddress = UInt64;
  PLLVMOrcExecutorAddress = ^LLVMOrcExecutorAddress;

  LLVMJITSymbolGenericFlags = (
    LLVMJITSymbolGenericFlagsNone = 0,
    LLVMJITSymbolGenericFlagsExported = 1,
    LLVMJITSymbolGenericFlagsWeak = 2,
    LLVMJITSymbolGenericFlagsCallable = 4,
    LLVMJITSymbolGenericFlagsMaterializationSideEffectsOnly = 8);
  PLLVMJITSymbolGenericFlags = ^LLVMJITSymbolGenericFlags;
  LLVMJITSymbolTargetFlags = UInt8;

  LLVMJITSymbolFlags = record
    GenericFlags: UInt8;
    TargetFlags: UInt8;
  end;

  LLVMJITEvaluatedSymbol = record
    Address: LLVMOrcExecutorAddress;
    Flags: LLVMJITSymbolFlags;
  end;

  LLVMOrcExecutionSessionRef = Pointer;
  PLLVMOrcExecutionSessionRef = ^LLVMOrcExecutionSessionRef;

  LLVMOrcErrorReporterFunction = procedure(Ctx: Pointer; Err: LLVMErrorRef); cdecl;
  LLVMOrcSymbolStringPoolRef = Pointer;
  PLLVMOrcSymbolStringPoolRef = ^LLVMOrcSymbolStringPoolRef;
  LLVMOrcSymbolStringPoolEntryRef = Pointer;
  PLLVMOrcSymbolStringPoolEntryRef = ^LLVMOrcSymbolStringPoolEntryRef;

  LLVMOrcCSymbolFlagsMapPair = record
    Name: LLVMOrcSymbolStringPoolEntryRef;
    Flags: LLVMJITSymbolFlags;
  end;

  LLVMOrcCSymbolFlagsMapPairs = PLLVMOrcCSymbolFlagsMapPair;

  LLVMOrcCSymbolMapPair = record
    Name: LLVMOrcSymbolStringPoolEntryRef;
    Sym: LLVMJITEvaluatedSymbol;
  end;

  LLVMOrcCSymbolMapPairs = PLLVMOrcCSymbolMapPair;

  LLVMOrcCSymbolAliasMapEntry = record
    Name: LLVMOrcSymbolStringPoolEntryRef;
    Flags: LLVMJITSymbolFlags;
  end;

  LLVMOrcCSymbolAliasMapPair = record
    Name: LLVMOrcSymbolStringPoolEntryRef;
    Entry: LLVMOrcCSymbolAliasMapEntry;
  end;

  LLVMOrcCSymbolAliasMapPairs = PLLVMOrcCSymbolAliasMapPair;
  LLVMOrcJITDylibRef = Pointer;
  PLLVMOrcJITDylibRef = ^LLVMOrcJITDylibRef;

  LLVMOrcCSymbolsList = record
    Symbols: PLLVMOrcSymbolStringPoolEntryRef;
    Length: NativeUInt;
  end;

  LLVMOrcCDependenceMapPair = record
    JD: LLVMOrcJITDylibRef;
    Names: LLVMOrcCSymbolsList;
  end;

  LLVMOrcCDependenceMapPairs = PLLVMOrcCDependenceMapPair;

  LLVMOrcCSymbolDependenceGroup = record
    Symbols: LLVMOrcCSymbolsList;
    Dependencies: LLVMOrcCDependenceMapPairs;
    NumDependencies: NativeUInt;
  end;

  LLVMOrcLookupKind = (
    LLVMOrcLookupKindStatic = 0,
    LLVMOrcLookupKindDLSym = 1);
  PLLVMOrcLookupKind = ^LLVMOrcLookupKind;

  LLVMOrcJITDylibLookupFlags = (
    LLVMOrcJITDylibLookupFlagsMatchExportedSymbolsOnly = 0,
    LLVMOrcJITDylibLookupFlagsMatchAllSymbols = 1);
  PLLVMOrcJITDylibLookupFlags = ^LLVMOrcJITDylibLookupFlags;

  LLVMOrcCJITDylibSearchOrderElement = record
    JD: LLVMOrcJITDylibRef;
    JDLookupFlags: LLVMOrcJITDylibLookupFlags;
  end;

  LLVMOrcCJITDylibSearchOrder = PLLVMOrcCJITDylibSearchOrderElement;

  LLVMOrcSymbolLookupFlags = (
    LLVMOrcSymbolLookupFlagsRequiredSymbol = 0,
    LLVMOrcSymbolLookupFlagsWeaklyReferencedSymbol = 1);
  PLLVMOrcSymbolLookupFlags = ^LLVMOrcSymbolLookupFlags;

  LLVMOrcCLookupSetElement = record
    Name: LLVMOrcSymbolStringPoolEntryRef;
    LookupFlags: LLVMOrcSymbolLookupFlags;
  end;

  LLVMOrcCLookupSet = PLLVMOrcCLookupSetElement;
  LLVMOrcMaterializationUnitRef = Pointer;
  PLLVMOrcMaterializationUnitRef = ^LLVMOrcMaterializationUnitRef;
  LLVMOrcMaterializationResponsibilityRef = Pointer;
  PLLVMOrcMaterializationResponsibilityRef = ^LLVMOrcMaterializationResponsibilityRef;

  LLVMOrcMaterializationUnitMaterializeFunction = procedure(Ctx: Pointer; MR: LLVMOrcMaterializationResponsibilityRef); cdecl;

  LLVMOrcMaterializationUnitDiscardFunction = procedure(Ctx: Pointer; JD: LLVMOrcJITDylibRef; Symbol: LLVMOrcSymbolStringPoolEntryRef); cdecl;

  LLVMOrcMaterializationUnitDestroyFunction = procedure(Ctx: Pointer); cdecl;
  LLVMOrcResourceTrackerRef = Pointer;
  PLLVMOrcResourceTrackerRef = ^LLVMOrcResourceTrackerRef;
  LLVMOrcDefinitionGeneratorRef = Pointer;
  PLLVMOrcDefinitionGeneratorRef = ^LLVMOrcDefinitionGeneratorRef;
  LLVMOrcLookupStateRef = Pointer;
  PLLVMOrcLookupStateRef = ^LLVMOrcLookupStateRef;

  LLVMOrcCAPIDefinitionGeneratorTryToGenerateFunction = function(GeneratorObj: LLVMOrcDefinitionGeneratorRef; Ctx: Pointer; LookupState: PLLVMOrcLookupStateRef; Kind: LLVMOrcLookupKind; JD: LLVMOrcJITDylibRef; JDLookupFlags: LLVMOrcJITDylibLookupFlags; LookupSet: LLVMOrcCLookupSet; LookupSetSize: NativeUInt): LLVMErrorRef; cdecl;

  LLVMOrcDisposeCAPIDefinitionGeneratorFunction = procedure(Ctx: Pointer); cdecl;

  LLVMOrcSymbolPredicate = function(Ctx: Pointer; Sym: LLVMOrcSymbolStringPoolEntryRef): Integer; cdecl;
  LLVMOrcThreadSafeContextRef = Pointer;
  PLLVMOrcThreadSafeContextRef = ^LLVMOrcThreadSafeContextRef;
  LLVMOrcThreadSafeModuleRef = Pointer;
  PLLVMOrcThreadSafeModuleRef = ^LLVMOrcThreadSafeModuleRef;

  LLVMOrcGenericIRModuleOperationFunction = function(Ctx: Pointer; M: LLVMModuleRef): LLVMErrorRef; cdecl;
  LLVMOrcJITTargetMachineBuilderRef = Pointer;
  PLLVMOrcJITTargetMachineBuilderRef = ^LLVMOrcJITTargetMachineBuilderRef;
  LLVMOrcObjectLayerRef = Pointer;
  PLLVMOrcObjectLayerRef = ^LLVMOrcObjectLayerRef;
  LLVMOrcObjectLinkingLayerRef = Pointer;
  PLLVMOrcObjectLinkingLayerRef = ^LLVMOrcObjectLinkingLayerRef;
  LLVMOrcIRTransformLayerRef = Pointer;
  PLLVMOrcIRTransformLayerRef = ^LLVMOrcIRTransformLayerRef;

  LLVMOrcIRTransformLayerTransformFunction = function(Ctx: Pointer; ModInOut: PLLVMOrcThreadSafeModuleRef; MR: LLVMOrcMaterializationResponsibilityRef): LLVMErrorRef; cdecl;
  LLVMOrcObjectTransformLayerRef = Pointer;
  PLLVMOrcObjectTransformLayerRef = ^LLVMOrcObjectTransformLayerRef;

  LLVMOrcObjectTransformLayerTransformFunction = function(Ctx: Pointer; ObjInOut: PLLVMMemoryBufferRef): LLVMErrorRef; cdecl;
  LLVMOrcIndirectStubsManagerRef = Pointer;
  PLLVMOrcIndirectStubsManagerRef = ^LLVMOrcIndirectStubsManagerRef;
  LLVMOrcLazyCallThroughManagerRef = Pointer;
  PLLVMOrcLazyCallThroughManagerRef = ^LLVMOrcLazyCallThroughManagerRef;
  LLVMOrcDumpObjectsRef = Pointer;
  PLLVMOrcDumpObjectsRef = ^LLVMOrcDumpObjectsRef;

  LLVMOrcExecutionSessionLookupHandleResultFunction = procedure(Err: LLVMErrorRef; Result: LLVMOrcCSymbolMapPairs; NumPairs: NativeUInt; Ctx: Pointer); cdecl;

  LLVMOrcLLJITBuilderObjectLinkingLayerCreatorFunction = function(Ctx: Pointer; ES: LLVMOrcExecutionSessionRef; const Triple: PUTF8Char): LLVMOrcObjectLayerRef; cdecl;
  LLVMOrcLLJITBuilderRef = Pointer;
  PLLVMOrcLLJITBuilderRef = ^LLVMOrcLLJITBuilderRef;
  LLVMOrcLLJITRef = Pointer;
  PLLVMOrcLLJITRef = ^LLVMOrcLLJITRef;
  LLVMSectionIteratorRef = Pointer;
  PLLVMSectionIteratorRef = ^LLVMSectionIteratorRef;
  LLVMSymbolIteratorRef = Pointer;
  PLLVMSymbolIteratorRef = ^LLVMSymbolIteratorRef;
  LLVMRelocationIteratorRef = Pointer;
  PLLVMRelocationIteratorRef = ^LLVMRelocationIteratorRef;

  LLVMBinaryType = (
    LLVMBinaryTypeArchive = 0,
    LLVMBinaryTypeMachOUniversalBinary = 1,
    LLVMBinaryTypeCOFFImportFile = 2,
    LLVMBinaryTypeIR = 3,
    LLVMBinaryTypeWinRes = 4,
    LLVMBinaryTypeCOFF = 5,
    LLVMBinaryTypeELF32L = 6,
    LLVMBinaryTypeELF32B = 7,
    LLVMBinaryTypeELF64L = 8,
    LLVMBinaryTypeELF64B = 9,
    LLVMBinaryTypeMachO32L = 10,
    LLVMBinaryTypeMachO32B = 11,
    LLVMBinaryTypeMachO64L = 12,
    LLVMBinaryTypeMachO64B = 13,
    LLVMBinaryTypeWasm = 14,
    LLVMBinaryTypeOffload = 15);
  PLLVMBinaryType = ^LLVMBinaryType;
  LLVMObjectFileRef = Pointer;
  PLLVMObjectFileRef = ^LLVMObjectFileRef;

  LLVMMemoryManagerCreateContextCallback = function(CtxCtx: Pointer): Pointer; cdecl;

  LLVMMemoryManagerNotifyTerminatingCallback = procedure(CtxCtx: Pointer); cdecl;

  LLVMRemarkType = (
    LLVMRemarkTypeUnknown = 0,
    LLVMRemarkTypePassed = 1,
    LLVMRemarkTypeMissed = 2,
    LLVMRemarkTypeAnalysis = 3,
    LLVMRemarkTypeAnalysisFPCommute = 4,
    LLVMRemarkTypeAnalysisAliasing = 5,
    LLVMRemarkTypeFailure = 6);
  PLLVMRemarkType = ^LLVMRemarkType;
  LLVMRemarkStringRef = Pointer;
  PLLVMRemarkStringRef = ^LLVMRemarkStringRef;
  LLVMRemarkDebugLocRef = Pointer;
  PLLVMRemarkDebugLocRef = ^LLVMRemarkDebugLocRef;
  LLVMRemarkArgRef = Pointer;
  PLLVMRemarkArgRef = ^LLVMRemarkArgRef;
  LLVMRemarkEntryRef = Pointer;
  PLLVMRemarkEntryRef = ^LLVMRemarkEntryRef;
  LLVMRemarkParserRef = Pointer;
  PLLVMRemarkParserRef = ^LLVMRemarkParserRef;
  LLVMPassBuilderOptionsRef = Pointer;
  PLLVMPassBuilderOptionsRef = ^LLVMPassBuilderOptionsRef;

var
  LLVMVerifyModule: function(M: LLVMModuleRef; Action: LLVMVerifierFailureAction; OutMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMVerifyFunction: function(Fn: LLVMValueRef; Action: LLVMVerifierFailureAction): LLVMBool; cdecl;
  LLVMViewFunctionCFG: procedure(Fn: LLVMValueRef); cdecl;
  LLVMViewFunctionCFGOnly: procedure(Fn: LLVMValueRef); cdecl;
  LLVMParseBitcode: function(MemBuf: LLVMMemoryBufferRef; OutModule: PLLVMModuleRef; OutMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMParseBitcode2: function(MemBuf: LLVMMemoryBufferRef; OutModule: PLLVMModuleRef): LLVMBool; cdecl;
  LLVMParseBitcodeInContext: function(ContextRef: LLVMContextRef; MemBuf: LLVMMemoryBufferRef; OutModule: PLLVMModuleRef; OutMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMParseBitcodeInContext2: function(ContextRef: LLVMContextRef; MemBuf: LLVMMemoryBufferRef; OutModule: PLLVMModuleRef): LLVMBool; cdecl;
  LLVMGetBitcodeModuleInContext: function(ContextRef: LLVMContextRef; MemBuf: LLVMMemoryBufferRef; OutM: PLLVMModuleRef; OutMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMGetBitcodeModuleInContext2: function(ContextRef: LLVMContextRef; MemBuf: LLVMMemoryBufferRef; OutM: PLLVMModuleRef): LLVMBool; cdecl;
  LLVMGetBitcodeModule: function(MemBuf: LLVMMemoryBufferRef; OutM: PLLVMModuleRef; OutMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMGetBitcodeModule2: function(MemBuf: LLVMMemoryBufferRef; OutM: PLLVMModuleRef): LLVMBool; cdecl;
  LLVMWriteBitcodeToFile: function(M: LLVMModuleRef; const Path: PUTF8Char): Integer; cdecl;
  LLVMWriteBitcodeToFD: function(M: LLVMModuleRef; FD: Integer; ShouldClose: Integer; Unbuffered: Integer): Integer; cdecl;
  LLVMWriteBitcodeToFileHandle: function(M: LLVMModuleRef; Handle: Integer): Integer; cdecl;
  LLVMWriteBitcodeToMemoryBuffer: function(M: LLVMModuleRef): LLVMMemoryBufferRef; cdecl;
  LLVMGetOrInsertComdat: function(M: LLVMModuleRef; const Name: PUTF8Char): LLVMComdatRef; cdecl;
  LLVMGetComdat: function(V: LLVMValueRef): LLVMComdatRef; cdecl;
  LLVMSetComdat: procedure(V: LLVMValueRef; C: LLVMComdatRef); cdecl;
  LLVMGetComdatSelectionKind: function(C: LLVMComdatRef): LLVMComdatSelectionKind; cdecl;
  LLVMSetComdatSelectionKind: procedure(C: LLVMComdatRef; Kind: LLVMComdatSelectionKind); cdecl;
  LLVMInstallFatalErrorHandler: procedure(Handler: LLVMFatalErrorHandler); cdecl;
  LLVMResetFatalErrorHandler: procedure(); cdecl;
  LLVMEnablePrettyStackTrace: procedure(); cdecl;
  LLVMShutdown: procedure(); cdecl;
  LLVMGetVersion: procedure(Major: PCardinal; Minor: PCardinal; Patch: PCardinal); cdecl;
  LLVMCreateMessage: function(const Message_: PUTF8Char): PUTF8Char; cdecl;
  LLVMDisposeMessage: procedure(Message_: PUTF8Char); cdecl;
  LLVMContextCreate: function(): LLVMContextRef; cdecl;
  LLVMGetGlobalContext: function(): LLVMContextRef; cdecl;
  LLVMContextSetDiagnosticHandler: procedure(C: LLVMContextRef; Handler: LLVMDiagnosticHandler; DiagnosticContext: Pointer); cdecl;
  LLVMContextGetDiagnosticHandler: function(C: LLVMContextRef): LLVMDiagnosticHandler; cdecl;
  LLVMContextGetDiagnosticContext: function(C: LLVMContextRef): Pointer; cdecl;
  LLVMContextSetYieldCallback: procedure(C: LLVMContextRef; Callback: LLVMYieldCallback; OpaqueHandle: Pointer); cdecl;
  LLVMContextShouldDiscardValueNames: function(C: LLVMContextRef): LLVMBool; cdecl;
  LLVMContextSetDiscardValueNames: procedure(C: LLVMContextRef; Discard: LLVMBool); cdecl;
  LLVMContextDispose: procedure(C: LLVMContextRef); cdecl;
  LLVMGetDiagInfoDescription: function(DI: LLVMDiagnosticInfoRef): PUTF8Char; cdecl;
  LLVMGetDiagInfoSeverity: function(DI: LLVMDiagnosticInfoRef): LLVMDiagnosticSeverity; cdecl;
  LLVMGetMDKindIDInContext: function(C: LLVMContextRef; const Name: PUTF8Char; SLen: Cardinal): Cardinal; cdecl;
  LLVMGetMDKindID: function(const Name: PUTF8Char; SLen: Cardinal): Cardinal; cdecl;
  LLVMGetSyncScopeID: function(C: LLVMContextRef; const Name: PUTF8Char; SLen: NativeUInt): Cardinal; cdecl;
  LLVMGetEnumAttributeKindForName: function(const Name: PUTF8Char; SLen: NativeUInt): Cardinal; cdecl;
  LLVMGetLastEnumAttributeKind: function(): Cardinal; cdecl;
  LLVMCreateEnumAttribute: function(C: LLVMContextRef; KindID: Cardinal; Val: UInt64): LLVMAttributeRef; cdecl;
  LLVMGetEnumAttributeKind: function(A: LLVMAttributeRef): Cardinal; cdecl;
  LLVMGetEnumAttributeValue: function(A: LLVMAttributeRef): UInt64; cdecl;
  LLVMCreateTypeAttribute: function(C: LLVMContextRef; KindID: Cardinal; type_ref: LLVMTypeRef): LLVMAttributeRef; cdecl;
  LLVMGetTypeAttributeValue: function(A: LLVMAttributeRef): LLVMTypeRef; cdecl;
  LLVMCreateConstantRangeAttribute: function(C: LLVMContextRef; KindID: Cardinal; NumBits: Cardinal; LowerWords: PUInt64; UpperWords: PUInt64): LLVMAttributeRef; cdecl;
  LLVMCreateStringAttribute: function(C: LLVMContextRef; const K: PUTF8Char; KLength: Cardinal; const V: PUTF8Char; VLength: Cardinal): LLVMAttributeRef; cdecl;
  LLVMGetStringAttributeKind: function(A: LLVMAttributeRef; Length: PCardinal): PUTF8Char; cdecl;
  LLVMGetStringAttributeValue: function(A: LLVMAttributeRef; Length: PCardinal): PUTF8Char; cdecl;
  LLVMIsEnumAttribute: function(A: LLVMAttributeRef): LLVMBool; cdecl;
  LLVMIsStringAttribute: function(A: LLVMAttributeRef): LLVMBool; cdecl;
  LLVMIsTypeAttribute: function(A: LLVMAttributeRef): LLVMBool; cdecl;
  LLVMGetTypeByName2: function(C: LLVMContextRef; const Name: PUTF8Char): LLVMTypeRef; cdecl;
  LLVMModuleCreateWithName: function(const ModuleID: PUTF8Char): LLVMModuleRef; cdecl;
  LLVMModuleCreateWithNameInContext: function(const ModuleID: PUTF8Char; C: LLVMContextRef): LLVMModuleRef; cdecl;
  LLVMCloneModule: function(M: LLVMModuleRef): LLVMModuleRef; cdecl;
  LLVMDisposeModule: procedure(M: LLVMModuleRef); cdecl;
  LLVMIsNewDbgInfoFormat: function(M: LLVMModuleRef): LLVMBool; cdecl;
  LLVMSetIsNewDbgInfoFormat: procedure(M: LLVMModuleRef; UseNewFormat: LLVMBool); cdecl;
  LLVMGetModuleIdentifier: function(M: LLVMModuleRef; Len: PNativeUInt): PUTF8Char; cdecl;
  LLVMSetModuleIdentifier: procedure(M: LLVMModuleRef; const Ident: PUTF8Char; Len: NativeUInt); cdecl;
  LLVMGetSourceFileName: function(M: LLVMModuleRef; Len: PNativeUInt): PUTF8Char; cdecl;
  LLVMSetSourceFileName: procedure(M: LLVMModuleRef; const Name: PUTF8Char; Len: NativeUInt); cdecl;
  LLVMGetDataLayoutStr: function(M: LLVMModuleRef): PUTF8Char; cdecl;
  LLVMGetDataLayout: function(M: LLVMModuleRef): PUTF8Char; cdecl;
  LLVMSetDataLayout: procedure(M: LLVMModuleRef; const DataLayoutStr: PUTF8Char); cdecl;
  LLVMGetTarget: function(M: LLVMModuleRef): PUTF8Char; cdecl;
  LLVMSetTarget: procedure(M: LLVMModuleRef; const Triple: PUTF8Char); cdecl;
  LLVMCopyModuleFlagsMetadata: function(M: LLVMModuleRef; Len: PNativeUInt): PLLVMModuleFlagEntry; cdecl;
  LLVMDisposeModuleFlagsMetadata: procedure(Entries: PLLVMModuleFlagEntry); cdecl;
  LLVMModuleFlagEntriesGetFlagBehavior: function(Entries: PLLVMModuleFlagEntry; Index: Cardinal): LLVMModuleFlagBehavior; cdecl;
  LLVMModuleFlagEntriesGetKey: function(Entries: PLLVMModuleFlagEntry; Index: Cardinal; Len: PNativeUInt): PUTF8Char; cdecl;
  LLVMModuleFlagEntriesGetMetadata: function(Entries: PLLVMModuleFlagEntry; Index: Cardinal): LLVMMetadataRef; cdecl;
  LLVMGetModuleFlag: function(M: LLVMModuleRef; const Key: PUTF8Char; KeyLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMAddModuleFlag: procedure(M: LLVMModuleRef; Behavior: LLVMModuleFlagBehavior; const Key: PUTF8Char; KeyLen: NativeUInt; Val: LLVMMetadataRef); cdecl;
  LLVMDumpModule: procedure(M: LLVMModuleRef); cdecl;
  LLVMPrintModuleToFile: function(M: LLVMModuleRef; const Filename: PUTF8Char; ErrorMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMPrintModuleToString: function(M: LLVMModuleRef): PUTF8Char; cdecl;
  LLVMGetModuleInlineAsm: function(M: LLVMModuleRef; Len: PNativeUInt): PUTF8Char; cdecl;
  LLVMSetModuleInlineAsm2: procedure(M: LLVMModuleRef; const Asm_: PUTF8Char; Len: NativeUInt); cdecl;
  LLVMAppendModuleInlineAsm: procedure(M: LLVMModuleRef; const Asm_: PUTF8Char; Len: NativeUInt); cdecl;
  LLVMGetInlineAsm: function(Ty: LLVMTypeRef; const AsmString: PUTF8Char; AsmStringSize: NativeUInt; const Constraints: PUTF8Char; ConstraintsSize: NativeUInt; HasSideEffects: LLVMBool; IsAlignStack: LLVMBool; Dialect: LLVMInlineAsmDialect; CanThrow: LLVMBool): LLVMValueRef; cdecl;
  LLVMGetInlineAsmAsmString: function(InlineAsmVal: LLVMValueRef; Len: PNativeUInt): PUTF8Char; cdecl;
  LLVMGetInlineAsmConstraintString: function(InlineAsmVal: LLVMValueRef; Len: PNativeUInt): PUTF8Char; cdecl;
  LLVMGetInlineAsmDialect: function(InlineAsmVal: LLVMValueRef): LLVMInlineAsmDialect; cdecl;
  LLVMGetInlineAsmFunctionType: function(InlineAsmVal: LLVMValueRef): LLVMTypeRef; cdecl;
  LLVMGetInlineAsmHasSideEffects: function(InlineAsmVal: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetInlineAsmNeedsAlignedStack: function(InlineAsmVal: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetInlineAsmCanUnwind: function(InlineAsmVal: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetModuleContext: function(M: LLVMModuleRef): LLVMContextRef; cdecl;
  LLVMGetTypeByName: function(M: LLVMModuleRef; const Name: PUTF8Char): LLVMTypeRef; cdecl;
  LLVMGetFirstNamedMetadata: function(M: LLVMModuleRef): LLVMNamedMDNodeRef; cdecl;
  LLVMGetLastNamedMetadata: function(M: LLVMModuleRef): LLVMNamedMDNodeRef; cdecl;
  LLVMGetNextNamedMetadata: function(NamedMDNode: LLVMNamedMDNodeRef): LLVMNamedMDNodeRef; cdecl;
  LLVMGetPreviousNamedMetadata: function(NamedMDNode: LLVMNamedMDNodeRef): LLVMNamedMDNodeRef; cdecl;
  LLVMGetNamedMetadata: function(M: LLVMModuleRef; const Name: PUTF8Char; NameLen: NativeUInt): LLVMNamedMDNodeRef; cdecl;
  LLVMGetOrInsertNamedMetadata: function(M: LLVMModuleRef; const Name: PUTF8Char; NameLen: NativeUInt): LLVMNamedMDNodeRef; cdecl;
  LLVMGetNamedMetadataName: function(NamedMD: LLVMNamedMDNodeRef; NameLen: PNativeUInt): PUTF8Char; cdecl;
  LLVMGetNamedMetadataNumOperands: function(M: LLVMModuleRef; const Name: PUTF8Char): Cardinal; cdecl;
  LLVMGetNamedMetadataOperands: procedure(M: LLVMModuleRef; const Name: PUTF8Char; Dest: PLLVMValueRef); cdecl;
  LLVMAddNamedMetadataOperand: procedure(M: LLVMModuleRef; const Name: PUTF8Char; Val: LLVMValueRef); cdecl;
  LLVMGetDebugLocDirectory: function(Val: LLVMValueRef; Length: PCardinal): PUTF8Char; cdecl;
  LLVMGetDebugLocFilename: function(Val: LLVMValueRef; Length: PCardinal): PUTF8Char; cdecl;
  LLVMGetDebugLocLine: function(Val: LLVMValueRef): Cardinal; cdecl;
  LLVMGetDebugLocColumn: function(Val: LLVMValueRef): Cardinal; cdecl;
  LLVMAddFunction: function(M: LLVMModuleRef; const Name: PUTF8Char; FunctionTy: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMGetNamedFunction: function(M: LLVMModuleRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMGetNamedFunctionWithLength: function(M: LLVMModuleRef; const Name: PUTF8Char; Length: NativeUInt): LLVMValueRef; cdecl;
  LLVMGetFirstFunction: function(M: LLVMModuleRef): LLVMValueRef; cdecl;
  LLVMGetLastFunction: function(M: LLVMModuleRef): LLVMValueRef; cdecl;
  LLVMGetNextFunction: function(Fn: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetPreviousFunction: function(Fn: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMSetModuleInlineAsm: procedure(M: LLVMModuleRef; const Asm_: PUTF8Char); cdecl;
  LLVMGetTypeKind: function(Ty: LLVMTypeRef): LLVMTypeKind; cdecl;
  LLVMTypeIsSized: function(Ty: LLVMTypeRef): LLVMBool; cdecl;
  LLVMGetTypeContext: function(Ty: LLVMTypeRef): LLVMContextRef; cdecl;
  LLVMDumpType: procedure(Val: LLVMTypeRef); cdecl;
  LLVMPrintTypeToString: function(Val: LLVMTypeRef): PUTF8Char; cdecl;
  LLVMInt1TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMInt8TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMInt16TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMInt32TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMInt64TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMInt128TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMIntTypeInContext: function(C: LLVMContextRef; NumBits: Cardinal): LLVMTypeRef; cdecl;
  LLVMInt1Type: function(): LLVMTypeRef; cdecl;
  LLVMInt8Type: function(): LLVMTypeRef; cdecl;
  LLVMInt16Type: function(): LLVMTypeRef; cdecl;
  LLVMInt32Type: function(): LLVMTypeRef; cdecl;
  LLVMInt64Type: function(): LLVMTypeRef; cdecl;
  LLVMInt128Type: function(): LLVMTypeRef; cdecl;
  LLVMIntType: function(NumBits: Cardinal): LLVMTypeRef; cdecl;
  LLVMGetIntTypeWidth: function(IntegerTy: LLVMTypeRef): Cardinal; cdecl;
  LLVMHalfTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMBFloatTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMFloatTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMDoubleTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMX86FP80TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMFP128TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMPPCFP128TypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMHalfType: function(): LLVMTypeRef; cdecl;
  LLVMBFloatType: function(): LLVMTypeRef; cdecl;
  LLVMFloatType: function(): LLVMTypeRef; cdecl;
  LLVMDoubleType: function(): LLVMTypeRef; cdecl;
  LLVMX86FP80Type: function(): LLVMTypeRef; cdecl;
  LLVMFP128Type: function(): LLVMTypeRef; cdecl;
  LLVMPPCFP128Type: function(): LLVMTypeRef; cdecl;
  LLVMFunctionType: function(ReturnType: LLVMTypeRef; ParamTypes: PLLVMTypeRef; ParamCount: Cardinal; IsVarArg: LLVMBool): LLVMTypeRef; cdecl;
  LLVMIsFunctionVarArg: function(FunctionTy: LLVMTypeRef): LLVMBool; cdecl;
  LLVMGetReturnType: function(FunctionTy: LLVMTypeRef): LLVMTypeRef; cdecl;
  LLVMCountParamTypes: function(FunctionTy: LLVMTypeRef): Cardinal; cdecl;
  LLVMGetParamTypes: procedure(FunctionTy: LLVMTypeRef; Dest: PLLVMTypeRef); cdecl;
  LLVMStructTypeInContext: function(C: LLVMContextRef; ElementTypes: PLLVMTypeRef; ElementCount: Cardinal; Packed_: LLVMBool): LLVMTypeRef; cdecl;
  LLVMStructType: function(ElementTypes: PLLVMTypeRef; ElementCount: Cardinal; Packed_: LLVMBool): LLVMTypeRef; cdecl;
  LLVMStructCreateNamed: function(C: LLVMContextRef; const Name: PUTF8Char): LLVMTypeRef; cdecl;
  LLVMGetStructName: function(Ty: LLVMTypeRef): PUTF8Char; cdecl;
  LLVMStructSetBody: procedure(StructTy: LLVMTypeRef; ElementTypes: PLLVMTypeRef; ElementCount: Cardinal; Packed_: LLVMBool); cdecl;
  LLVMCountStructElementTypes: function(StructTy: LLVMTypeRef): Cardinal; cdecl;
  LLVMGetStructElementTypes: procedure(StructTy: LLVMTypeRef; Dest: PLLVMTypeRef); cdecl;
  LLVMStructGetTypeAtIndex: function(StructTy: LLVMTypeRef; i: Cardinal): LLVMTypeRef; cdecl;
  LLVMIsPackedStruct: function(StructTy: LLVMTypeRef): LLVMBool; cdecl;
  LLVMIsOpaqueStruct: function(StructTy: LLVMTypeRef): LLVMBool; cdecl;
  LLVMIsLiteralStruct: function(StructTy: LLVMTypeRef): LLVMBool; cdecl;
  LLVMGetElementType: function(Ty: LLVMTypeRef): LLVMTypeRef; cdecl;
  LLVMGetSubtypes: procedure(Tp: LLVMTypeRef; Arr: PLLVMTypeRef); cdecl;
  LLVMGetNumContainedTypes: function(Tp: LLVMTypeRef): Cardinal; cdecl;
  LLVMArrayType: function(ElementType: LLVMTypeRef; ElementCount: Cardinal): LLVMTypeRef; cdecl;
  LLVMArrayType2: function(ElementType: LLVMTypeRef; ElementCount: UInt64): LLVMTypeRef; cdecl;
  LLVMGetArrayLength: function(ArrayTy: LLVMTypeRef): Cardinal; cdecl;
  LLVMGetArrayLength2: function(ArrayTy: LLVMTypeRef): UInt64; cdecl;
  LLVMPointerType: function(ElementType: LLVMTypeRef; AddressSpace: Cardinal): LLVMTypeRef; cdecl;
  LLVMPointerTypeIsOpaque: function(Ty: LLVMTypeRef): LLVMBool; cdecl;
  LLVMPointerTypeInContext: function(C: LLVMContextRef; AddressSpace: Cardinal): LLVMTypeRef; cdecl;
  LLVMGetPointerAddressSpace: function(PointerTy: LLVMTypeRef): Cardinal; cdecl;
  LLVMVectorType: function(ElementType: LLVMTypeRef; ElementCount: Cardinal): LLVMTypeRef; cdecl;
  LLVMScalableVectorType: function(ElementType: LLVMTypeRef; ElementCount: Cardinal): LLVMTypeRef; cdecl;
  LLVMGetVectorSize: function(VectorTy: LLVMTypeRef): Cardinal; cdecl;
  LLVMGetConstantPtrAuthPointer: function(PtrAuth: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetConstantPtrAuthKey: function(PtrAuth: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetConstantPtrAuthDiscriminator: function(PtrAuth: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetConstantPtrAuthAddrDiscriminator: function(PtrAuth: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMVoidTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMLabelTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMX86AMXTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMTokenTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMMetadataTypeInContext: function(C: LLVMContextRef): LLVMTypeRef; cdecl;
  LLVMVoidType: function(): LLVMTypeRef; cdecl;
  LLVMLabelType: function(): LLVMTypeRef; cdecl;
  LLVMX86AMXType: function(): LLVMTypeRef; cdecl;
  LLVMTargetExtTypeInContext: function(C: LLVMContextRef; const Name: PUTF8Char; TypeParams: PLLVMTypeRef; TypeParamCount: Cardinal; IntParams: PCardinal; IntParamCount: Cardinal): LLVMTypeRef; cdecl;
  LLVMGetTargetExtTypeName: function(TargetExtTy: LLVMTypeRef): PUTF8Char; cdecl;
  LLVMGetTargetExtTypeNumTypeParams: function(TargetExtTy: LLVMTypeRef): Cardinal; cdecl;
  LLVMGetTargetExtTypeTypeParam: function(TargetExtTy: LLVMTypeRef; Idx: Cardinal): LLVMTypeRef; cdecl;
  LLVMGetTargetExtTypeNumIntParams: function(TargetExtTy: LLVMTypeRef): Cardinal; cdecl;
  LLVMGetTargetExtTypeIntParam: function(TargetExtTy: LLVMTypeRef; Idx: Cardinal): Cardinal; cdecl;
  LLVMTypeOf: function(Val: LLVMValueRef): LLVMTypeRef; cdecl;
  LLVMGetValueKind: function(Val: LLVMValueRef): LLVMValueKind; cdecl;
  LLVMGetValueName2: function(Val: LLVMValueRef; Length: PNativeUInt): PUTF8Char; cdecl;
  LLVMSetValueName2: procedure(Val: LLVMValueRef; const Name: PUTF8Char; NameLen: NativeUInt); cdecl;
  LLVMDumpValue: procedure(Val: LLVMValueRef); cdecl;
  LLVMPrintValueToString: function(Val: LLVMValueRef): PUTF8Char; cdecl;
  LLVMGetValueContext: function(Val: LLVMValueRef): LLVMContextRef; cdecl;
  LLVMPrintDbgRecordToString: function(Record_: LLVMDbgRecordRef): PUTF8Char; cdecl;
  LLVMReplaceAllUsesWith: procedure(OldVal: LLVMValueRef; NewVal: LLVMValueRef); cdecl;
  LLVMIsConstant: function(Val: LLVMValueRef): LLVMBool; cdecl;
  LLVMIsUndef: function(Val: LLVMValueRef): LLVMBool; cdecl;
  LLVMIsPoison: function(Val: LLVMValueRef): LLVMBool; cdecl;
  LLVMIsAArgument: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsABasicBlock: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAInlineAsm: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAUser: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstant: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsABlockAddress: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantAggregateZero: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantArray: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantDataSequential: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantDataArray: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantDataVector: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantExpr: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantFP: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantInt: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantPointerNull: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantStruct: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantTokenNone: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantVector: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAConstantPtrAuth: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAGlobalValue: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAGlobalAlias: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAGlobalObject: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFunction: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAGlobalVariable: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAGlobalIFunc: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAUndefValue: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAPoisonValue: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAInstruction: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAUnaryOperator: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsABinaryOperator: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACallInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAIntrinsicInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsADbgInfoIntrinsic: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsADbgVariableIntrinsic: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsADbgDeclareInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsADbgLabelInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAMemIntrinsic: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAMemCpyInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAMemMoveInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAMemSetInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACmpInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFCmpInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAICmpInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAExtractElementInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAGetElementPtrInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAInsertElementInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAInsertValueInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsALandingPadInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAPHINode: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsASelectInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAShuffleVectorInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAStoreInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsABranchInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAIndirectBrInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAInvokeInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAReturnInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsASwitchInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAUnreachableInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAResumeInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACleanupReturnInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACatchReturnInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACatchSwitchInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACallBrInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFuncletPadInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACatchPadInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACleanupPadInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAUnaryInstruction: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAAllocaInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsACastInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAAddrSpaceCastInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsABitCastInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFPExtInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFPToSIInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFPToUIInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFPTruncInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAIntToPtrInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAPtrToIntInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsASExtInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsASIToFPInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsATruncInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAUIToFPInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAZExtInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAExtractValueInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsALoadInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAVAArgInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFreezeInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAAtomicCmpXchgInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAAtomicRMWInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAFenceInst: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAMDNode: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAValueAsMetadata: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsAMDString: function(Val: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetValueName: function(Val: LLVMValueRef): PUTF8Char; cdecl;
  LLVMSetValueName: procedure(Val: LLVMValueRef; const Name: PUTF8Char); cdecl;
  LLVMGetFirstUse: function(Val: LLVMValueRef): LLVMUseRef; cdecl;
  LLVMGetNextUse: function(U: LLVMUseRef): LLVMUseRef; cdecl;
  LLVMGetUser: function(U: LLVMUseRef): LLVMValueRef; cdecl;
  LLVMGetUsedValue: function(U: LLVMUseRef): LLVMValueRef; cdecl;
  LLVMGetOperand: function(Val: LLVMValueRef; Index: Cardinal): LLVMValueRef; cdecl;
  LLVMGetOperandUse: function(Val: LLVMValueRef; Index: Cardinal): LLVMUseRef; cdecl;
  LLVMSetOperand: procedure(User: LLVMValueRef; Index: Cardinal; Val: LLVMValueRef); cdecl;
  LLVMGetNumOperands: function(Val: LLVMValueRef): Integer; cdecl;
  LLVMConstNull: function(Ty: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstAllOnes: function(Ty: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMGetUndef: function(Ty: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMGetPoison: function(Ty: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMIsNull: function(Val: LLVMValueRef): LLVMBool; cdecl;
  LLVMConstPointerNull: function(Ty: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstInt: function(IntTy: LLVMTypeRef; N: UInt64; SignExtend: LLVMBool): LLVMValueRef; cdecl;
  LLVMConstIntOfArbitraryPrecision: function(IntTy: LLVMTypeRef; NumWords: Cardinal; Words: PUInt64): LLVMValueRef; cdecl;
  LLVMConstIntOfString: function(IntTy: LLVMTypeRef; const Text: PUTF8Char; Radix: UInt8): LLVMValueRef; cdecl;
  LLVMConstIntOfStringAndSize: function(IntTy: LLVMTypeRef; const Text: PUTF8Char; SLen: Cardinal; Radix: UInt8): LLVMValueRef; cdecl;
  LLVMConstReal: function(RealTy: LLVMTypeRef; N: Double): LLVMValueRef; cdecl;
  LLVMConstRealOfString: function(RealTy: LLVMTypeRef; const Text: PUTF8Char): LLVMValueRef; cdecl;
  LLVMConstRealOfStringAndSize: function(RealTy: LLVMTypeRef; const Text: PUTF8Char; SLen: Cardinal): LLVMValueRef; cdecl;
  LLVMConstIntGetZExtValue: function(ConstantVal: LLVMValueRef): UInt64; cdecl;
  LLVMConstIntGetSExtValue: function(ConstantVal: LLVMValueRef): Int64; cdecl;
  LLVMConstRealGetDouble: function(ConstantVal: LLVMValueRef; losesInfo: PLLVMBool): Double; cdecl;
  LLVMConstStringInContext: function(C: LLVMContextRef; const Str: PUTF8Char; Length: Cardinal; DontNullTerminate: LLVMBool): LLVMValueRef; cdecl;
  LLVMConstStringInContext2: function(C: LLVMContextRef; const Str: PUTF8Char; Length: NativeUInt; DontNullTerminate: LLVMBool): LLVMValueRef; cdecl;
  LLVMConstString: function(const Str: PUTF8Char; Length: Cardinal; DontNullTerminate: LLVMBool): LLVMValueRef; cdecl;
  LLVMIsConstantString: function(c: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetAsString: function(c: LLVMValueRef; Length: PNativeUInt): PUTF8Char; cdecl;
  LLVMGetRawDataValues: function(c: LLVMValueRef; SizeInBytes: PNativeUInt): PUTF8Char; cdecl;
  LLVMConstStructInContext: function(C: LLVMContextRef; ConstantVals: PLLVMValueRef; Count: Cardinal; Packed_: LLVMBool): LLVMValueRef; cdecl;
  LLVMConstStruct: function(ConstantVals: PLLVMValueRef; Count: Cardinal; Packed_: LLVMBool): LLVMValueRef; cdecl;
  LLVMConstArray: function(ElementTy: LLVMTypeRef; ConstantVals: PLLVMValueRef; Length: Cardinal): LLVMValueRef; cdecl;
  LLVMConstArray2: function(ElementTy: LLVMTypeRef; ConstantVals: PLLVMValueRef; Length: UInt64): LLVMValueRef; cdecl;
  LLVMConstDataArray: function(ElementTy: LLVMTypeRef; const Data: PUTF8Char; SizeInBytes: NativeUInt): LLVMValueRef; cdecl;
  LLVMConstNamedStruct: function(StructTy: LLVMTypeRef; ConstantVals: PLLVMValueRef; Count: Cardinal): LLVMValueRef; cdecl;
  LLVMGetAggregateElement: function(C: LLVMValueRef; Idx: Cardinal): LLVMValueRef; cdecl;
  LLVMGetElementAsConstant: function(C: LLVMValueRef; idx: Cardinal): LLVMValueRef; cdecl;
  LLVMConstVector: function(ScalarConstantVals: PLLVMValueRef; Size: Cardinal): LLVMValueRef; cdecl;
  LLVMConstantPtrAuth: function(Ptr: LLVMValueRef; Key: LLVMValueRef; Disc: LLVMValueRef; AddrDisc: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetConstOpcode: function(ConstantVal: LLVMValueRef): LLVMOpcode; cdecl;
  LLVMAlignOf: function(Ty: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMSizeOf: function(Ty: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstNeg: function(ConstantVal: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstNSWNeg: function(ConstantVal: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstNUWNeg: function(ConstantVal: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstNot: function(ConstantVal: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstAdd: function(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstNSWAdd: function(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstNUWAdd: function(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstSub: function(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstNSWSub: function(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstNUWSub: function(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstXor: function(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstGEP2: function(Ty: LLVMTypeRef; ConstantVal: LLVMValueRef; ConstantIndices: PLLVMValueRef; NumIndices: Cardinal): LLVMValueRef; cdecl;
  LLVMConstInBoundsGEP2: function(Ty: LLVMTypeRef; ConstantVal: LLVMValueRef; ConstantIndices: PLLVMValueRef; NumIndices: Cardinal): LLVMValueRef; cdecl;
  LLVMConstGEPWithNoWrapFlags: function(Ty: LLVMTypeRef; ConstantVal: LLVMValueRef; ConstantIndices: PLLVMValueRef; NumIndices: Cardinal; NoWrapFlags: LLVMGEPNoWrapFlags): LLVMValueRef; cdecl;
  LLVMConstTrunc: function(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstPtrToInt: function(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstIntToPtr: function(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstBitCast: function(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstAddrSpaceCast: function(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstTruncOrBitCast: function(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstPointerCast: function(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef; cdecl;
  LLVMConstExtractElement: function(VectorConstant: LLVMValueRef; IndexConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstInsertElement: function(VectorConstant: LLVMValueRef; ElementValueConstant: LLVMValueRef; IndexConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMConstShuffleVector: function(VectorAConstant: LLVMValueRef; VectorBConstant: LLVMValueRef; MaskConstant: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMBlockAddress: function(F: LLVMValueRef; BB: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMGetBlockAddressFunction: function(BlockAddr: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetBlockAddressBasicBlock: function(BlockAddr: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMConstInlineAsm: function(Ty: LLVMTypeRef; const AsmString: PUTF8Char; const Constraints: PUTF8Char; HasSideEffects: LLVMBool; IsAlignStack: LLVMBool): LLVMValueRef; cdecl;
  LLVMGetGlobalParent: function(Global: LLVMValueRef): LLVMModuleRef; cdecl;
  LLVMIsDeclaration: function(Global: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetLinkage: function(Global: LLVMValueRef): LLVMLinkage; cdecl;
  LLVMSetLinkage: procedure(Global: LLVMValueRef; Linkage: LLVMLinkage); cdecl;
  LLVMGetSection: function(Global: LLVMValueRef): PUTF8Char; cdecl;
  LLVMSetSection: procedure(Global: LLVMValueRef; const Section: PUTF8Char); cdecl;
  LLVMGetVisibility: function(Global: LLVMValueRef): LLVMVisibility; cdecl;
  LLVMSetVisibility: procedure(Global: LLVMValueRef; Viz: LLVMVisibility); cdecl;
  LLVMGetDLLStorageClass: function(Global: LLVMValueRef): LLVMDLLStorageClass; cdecl;
  LLVMSetDLLStorageClass: procedure(Global: LLVMValueRef; Class_: LLVMDLLStorageClass); cdecl;
  LLVMGetUnnamedAddress: function(Global: LLVMValueRef): LLVMUnnamedAddr; cdecl;
  LLVMSetUnnamedAddress: procedure(Global: LLVMValueRef; UnnamedAddr: LLVMUnnamedAddr); cdecl;
  LLVMGlobalGetValueType: function(Global: LLVMValueRef): LLVMTypeRef; cdecl;
  LLVMHasUnnamedAddr: function(Global: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetUnnamedAddr: procedure(Global: LLVMValueRef; HasUnnamedAddr: LLVMBool); cdecl;
  LLVMGetAlignment: function(V: LLVMValueRef): Cardinal; cdecl;
  LLVMSetAlignment: procedure(V: LLVMValueRef; Bytes: Cardinal); cdecl;
  LLVMGlobalSetMetadata: procedure(Global: LLVMValueRef; Kind: Cardinal; MD: LLVMMetadataRef); cdecl;
  LLVMGlobalEraseMetadata: procedure(Global: LLVMValueRef; Kind: Cardinal); cdecl;
  LLVMGlobalClearMetadata: procedure(Global: LLVMValueRef); cdecl;
  LLVMGlobalCopyAllMetadata: function(Value: LLVMValueRef; NumEntries: PNativeUInt): PLLVMValueMetadataEntry; cdecl;
  LLVMDisposeValueMetadataEntries: procedure(Entries: PLLVMValueMetadataEntry); cdecl;
  LLVMValueMetadataEntriesGetKind: function(Entries: PLLVMValueMetadataEntry; Index: Cardinal): Cardinal; cdecl;
  LLVMValueMetadataEntriesGetMetadata: function(Entries: PLLVMValueMetadataEntry; Index: Cardinal): LLVMMetadataRef; cdecl;
  LLVMAddGlobal: function(M: LLVMModuleRef; Ty: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMAddGlobalInAddressSpace: function(M: LLVMModuleRef; Ty: LLVMTypeRef; const Name: PUTF8Char; AddressSpace: Cardinal): LLVMValueRef; cdecl;
  LLVMGetNamedGlobal: function(M: LLVMModuleRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMGetNamedGlobalWithLength: function(M: LLVMModuleRef; const Name: PUTF8Char; Length: NativeUInt): LLVMValueRef; cdecl;
  LLVMGetFirstGlobal: function(M: LLVMModuleRef): LLVMValueRef; cdecl;
  LLVMGetLastGlobal: function(M: LLVMModuleRef): LLVMValueRef; cdecl;
  LLVMGetNextGlobal: function(GlobalVar: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetPreviousGlobal: function(GlobalVar: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMDeleteGlobal: procedure(GlobalVar: LLVMValueRef); cdecl;
  LLVMGetInitializer: function(GlobalVar: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMSetInitializer: procedure(GlobalVar: LLVMValueRef; ConstantVal: LLVMValueRef); cdecl;
  LLVMIsThreadLocal: function(GlobalVar: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetThreadLocal: procedure(GlobalVar: LLVMValueRef; IsThreadLocal: LLVMBool); cdecl;
  LLVMIsGlobalConstant: function(GlobalVar: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetGlobalConstant: procedure(GlobalVar: LLVMValueRef; IsConstant: LLVMBool); cdecl;
  LLVMGetThreadLocalMode: function(GlobalVar: LLVMValueRef): LLVMThreadLocalMode; cdecl;
  LLVMSetThreadLocalMode: procedure(GlobalVar: LLVMValueRef; Mode: LLVMThreadLocalMode); cdecl;
  LLVMIsExternallyInitialized: function(GlobalVar: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetExternallyInitialized: procedure(GlobalVar: LLVMValueRef; IsExtInit: LLVMBool); cdecl;
  LLVMAddAlias2: function(M: LLVMModuleRef; ValueTy: LLVMTypeRef; AddrSpace: Cardinal; Aliasee: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMGetNamedGlobalAlias: function(M: LLVMModuleRef; const Name: PUTF8Char; NameLen: NativeUInt): LLVMValueRef; cdecl;
  LLVMGetFirstGlobalAlias: function(M: LLVMModuleRef): LLVMValueRef; cdecl;
  LLVMGetLastGlobalAlias: function(M: LLVMModuleRef): LLVMValueRef; cdecl;
  LLVMGetNextGlobalAlias: function(GA: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetPreviousGlobalAlias: function(GA: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMAliasGetAliasee: function(Alias: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMAliasSetAliasee: procedure(Alias: LLVMValueRef; Aliasee: LLVMValueRef); cdecl;
  LLVMDeleteFunction: procedure(Fn: LLVMValueRef); cdecl;
  LLVMHasPersonalityFn: function(Fn: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetPersonalityFn: function(Fn: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMSetPersonalityFn: procedure(Fn: LLVMValueRef; PersonalityFn: LLVMValueRef); cdecl;
  LLVMLookupIntrinsicID: function(const Name: PUTF8Char; NameLen: NativeUInt): Cardinal; cdecl;
  LLVMGetIntrinsicID: function(Fn: LLVMValueRef): Cardinal; cdecl;
  LLVMGetIntrinsicDeclaration: function(Mod_: LLVMModuleRef; ID: Cardinal; ParamTypes: PLLVMTypeRef; ParamCount: NativeUInt): LLVMValueRef; cdecl;
  LLVMIntrinsicGetType: function(Ctx: LLVMContextRef; ID: Cardinal; ParamTypes: PLLVMTypeRef; ParamCount: NativeUInt): LLVMTypeRef; cdecl;
  LLVMIntrinsicGetName: function(ID: Cardinal; NameLength: PNativeUInt): PUTF8Char; cdecl;
  LLVMIntrinsicCopyOverloadedName: function(ID: Cardinal; ParamTypes: PLLVMTypeRef; ParamCount: NativeUInt; NameLength: PNativeUInt): PUTF8Char; cdecl;
  LLVMIntrinsicCopyOverloadedName2: function(Mod_: LLVMModuleRef; ID: Cardinal; ParamTypes: PLLVMTypeRef; ParamCount: NativeUInt; NameLength: PNativeUInt): PUTF8Char; cdecl;
  LLVMIntrinsicIsOverloaded: function(ID: Cardinal): LLVMBool; cdecl;
  LLVMGetFunctionCallConv: function(Fn: LLVMValueRef): Cardinal; cdecl;
  LLVMSetFunctionCallConv: procedure(Fn: LLVMValueRef; CC: Cardinal); cdecl;
  LLVMGetGC: function(Fn: LLVMValueRef): PUTF8Char; cdecl;
  LLVMSetGC: procedure(Fn: LLVMValueRef; const Name: PUTF8Char); cdecl;
  LLVMGetPrefixData: function(Fn: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMHasPrefixData: function(Fn: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetPrefixData: procedure(Fn: LLVMValueRef; prefixData: LLVMValueRef); cdecl;
  LLVMGetPrologueData: function(Fn: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMHasPrologueData: function(Fn: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetPrologueData: procedure(Fn: LLVMValueRef; prologueData: LLVMValueRef); cdecl;
  LLVMAddAttributeAtIndex: procedure(F: LLVMValueRef; Idx: LLVMAttributeIndex; A: LLVMAttributeRef); cdecl;
  LLVMGetAttributeCountAtIndex: function(F: LLVMValueRef; Idx: LLVMAttributeIndex): Cardinal; cdecl;
  LLVMGetAttributesAtIndex: procedure(F: LLVMValueRef; Idx: LLVMAttributeIndex; Attrs: PLLVMAttributeRef); cdecl;
  LLVMGetEnumAttributeAtIndex: function(F: LLVMValueRef; Idx: LLVMAttributeIndex; KindID: Cardinal): LLVMAttributeRef; cdecl;
  LLVMGetStringAttributeAtIndex: function(F: LLVMValueRef; Idx: LLVMAttributeIndex; const K: PUTF8Char; KLen: Cardinal): LLVMAttributeRef; cdecl;
  LLVMRemoveEnumAttributeAtIndex: procedure(F: LLVMValueRef; Idx: LLVMAttributeIndex; KindID: Cardinal); cdecl;
  LLVMRemoveStringAttributeAtIndex: procedure(F: LLVMValueRef; Idx: LLVMAttributeIndex; const K: PUTF8Char; KLen: Cardinal); cdecl;
  LLVMAddTargetDependentFunctionAttr: procedure(Fn: LLVMValueRef; const A: PUTF8Char; const V: PUTF8Char); cdecl;
  LLVMCountParams: function(Fn: LLVMValueRef): Cardinal; cdecl;
  LLVMGetParams: procedure(Fn: LLVMValueRef; Params: PLLVMValueRef); cdecl;
  LLVMGetParam: function(Fn: LLVMValueRef; Index: Cardinal): LLVMValueRef; cdecl;
  LLVMGetParamParent: function(Inst: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetFirstParam: function(Fn: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetLastParam: function(Fn: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetNextParam: function(Arg: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetPreviousParam: function(Arg: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMSetParamAlignment: procedure(Arg: LLVMValueRef; Align: Cardinal); cdecl;
  LLVMAddGlobalIFunc: function(M: LLVMModuleRef; const Name: PUTF8Char; NameLen: NativeUInt; Ty: LLVMTypeRef; AddrSpace: Cardinal; Resolver: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetNamedGlobalIFunc: function(M: LLVMModuleRef; const Name: PUTF8Char; NameLen: NativeUInt): LLVMValueRef; cdecl;
  LLVMGetFirstGlobalIFunc: function(M: LLVMModuleRef): LLVMValueRef; cdecl;
  LLVMGetLastGlobalIFunc: function(M: LLVMModuleRef): LLVMValueRef; cdecl;
  LLVMGetNextGlobalIFunc: function(IFunc: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetPreviousGlobalIFunc: function(IFunc: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetGlobalIFuncResolver: function(IFunc: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMSetGlobalIFuncResolver: procedure(IFunc: LLVMValueRef; Resolver: LLVMValueRef); cdecl;
  LLVMEraseGlobalIFunc: procedure(IFunc: LLVMValueRef); cdecl;
  LLVMRemoveGlobalIFunc: procedure(IFunc: LLVMValueRef); cdecl;
  LLVMMDStringInContext2: function(C: LLVMContextRef; const Str: PUTF8Char; SLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMMDNodeInContext2: function(C: LLVMContextRef; MDs: PLLVMMetadataRef; Count: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMMetadataAsValue: function(C: LLVMContextRef; MD: LLVMMetadataRef): LLVMValueRef; cdecl;
  LLVMValueAsMetadata: function(Val: LLVMValueRef): LLVMMetadataRef; cdecl;
  LLVMGetMDString: function(V: LLVMValueRef; Length: PCardinal): PUTF8Char; cdecl;
  LLVMGetMDNodeNumOperands: function(V: LLVMValueRef): Cardinal; cdecl;
  LLVMGetMDNodeOperands: procedure(V: LLVMValueRef; Dest: PLLVMValueRef); cdecl;
  LLVMReplaceMDNodeOperandWith: procedure(V: LLVMValueRef; Index: Cardinal; Replacement: LLVMMetadataRef); cdecl;
  LLVMMDStringInContext: function(C: LLVMContextRef; const Str: PUTF8Char; SLen: Cardinal): LLVMValueRef; cdecl;
  LLVMMDString: function(const Str: PUTF8Char; SLen: Cardinal): LLVMValueRef; cdecl;
  LLVMMDNodeInContext: function(C: LLVMContextRef; Vals: PLLVMValueRef; Count: Cardinal): LLVMValueRef; cdecl;
  LLVMMDNode: function(Vals: PLLVMValueRef; Count: Cardinal): LLVMValueRef; cdecl;
  LLVMCreateOperandBundle: function(const Tag: PUTF8Char; TagLen: NativeUInt; Args: PLLVMValueRef; NumArgs: Cardinal): LLVMOperandBundleRef; cdecl;
  LLVMDisposeOperandBundle: procedure(Bundle: LLVMOperandBundleRef); cdecl;
  LLVMGetOperandBundleTag: function(Bundle: LLVMOperandBundleRef; Len: PNativeUInt): PUTF8Char; cdecl;
  LLVMGetNumOperandBundleArgs: function(Bundle: LLVMOperandBundleRef): Cardinal; cdecl;
  LLVMGetOperandBundleArgAtIndex: function(Bundle: LLVMOperandBundleRef; Index: Cardinal): LLVMValueRef; cdecl;
  LLVMBasicBlockAsValue: function(BB: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMValueIsBasicBlock: function(Val: LLVMValueRef): LLVMBool; cdecl;
  LLVMValueAsBasicBlock: function(Val: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMGetBasicBlockName: function(BB: LLVMBasicBlockRef): PUTF8Char; cdecl;
  LLVMGetBasicBlockParent: function(BB: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMGetBasicBlockTerminator: function(BB: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMCountBasicBlocks: function(Fn: LLVMValueRef): Cardinal; cdecl;
  LLVMGetBasicBlocks: procedure(Fn: LLVMValueRef; BasicBlocks: PLLVMBasicBlockRef); cdecl;
  LLVMGetFirstBasicBlock: function(Fn: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMGetLastBasicBlock: function(Fn: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMGetNextBasicBlock: function(BB: LLVMBasicBlockRef): LLVMBasicBlockRef; cdecl;
  LLVMGetPreviousBasicBlock: function(BB: LLVMBasicBlockRef): LLVMBasicBlockRef; cdecl;
  LLVMGetEntryBasicBlock: function(Fn: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMInsertExistingBasicBlockAfterInsertBlock: procedure(Builder: LLVMBuilderRef; BB: LLVMBasicBlockRef); cdecl;
  LLVMAppendExistingBasicBlock: procedure(Fn: LLVMValueRef; BB: LLVMBasicBlockRef); cdecl;
  LLVMCreateBasicBlockInContext: function(C: LLVMContextRef; const Name: PUTF8Char): LLVMBasicBlockRef; cdecl;
  LLVMAppendBasicBlockInContext: function(C: LLVMContextRef; Fn: LLVMValueRef; const Name: PUTF8Char): LLVMBasicBlockRef; cdecl;
  LLVMAppendBasicBlock: function(Fn: LLVMValueRef; const Name: PUTF8Char): LLVMBasicBlockRef; cdecl;
  LLVMInsertBasicBlockInContext: function(C: LLVMContextRef; BB: LLVMBasicBlockRef; const Name: PUTF8Char): LLVMBasicBlockRef; cdecl;
  LLVMInsertBasicBlock: function(InsertBeforeBB: LLVMBasicBlockRef; const Name: PUTF8Char): LLVMBasicBlockRef; cdecl;
  LLVMDeleteBasicBlock: procedure(BB: LLVMBasicBlockRef); cdecl;
  LLVMRemoveBasicBlockFromParent: procedure(BB: LLVMBasicBlockRef); cdecl;
  LLVMMoveBasicBlockBefore: procedure(BB: LLVMBasicBlockRef; MovePos: LLVMBasicBlockRef); cdecl;
  LLVMMoveBasicBlockAfter: procedure(BB: LLVMBasicBlockRef; MovePos: LLVMBasicBlockRef); cdecl;
  LLVMGetFirstInstruction: function(BB: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMGetLastInstruction: function(BB: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMHasMetadata: function(Val: LLVMValueRef): Integer; cdecl;
  LLVMGetMetadata: function(Val: LLVMValueRef; KindID: Cardinal): LLVMValueRef; cdecl;
  LLVMSetMetadata: procedure(Val: LLVMValueRef; KindID: Cardinal; Node: LLVMValueRef); cdecl;
  LLVMInstructionGetAllMetadataOtherThanDebugLoc: function(Instr: LLVMValueRef; NumEntries: PNativeUInt): PLLVMValueMetadataEntry; cdecl;
  LLVMGetInstructionParent: function(Inst: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMGetNextInstruction: function(Inst: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetPreviousInstruction: function(Inst: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMInstructionRemoveFromParent: procedure(Inst: LLVMValueRef); cdecl;
  LLVMInstructionEraseFromParent: procedure(Inst: LLVMValueRef); cdecl;
  LLVMDeleteInstruction: procedure(Inst: LLVMValueRef); cdecl;
  LLVMGetInstructionOpcode: function(Inst: LLVMValueRef): LLVMOpcode; cdecl;
  LLVMGetICmpPredicate: function(Inst: LLVMValueRef): LLVMIntPredicate; cdecl;
  LLVMGetICmpSameSign: function(Inst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetICmpSameSign: procedure(Inst: LLVMValueRef; SameSign: LLVMBool); cdecl;
  LLVMGetFCmpPredicate: function(Inst: LLVMValueRef): LLVMRealPredicate; cdecl;
  LLVMInstructionClone: function(Inst: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMIsATerminatorInst: function(Inst: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetFirstDbgRecord: function(Inst: LLVMValueRef): LLVMDbgRecordRef; cdecl;
  LLVMGetLastDbgRecord: function(Inst: LLVMValueRef): LLVMDbgRecordRef; cdecl;
  LLVMGetNextDbgRecord: function(DbgRecord: LLVMDbgRecordRef): LLVMDbgRecordRef; cdecl;
  LLVMGetPreviousDbgRecord: function(DbgRecord: LLVMDbgRecordRef): LLVMDbgRecordRef; cdecl;
  LLVMGetNumArgOperands: function(Instr: LLVMValueRef): Cardinal; cdecl;
  LLVMSetInstructionCallConv: procedure(Instr: LLVMValueRef; CC: Cardinal); cdecl;
  LLVMGetInstructionCallConv: function(Instr: LLVMValueRef): Cardinal; cdecl;
  LLVMSetInstrParamAlignment: procedure(Instr: LLVMValueRef; Idx: LLVMAttributeIndex; Align: Cardinal); cdecl;
  LLVMAddCallSiteAttribute: procedure(C: LLVMValueRef; Idx: LLVMAttributeIndex; A: LLVMAttributeRef); cdecl;
  LLVMGetCallSiteAttributeCount: function(C: LLVMValueRef; Idx: LLVMAttributeIndex): Cardinal; cdecl;
  LLVMGetCallSiteAttributes: procedure(C: LLVMValueRef; Idx: LLVMAttributeIndex; Attrs: PLLVMAttributeRef); cdecl;
  LLVMGetCallSiteEnumAttribute: function(C: LLVMValueRef; Idx: LLVMAttributeIndex; KindID: Cardinal): LLVMAttributeRef; cdecl;
  LLVMGetCallSiteStringAttribute: function(C: LLVMValueRef; Idx: LLVMAttributeIndex; const K: PUTF8Char; KLen: Cardinal): LLVMAttributeRef; cdecl;
  LLVMRemoveCallSiteEnumAttribute: procedure(C: LLVMValueRef; Idx: LLVMAttributeIndex; KindID: Cardinal); cdecl;
  LLVMRemoveCallSiteStringAttribute: procedure(C: LLVMValueRef; Idx: LLVMAttributeIndex; const K: PUTF8Char; KLen: Cardinal); cdecl;
  LLVMGetCalledFunctionType: function(C: LLVMValueRef): LLVMTypeRef; cdecl;
  LLVMGetCalledValue: function(Instr: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMGetNumOperandBundles: function(C: LLVMValueRef): Cardinal; cdecl;
  LLVMGetOperandBundleAtIndex: function(C: LLVMValueRef; Index: Cardinal): LLVMOperandBundleRef; cdecl;
  LLVMIsTailCall: function(CallInst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetTailCall: procedure(CallInst: LLVMValueRef; IsTailCall: LLVMBool); cdecl;
  LLVMGetTailCallKind: function(CallInst: LLVMValueRef): LLVMTailCallKind; cdecl;
  LLVMSetTailCallKind: procedure(CallInst: LLVMValueRef; kind: LLVMTailCallKind); cdecl;
  LLVMGetNormalDest: function(InvokeInst: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMGetUnwindDest: function(InvokeInst: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMSetNormalDest: procedure(InvokeInst: LLVMValueRef; B: LLVMBasicBlockRef); cdecl;
  LLVMSetUnwindDest: procedure(InvokeInst: LLVMValueRef; B: LLVMBasicBlockRef); cdecl;
  LLVMGetCallBrDefaultDest: function(CallBr: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMGetCallBrNumIndirectDests: function(CallBr: LLVMValueRef): Cardinal; cdecl;
  LLVMGetCallBrIndirectDest: function(CallBr: LLVMValueRef; Idx: Cardinal): LLVMBasicBlockRef; cdecl;
  LLVMGetNumSuccessors: function(Term: LLVMValueRef): Cardinal; cdecl;
  LLVMGetSuccessor: function(Term: LLVMValueRef; i: Cardinal): LLVMBasicBlockRef; cdecl;
  LLVMSetSuccessor: procedure(Term: LLVMValueRef; i: Cardinal; block: LLVMBasicBlockRef); cdecl;
  LLVMIsConditional: function(Branch: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetCondition: function(Branch: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMSetCondition: procedure(Branch: LLVMValueRef; Cond: LLVMValueRef); cdecl;
  LLVMGetSwitchDefaultDest: function(SwitchInstr: LLVMValueRef): LLVMBasicBlockRef; cdecl;
  LLVMGetAllocatedType: function(Alloca: LLVMValueRef): LLVMTypeRef; cdecl;
  LLVMIsInBounds: function(GEP: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetIsInBounds: procedure(GEP: LLVMValueRef; InBounds: LLVMBool); cdecl;
  LLVMGetGEPSourceElementType: function(GEP: LLVMValueRef): LLVMTypeRef; cdecl;
  LLVMGEPGetNoWrapFlags: function(GEP: LLVMValueRef): LLVMGEPNoWrapFlags; cdecl;
  LLVMGEPSetNoWrapFlags: procedure(GEP: LLVMValueRef; NoWrapFlags: LLVMGEPNoWrapFlags); cdecl;
  LLVMAddIncoming: procedure(PhiNode: LLVMValueRef; IncomingValues: PLLVMValueRef; IncomingBlocks: PLLVMBasicBlockRef; Count: Cardinal); cdecl;
  LLVMCountIncoming: function(PhiNode: LLVMValueRef): Cardinal; cdecl;
  LLVMGetIncomingValue: function(PhiNode: LLVMValueRef; Index: Cardinal): LLVMValueRef; cdecl;
  LLVMGetIncomingBlock: function(PhiNode: LLVMValueRef; Index: Cardinal): LLVMBasicBlockRef; cdecl;
  LLVMGetNumIndices: function(Inst: LLVMValueRef): Cardinal; cdecl;
  LLVMGetIndices: function(Inst: LLVMValueRef): PCardinal; cdecl;
  LLVMCreateBuilderInContext: function(C: LLVMContextRef): LLVMBuilderRef; cdecl;
  LLVMCreateBuilder: function(): LLVMBuilderRef; cdecl;
  LLVMPositionBuilder: procedure(Builder: LLVMBuilderRef; Block: LLVMBasicBlockRef; Instr: LLVMValueRef); cdecl;
  LLVMPositionBuilderBeforeDbgRecords: procedure(Builder: LLVMBuilderRef; Block: LLVMBasicBlockRef; Inst: LLVMValueRef); cdecl;
  LLVMPositionBuilderBefore: procedure(Builder: LLVMBuilderRef; Instr: LLVMValueRef); cdecl;
  LLVMPositionBuilderBeforeInstrAndDbgRecords: procedure(Builder: LLVMBuilderRef; Instr: LLVMValueRef); cdecl;
  LLVMPositionBuilderAtEnd: procedure(Builder: LLVMBuilderRef; Block: LLVMBasicBlockRef); cdecl;
  LLVMGetInsertBlock: function(Builder: LLVMBuilderRef): LLVMBasicBlockRef; cdecl;
  LLVMClearInsertionPosition: procedure(Builder: LLVMBuilderRef); cdecl;
  LLVMInsertIntoBuilder: procedure(Builder: LLVMBuilderRef; Instr: LLVMValueRef); cdecl;
  LLVMInsertIntoBuilderWithName: procedure(Builder: LLVMBuilderRef; Instr: LLVMValueRef; const Name: PUTF8Char); cdecl;
  LLVMDisposeBuilder: procedure(Builder: LLVMBuilderRef); cdecl;
  LLVMGetCurrentDebugLocation2: function(Builder: LLVMBuilderRef): LLVMMetadataRef; cdecl;
  LLVMSetCurrentDebugLocation2: procedure(Builder: LLVMBuilderRef; Loc: LLVMMetadataRef); cdecl;
  LLVMSetInstDebugLocation: procedure(Builder: LLVMBuilderRef; Inst: LLVMValueRef); cdecl;
  LLVMAddMetadataToInst: procedure(Builder: LLVMBuilderRef; Inst: LLVMValueRef); cdecl;
  LLVMBuilderGetDefaultFPMathTag: function(Builder: LLVMBuilderRef): LLVMMetadataRef; cdecl;
  LLVMBuilderSetDefaultFPMathTag: procedure(Builder: LLVMBuilderRef; FPMathTag: LLVMMetadataRef); cdecl;
  LLVMGetBuilderContext: function(Builder: LLVMBuilderRef): LLVMContextRef; cdecl;
  LLVMSetCurrentDebugLocation: procedure(Builder: LLVMBuilderRef; L: LLVMValueRef); cdecl;
  LLVMGetCurrentDebugLocation: function(Builder: LLVMBuilderRef): LLVMValueRef; cdecl;
  LLVMBuildRetVoid: function(p1: LLVMBuilderRef): LLVMValueRef; cdecl;
  LLVMBuildRet: function(p1: LLVMBuilderRef; V: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMBuildAggregateRet: function(p1: LLVMBuilderRef; RetVals: PLLVMValueRef; N: Cardinal): LLVMValueRef; cdecl;
  LLVMBuildBr: function(p1: LLVMBuilderRef; Dest: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMBuildCondBr: function(p1: LLVMBuilderRef; If_: LLVMValueRef; Then_: LLVMBasicBlockRef; Else_: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMBuildSwitch: function(p1: LLVMBuilderRef; V: LLVMValueRef; Else_: LLVMBasicBlockRef; NumCases: Cardinal): LLVMValueRef; cdecl;
  LLVMBuildIndirectBr: function(B: LLVMBuilderRef; Addr: LLVMValueRef; NumDests: Cardinal): LLVMValueRef; cdecl;
  LLVMBuildCallBr: function(B: LLVMBuilderRef; Ty: LLVMTypeRef; Fn: LLVMValueRef; DefaultDest: LLVMBasicBlockRef; IndirectDests: PLLVMBasicBlockRef; NumIndirectDests: Cardinal; Args: PLLVMValueRef; NumArgs: Cardinal; Bundles: PLLVMOperandBundleRef; NumBundles: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildInvoke2: function(p1: LLVMBuilderRef; Ty: LLVMTypeRef; Fn: LLVMValueRef; Args: PLLVMValueRef; NumArgs: Cardinal; Then_: LLVMBasicBlockRef; Catch: LLVMBasicBlockRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildInvokeWithOperandBundles: function(p1: LLVMBuilderRef; Ty: LLVMTypeRef; Fn: LLVMValueRef; Args: PLLVMValueRef; NumArgs: Cardinal; Then_: LLVMBasicBlockRef; Catch: LLVMBasicBlockRef; Bundles: PLLVMOperandBundleRef; NumBundles: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildUnreachable: function(p1: LLVMBuilderRef): LLVMValueRef; cdecl;
  LLVMBuildResume: function(B: LLVMBuilderRef; Exn: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMBuildLandingPad: function(B: LLVMBuilderRef; Ty: LLVMTypeRef; PersFn: LLVMValueRef; NumClauses: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildCleanupRet: function(B: LLVMBuilderRef; CatchPad: LLVMValueRef; BB: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMBuildCatchRet: function(B: LLVMBuilderRef; CatchPad: LLVMValueRef; BB: LLVMBasicBlockRef): LLVMValueRef; cdecl;
  LLVMBuildCatchPad: function(B: LLVMBuilderRef; ParentPad: LLVMValueRef; Args: PLLVMValueRef; NumArgs: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildCleanupPad: function(B: LLVMBuilderRef; ParentPad: LLVMValueRef; Args: PLLVMValueRef; NumArgs: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildCatchSwitch: function(B: LLVMBuilderRef; ParentPad: LLVMValueRef; UnwindBB: LLVMBasicBlockRef; NumHandlers: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMAddCase: procedure(Switch: LLVMValueRef; OnVal: LLVMValueRef; Dest: LLVMBasicBlockRef); cdecl;
  LLVMAddDestination: procedure(IndirectBr: LLVMValueRef; Dest: LLVMBasicBlockRef); cdecl;
  LLVMGetNumClauses: function(LandingPad: LLVMValueRef): Cardinal; cdecl;
  LLVMGetClause: function(LandingPad: LLVMValueRef; Idx: Cardinal): LLVMValueRef; cdecl;
  LLVMAddClause: procedure(LandingPad: LLVMValueRef; ClauseVal: LLVMValueRef); cdecl;
  LLVMIsCleanup: function(LandingPad: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetCleanup: procedure(LandingPad: LLVMValueRef; Val: LLVMBool); cdecl;
  LLVMAddHandler: procedure(CatchSwitch: LLVMValueRef; Dest: LLVMBasicBlockRef); cdecl;
  LLVMGetNumHandlers: function(CatchSwitch: LLVMValueRef): Cardinal; cdecl;
  LLVMGetHandlers: procedure(CatchSwitch: LLVMValueRef; Handlers: PLLVMBasicBlockRef); cdecl;
  LLVMGetArgOperand: function(Funclet: LLVMValueRef; i: Cardinal): LLVMValueRef; cdecl;
  LLVMSetArgOperand: procedure(Funclet: LLVMValueRef; i: Cardinal; value: LLVMValueRef); cdecl;
  LLVMGetParentCatchSwitch: function(CatchPad: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMSetParentCatchSwitch: procedure(CatchPad: LLVMValueRef; CatchSwitch: LLVMValueRef); cdecl;
  LLVMBuildAdd: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNSWAdd: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNUWAdd: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFAdd: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildSub: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNSWSub: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNUWSub: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFSub: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildMul: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNSWMul: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNUWMul: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFMul: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildUDiv: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildExactUDiv: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildSDiv: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildExactSDiv: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFDiv: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildURem: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildSRem: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFRem: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildShl: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildLShr: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildAShr: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildAnd: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildOr: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildXor: function(p1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildBinOp: function(B: LLVMBuilderRef; Op: LLVMOpcode; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNeg: function(p1: LLVMBuilderRef; V: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNSWNeg: function(B: LLVMBuilderRef; V: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNUWNeg: function(B: LLVMBuilderRef; V: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFNeg: function(p1: LLVMBuilderRef; V: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildNot: function(p1: LLVMBuilderRef; V: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMGetNUW: function(ArithInst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetNUW: procedure(ArithInst: LLVMValueRef; HasNUW: LLVMBool); cdecl;
  LLVMGetNSW: function(ArithInst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetNSW: procedure(ArithInst: LLVMValueRef; HasNSW: LLVMBool); cdecl;
  LLVMGetExact: function(DivOrShrInst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetExact: procedure(DivOrShrInst: LLVMValueRef; IsExact: LLVMBool); cdecl;
  LLVMGetNNeg: function(NonNegInst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetNNeg: procedure(NonNegInst: LLVMValueRef; IsNonNeg: LLVMBool); cdecl;
  LLVMGetFastMathFlags: function(FPMathInst: LLVMValueRef): LLVMFastMathFlags; cdecl;
  LLVMSetFastMathFlags: procedure(FPMathInst: LLVMValueRef; FMF: LLVMFastMathFlags); cdecl;
  LLVMCanValueUseFastMathFlags: function(Inst: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetIsDisjoint: function(Inst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetIsDisjoint: procedure(Inst: LLVMValueRef; IsDisjoint: LLVMBool); cdecl;
  LLVMBuildMalloc: function(p1: LLVMBuilderRef; Ty: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildArrayMalloc: function(p1: LLVMBuilderRef; Ty: LLVMTypeRef; Val: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildMemSet: function(B: LLVMBuilderRef; Ptr: LLVMValueRef; Val: LLVMValueRef; Len: LLVMValueRef; Align: Cardinal): LLVMValueRef; cdecl;
  LLVMBuildMemCpy: function(B: LLVMBuilderRef; Dst: LLVMValueRef; DstAlign: Cardinal; Src: LLVMValueRef; SrcAlign: Cardinal; Size: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMBuildMemMove: function(B: LLVMBuilderRef; Dst: LLVMValueRef; DstAlign: Cardinal; Src: LLVMValueRef; SrcAlign: Cardinal; Size: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMBuildAlloca: function(p1: LLVMBuilderRef; Ty: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildArrayAlloca: function(p1: LLVMBuilderRef; Ty: LLVMTypeRef; Val: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFree: function(p1: LLVMBuilderRef; PointerVal: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMBuildLoad2: function(p1: LLVMBuilderRef; Ty: LLVMTypeRef; PointerVal: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildStore: function(p1: LLVMBuilderRef; Val: LLVMValueRef; Ptr: LLVMValueRef): LLVMValueRef; cdecl;
  LLVMBuildGEP2: function(B: LLVMBuilderRef; Ty: LLVMTypeRef; Pointer: LLVMValueRef; Indices: PLLVMValueRef; NumIndices: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildInBoundsGEP2: function(B: LLVMBuilderRef; Ty: LLVMTypeRef; Pointer: LLVMValueRef; Indices: PLLVMValueRef; NumIndices: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildGEPWithNoWrapFlags: function(B: LLVMBuilderRef; Ty: LLVMTypeRef; Pointer: LLVMValueRef; Indices: PLLVMValueRef; NumIndices: Cardinal; const Name: PUTF8Char; NoWrapFlags: LLVMGEPNoWrapFlags): LLVMValueRef; cdecl;
  LLVMBuildStructGEP2: function(B: LLVMBuilderRef; Ty: LLVMTypeRef; Pointer: LLVMValueRef; Idx: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildGlobalString: function(B: LLVMBuilderRef; const Str: PUTF8Char; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildGlobalStringPtr: function(B: LLVMBuilderRef; const Str: PUTF8Char; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMGetVolatile: function(MemoryAccessInst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetVolatile: procedure(MemoryAccessInst: LLVMValueRef; IsVolatile: LLVMBool); cdecl;
  LLVMGetWeak: function(CmpXchgInst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetWeak: procedure(CmpXchgInst: LLVMValueRef; IsWeak: LLVMBool); cdecl;
  LLVMGetOrdering: function(MemoryAccessInst: LLVMValueRef): LLVMAtomicOrdering; cdecl;
  LLVMSetOrdering: procedure(MemoryAccessInst: LLVMValueRef; Ordering: LLVMAtomicOrdering); cdecl;
  LLVMGetAtomicRMWBinOp: function(AtomicRMWInst: LLVMValueRef): LLVMAtomicRMWBinOp; cdecl;
  LLVMSetAtomicRMWBinOp: procedure(AtomicRMWInst: LLVMValueRef; BinOp: LLVMAtomicRMWBinOp); cdecl;
  LLVMBuildTrunc: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildZExt: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildSExt: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFPToUI: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFPToSI: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildUIToFP: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildSIToFP: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFPTrunc: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFPExt: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildPtrToInt: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildIntToPtr: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildBitCast: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildAddrSpaceCast: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildZExtOrBitCast: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildSExtOrBitCast: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildTruncOrBitCast: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildCast: function(B: LLVMBuilderRef; Op: LLVMOpcode; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildPointerCast: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildIntCast2: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; IsSigned: LLVMBool; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFPCast: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildIntCast: function(p1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMGetCastOpcode: function(Src: LLVMValueRef; SrcIsSigned: LLVMBool; DestTy: LLVMTypeRef; DestIsSigned: LLVMBool): LLVMOpcode; cdecl;
  LLVMBuildICmp: function(p1: LLVMBuilderRef; Op: LLVMIntPredicate; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFCmp: function(p1: LLVMBuilderRef; Op: LLVMRealPredicate; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildPhi: function(p1: LLVMBuilderRef; Ty: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildCall2: function(p1: LLVMBuilderRef; p2: LLVMTypeRef; Fn: LLVMValueRef; Args: PLLVMValueRef; NumArgs: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildCallWithOperandBundles: function(p1: LLVMBuilderRef; p2: LLVMTypeRef; Fn: LLVMValueRef; Args: PLLVMValueRef; NumArgs: Cardinal; Bundles: PLLVMOperandBundleRef; NumBundles: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildSelect: function(p1: LLVMBuilderRef; If_: LLVMValueRef; Then_: LLVMValueRef; Else_: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildVAArg: function(p1: LLVMBuilderRef; List: LLVMValueRef; Ty: LLVMTypeRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildExtractElement: function(p1: LLVMBuilderRef; VecVal: LLVMValueRef; Index: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildInsertElement: function(p1: LLVMBuilderRef; VecVal: LLVMValueRef; EltVal: LLVMValueRef; Index: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildShuffleVector: function(p1: LLVMBuilderRef; V1: LLVMValueRef; V2: LLVMValueRef; Mask: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildExtractValue: function(p1: LLVMBuilderRef; AggVal: LLVMValueRef; Index: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildInsertValue: function(p1: LLVMBuilderRef; AggVal: LLVMValueRef; EltVal: LLVMValueRef; Index: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFreeze: function(p1: LLVMBuilderRef; Val: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildIsNull: function(p1: LLVMBuilderRef; Val: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildIsNotNull: function(p1: LLVMBuilderRef; Val: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildPtrDiff2: function(p1: LLVMBuilderRef; ElemTy: LLVMTypeRef; LHS: LLVMValueRef; RHS: LLVMValueRef; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFence: function(B: LLVMBuilderRef; ordering: LLVMAtomicOrdering; singleThread: LLVMBool; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildFenceSyncScope: function(B: LLVMBuilderRef; ordering: LLVMAtomicOrdering; SSID: Cardinal; const Name: PUTF8Char): LLVMValueRef; cdecl;
  LLVMBuildAtomicRMW: function(B: LLVMBuilderRef; op: LLVMAtomicRMWBinOp; PTR: LLVMValueRef; Val: LLVMValueRef; ordering: LLVMAtomicOrdering; singleThread: LLVMBool): LLVMValueRef; cdecl;
  LLVMBuildAtomicRMWSyncScope: function(B: LLVMBuilderRef; op: LLVMAtomicRMWBinOp; PTR: LLVMValueRef; Val: LLVMValueRef; ordering: LLVMAtomicOrdering; SSID: Cardinal): LLVMValueRef; cdecl;
  LLVMBuildAtomicCmpXchg: function(B: LLVMBuilderRef; Ptr: LLVMValueRef; Cmp: LLVMValueRef; New: LLVMValueRef; SuccessOrdering: LLVMAtomicOrdering; FailureOrdering: LLVMAtomicOrdering; SingleThread: LLVMBool): LLVMValueRef; cdecl;
  LLVMBuildAtomicCmpXchgSyncScope: function(B: LLVMBuilderRef; Ptr: LLVMValueRef; Cmp: LLVMValueRef; New: LLVMValueRef; SuccessOrdering: LLVMAtomicOrdering; FailureOrdering: LLVMAtomicOrdering; SSID: Cardinal): LLVMValueRef; cdecl;
  LLVMGetNumMaskElements: function(ShuffleVectorInst: LLVMValueRef): Cardinal; cdecl;
  LLVMGetUndefMaskElem: function(): Integer; cdecl;
  LLVMGetMaskValue: function(ShuffleVectorInst: LLVMValueRef; Elt: Cardinal): Integer; cdecl;
  LLVMIsAtomicSingleThread: function(AtomicInst: LLVMValueRef): LLVMBool; cdecl;
  LLVMSetAtomicSingleThread: procedure(AtomicInst: LLVMValueRef; SingleThread: LLVMBool); cdecl;
  LLVMIsAtomic: function(Inst: LLVMValueRef): LLVMBool; cdecl;
  LLVMGetAtomicSyncScopeID: function(AtomicInst: LLVMValueRef): Cardinal; cdecl;
  LLVMSetAtomicSyncScopeID: procedure(AtomicInst: LLVMValueRef; SSID: Cardinal); cdecl;
  LLVMGetCmpXchgSuccessOrdering: function(CmpXchgInst: LLVMValueRef): LLVMAtomicOrdering; cdecl;
  LLVMSetCmpXchgSuccessOrdering: procedure(CmpXchgInst: LLVMValueRef; Ordering: LLVMAtomicOrdering); cdecl;
  LLVMGetCmpXchgFailureOrdering: function(CmpXchgInst: LLVMValueRef): LLVMAtomicOrdering; cdecl;
  LLVMSetCmpXchgFailureOrdering: procedure(CmpXchgInst: LLVMValueRef; Ordering: LLVMAtomicOrdering); cdecl;
  LLVMCreateModuleProviderForExistingModule: function(M: LLVMModuleRef): LLVMModuleProviderRef; cdecl;
  LLVMDisposeModuleProvider: procedure(M: LLVMModuleProviderRef); cdecl;
  LLVMCreateMemoryBufferWithContentsOfFile: function(const Path: PUTF8Char; OutMemBuf: PLLVMMemoryBufferRef; OutMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMCreateMemoryBufferWithSTDIN: function(OutMemBuf: PLLVMMemoryBufferRef; OutMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMCreateMemoryBufferWithMemoryRange: function(const InputData: PUTF8Char; InputDataLength: NativeUInt; const BufferName: PUTF8Char; RequiresNullTerminator: LLVMBool): LLVMMemoryBufferRef; cdecl;
  LLVMCreateMemoryBufferWithMemoryRangeCopy: function(const InputData: PUTF8Char; InputDataLength: NativeUInt; const BufferName: PUTF8Char): LLVMMemoryBufferRef; cdecl;
  LLVMGetBufferStart: function(MemBuf: LLVMMemoryBufferRef): PUTF8Char; cdecl;
  LLVMGetBufferSize: function(MemBuf: LLVMMemoryBufferRef): NativeUInt; cdecl;
  LLVMDisposeMemoryBuffer: procedure(MemBuf: LLVMMemoryBufferRef); cdecl;
  LLVMCreatePassManager: function(): LLVMPassManagerRef; cdecl;
  LLVMCreateFunctionPassManagerForModule: function(M: LLVMModuleRef): LLVMPassManagerRef; cdecl;
  LLVMCreateFunctionPassManager: function(MP: LLVMModuleProviderRef): LLVMPassManagerRef; cdecl;
  LLVMRunPassManager: function(PM: LLVMPassManagerRef; M: LLVMModuleRef): LLVMBool; cdecl;
  LLVMInitializeFunctionPassManager: function(FPM: LLVMPassManagerRef): LLVMBool; cdecl;
  LLVMRunFunctionPassManager: function(FPM: LLVMPassManagerRef; F: LLVMValueRef): LLVMBool; cdecl;
  LLVMFinalizeFunctionPassManager: function(FPM: LLVMPassManagerRef): LLVMBool; cdecl;
  LLVMDisposePassManager: procedure(PM: LLVMPassManagerRef); cdecl;
  LLVMStartMultithreaded: function(): LLVMBool; cdecl;
  LLVMStopMultithreaded: procedure(); cdecl;
  LLVMIsMultithreaded: function(): LLVMBool; cdecl;
  LLVMDebugMetadataVersion: function(): Cardinal; cdecl;
  LLVMGetModuleDebugMetadataVersion: function(Module: LLVMModuleRef): Cardinal; cdecl;
  LLVMStripModuleDebugInfo: function(Module: LLVMModuleRef): LLVMBool; cdecl;
  LLVMCreateDIBuilderDisallowUnresolved: function(M: LLVMModuleRef): LLVMDIBuilderRef; cdecl;
  LLVMCreateDIBuilder: function(M: LLVMModuleRef): LLVMDIBuilderRef; cdecl;
  LLVMDisposeDIBuilder: procedure(Builder: LLVMDIBuilderRef); cdecl;
  LLVMDIBuilderFinalize: procedure(Builder: LLVMDIBuilderRef); cdecl;
  LLVMDIBuilderFinalizeSubprogram: procedure(Builder: LLVMDIBuilderRef; Subprogram: LLVMMetadataRef); cdecl;
  LLVMDIBuilderCreateCompileUnit: function(Builder: LLVMDIBuilderRef; Lang: LLVMDWARFSourceLanguage; FileRef: LLVMMetadataRef; const Producer: PUTF8Char; ProducerLen: NativeUInt; isOptimized: LLVMBool; const Flags: PUTF8Char; FlagsLen: NativeUInt; RuntimeVer: Cardinal; const SplitName: PUTF8Char; SplitNameLen: NativeUInt; Kind: LLVMDWARFEmissionKind; DWOId: Cardinal; SplitDebugInlining: LLVMBool; DebugInfoForProfiling: LLVMBool; const SysRoot: PUTF8Char; SysRootLen: NativeUInt; const SDK: PUTF8Char; SDKLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateFile: function(Builder: LLVMDIBuilderRef; const Filename: PUTF8Char; FilenameLen: NativeUInt; const Directory: PUTF8Char; DirectoryLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateModule: function(Builder: LLVMDIBuilderRef; ParentScope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; const ConfigMacros: PUTF8Char; ConfigMacrosLen: NativeUInt; const IncludePath: PUTF8Char; IncludePathLen: NativeUInt; const APINotesFile: PUTF8Char; APINotesFileLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateNameSpace: function(Builder: LLVMDIBuilderRef; ParentScope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; ExportSymbols: LLVMBool): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateFunction: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; const LinkageName: PUTF8Char; LinkageNameLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; Ty: LLVMMetadataRef; IsLocalToUnit: LLVMBool; IsDefinition: LLVMBool; ScopeLine: Cardinal; Flags: LLVMDIFlags; IsOptimized: LLVMBool): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateLexicalBlock: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; File_: LLVMMetadataRef; Line: Cardinal; Column: Cardinal): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateLexicalBlockFile: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; File_: LLVMMetadataRef; Discriminator: Cardinal): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateImportedModuleFromNamespace: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; NS: LLVMMetadataRef; File_: LLVMMetadataRef; Line: Cardinal): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateImportedModuleFromAlias: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; ImportedEntity: LLVMMetadataRef; File_: LLVMMetadataRef; Line: Cardinal; Elements: PLLVMMetadataRef; NumElements: Cardinal): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateImportedModuleFromModule: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; M: LLVMMetadataRef; File_: LLVMMetadataRef; Line: Cardinal; Elements: PLLVMMetadataRef; NumElements: Cardinal): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateImportedDeclaration: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; Decl: LLVMMetadataRef; File_: LLVMMetadataRef; Line: Cardinal; const Name: PUTF8Char; NameLen: NativeUInt; Elements: PLLVMMetadataRef; NumElements: Cardinal): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateDebugLocation: function(Ctx: LLVMContextRef; Line: Cardinal; Column: Cardinal; Scope: LLVMMetadataRef; InlinedAt: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDILocationGetLine: function(Location: LLVMMetadataRef): Cardinal; cdecl;
  LLVMDILocationGetColumn: function(Location: LLVMMetadataRef): Cardinal; cdecl;
  LLVMDILocationGetScope: function(Location: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDILocationGetInlinedAt: function(Location: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIScopeGetFile: function(Scope: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIFileGetDirectory: function(File_: LLVMMetadataRef; Len: PCardinal): PUTF8Char; cdecl;
  LLVMDIFileGetFilename: function(File_: LLVMMetadataRef; Len: PCardinal): PUTF8Char; cdecl;
  LLVMDIFileGetSource: function(File_: LLVMMetadataRef; Len: PCardinal): PUTF8Char; cdecl;
  LLVMDIBuilderGetOrCreateTypeArray: function(Builder: LLVMDIBuilderRef; Data: PLLVMMetadataRef; NumElements: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateSubroutineType: function(Builder: LLVMDIBuilderRef; File_: LLVMMetadataRef; ParameterTypes: PLLVMMetadataRef; NumParameterTypes: Cardinal; Flags: LLVMDIFlags): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateMacro: function(Builder: LLVMDIBuilderRef; ParentMacroFile: LLVMMetadataRef; Line: Cardinal; RecordType: LLVMDWARFMacinfoRecordType; const Name: PUTF8Char; NameLen: NativeUInt; const Value: PUTF8Char; ValueLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateTempMacroFile: function(Builder: LLVMDIBuilderRef; ParentMacroFile: LLVMMetadataRef; Line: Cardinal; File_: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateEnumerator: function(Builder: LLVMDIBuilderRef; const Name: PUTF8Char; NameLen: NativeUInt; Value: Int64; IsUnsigned: LLVMBool): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateEnumeratorOfArbitraryPrecision: function(Builder: LLVMDIBuilderRef; const Name: PUTF8Char; NameLen: NativeUInt; SizeInBits: UInt64; Words: PUInt64; IsUnsigned: LLVMBool): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateEnumerationType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNumber: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; Elements: PLLVMMetadataRef; NumElements: Cardinal; ClassTy: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateUnionType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNumber: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; Flags: LLVMDIFlags; Elements: PLLVMMetadataRef; NumElements: Cardinal; RunTimeLang: Cardinal; const UniqueId: PUTF8Char; UniqueIdLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateArrayType: function(Builder: LLVMDIBuilderRef; Size: UInt64; AlignInBits: UInt32; Ty: LLVMMetadataRef; Subscripts: PLLVMMetadataRef; NumSubscripts: Cardinal): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateSetType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNumber: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; BaseTy: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateSubrangeType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; LineNo: Cardinal; File_: LLVMMetadataRef; SizeInBits: UInt64; AlignInBits: UInt32; Flags: LLVMDIFlags; BaseTy: LLVMMetadataRef; LowerBound: LLVMMetadataRef; UpperBound: LLVMMetadataRef; Stride: LLVMMetadataRef; Bias: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateDynamicArrayType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; LineNo: Cardinal; File_: LLVMMetadataRef; Size: UInt64; AlignInBits: UInt32; Ty: LLVMMetadataRef; Subscripts: PLLVMMetadataRef; NumSubscripts: Cardinal; DataLocation: LLVMMetadataRef; Associated: LLVMMetadataRef; Allocated: LLVMMetadataRef; Rank: LLVMMetadataRef; BitStride: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMReplaceArrays: procedure(Builder: LLVMDIBuilderRef; T: PLLVMMetadataRef; Elements: PLLVMMetadataRef; NumElements: Cardinal); cdecl;
  LLVMDIBuilderCreateVectorType: function(Builder: LLVMDIBuilderRef; Size: UInt64; AlignInBits: UInt32; Ty: LLVMMetadataRef; Subscripts: PLLVMMetadataRef; NumSubscripts: Cardinal): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateUnspecifiedType: function(Builder: LLVMDIBuilderRef; const Name: PUTF8Char; NameLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateBasicType: function(Builder: LLVMDIBuilderRef; const Name: PUTF8Char; NameLen: NativeUInt; SizeInBits: UInt64; Encoding: LLVMDWARFTypeEncoding; Flags: LLVMDIFlags): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreatePointerType: function(Builder: LLVMDIBuilderRef; PointeeTy: LLVMMetadataRef; SizeInBits: UInt64; AlignInBits: UInt32; AddressSpace: Cardinal; const Name: PUTF8Char; NameLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateStructType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNumber: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; Flags: LLVMDIFlags; DerivedFrom: LLVMMetadataRef; Elements: PLLVMMetadataRef; NumElements: Cardinal; RunTimeLang: Cardinal; VTableHolder: LLVMMetadataRef; const UniqueId: PUTF8Char; UniqueIdLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateMemberType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; OffsetInBits: UInt64; Flags: LLVMDIFlags; Ty: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateStaticMemberType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNumber: Cardinal; Type_: LLVMMetadataRef; Flags: LLVMDIFlags; ConstantVal: LLVMValueRef; AlignInBits: UInt32): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateMemberPointerType: function(Builder: LLVMDIBuilderRef; PointeeType: LLVMMetadataRef; ClassType: LLVMMetadataRef; SizeInBits: UInt64; AlignInBits: UInt32; Flags: LLVMDIFlags): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateObjCIVar: function(Builder: LLVMDIBuilderRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; OffsetInBits: UInt64; Flags: LLVMDIFlags; Ty: LLVMMetadataRef; PropertyNode: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateObjCProperty: function(Builder: LLVMDIBuilderRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; const GetterName: PUTF8Char; GetterNameLen: NativeUInt; const SetterName: PUTF8Char; SetterNameLen: NativeUInt; PropertyAttributes: Cardinal; Ty: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateObjectPointerType: function(Builder: LLVMDIBuilderRef; Type_: LLVMMetadataRef; Implicit: LLVMBool): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateQualifiedType: function(Builder: LLVMDIBuilderRef; Tag: Cardinal; Type_: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateReferenceType: function(Builder: LLVMDIBuilderRef; Tag: Cardinal; Type_: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateNullPtrType: function(Builder: LLVMDIBuilderRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateTypedef: function(Builder: LLVMDIBuilderRef; Type_: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; Scope: LLVMMetadataRef; AlignInBits: UInt32): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateInheritance: function(Builder: LLVMDIBuilderRef; Ty: LLVMMetadataRef; BaseTy: LLVMMetadataRef; BaseOffset: UInt64; VBPtrOffset: UInt32; Flags: LLVMDIFlags): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateForwardDecl: function(Builder: LLVMDIBuilderRef; Tag: Cardinal; const Name: PUTF8Char; NameLen: NativeUInt; Scope: LLVMMetadataRef; File_: LLVMMetadataRef; Line: Cardinal; RuntimeLang: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; const UniqueIdentifier: PUTF8Char; UniqueIdentifierLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateReplaceableCompositeType: function(Builder: LLVMDIBuilderRef; Tag: Cardinal; const Name: PUTF8Char; NameLen: NativeUInt; Scope: LLVMMetadataRef; File_: LLVMMetadataRef; Line: Cardinal; RuntimeLang: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; Flags: LLVMDIFlags; const UniqueIdentifier: PUTF8Char; UniqueIdentifierLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateBitFieldMemberType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNumber: Cardinal; SizeInBits: UInt64; OffsetInBits: UInt64; StorageOffsetInBits: UInt64; Flags: LLVMDIFlags; Type_: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateClassType: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNumber: Cardinal; SizeInBits: UInt64; AlignInBits: UInt32; OffsetInBits: UInt64; Flags: LLVMDIFlags; DerivedFrom: LLVMMetadataRef; Elements: PLLVMMetadataRef; NumElements: Cardinal; VTableHolder: LLVMMetadataRef; TemplateParamsNode: LLVMMetadataRef; const UniqueIdentifier: PUTF8Char; UniqueIdentifierLen: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateArtificialType: function(Builder: LLVMDIBuilderRef; Type_: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDITypeGetName: function(DType: LLVMMetadataRef; Length: PNativeUInt): PUTF8Char; cdecl;
  LLVMDITypeGetSizeInBits: function(DType: LLVMMetadataRef): UInt64; cdecl;
  LLVMDITypeGetOffsetInBits: function(DType: LLVMMetadataRef): UInt64; cdecl;
  LLVMDITypeGetAlignInBits: function(DType: LLVMMetadataRef): UInt32; cdecl;
  LLVMDITypeGetLine: function(DType: LLVMMetadataRef): Cardinal; cdecl;
  LLVMDITypeGetFlags: function(DType: LLVMMetadataRef): LLVMDIFlags; cdecl;
  LLVMDIBuilderGetOrCreateSubrange: function(Builder: LLVMDIBuilderRef; LowerBound: Int64; Count: Int64): LLVMMetadataRef; cdecl;
  LLVMDIBuilderGetOrCreateArray: function(Builder: LLVMDIBuilderRef; Data: PLLVMMetadataRef; NumElements: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateExpression: function(Builder: LLVMDIBuilderRef; Addr: PUInt64; Length: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateConstantValueExpression: function(Builder: LLVMDIBuilderRef; Value: UInt64): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateGlobalVariableExpression: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; const Linkage: PUTF8Char; LinkLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; Ty: LLVMMetadataRef; LocalToUnit: LLVMBool; Expr: LLVMMetadataRef; Decl: LLVMMetadataRef; AlignInBits: UInt32): LLVMMetadataRef; cdecl;
  LLVMGetDINodeTag: function(MD: LLVMMetadataRef): UInt16; cdecl;
  LLVMDIGlobalVariableExpressionGetVariable: function(GVE: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIGlobalVariableExpressionGetExpression: function(GVE: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIVariableGetFile: function(Var_: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIVariableGetScope: function(Var_: LLVMMetadataRef): LLVMMetadataRef; cdecl;
  LLVMDIVariableGetLine: function(Var_: LLVMMetadataRef): Cardinal; cdecl;
  LLVMTemporaryMDNode: function(Ctx: LLVMContextRef; Data: PLLVMMetadataRef; NumElements: NativeUInt): LLVMMetadataRef; cdecl;
  LLVMDisposeTemporaryMDNode: procedure(TempNode: LLVMMetadataRef); cdecl;
  LLVMMetadataReplaceAllUsesWith: procedure(TempTargetMetadata: LLVMMetadataRef; Replacement: LLVMMetadataRef); cdecl;
  LLVMDIBuilderCreateTempGlobalVariableFwdDecl: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; const Linkage: PUTF8Char; LnkLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; Ty: LLVMMetadataRef; LocalToUnit: LLVMBool; Decl: LLVMMetadataRef; AlignInBits: UInt32): LLVMMetadataRef; cdecl;
  LLVMDIBuilderInsertDeclareRecordBefore: function(Builder: LLVMDIBuilderRef; Storage: LLVMValueRef; VarInfo: LLVMMetadataRef; Expr: LLVMMetadataRef; DebugLoc: LLVMMetadataRef; Instr: LLVMValueRef): LLVMDbgRecordRef; cdecl;
  LLVMDIBuilderInsertDeclareRecordAtEnd: function(Builder: LLVMDIBuilderRef; Storage: LLVMValueRef; VarInfo: LLVMMetadataRef; Expr: LLVMMetadataRef; DebugLoc: LLVMMetadataRef; Block: LLVMBasicBlockRef): LLVMDbgRecordRef; cdecl;
  LLVMDIBuilderInsertDbgValueRecordBefore: function(Builder: LLVMDIBuilderRef; Val: LLVMValueRef; VarInfo: LLVMMetadataRef; Expr: LLVMMetadataRef; DebugLoc: LLVMMetadataRef; Instr: LLVMValueRef): LLVMDbgRecordRef; cdecl;
  LLVMDIBuilderInsertDbgValueRecordAtEnd: function(Builder: LLVMDIBuilderRef; Val: LLVMValueRef; VarInfo: LLVMMetadataRef; Expr: LLVMMetadataRef; DebugLoc: LLVMMetadataRef; Block: LLVMBasicBlockRef): LLVMDbgRecordRef; cdecl;
  LLVMDIBuilderCreateAutoVariable: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; Ty: LLVMMetadataRef; AlwaysPreserve: LLVMBool; Flags: LLVMDIFlags; AlignInBits: UInt32): LLVMMetadataRef; cdecl;
  LLVMDIBuilderCreateParameterVariable: function(Builder: LLVMDIBuilderRef; Scope: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; ArgNo: Cardinal; File_: LLVMMetadataRef; LineNo: Cardinal; Ty: LLVMMetadataRef; AlwaysPreserve: LLVMBool; Flags: LLVMDIFlags): LLVMMetadataRef; cdecl;
  LLVMGetSubprogram: function(Func: LLVMValueRef): LLVMMetadataRef; cdecl;
  LLVMSetSubprogram: procedure(Func: LLVMValueRef; SP: LLVMMetadataRef); cdecl;
  LLVMDISubprogramGetLine: function(Subprogram: LLVMMetadataRef): Cardinal; cdecl;
  LLVMDISubprogramReplaceType: procedure(Subprogram: LLVMMetadataRef; SubroutineType: LLVMMetadataRef); cdecl;
  LLVMInstructionGetDebugLoc: function(Inst: LLVMValueRef): LLVMMetadataRef; cdecl;
  LLVMInstructionSetDebugLoc: procedure(Inst: LLVMValueRef; Loc: LLVMMetadataRef); cdecl;
  LLVMDIBuilderCreateLabel: function(Builder: LLVMDIBuilderRef; Context: LLVMMetadataRef; const Name: PUTF8Char; NameLen: NativeUInt; File_: LLVMMetadataRef; LineNo: Cardinal; AlwaysPreserve: LLVMBool): LLVMMetadataRef; cdecl;
  LLVMDIBuilderInsertLabelBefore: function(Builder: LLVMDIBuilderRef; LabelInfo: LLVMMetadataRef; Location: LLVMMetadataRef; InsertBefore: LLVMValueRef): LLVMDbgRecordRef; cdecl;
  LLVMDIBuilderInsertLabelAtEnd: function(Builder: LLVMDIBuilderRef; LabelInfo: LLVMMetadataRef; Location: LLVMMetadataRef; InsertAtEnd: LLVMBasicBlockRef): LLVMDbgRecordRef; cdecl;
  LLVMGetMetadataKind: function(Metadata: LLVMMetadataRef): LLVMMetadataKind; cdecl;
  LLVMCreateDisasm: function(const TripleName: PUTF8Char; DisInfo: Pointer; TagType: Integer; GetOpInfo: LLVMOpInfoCallback; SymbolLookUp: LLVMSymbolLookupCallback): LLVMDisasmContextRef; cdecl;
  LLVMCreateDisasmCPU: function(const Triple: PUTF8Char; const CPU: PUTF8Char; DisInfo: Pointer; TagType: Integer; GetOpInfo: LLVMOpInfoCallback; SymbolLookUp: LLVMSymbolLookupCallback): LLVMDisasmContextRef; cdecl;
  LLVMCreateDisasmCPUFeatures: function(const Triple: PUTF8Char; const CPU: PUTF8Char; const Features: PUTF8Char; DisInfo: Pointer; TagType: Integer; GetOpInfo: LLVMOpInfoCallback; SymbolLookUp: LLVMSymbolLookupCallback): LLVMDisasmContextRef; cdecl;
  LLVMSetDisasmOptions: function(DC: LLVMDisasmContextRef; Options: UInt64): Integer; cdecl;
  LLVMDisasmDispose: procedure(DC: LLVMDisasmContextRef); cdecl;
  LLVMDisasmInstruction: function(DC: LLVMDisasmContextRef; Bytes: PUInt8; BytesSize: UInt64; PC: UInt64; OutString: PUTF8Char; OutStringSize: NativeUInt): NativeUInt; cdecl;
  LLVMGetErrorTypeId: function(Err: LLVMErrorRef): LLVMErrorTypeId; cdecl;
  LLVMConsumeError: procedure(Err: LLVMErrorRef); cdecl;
  LLVMCantFail: procedure(Err: LLVMErrorRef); cdecl;
  LLVMGetErrorMessage: function(Err: LLVMErrorRef): PUTF8Char; cdecl;
  LLVMDisposeErrorMessage: procedure(ErrMsg: PUTF8Char); cdecl;
  LLVMGetStringErrorTypeId: function(): LLVMErrorTypeId; cdecl;
  LLVMCreateStringError: function(const ErrMsg: PUTF8Char): LLVMErrorRef; cdecl;
  LLVMInitializeAArch64TargetInfo: procedure(); cdecl;
  LLVMInitializeAMDGPUTargetInfo: procedure(); cdecl;
  LLVMInitializeARMTargetInfo: procedure(); cdecl;
  LLVMInitializeAVRTargetInfo: procedure(); cdecl;
  LLVMInitializeBPFTargetInfo: procedure(); cdecl;
  LLVMInitializeHexagonTargetInfo: procedure(); cdecl;
  LLVMInitializeLanaiTargetInfo: procedure(); cdecl;
  LLVMInitializeLoongArchTargetInfo: procedure(); cdecl;
  LLVMInitializeMipsTargetInfo: procedure(); cdecl;
  LLVMInitializeMSP430TargetInfo: procedure(); cdecl;
  LLVMInitializeNVPTXTargetInfo: procedure(); cdecl;
  LLVMInitializePowerPCTargetInfo: procedure(); cdecl;
  LLVMInitializeRISCVTargetInfo: procedure(); cdecl;
  LLVMInitializeSparcTargetInfo: procedure(); cdecl;
  LLVMInitializeSPIRVTargetInfo: procedure(); cdecl;
  LLVMInitializeSystemZTargetInfo: procedure(); cdecl;
  LLVMInitializeVETargetInfo: procedure(); cdecl;
  LLVMInitializeWebAssemblyTargetInfo: procedure(); cdecl;
  LLVMInitializeX86TargetInfo: procedure(); cdecl;
  LLVMInitializeXCoreTargetInfo: procedure(); cdecl;
  LLVMInitializeAArch64Target: procedure(); cdecl;
  LLVMInitializeAMDGPUTarget: procedure(); cdecl;
  LLVMInitializeARMTarget: procedure(); cdecl;
  LLVMInitializeAVRTarget: procedure(); cdecl;
  LLVMInitializeBPFTarget: procedure(); cdecl;
  LLVMInitializeHexagonTarget: procedure(); cdecl;
  LLVMInitializeLanaiTarget: procedure(); cdecl;
  LLVMInitializeLoongArchTarget: procedure(); cdecl;
  LLVMInitializeMipsTarget: procedure(); cdecl;
  LLVMInitializeMSP430Target: procedure(); cdecl;
  LLVMInitializeNVPTXTarget: procedure(); cdecl;
  LLVMInitializePowerPCTarget: procedure(); cdecl;
  LLVMInitializeRISCVTarget: procedure(); cdecl;
  LLVMInitializeSparcTarget: procedure(); cdecl;
  LLVMInitializeSPIRVTarget: procedure(); cdecl;
  LLVMInitializeSystemZTarget: procedure(); cdecl;
  LLVMInitializeVETarget: procedure(); cdecl;
  LLVMInitializeWebAssemblyTarget: procedure(); cdecl;
  LLVMInitializeX86Target: procedure(); cdecl;
  LLVMInitializeXCoreTarget: procedure(); cdecl;
  LLVMInitializeAArch64TargetMC: procedure(); cdecl;
  LLVMInitializeAMDGPUTargetMC: procedure(); cdecl;
  LLVMInitializeARMTargetMC: procedure(); cdecl;
  LLVMInitializeAVRTargetMC: procedure(); cdecl;
  LLVMInitializeBPFTargetMC: procedure(); cdecl;
  LLVMInitializeHexagonTargetMC: procedure(); cdecl;
  LLVMInitializeLanaiTargetMC: procedure(); cdecl;
  LLVMInitializeLoongArchTargetMC: procedure(); cdecl;
  LLVMInitializeMipsTargetMC: procedure(); cdecl;
  LLVMInitializeMSP430TargetMC: procedure(); cdecl;
  LLVMInitializeNVPTXTargetMC: procedure(); cdecl;
  LLVMInitializePowerPCTargetMC: procedure(); cdecl;
  LLVMInitializeRISCVTargetMC: procedure(); cdecl;
  LLVMInitializeSparcTargetMC: procedure(); cdecl;
  LLVMInitializeSPIRVTargetMC: procedure(); cdecl;
  LLVMInitializeSystemZTargetMC: procedure(); cdecl;
  LLVMInitializeVETargetMC: procedure(); cdecl;
  LLVMInitializeWebAssemblyTargetMC: procedure(); cdecl;
  LLVMInitializeX86TargetMC: procedure(); cdecl;
  LLVMInitializeXCoreTargetMC: procedure(); cdecl;
  LLVMInitializeAArch64AsmPrinter: procedure(); cdecl;
  LLVMInitializeAMDGPUAsmPrinter: procedure(); cdecl;
  LLVMInitializeARMAsmPrinter: procedure(); cdecl;
  LLVMInitializeAVRAsmPrinter: procedure(); cdecl;
  LLVMInitializeBPFAsmPrinter: procedure(); cdecl;
  LLVMInitializeHexagonAsmPrinter: procedure(); cdecl;
  LLVMInitializeLanaiAsmPrinter: procedure(); cdecl;
  LLVMInitializeLoongArchAsmPrinter: procedure(); cdecl;
  LLVMInitializeMipsAsmPrinter: procedure(); cdecl;
  LLVMInitializeMSP430AsmPrinter: procedure(); cdecl;
  LLVMInitializeNVPTXAsmPrinter: procedure(); cdecl;
  LLVMInitializePowerPCAsmPrinter: procedure(); cdecl;
  LLVMInitializeRISCVAsmPrinter: procedure(); cdecl;
  LLVMInitializeSparcAsmPrinter: procedure(); cdecl;
  LLVMInitializeSPIRVAsmPrinter: procedure(); cdecl;
  LLVMInitializeSystemZAsmPrinter: procedure(); cdecl;
  LLVMInitializeVEAsmPrinter: procedure(); cdecl;
  LLVMInitializeWebAssemblyAsmPrinter: procedure(); cdecl;
  LLVMInitializeX86AsmPrinter: procedure(); cdecl;
  LLVMInitializeXCoreAsmPrinter: procedure(); cdecl;
  LLVMInitializeAArch64AsmParser: procedure(); cdecl;
  LLVMInitializeAMDGPUAsmParser: procedure(); cdecl;
  LLVMInitializeARMAsmParser: procedure(); cdecl;
  LLVMInitializeAVRAsmParser: procedure(); cdecl;
  LLVMInitializeBPFAsmParser: procedure(); cdecl;
  LLVMInitializeHexagonAsmParser: procedure(); cdecl;
  LLVMInitializeLanaiAsmParser: procedure(); cdecl;
  LLVMInitializeLoongArchAsmParser: procedure(); cdecl;
  LLVMInitializeMipsAsmParser: procedure(); cdecl;
  LLVMInitializeMSP430AsmParser: procedure(); cdecl;
  LLVMInitializePowerPCAsmParser: procedure(); cdecl;
  LLVMInitializeRISCVAsmParser: procedure(); cdecl;
  LLVMInitializeSparcAsmParser: procedure(); cdecl;
  LLVMInitializeSystemZAsmParser: procedure(); cdecl;
  LLVMInitializeVEAsmParser: procedure(); cdecl;
  LLVMInitializeWebAssemblyAsmParser: procedure(); cdecl;
  LLVMInitializeX86AsmParser: procedure(); cdecl;
  LLVMInitializeAArch64Disassembler: procedure(); cdecl;
  LLVMInitializeAMDGPUDisassembler: procedure(); cdecl;
  LLVMInitializeARMDisassembler: procedure(); cdecl;
  LLVMInitializeAVRDisassembler: procedure(); cdecl;
  LLVMInitializeBPFDisassembler: procedure(); cdecl;
  LLVMInitializeHexagonDisassembler: procedure(); cdecl;
  LLVMInitializeLanaiDisassembler: procedure(); cdecl;
  LLVMInitializeLoongArchDisassembler: procedure(); cdecl;
  LLVMInitializeMipsDisassembler: procedure(); cdecl;
  LLVMInitializeMSP430Disassembler: procedure(); cdecl;
  LLVMInitializePowerPCDisassembler: procedure(); cdecl;
  LLVMInitializeRISCVDisassembler: procedure(); cdecl;
  LLVMInitializeSparcDisassembler: procedure(); cdecl;
  LLVMInitializeSystemZDisassembler: procedure(); cdecl;
  LLVMInitializeVEDisassembler: procedure(); cdecl;
  LLVMInitializeWebAssemblyDisassembler: procedure(); cdecl;
  LLVMInitializeX86Disassembler: procedure(); cdecl;
  LLVMInitializeXCoreDisassembler: procedure(); cdecl;
  LLVMGetModuleDataLayout: function(M: LLVMModuleRef): LLVMTargetDataRef; cdecl;
  LLVMSetModuleDataLayout: procedure(M: LLVMModuleRef; DL: LLVMTargetDataRef); cdecl;
  LLVMCreateTargetData: function(const StringRep: PUTF8Char): LLVMTargetDataRef; cdecl;
  LLVMDisposeTargetData: procedure(TD: LLVMTargetDataRef); cdecl;
  LLVMAddTargetLibraryInfo: procedure(TLI: LLVMTargetLibraryInfoRef; PM: LLVMPassManagerRef); cdecl;
  LLVMCopyStringRepOfTargetData: function(TD: LLVMTargetDataRef): PUTF8Char; cdecl;
  LLVMByteOrder: function(TD: LLVMTargetDataRef): LLVMByteOrdering; cdecl;
  LLVMPointerSize: function(TD: LLVMTargetDataRef): Cardinal; cdecl;
  LLVMPointerSizeForAS: function(TD: LLVMTargetDataRef; AS_: Cardinal): Cardinal; cdecl;
  LLVMIntPtrType: function(TD: LLVMTargetDataRef): LLVMTypeRef; cdecl;
  LLVMIntPtrTypeForAS: function(TD: LLVMTargetDataRef; AS_: Cardinal): LLVMTypeRef; cdecl;
  LLVMIntPtrTypeInContext: function(C: LLVMContextRef; TD: LLVMTargetDataRef): LLVMTypeRef; cdecl;
  LLVMIntPtrTypeForASInContext: function(C: LLVMContextRef; TD: LLVMTargetDataRef; AS_: Cardinal): LLVMTypeRef; cdecl;
  LLVMSizeOfTypeInBits: function(TD: LLVMTargetDataRef; Ty: LLVMTypeRef): UInt64; cdecl;
  LLVMStoreSizeOfType: function(TD: LLVMTargetDataRef; Ty: LLVMTypeRef): UInt64; cdecl;
  LLVMABISizeOfType: function(TD: LLVMTargetDataRef; Ty: LLVMTypeRef): UInt64; cdecl;
  LLVMABIAlignmentOfType: function(TD: LLVMTargetDataRef; Ty: LLVMTypeRef): Cardinal; cdecl;
  LLVMCallFrameAlignmentOfType: function(TD: LLVMTargetDataRef; Ty: LLVMTypeRef): Cardinal; cdecl;
  LLVMPreferredAlignmentOfType: function(TD: LLVMTargetDataRef; Ty: LLVMTypeRef): Cardinal; cdecl;
  LLVMPreferredAlignmentOfGlobal: function(TD: LLVMTargetDataRef; GlobalVar: LLVMValueRef): Cardinal; cdecl;
  LLVMElementAtOffset: function(TD: LLVMTargetDataRef; StructTy: LLVMTypeRef; Offset: UInt64): Cardinal; cdecl;
  LLVMOffsetOfElement: function(TD: LLVMTargetDataRef; StructTy: LLVMTypeRef; Element: Cardinal): UInt64; cdecl;
  LLVMGetFirstTarget: function(): LLVMTargetRef; cdecl;
  LLVMGetNextTarget: function(T: LLVMTargetRef): LLVMTargetRef; cdecl;
  LLVMGetTargetFromName: function(const Name: PUTF8Char): LLVMTargetRef; cdecl;
  LLVMGetTargetFromTriple: function(const Triple: PUTF8Char; T: PLLVMTargetRef; ErrorMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMGetTargetName: function(T: LLVMTargetRef): PUTF8Char; cdecl;
  LLVMGetTargetDescription: function(T: LLVMTargetRef): PUTF8Char; cdecl;
  LLVMTargetHasJIT: function(T: LLVMTargetRef): LLVMBool; cdecl;
  LLVMTargetHasTargetMachine: function(T: LLVMTargetRef): LLVMBool; cdecl;
  LLVMTargetHasAsmBackend: function(T: LLVMTargetRef): LLVMBool; cdecl;
  LLVMCreateTargetMachineOptions: function(): LLVMTargetMachineOptionsRef; cdecl;
  LLVMDisposeTargetMachineOptions: procedure(Options: LLVMTargetMachineOptionsRef); cdecl;
  LLVMTargetMachineOptionsSetCPU: procedure(Options: LLVMTargetMachineOptionsRef; const CPU: PUTF8Char); cdecl;
  LLVMTargetMachineOptionsSetFeatures: procedure(Options: LLVMTargetMachineOptionsRef; const Features: PUTF8Char); cdecl;
  LLVMTargetMachineOptionsSetABI: procedure(Options: LLVMTargetMachineOptionsRef; const ABI: PUTF8Char); cdecl;
  LLVMTargetMachineOptionsSetCodeGenOptLevel: procedure(Options: LLVMTargetMachineOptionsRef; Level: LLVMCodeGenOptLevel); cdecl;
  LLVMTargetMachineOptionsSetRelocMode: procedure(Options: LLVMTargetMachineOptionsRef; Reloc: LLVMRelocMode); cdecl;
  LLVMTargetMachineOptionsSetCodeModel: procedure(Options: LLVMTargetMachineOptionsRef; CodeModel: LLVMCodeModel); cdecl;
  LLVMCreateTargetMachineWithOptions: function(T: LLVMTargetRef; const Triple: PUTF8Char; Options: LLVMTargetMachineOptionsRef): LLVMTargetMachineRef; cdecl;
  LLVMCreateTargetMachine: function(T: LLVMTargetRef; const Triple: PUTF8Char; const CPU: PUTF8Char; const Features: PUTF8Char; Level: LLVMCodeGenOptLevel; Reloc: LLVMRelocMode; CodeModel: LLVMCodeModel): LLVMTargetMachineRef; cdecl;
  LLVMDisposeTargetMachine: procedure(T: LLVMTargetMachineRef); cdecl;
  LLVMGetTargetMachineTarget: function(T: LLVMTargetMachineRef): LLVMTargetRef; cdecl;
  LLVMGetTargetMachineTriple: function(T: LLVMTargetMachineRef): PUTF8Char; cdecl;
  LLVMGetTargetMachineCPU: function(T: LLVMTargetMachineRef): PUTF8Char; cdecl;
  LLVMGetTargetMachineFeatureString: function(T: LLVMTargetMachineRef): PUTF8Char; cdecl;
  LLVMCreateTargetDataLayout: function(T: LLVMTargetMachineRef): LLVMTargetDataRef; cdecl;
  LLVMSetTargetMachineAsmVerbosity: procedure(T: LLVMTargetMachineRef; VerboseAsm: LLVMBool); cdecl;
  LLVMSetTargetMachineFastISel: procedure(T: LLVMTargetMachineRef; Enable: LLVMBool); cdecl;
  LLVMSetTargetMachineGlobalISel: procedure(T: LLVMTargetMachineRef; Enable: LLVMBool); cdecl;
  LLVMSetTargetMachineGlobalISelAbort: procedure(T: LLVMTargetMachineRef; Mode: LLVMGlobalISelAbortMode); cdecl;
  LLVMSetTargetMachineMachineOutliner: procedure(T: LLVMTargetMachineRef; Enable: LLVMBool); cdecl;
  LLVMTargetMachineEmitToFile: function(T: LLVMTargetMachineRef; M: LLVMModuleRef; const Filename: PUTF8Char; codegen: LLVMCodeGenFileType; ErrorMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMTargetMachineEmitToMemoryBuffer: function(T: LLVMTargetMachineRef; M: LLVMModuleRef; codegen: LLVMCodeGenFileType; ErrorMessage: PPUTF8Char; OutMemBuf: PLLVMMemoryBufferRef): LLVMBool; cdecl;
  LLVMGetDefaultTargetTriple: function(): PUTF8Char; cdecl;
  LLVMNormalizeTargetTriple: function(const triple: PUTF8Char): PUTF8Char; cdecl;
  LLVMGetHostCPUName: function(): PUTF8Char; cdecl;
  LLVMGetHostCPUFeatures: function(): PUTF8Char; cdecl;
  LLVMAddAnalysisPasses: procedure(T: LLVMTargetMachineRef; PM: LLVMPassManagerRef); cdecl;
  LLVMLinkInMCJIT: procedure(); cdecl;
  LLVMLinkInInterpreter: procedure(); cdecl;
  LLVMCreateGenericValueOfInt: function(Ty: LLVMTypeRef; N: UInt64; IsSigned: LLVMBool): LLVMGenericValueRef; cdecl;
  LLVMCreateGenericValueOfPointer: function(P: Pointer): LLVMGenericValueRef; cdecl;
  LLVMCreateGenericValueOfFloat: function(Ty: LLVMTypeRef; N: Double): LLVMGenericValueRef; cdecl;
  LLVMGenericValueIntWidth: function(GenValRef: LLVMGenericValueRef): Cardinal; cdecl;
  LLVMGenericValueToInt: function(GenVal: LLVMGenericValueRef; IsSigned: LLVMBool): UInt64; cdecl;
  LLVMGenericValueToPointer: function(GenVal: LLVMGenericValueRef): Pointer; cdecl;
  LLVMGenericValueToFloat: function(TyRef: LLVMTypeRef; GenVal: LLVMGenericValueRef): Double; cdecl;
  LLVMDisposeGenericValue: procedure(GenVal: LLVMGenericValueRef); cdecl;
  LLVMCreateExecutionEngineForModule: function(OutEE: PLLVMExecutionEngineRef; M: LLVMModuleRef; OutError: PPUTF8Char): LLVMBool; cdecl;
  LLVMCreateInterpreterForModule: function(OutInterp: PLLVMExecutionEngineRef; M: LLVMModuleRef; OutError: PPUTF8Char): LLVMBool; cdecl;
  LLVMCreateJITCompilerForModule: function(OutJIT: PLLVMExecutionEngineRef; M: LLVMModuleRef; OptLevel: Cardinal; OutError: PPUTF8Char): LLVMBool; cdecl;
  LLVMInitializeMCJITCompilerOptions: procedure(Options: PLLVMMCJITCompilerOptions; SizeOfOptions: NativeUInt); cdecl;
  LLVMCreateMCJITCompilerForModule: function(OutJIT: PLLVMExecutionEngineRef; M: LLVMModuleRef; Options: PLLVMMCJITCompilerOptions; SizeOfOptions: NativeUInt; OutError: PPUTF8Char): LLVMBool; cdecl;
  LLVMDisposeExecutionEngine: procedure(EE: LLVMExecutionEngineRef); cdecl;
  LLVMRunStaticConstructors: procedure(EE: LLVMExecutionEngineRef); cdecl;
  LLVMRunStaticDestructors: procedure(EE: LLVMExecutionEngineRef); cdecl;
  LLVMRunFunctionAsMain: function(EE: LLVMExecutionEngineRef; F: LLVMValueRef; ArgC: Cardinal; const ArgV: PPUTF8Char; const EnvP: PPUTF8Char): Integer; cdecl;
  LLVMRunFunction: function(EE: LLVMExecutionEngineRef; F: LLVMValueRef; NumArgs: Cardinal; Args: PLLVMGenericValueRef): LLVMGenericValueRef; cdecl;
  LLVMFreeMachineCodeForFunction: procedure(EE: LLVMExecutionEngineRef; F: LLVMValueRef); cdecl;
  LLVMAddModule: procedure(EE: LLVMExecutionEngineRef; M: LLVMModuleRef); cdecl;
  LLVMRemoveModule: function(EE: LLVMExecutionEngineRef; M: LLVMModuleRef; OutMod: PLLVMModuleRef; OutError: PPUTF8Char): LLVMBool; cdecl;
  LLVMFindFunction: function(EE: LLVMExecutionEngineRef; const Name: PUTF8Char; OutFn: PLLVMValueRef): LLVMBool; cdecl;
  LLVMRecompileAndRelinkFunction: function(EE: LLVMExecutionEngineRef; Fn: LLVMValueRef): Pointer; cdecl;
  LLVMGetExecutionEngineTargetData: function(EE: LLVMExecutionEngineRef): LLVMTargetDataRef; cdecl;
  LLVMGetExecutionEngineTargetMachine: function(EE: LLVMExecutionEngineRef): LLVMTargetMachineRef; cdecl;
  LLVMAddGlobalMapping: procedure(EE: LLVMExecutionEngineRef; Global: LLVMValueRef; Addr: Pointer); cdecl;
  LLVMGetPointerToGlobal: function(EE: LLVMExecutionEngineRef; Global: LLVMValueRef): Pointer; cdecl;
  LLVMGetGlobalValueAddress: function(EE: LLVMExecutionEngineRef; const Name: PUTF8Char): UInt64; cdecl;
  LLVMGetFunctionAddress: function(EE: LLVMExecutionEngineRef; const Name: PUTF8Char): UInt64; cdecl;
  LLVMExecutionEngineGetErrMsg: function(EE: LLVMExecutionEngineRef; OutError: PPUTF8Char): LLVMBool; cdecl;
  LLVMCreateSimpleMCJITMemoryManager: function(Opaque: Pointer; AllocateCodeSection: LLVMMemoryManagerAllocateCodeSectionCallback; AllocateDataSection: LLVMMemoryManagerAllocateDataSectionCallback; FinalizeMemory: LLVMMemoryManagerFinalizeMemoryCallback; Destroy: LLVMMemoryManagerDestroyCallback): LLVMMCJITMemoryManagerRef; cdecl;
  LLVMDisposeMCJITMemoryManager: procedure(MM: LLVMMCJITMemoryManagerRef); cdecl;
  LLVMCreateGDBRegistrationListener: function(): LLVMJITEventListenerRef; cdecl;
  LLVMCreateIntelJITEventListener: function(): LLVMJITEventListenerRef; cdecl;
  LLVMCreateOProfileJITEventListener: function(): LLVMJITEventListenerRef; cdecl;
  LLVMCreatePerfJITEventListener: function(): LLVMJITEventListenerRef; cdecl;
  LLVMParseIRInContext: function(ContextRef: LLVMContextRef; MemBuf: LLVMMemoryBufferRef; OutM: PLLVMModuleRef; OutMessage: PPUTF8Char): LLVMBool; cdecl;
  LLVMLinkModules2: function(Dest: LLVMModuleRef; Src: LLVMModuleRef): LLVMBool; cdecl;
  LLVMOrcExecutionSessionSetErrorReporter: procedure(ES: LLVMOrcExecutionSessionRef; ReportError: LLVMOrcErrorReporterFunction; Ctx: Pointer); cdecl;
  LLVMOrcExecutionSessionGetSymbolStringPool: function(ES: LLVMOrcExecutionSessionRef): LLVMOrcSymbolStringPoolRef; cdecl;
  LLVMOrcSymbolStringPoolClearDeadEntries: procedure(SSP: LLVMOrcSymbolStringPoolRef); cdecl;
  LLVMOrcExecutionSessionIntern: function(ES: LLVMOrcExecutionSessionRef; const Name: PUTF8Char): LLVMOrcSymbolStringPoolEntryRef; cdecl;
  LLVMOrcExecutionSessionLookup: procedure(ES: LLVMOrcExecutionSessionRef; K: LLVMOrcLookupKind; SearchOrder: LLVMOrcCJITDylibSearchOrder; SearchOrderSize: NativeUInt; Symbols: LLVMOrcCLookupSet; SymbolsSize: NativeUInt; HandleResult: LLVMOrcExecutionSessionLookupHandleResultFunction; Ctx: Pointer); cdecl;
  LLVMOrcRetainSymbolStringPoolEntry: procedure(S: LLVMOrcSymbolStringPoolEntryRef); cdecl;
  LLVMOrcReleaseSymbolStringPoolEntry: procedure(S: LLVMOrcSymbolStringPoolEntryRef); cdecl;
  LLVMOrcSymbolStringPoolEntryStr: function(S: LLVMOrcSymbolStringPoolEntryRef): PUTF8Char; cdecl;
  LLVMOrcReleaseResourceTracker: procedure(RT: LLVMOrcResourceTrackerRef); cdecl;
  LLVMOrcResourceTrackerTransferTo: procedure(SrcRT: LLVMOrcResourceTrackerRef; DstRT: LLVMOrcResourceTrackerRef); cdecl;
  LLVMOrcResourceTrackerRemove: function(RT: LLVMOrcResourceTrackerRef): LLVMErrorRef; cdecl;
  LLVMOrcDisposeDefinitionGenerator: procedure(DG: LLVMOrcDefinitionGeneratorRef); cdecl;
  LLVMOrcDisposeMaterializationUnit: procedure(MU: LLVMOrcMaterializationUnitRef); cdecl;
  LLVMOrcCreateCustomMaterializationUnit: function(const Name: PUTF8Char; Ctx: Pointer; Syms: LLVMOrcCSymbolFlagsMapPairs; NumSyms: NativeUInt; InitSym: LLVMOrcSymbolStringPoolEntryRef; Materialize: LLVMOrcMaterializationUnitMaterializeFunction; Discard: LLVMOrcMaterializationUnitDiscardFunction; Destroy: LLVMOrcMaterializationUnitDestroyFunction): LLVMOrcMaterializationUnitRef; cdecl;
  LLVMOrcAbsoluteSymbols: function(Syms: LLVMOrcCSymbolMapPairs; NumPairs: NativeUInt): LLVMOrcMaterializationUnitRef; cdecl;
  LLVMOrcLazyReexports: function(LCTM: LLVMOrcLazyCallThroughManagerRef; ISM: LLVMOrcIndirectStubsManagerRef; SourceRef: LLVMOrcJITDylibRef; CallableAliases: LLVMOrcCSymbolAliasMapPairs; NumPairs: NativeUInt): LLVMOrcMaterializationUnitRef; cdecl;
  LLVMOrcDisposeMaterializationResponsibility: procedure(MR: LLVMOrcMaterializationResponsibilityRef); cdecl;
  LLVMOrcMaterializationResponsibilityGetTargetDylib: function(MR: LLVMOrcMaterializationResponsibilityRef): LLVMOrcJITDylibRef; cdecl;
  LLVMOrcMaterializationResponsibilityGetExecutionSession: function(MR: LLVMOrcMaterializationResponsibilityRef): LLVMOrcExecutionSessionRef; cdecl;
  LLVMOrcMaterializationResponsibilityGetSymbols: function(MR: LLVMOrcMaterializationResponsibilityRef; NumPairs: PNativeUInt): LLVMOrcCSymbolFlagsMapPairs; cdecl;
  LLVMOrcDisposeCSymbolFlagsMap: procedure(Pairs: LLVMOrcCSymbolFlagsMapPairs); cdecl;
  LLVMOrcMaterializationResponsibilityGetInitializerSymbol: function(MR: LLVMOrcMaterializationResponsibilityRef): LLVMOrcSymbolStringPoolEntryRef; cdecl;
  LLVMOrcMaterializationResponsibilityGetRequestedSymbols: function(MR: LLVMOrcMaterializationResponsibilityRef; NumSymbols: PNativeUInt): PLLVMOrcSymbolStringPoolEntryRef; cdecl;
  LLVMOrcDisposeSymbols: procedure(Symbols: PLLVMOrcSymbolStringPoolEntryRef); cdecl;
  LLVMOrcMaterializationResponsibilityNotifyResolved: function(MR: LLVMOrcMaterializationResponsibilityRef; Symbols: LLVMOrcCSymbolMapPairs; NumPairs: NativeUInt): LLVMErrorRef; cdecl;
  LLVMOrcMaterializationResponsibilityNotifyEmitted: function(MR: LLVMOrcMaterializationResponsibilityRef; SymbolDepGroups: PLLVMOrcCSymbolDependenceGroup; NumSymbolDepGroups: NativeUInt): LLVMErrorRef; cdecl;
  LLVMOrcMaterializationResponsibilityDefineMaterializing: function(MR: LLVMOrcMaterializationResponsibilityRef; Pairs: LLVMOrcCSymbolFlagsMapPairs; NumPairs: NativeUInt): LLVMErrorRef; cdecl;
  LLVMOrcMaterializationResponsibilityFailMaterialization: procedure(MR: LLVMOrcMaterializationResponsibilityRef); cdecl;
  LLVMOrcMaterializationResponsibilityReplace: function(MR: LLVMOrcMaterializationResponsibilityRef; MU: LLVMOrcMaterializationUnitRef): LLVMErrorRef; cdecl;
  LLVMOrcMaterializationResponsibilityDelegate: function(MR: LLVMOrcMaterializationResponsibilityRef; Symbols: PLLVMOrcSymbolStringPoolEntryRef; NumSymbols: NativeUInt; Result: PLLVMOrcMaterializationResponsibilityRef): LLVMErrorRef; cdecl;
  LLVMOrcExecutionSessionCreateBareJITDylib: function(ES: LLVMOrcExecutionSessionRef; const Name: PUTF8Char): LLVMOrcJITDylibRef; cdecl;
  LLVMOrcExecutionSessionCreateJITDylib: function(ES: LLVMOrcExecutionSessionRef; Result: PLLVMOrcJITDylibRef; const Name: PUTF8Char): LLVMErrorRef; cdecl;
  LLVMOrcExecutionSessionGetJITDylibByName: function(ES: LLVMOrcExecutionSessionRef; const Name: PUTF8Char): LLVMOrcJITDylibRef; cdecl;
  LLVMOrcJITDylibCreateResourceTracker: function(JD: LLVMOrcJITDylibRef): LLVMOrcResourceTrackerRef; cdecl;
  LLVMOrcJITDylibGetDefaultResourceTracker: function(JD: LLVMOrcJITDylibRef): LLVMOrcResourceTrackerRef; cdecl;
  LLVMOrcJITDylibDefine: function(JD: LLVMOrcJITDylibRef; MU: LLVMOrcMaterializationUnitRef): LLVMErrorRef; cdecl;
  LLVMOrcJITDylibClear: function(JD: LLVMOrcJITDylibRef): LLVMErrorRef; cdecl;
  LLVMOrcJITDylibAddGenerator: procedure(JD: LLVMOrcJITDylibRef; DG: LLVMOrcDefinitionGeneratorRef); cdecl;
  LLVMOrcCreateCustomCAPIDefinitionGenerator: function(F: LLVMOrcCAPIDefinitionGeneratorTryToGenerateFunction; Ctx: Pointer; Dispose: LLVMOrcDisposeCAPIDefinitionGeneratorFunction): LLVMOrcDefinitionGeneratorRef; cdecl;
  LLVMOrcLookupStateContinueLookup: procedure(S: LLVMOrcLookupStateRef; Err: LLVMErrorRef); cdecl;
  LLVMOrcCreateDynamicLibrarySearchGeneratorForProcess: function(Result: PLLVMOrcDefinitionGeneratorRef; GlobalPrefx: UTF8Char; Filter: LLVMOrcSymbolPredicate; FilterCtx: Pointer): LLVMErrorRef; cdecl;
  LLVMOrcCreateDynamicLibrarySearchGeneratorForPath: function(Result: PLLVMOrcDefinitionGeneratorRef; const FileName: PUTF8Char; GlobalPrefix: UTF8Char; Filter: LLVMOrcSymbolPredicate; FilterCtx: Pointer): LLVMErrorRef; cdecl;
  LLVMOrcCreateStaticLibrarySearchGeneratorForPath: function(Result: PLLVMOrcDefinitionGeneratorRef; ObjLayer: LLVMOrcObjectLayerRef; const FileName: PUTF8Char): LLVMErrorRef; cdecl;
  LLVMOrcCreateNewThreadSafeContext: function(): LLVMOrcThreadSafeContextRef; cdecl;
  LLVMOrcCreateNewThreadSafeContextFromLLVMContext: function(Ctx: LLVMContextRef): LLVMOrcThreadSafeContextRef; cdecl;
  LLVMOrcDisposeThreadSafeContext: procedure(TSCtx: LLVMOrcThreadSafeContextRef); cdecl;
  LLVMOrcCreateNewThreadSafeModule: function(M: LLVMModuleRef; TSCtx: LLVMOrcThreadSafeContextRef): LLVMOrcThreadSafeModuleRef; cdecl;
  LLVMOrcDisposeThreadSafeModule: procedure(TSM: LLVMOrcThreadSafeModuleRef); cdecl;
  LLVMOrcThreadSafeModuleWithModuleDo: function(TSM: LLVMOrcThreadSafeModuleRef; F: LLVMOrcGenericIRModuleOperationFunction; Ctx: Pointer): LLVMErrorRef; cdecl;
  LLVMOrcJITTargetMachineBuilderDetectHost: function(Result: PLLVMOrcJITTargetMachineBuilderRef): LLVMErrorRef; cdecl;
  LLVMOrcJITTargetMachineBuilderCreateFromTargetMachine: function(TM: LLVMTargetMachineRef): LLVMOrcJITTargetMachineBuilderRef; cdecl;
  LLVMOrcDisposeJITTargetMachineBuilder: procedure(JTMB: LLVMOrcJITTargetMachineBuilderRef); cdecl;
  LLVMOrcJITTargetMachineBuilderGetTargetTriple: function(JTMB: LLVMOrcJITTargetMachineBuilderRef): PUTF8Char; cdecl;
  LLVMOrcJITTargetMachineBuilderSetTargetTriple: procedure(JTMB: LLVMOrcJITTargetMachineBuilderRef; const TargetTriple: PUTF8Char); cdecl;
  LLVMOrcObjectLayerAddObjectFile: function(ObjLayer: LLVMOrcObjectLayerRef; JD: LLVMOrcJITDylibRef; ObjBuffer: LLVMMemoryBufferRef): LLVMErrorRef; cdecl;
  LLVMOrcObjectLayerAddObjectFileWithRT: function(ObjLayer: LLVMOrcObjectLayerRef; RT: LLVMOrcResourceTrackerRef; ObjBuffer: LLVMMemoryBufferRef): LLVMErrorRef; cdecl;
  LLVMOrcObjectLayerEmit: procedure(ObjLayer: LLVMOrcObjectLayerRef; R: LLVMOrcMaterializationResponsibilityRef; ObjBuffer: LLVMMemoryBufferRef); cdecl;
  LLVMOrcDisposeObjectLayer: procedure(ObjLayer: LLVMOrcObjectLayerRef); cdecl;
  LLVMOrcIRTransformLayerEmit: procedure(IRTransformLayer: LLVMOrcIRTransformLayerRef; MR: LLVMOrcMaterializationResponsibilityRef; TSM: LLVMOrcThreadSafeModuleRef); cdecl;
  LLVMOrcIRTransformLayerSetTransform: procedure(IRTransformLayer: LLVMOrcIRTransformLayerRef; TransformFunction: LLVMOrcIRTransformLayerTransformFunction; Ctx: Pointer); cdecl;
  LLVMOrcObjectTransformLayerSetTransform: procedure(ObjTransformLayer: LLVMOrcObjectTransformLayerRef; TransformFunction: LLVMOrcObjectTransformLayerTransformFunction; Ctx: Pointer); cdecl;
  LLVMOrcCreateLocalIndirectStubsManager: function(const TargetTriple: PUTF8Char): LLVMOrcIndirectStubsManagerRef; cdecl;
  LLVMOrcDisposeIndirectStubsManager: procedure(ISM: LLVMOrcIndirectStubsManagerRef); cdecl;
  LLVMOrcCreateLocalLazyCallThroughManager: function(const TargetTriple: PUTF8Char; ES: LLVMOrcExecutionSessionRef; ErrorHandlerAddr: LLVMOrcJITTargetAddress; LCTM: PLLVMOrcLazyCallThroughManagerRef): LLVMErrorRef; cdecl;
  LLVMOrcDisposeLazyCallThroughManager: procedure(LCTM: LLVMOrcLazyCallThroughManagerRef); cdecl;
  LLVMOrcCreateDumpObjects: function(const DumpDir: PUTF8Char; const IdentifierOverride: PUTF8Char): LLVMOrcDumpObjectsRef; cdecl;
  LLVMOrcDisposeDumpObjects: procedure(DumpObjects: LLVMOrcDumpObjectsRef); cdecl;
  LLVMOrcDumpObjects_CallOperator: function(DumpObjects: LLVMOrcDumpObjectsRef; ObjBuffer: PLLVMMemoryBufferRef): LLVMErrorRef; cdecl;
  LLVMOrcCreateLLJITBuilder: function(): LLVMOrcLLJITBuilderRef; cdecl;
  LLVMOrcDisposeLLJITBuilder: procedure(Builder: LLVMOrcLLJITBuilderRef); cdecl;
  LLVMOrcLLJITBuilderSetJITTargetMachineBuilder: procedure(Builder: LLVMOrcLLJITBuilderRef; JTMB: LLVMOrcJITTargetMachineBuilderRef); cdecl;
  LLVMOrcLLJITBuilderSetObjectLinkingLayerCreator: procedure(Builder: LLVMOrcLLJITBuilderRef; F: LLVMOrcLLJITBuilderObjectLinkingLayerCreatorFunction; Ctx: Pointer); cdecl;
  LLVMOrcCreateLLJIT: function(Result: PLLVMOrcLLJITRef; Builder: LLVMOrcLLJITBuilderRef): LLVMErrorRef; cdecl;
  LLVMOrcDisposeLLJIT: function(J: LLVMOrcLLJITRef): LLVMErrorRef; cdecl;
  LLVMOrcLLJITGetExecutionSession: function(J: LLVMOrcLLJITRef): LLVMOrcExecutionSessionRef; cdecl;
  LLVMOrcLLJITGetMainJITDylib: function(J: LLVMOrcLLJITRef): LLVMOrcJITDylibRef; cdecl;
  LLVMOrcLLJITGetTripleString: function(J: LLVMOrcLLJITRef): PUTF8Char; cdecl;
  LLVMOrcLLJITGetGlobalPrefix: function(J: LLVMOrcLLJITRef): UTF8Char; cdecl;
  LLVMOrcLLJITMangleAndIntern: function(J: LLVMOrcLLJITRef; const UnmangledName: PUTF8Char): LLVMOrcSymbolStringPoolEntryRef; cdecl;
  LLVMOrcLLJITAddObjectFile: function(J: LLVMOrcLLJITRef; JD: LLVMOrcJITDylibRef; ObjBuffer: LLVMMemoryBufferRef): LLVMErrorRef; cdecl;
  LLVMOrcLLJITAddObjectFileWithRT: function(J: LLVMOrcLLJITRef; RT: LLVMOrcResourceTrackerRef; ObjBuffer: LLVMMemoryBufferRef): LLVMErrorRef; cdecl;
  LLVMOrcLLJITAddLLVMIRModule: function(J: LLVMOrcLLJITRef; JD: LLVMOrcJITDylibRef; TSM: LLVMOrcThreadSafeModuleRef): LLVMErrorRef; cdecl;
  LLVMOrcLLJITAddLLVMIRModuleWithRT: function(J: LLVMOrcLLJITRef; JD: LLVMOrcResourceTrackerRef; TSM: LLVMOrcThreadSafeModuleRef): LLVMErrorRef; cdecl;
  LLVMOrcLLJITLookup: function(J: LLVMOrcLLJITRef; Result: PLLVMOrcExecutorAddress; const Name: PUTF8Char): LLVMErrorRef; cdecl;
  LLVMOrcLLJITGetObjLinkingLayer: function(J: LLVMOrcLLJITRef): LLVMOrcObjectLayerRef; cdecl;
  LLVMOrcLLJITGetObjTransformLayer: function(J: LLVMOrcLLJITRef): LLVMOrcObjectTransformLayerRef; cdecl;
  LLVMOrcLLJITGetIRTransformLayer: function(J: LLVMOrcLLJITRef): LLVMOrcIRTransformLayerRef; cdecl;
  LLVMOrcLLJITGetDataLayoutStr: function(J: LLVMOrcLLJITRef): PUTF8Char; cdecl;
  LLVMOrcLLJITEnableDebugSupport: function(J: LLVMOrcLLJITRef): LLVMErrorRef; cdecl;
  LLVMCreateBinary: function(MemBuf: LLVMMemoryBufferRef; Context: LLVMContextRef; ErrorMessage: PPUTF8Char): LLVMBinaryRef; cdecl;
  LLVMDisposeBinary: procedure(BR: LLVMBinaryRef); cdecl;
  LLVMBinaryCopyMemoryBuffer: function(BR: LLVMBinaryRef): LLVMMemoryBufferRef; cdecl;
  LLVMBinaryGetType: function(BR: LLVMBinaryRef): LLVMBinaryType; cdecl;
  LLVMMachOUniversalBinaryCopyObjectForArch: function(BR: LLVMBinaryRef; const Arch: PUTF8Char; ArchLen: NativeUInt; ErrorMessage: PPUTF8Char): LLVMBinaryRef; cdecl;
  LLVMObjectFileCopySectionIterator: function(BR: LLVMBinaryRef): LLVMSectionIteratorRef; cdecl;
  LLVMObjectFileIsSectionIteratorAtEnd: function(BR: LLVMBinaryRef; SI: LLVMSectionIteratorRef): LLVMBool; cdecl;
  LLVMObjectFileCopySymbolIterator: function(BR: LLVMBinaryRef): LLVMSymbolIteratorRef; cdecl;
  LLVMObjectFileIsSymbolIteratorAtEnd: function(BR: LLVMBinaryRef; SI: LLVMSymbolIteratorRef): LLVMBool; cdecl;
  LLVMDisposeSectionIterator: procedure(SI: LLVMSectionIteratorRef); cdecl;
  LLVMMoveToNextSection: procedure(SI: LLVMSectionIteratorRef); cdecl;
  LLVMMoveToContainingSection: procedure(Sect: LLVMSectionIteratorRef; Sym: LLVMSymbolIteratorRef); cdecl;
  LLVMDisposeSymbolIterator: procedure(SI: LLVMSymbolIteratorRef); cdecl;
  LLVMMoveToNextSymbol: procedure(SI: LLVMSymbolIteratorRef); cdecl;
  LLVMGetSectionName: function(SI: LLVMSectionIteratorRef): PUTF8Char; cdecl;
  LLVMGetSectionSize: function(SI: LLVMSectionIteratorRef): UInt64; cdecl;
  LLVMGetSectionContents: function(SI: LLVMSectionIteratorRef): PUTF8Char; cdecl;
  LLVMGetSectionAddress: function(SI: LLVMSectionIteratorRef): UInt64; cdecl;
  LLVMGetSectionContainsSymbol: function(SI: LLVMSectionIteratorRef; Sym: LLVMSymbolIteratorRef): LLVMBool; cdecl;
  LLVMGetRelocations: function(Section: LLVMSectionIteratorRef): LLVMRelocationIteratorRef; cdecl;
  LLVMDisposeRelocationIterator: procedure(RI: LLVMRelocationIteratorRef); cdecl;
  LLVMIsRelocationIteratorAtEnd: function(Section: LLVMSectionIteratorRef; RI: LLVMRelocationIteratorRef): LLVMBool; cdecl;
  LLVMMoveToNextRelocation: procedure(RI: LLVMRelocationIteratorRef); cdecl;
  LLVMGetSymbolName: function(SI: LLVMSymbolIteratorRef): PUTF8Char; cdecl;
  LLVMGetSymbolAddress: function(SI: LLVMSymbolIteratorRef): UInt64; cdecl;
  LLVMGetSymbolSize: function(SI: LLVMSymbolIteratorRef): UInt64; cdecl;
  LLVMGetRelocationOffset: function(RI: LLVMRelocationIteratorRef): UInt64; cdecl;
  LLVMGetRelocationSymbol: function(RI: LLVMRelocationIteratorRef): LLVMSymbolIteratorRef; cdecl;
  LLVMGetRelocationType: function(RI: LLVMRelocationIteratorRef): UInt64; cdecl;
  LLVMGetRelocationTypeName: function(RI: LLVMRelocationIteratorRef): PUTF8Char; cdecl;
  LLVMGetRelocationValueString: function(RI: LLVMRelocationIteratorRef): PUTF8Char; cdecl;
  LLVMCreateObjectFile: function(MemBuf: LLVMMemoryBufferRef): LLVMObjectFileRef; cdecl;
  LLVMDisposeObjectFile: procedure(ObjectFile: LLVMObjectFileRef); cdecl;
  LLVMGetSections: function(ObjectFile: LLVMObjectFileRef): LLVMSectionIteratorRef; cdecl;
  LLVMIsSectionIteratorAtEnd: function(ObjectFile: LLVMObjectFileRef; SI: LLVMSectionIteratorRef): LLVMBool; cdecl;
  LLVMGetSymbols: function(ObjectFile: LLVMObjectFileRef): LLVMSymbolIteratorRef; cdecl;
  LLVMIsSymbolIteratorAtEnd: function(ObjectFile: LLVMObjectFileRef; SI: LLVMSymbolIteratorRef): LLVMBool; cdecl;
  LLVMOrcCreateRTDyldObjectLinkingLayerWithSectionMemoryManager: function(ES: LLVMOrcExecutionSessionRef): LLVMOrcObjectLayerRef; cdecl;
  LLVMOrcCreateRTDyldObjectLinkingLayerWithMCJITMemoryManagerLikeCallbacks: function(ES: LLVMOrcExecutionSessionRef; CreateContextCtx: Pointer; CreateContext: LLVMMemoryManagerCreateContextCallback; NotifyTerminating: LLVMMemoryManagerNotifyTerminatingCallback; AllocateCodeSection: LLVMMemoryManagerAllocateCodeSectionCallback; AllocateDataSection: LLVMMemoryManagerAllocateDataSectionCallback; FinalizeMemory: LLVMMemoryManagerFinalizeMemoryCallback; Destroy: LLVMMemoryManagerDestroyCallback): LLVMOrcObjectLayerRef; cdecl;
  LLVMOrcRTDyldObjectLinkingLayerRegisterJITEventListener: procedure(RTDyldObjLinkingLayer: LLVMOrcObjectLayerRef; Listener: LLVMJITEventListenerRef); cdecl;
  LLVMRemarkStringGetData: function(String_: LLVMRemarkStringRef): PUTF8Char; cdecl;
  LLVMRemarkStringGetLen: function(String_: LLVMRemarkStringRef): UInt32; cdecl;
  LLVMRemarkDebugLocGetSourceFilePath: function(DL: LLVMRemarkDebugLocRef): LLVMRemarkStringRef; cdecl;
  LLVMRemarkDebugLocGetSourceLine: function(DL: LLVMRemarkDebugLocRef): UInt32; cdecl;
  LLVMRemarkDebugLocGetSourceColumn: function(DL: LLVMRemarkDebugLocRef): UInt32; cdecl;
  LLVMRemarkArgGetKey: function(Arg: LLVMRemarkArgRef): LLVMRemarkStringRef; cdecl;
  LLVMRemarkArgGetValue: function(Arg: LLVMRemarkArgRef): LLVMRemarkStringRef; cdecl;
  LLVMRemarkArgGetDebugLoc: function(Arg: LLVMRemarkArgRef): LLVMRemarkDebugLocRef; cdecl;
  LLVMRemarkEntryDispose: procedure(Remark: LLVMRemarkEntryRef); cdecl;
  LLVMRemarkEntryGetType: function(Remark: LLVMRemarkEntryRef): LLVMRemarkType; cdecl;
  LLVMRemarkEntryGetPassName: function(Remark: LLVMRemarkEntryRef): LLVMRemarkStringRef; cdecl;
  LLVMRemarkEntryGetRemarkName: function(Remark: LLVMRemarkEntryRef): LLVMRemarkStringRef; cdecl;
  LLVMRemarkEntryGetFunctionName: function(Remark: LLVMRemarkEntryRef): LLVMRemarkStringRef; cdecl;
  LLVMRemarkEntryGetDebugLoc: function(Remark: LLVMRemarkEntryRef): LLVMRemarkDebugLocRef; cdecl;
  LLVMRemarkEntryGetHotness: function(Remark: LLVMRemarkEntryRef): UInt64; cdecl;
  LLVMRemarkEntryGetNumArgs: function(Remark: LLVMRemarkEntryRef): UInt32; cdecl;
  LLVMRemarkEntryGetFirstArg: function(Remark: LLVMRemarkEntryRef): LLVMRemarkArgRef; cdecl;
  LLVMRemarkEntryGetNextArg: function(It: LLVMRemarkArgRef; Remark: LLVMRemarkEntryRef): LLVMRemarkArgRef; cdecl;
  LLVMRemarkParserCreateYAML: function(const Buf: Pointer; Size: UInt64): LLVMRemarkParserRef; cdecl;
  LLVMRemarkParserCreateBitstream: function(const Buf: Pointer; Size: UInt64): LLVMRemarkParserRef; cdecl;
  LLVMRemarkParserGetNext: function(Parser: LLVMRemarkParserRef): LLVMRemarkEntryRef; cdecl;
  LLVMRemarkParserHasError: function(Parser: LLVMRemarkParserRef): LLVMBool; cdecl;
  LLVMRemarkParserGetErrorMessage: function(Parser: LLVMRemarkParserRef): PUTF8Char; cdecl;
  LLVMRemarkParserDispose: procedure(Parser: LLVMRemarkParserRef); cdecl;
  LLVMRemarkVersion: function(): UInt32; cdecl;
  LLVMLoadLibraryPermanently: function(const Filename: PUTF8Char): LLVMBool; cdecl;
  LLVMParseCommandLineOptions: procedure(argc: Integer; const argv: PPUTF8Char; const Overview: PUTF8Char); cdecl;
  LLVMSearchForAddressOfSymbol: function(const symbolName: PUTF8Char): Pointer; cdecl;
  LLVMAddSymbol: procedure(const symbolName: PUTF8Char; symbolValue: Pointer); cdecl;
  LLVMRunPasses: function(M: LLVMModuleRef; const Passes: PUTF8Char; TM: LLVMTargetMachineRef; Options: LLVMPassBuilderOptionsRef): LLVMErrorRef; cdecl;
  LLVMRunPassesOnFunction: function(F: LLVMValueRef; const Passes: PUTF8Char; TM: LLVMTargetMachineRef; Options: LLVMPassBuilderOptionsRef): LLVMErrorRef; cdecl;
  LLVMCreatePassBuilderOptions: function(): LLVMPassBuilderOptionsRef; cdecl;
  LLVMPassBuilderOptionsSetVerifyEach: procedure(Options: LLVMPassBuilderOptionsRef; VerifyEach: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetDebugLogging: procedure(Options: LLVMPassBuilderOptionsRef; DebugLogging: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetAAPipeline: procedure(Options: LLVMPassBuilderOptionsRef; const AAPipeline: PUTF8Char); cdecl;
  LLVMPassBuilderOptionsSetLoopInterleaving: procedure(Options: LLVMPassBuilderOptionsRef; LoopInterleaving: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetLoopVectorization: procedure(Options: LLVMPassBuilderOptionsRef; LoopVectorization: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetSLPVectorization: procedure(Options: LLVMPassBuilderOptionsRef; SLPVectorization: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetLoopUnrolling: procedure(Options: LLVMPassBuilderOptionsRef; LoopUnrolling: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetForgetAllSCEVInLoopUnroll: procedure(Options: LLVMPassBuilderOptionsRef; ForgetAllSCEVInLoopUnroll: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetLicmMssaOptCap: procedure(Options: LLVMPassBuilderOptionsRef; LicmMssaOptCap: Cardinal); cdecl;
  LLVMPassBuilderOptionsSetLicmMssaNoAccForPromotionCap: procedure(Options: LLVMPassBuilderOptionsRef; LicmMssaNoAccForPromotionCap: Cardinal); cdecl;
  LLVMPassBuilderOptionsSetCallGraphProfile: procedure(Options: LLVMPassBuilderOptionsRef; CallGraphProfile: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetMergeFunctions: procedure(Options: LLVMPassBuilderOptionsRef; MergeFunctions: LLVMBool); cdecl;
  LLVMPassBuilderOptionsSetInlinerThreshold: procedure(Options: LLVMPassBuilderOptionsRef; Threshold: Integer); cdecl;
  LLVMDisposePassBuilderOptions: procedure(Options: LLVMPassBuilderOptionsRef); cdecl;
  LLD_Link: function(argc: Integer; argv: PPUTF8Char; const flavor: PUTF8Char; canRunAgain: PInteger): Integer; cdecl;

procedure GetExports(const aDLLHandle: THandle);

implementation

procedure GetExports(const aDLLHandle: THandle);
begin
  if aDllHandle = 0 then Exit;
  LLD_Link := GetProcAddress(aDLLHandle, 'LLD_Link');
  LLVMABIAlignmentOfType := GetProcAddress(aDLLHandle, 'LLVMABIAlignmentOfType');
  LLVMABISizeOfType := GetProcAddress(aDLLHandle, 'LLVMABISizeOfType');
  LLVMAddAlias2 := GetProcAddress(aDLLHandle, 'LLVMAddAlias2');
  LLVMAddAnalysisPasses := GetProcAddress(aDLLHandle, 'LLVMAddAnalysisPasses');
  LLVMAddAttributeAtIndex := GetProcAddress(aDLLHandle, 'LLVMAddAttributeAtIndex');
  LLVMAddCallSiteAttribute := GetProcAddress(aDLLHandle, 'LLVMAddCallSiteAttribute');
  LLVMAddCase := GetProcAddress(aDLLHandle, 'LLVMAddCase');
  LLVMAddClause := GetProcAddress(aDLLHandle, 'LLVMAddClause');
  LLVMAddDestination := GetProcAddress(aDLLHandle, 'LLVMAddDestination');
  LLVMAddFunction := GetProcAddress(aDLLHandle, 'LLVMAddFunction');
  LLVMAddGlobal := GetProcAddress(aDLLHandle, 'LLVMAddGlobal');
  LLVMAddGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMAddGlobalIFunc');
  LLVMAddGlobalInAddressSpace := GetProcAddress(aDLLHandle, 'LLVMAddGlobalInAddressSpace');
  LLVMAddGlobalMapping := GetProcAddress(aDLLHandle, 'LLVMAddGlobalMapping');
  LLVMAddHandler := GetProcAddress(aDLLHandle, 'LLVMAddHandler');
  LLVMAddIncoming := GetProcAddress(aDLLHandle, 'LLVMAddIncoming');
  LLVMAddMetadataToInst := GetProcAddress(aDLLHandle, 'LLVMAddMetadataToInst');
  LLVMAddModule := GetProcAddress(aDLLHandle, 'LLVMAddModule');
  LLVMAddModuleFlag := GetProcAddress(aDLLHandle, 'LLVMAddModuleFlag');
  LLVMAddNamedMetadataOperand := GetProcAddress(aDLLHandle, 'LLVMAddNamedMetadataOperand');
  LLVMAddSymbol := GetProcAddress(aDLLHandle, 'LLVMAddSymbol');
  LLVMAddTargetDependentFunctionAttr := GetProcAddress(aDLLHandle, 'LLVMAddTargetDependentFunctionAttr');
  LLVMAddTargetLibraryInfo := GetProcAddress(aDLLHandle, 'LLVMAddTargetLibraryInfo');
  LLVMAliasGetAliasee := GetProcAddress(aDLLHandle, 'LLVMAliasGetAliasee');
  LLVMAliasSetAliasee := GetProcAddress(aDLLHandle, 'LLVMAliasSetAliasee');
  LLVMAlignOf := GetProcAddress(aDLLHandle, 'LLVMAlignOf');
  LLVMAppendBasicBlock := GetProcAddress(aDLLHandle, 'LLVMAppendBasicBlock');
  LLVMAppendBasicBlockInContext := GetProcAddress(aDLLHandle, 'LLVMAppendBasicBlockInContext');
  LLVMAppendExistingBasicBlock := GetProcAddress(aDLLHandle, 'LLVMAppendExistingBasicBlock');
  LLVMAppendModuleInlineAsm := GetProcAddress(aDLLHandle, 'LLVMAppendModuleInlineAsm');
  LLVMArrayType := GetProcAddress(aDLLHandle, 'LLVMArrayType');
  LLVMArrayType2 := GetProcAddress(aDLLHandle, 'LLVMArrayType2');
  LLVMBasicBlockAsValue := GetProcAddress(aDLLHandle, 'LLVMBasicBlockAsValue');
  LLVMBFloatType := GetProcAddress(aDLLHandle, 'LLVMBFloatType');
  LLVMBFloatTypeInContext := GetProcAddress(aDLLHandle, 'LLVMBFloatTypeInContext');
  LLVMBinaryCopyMemoryBuffer := GetProcAddress(aDLLHandle, 'LLVMBinaryCopyMemoryBuffer');
  LLVMBinaryGetType := GetProcAddress(aDLLHandle, 'LLVMBinaryGetType');
  LLVMBlockAddress := GetProcAddress(aDLLHandle, 'LLVMBlockAddress');
  LLVMBuildAdd := GetProcAddress(aDLLHandle, 'LLVMBuildAdd');
  LLVMBuildAddrSpaceCast := GetProcAddress(aDLLHandle, 'LLVMBuildAddrSpaceCast');
  LLVMBuildAggregateRet := GetProcAddress(aDLLHandle, 'LLVMBuildAggregateRet');
  LLVMBuildAlloca := GetProcAddress(aDLLHandle, 'LLVMBuildAlloca');
  LLVMBuildAnd := GetProcAddress(aDLLHandle, 'LLVMBuildAnd');
  LLVMBuildArrayAlloca := GetProcAddress(aDLLHandle, 'LLVMBuildArrayAlloca');
  LLVMBuildArrayMalloc := GetProcAddress(aDLLHandle, 'LLVMBuildArrayMalloc');
  LLVMBuildAShr := GetProcAddress(aDLLHandle, 'LLVMBuildAShr');
  LLVMBuildAtomicCmpXchg := GetProcAddress(aDLLHandle, 'LLVMBuildAtomicCmpXchg');
  LLVMBuildAtomicCmpXchgSyncScope := GetProcAddress(aDLLHandle, 'LLVMBuildAtomicCmpXchgSyncScope');
  LLVMBuildAtomicRMW := GetProcAddress(aDLLHandle, 'LLVMBuildAtomicRMW');
  LLVMBuildAtomicRMWSyncScope := GetProcAddress(aDLLHandle, 'LLVMBuildAtomicRMWSyncScope');
  LLVMBuildBinOp := GetProcAddress(aDLLHandle, 'LLVMBuildBinOp');
  LLVMBuildBitCast := GetProcAddress(aDLLHandle, 'LLVMBuildBitCast');
  LLVMBuildBr := GetProcAddress(aDLLHandle, 'LLVMBuildBr');
  LLVMBuildCall2 := GetProcAddress(aDLLHandle, 'LLVMBuildCall2');
  LLVMBuildCallBr := GetProcAddress(aDLLHandle, 'LLVMBuildCallBr');
  LLVMBuildCallWithOperandBundles := GetProcAddress(aDLLHandle, 'LLVMBuildCallWithOperandBundles');
  LLVMBuildCast := GetProcAddress(aDLLHandle, 'LLVMBuildCast');
  LLVMBuildCatchPad := GetProcAddress(aDLLHandle, 'LLVMBuildCatchPad');
  LLVMBuildCatchRet := GetProcAddress(aDLLHandle, 'LLVMBuildCatchRet');
  LLVMBuildCatchSwitch := GetProcAddress(aDLLHandle, 'LLVMBuildCatchSwitch');
  LLVMBuildCleanupPad := GetProcAddress(aDLLHandle, 'LLVMBuildCleanupPad');
  LLVMBuildCleanupRet := GetProcAddress(aDLLHandle, 'LLVMBuildCleanupRet');
  LLVMBuildCondBr := GetProcAddress(aDLLHandle, 'LLVMBuildCondBr');
  LLVMBuilderGetDefaultFPMathTag := GetProcAddress(aDLLHandle, 'LLVMBuilderGetDefaultFPMathTag');
  LLVMBuilderSetDefaultFPMathTag := GetProcAddress(aDLLHandle, 'LLVMBuilderSetDefaultFPMathTag');
  LLVMBuildExactSDiv := GetProcAddress(aDLLHandle, 'LLVMBuildExactSDiv');
  LLVMBuildExactUDiv := GetProcAddress(aDLLHandle, 'LLVMBuildExactUDiv');
  LLVMBuildExtractElement := GetProcAddress(aDLLHandle, 'LLVMBuildExtractElement');
  LLVMBuildExtractValue := GetProcAddress(aDLLHandle, 'LLVMBuildExtractValue');
  LLVMBuildFAdd := GetProcAddress(aDLLHandle, 'LLVMBuildFAdd');
  LLVMBuildFCmp := GetProcAddress(aDLLHandle, 'LLVMBuildFCmp');
  LLVMBuildFDiv := GetProcAddress(aDLLHandle, 'LLVMBuildFDiv');
  LLVMBuildFence := GetProcAddress(aDLLHandle, 'LLVMBuildFence');
  LLVMBuildFenceSyncScope := GetProcAddress(aDLLHandle, 'LLVMBuildFenceSyncScope');
  LLVMBuildFMul := GetProcAddress(aDLLHandle, 'LLVMBuildFMul');
  LLVMBuildFNeg := GetProcAddress(aDLLHandle, 'LLVMBuildFNeg');
  LLVMBuildFPCast := GetProcAddress(aDLLHandle, 'LLVMBuildFPCast');
  LLVMBuildFPExt := GetProcAddress(aDLLHandle, 'LLVMBuildFPExt');
  LLVMBuildFPToSI := GetProcAddress(aDLLHandle, 'LLVMBuildFPToSI');
  LLVMBuildFPToUI := GetProcAddress(aDLLHandle, 'LLVMBuildFPToUI');
  LLVMBuildFPTrunc := GetProcAddress(aDLLHandle, 'LLVMBuildFPTrunc');
  LLVMBuildFree := GetProcAddress(aDLLHandle, 'LLVMBuildFree');
  LLVMBuildFreeze := GetProcAddress(aDLLHandle, 'LLVMBuildFreeze');
  LLVMBuildFRem := GetProcAddress(aDLLHandle, 'LLVMBuildFRem');
  LLVMBuildFSub := GetProcAddress(aDLLHandle, 'LLVMBuildFSub');
  LLVMBuildGEP2 := GetProcAddress(aDLLHandle, 'LLVMBuildGEP2');
  LLVMBuildGEPWithNoWrapFlags := GetProcAddress(aDLLHandle, 'LLVMBuildGEPWithNoWrapFlags');
  LLVMBuildGlobalString := GetProcAddress(aDLLHandle, 'LLVMBuildGlobalString');
  LLVMBuildGlobalStringPtr := GetProcAddress(aDLLHandle, 'LLVMBuildGlobalStringPtr');
  LLVMBuildICmp := GetProcAddress(aDLLHandle, 'LLVMBuildICmp');
  LLVMBuildInBoundsGEP2 := GetProcAddress(aDLLHandle, 'LLVMBuildInBoundsGEP2');
  LLVMBuildIndirectBr := GetProcAddress(aDLLHandle, 'LLVMBuildIndirectBr');
  LLVMBuildInsertElement := GetProcAddress(aDLLHandle, 'LLVMBuildInsertElement');
  LLVMBuildInsertValue := GetProcAddress(aDLLHandle, 'LLVMBuildInsertValue');
  LLVMBuildIntCast := GetProcAddress(aDLLHandle, 'LLVMBuildIntCast');
  LLVMBuildIntCast2 := GetProcAddress(aDLLHandle, 'LLVMBuildIntCast2');
  LLVMBuildIntToPtr := GetProcAddress(aDLLHandle, 'LLVMBuildIntToPtr');
  LLVMBuildInvoke2 := GetProcAddress(aDLLHandle, 'LLVMBuildInvoke2');
  LLVMBuildInvokeWithOperandBundles := GetProcAddress(aDLLHandle, 'LLVMBuildInvokeWithOperandBundles');
  LLVMBuildIsNotNull := GetProcAddress(aDLLHandle, 'LLVMBuildIsNotNull');
  LLVMBuildIsNull := GetProcAddress(aDLLHandle, 'LLVMBuildIsNull');
  LLVMBuildLandingPad := GetProcAddress(aDLLHandle, 'LLVMBuildLandingPad');
  LLVMBuildLoad2 := GetProcAddress(aDLLHandle, 'LLVMBuildLoad2');
  LLVMBuildLShr := GetProcAddress(aDLLHandle, 'LLVMBuildLShr');
  LLVMBuildMalloc := GetProcAddress(aDLLHandle, 'LLVMBuildMalloc');
  LLVMBuildMemCpy := GetProcAddress(aDLLHandle, 'LLVMBuildMemCpy');
  LLVMBuildMemMove := GetProcAddress(aDLLHandle, 'LLVMBuildMemMove');
  LLVMBuildMemSet := GetProcAddress(aDLLHandle, 'LLVMBuildMemSet');
  LLVMBuildMul := GetProcAddress(aDLLHandle, 'LLVMBuildMul');
  LLVMBuildNeg := GetProcAddress(aDLLHandle, 'LLVMBuildNeg');
  LLVMBuildNot := GetProcAddress(aDLLHandle, 'LLVMBuildNot');
  LLVMBuildNSWAdd := GetProcAddress(aDLLHandle, 'LLVMBuildNSWAdd');
  LLVMBuildNSWMul := GetProcAddress(aDLLHandle, 'LLVMBuildNSWMul');
  LLVMBuildNSWNeg := GetProcAddress(aDLLHandle, 'LLVMBuildNSWNeg');
  LLVMBuildNSWSub := GetProcAddress(aDLLHandle, 'LLVMBuildNSWSub');
  LLVMBuildNUWAdd := GetProcAddress(aDLLHandle, 'LLVMBuildNUWAdd');
  LLVMBuildNUWMul := GetProcAddress(aDLLHandle, 'LLVMBuildNUWMul');
  LLVMBuildNUWNeg := GetProcAddress(aDLLHandle, 'LLVMBuildNUWNeg');
  LLVMBuildNUWSub := GetProcAddress(aDLLHandle, 'LLVMBuildNUWSub');
  LLVMBuildOr := GetProcAddress(aDLLHandle, 'LLVMBuildOr');
  LLVMBuildPhi := GetProcAddress(aDLLHandle, 'LLVMBuildPhi');
  LLVMBuildPointerCast := GetProcAddress(aDLLHandle, 'LLVMBuildPointerCast');
  LLVMBuildPtrDiff2 := GetProcAddress(aDLLHandle, 'LLVMBuildPtrDiff2');
  LLVMBuildPtrToInt := GetProcAddress(aDLLHandle, 'LLVMBuildPtrToInt');
  LLVMBuildResume := GetProcAddress(aDLLHandle, 'LLVMBuildResume');
  LLVMBuildRet := GetProcAddress(aDLLHandle, 'LLVMBuildRet');
  LLVMBuildRetVoid := GetProcAddress(aDLLHandle, 'LLVMBuildRetVoid');
  LLVMBuildSDiv := GetProcAddress(aDLLHandle, 'LLVMBuildSDiv');
  LLVMBuildSelect := GetProcAddress(aDLLHandle, 'LLVMBuildSelect');
  LLVMBuildSExt := GetProcAddress(aDLLHandle, 'LLVMBuildSExt');
  LLVMBuildSExtOrBitCast := GetProcAddress(aDLLHandle, 'LLVMBuildSExtOrBitCast');
  LLVMBuildShl := GetProcAddress(aDLLHandle, 'LLVMBuildShl');
  LLVMBuildShuffleVector := GetProcAddress(aDLLHandle, 'LLVMBuildShuffleVector');
  LLVMBuildSIToFP := GetProcAddress(aDLLHandle, 'LLVMBuildSIToFP');
  LLVMBuildSRem := GetProcAddress(aDLLHandle, 'LLVMBuildSRem');
  LLVMBuildStore := GetProcAddress(aDLLHandle, 'LLVMBuildStore');
  LLVMBuildStructGEP2 := GetProcAddress(aDLLHandle, 'LLVMBuildStructGEP2');
  LLVMBuildSub := GetProcAddress(aDLLHandle, 'LLVMBuildSub');
  LLVMBuildSwitch := GetProcAddress(aDLLHandle, 'LLVMBuildSwitch');
  LLVMBuildTrunc := GetProcAddress(aDLLHandle, 'LLVMBuildTrunc');
  LLVMBuildTruncOrBitCast := GetProcAddress(aDLLHandle, 'LLVMBuildTruncOrBitCast');
  LLVMBuildUDiv := GetProcAddress(aDLLHandle, 'LLVMBuildUDiv');
  LLVMBuildUIToFP := GetProcAddress(aDLLHandle, 'LLVMBuildUIToFP');
  LLVMBuildUnreachable := GetProcAddress(aDLLHandle, 'LLVMBuildUnreachable');
  LLVMBuildURem := GetProcAddress(aDLLHandle, 'LLVMBuildURem');
  LLVMBuildVAArg := GetProcAddress(aDLLHandle, 'LLVMBuildVAArg');
  LLVMBuildXor := GetProcAddress(aDLLHandle, 'LLVMBuildXor');
  LLVMBuildZExt := GetProcAddress(aDLLHandle, 'LLVMBuildZExt');
  LLVMBuildZExtOrBitCast := GetProcAddress(aDLLHandle, 'LLVMBuildZExtOrBitCast');
  LLVMByteOrder := GetProcAddress(aDLLHandle, 'LLVMByteOrder');
  LLVMCallFrameAlignmentOfType := GetProcAddress(aDLLHandle, 'LLVMCallFrameAlignmentOfType');
  LLVMCantFail := GetProcAddress(aDLLHandle, 'LLVMCantFail');
  LLVMCanValueUseFastMathFlags := GetProcAddress(aDLLHandle, 'LLVMCanValueUseFastMathFlags');
  LLVMClearInsertionPosition := GetProcAddress(aDLLHandle, 'LLVMClearInsertionPosition');
  LLVMCloneModule := GetProcAddress(aDLLHandle, 'LLVMCloneModule');
  LLVMConstAdd := GetProcAddress(aDLLHandle, 'LLVMConstAdd');
  LLVMConstAddrSpaceCast := GetProcAddress(aDLLHandle, 'LLVMConstAddrSpaceCast');
  LLVMConstAllOnes := GetProcAddress(aDLLHandle, 'LLVMConstAllOnes');
  LLVMConstantPtrAuth := GetProcAddress(aDLLHandle, 'LLVMConstantPtrAuth');
  LLVMConstArray := GetProcAddress(aDLLHandle, 'LLVMConstArray');
  LLVMConstArray2 := GetProcAddress(aDLLHandle, 'LLVMConstArray2');
  LLVMConstBitCast := GetProcAddress(aDLLHandle, 'LLVMConstBitCast');
  LLVMConstDataArray := GetProcAddress(aDLLHandle, 'LLVMConstDataArray');
  LLVMConstExtractElement := GetProcAddress(aDLLHandle, 'LLVMConstExtractElement');
  LLVMConstGEP2 := GetProcAddress(aDLLHandle, 'LLVMConstGEP2');
  LLVMConstGEPWithNoWrapFlags := GetProcAddress(aDLLHandle, 'LLVMConstGEPWithNoWrapFlags');
  LLVMConstInBoundsGEP2 := GetProcAddress(aDLLHandle, 'LLVMConstInBoundsGEP2');
  LLVMConstInlineAsm := GetProcAddress(aDLLHandle, 'LLVMConstInlineAsm');
  LLVMConstInsertElement := GetProcAddress(aDLLHandle, 'LLVMConstInsertElement');
  LLVMConstInt := GetProcAddress(aDLLHandle, 'LLVMConstInt');
  LLVMConstIntGetSExtValue := GetProcAddress(aDLLHandle, 'LLVMConstIntGetSExtValue');
  LLVMConstIntGetZExtValue := GetProcAddress(aDLLHandle, 'LLVMConstIntGetZExtValue');
  LLVMConstIntOfArbitraryPrecision := GetProcAddress(aDLLHandle, 'LLVMConstIntOfArbitraryPrecision');
  LLVMConstIntOfString := GetProcAddress(aDLLHandle, 'LLVMConstIntOfString');
  LLVMConstIntOfStringAndSize := GetProcAddress(aDLLHandle, 'LLVMConstIntOfStringAndSize');
  LLVMConstIntToPtr := GetProcAddress(aDLLHandle, 'LLVMConstIntToPtr');
  LLVMConstNamedStruct := GetProcAddress(aDLLHandle, 'LLVMConstNamedStruct');
  LLVMConstNeg := GetProcAddress(aDLLHandle, 'LLVMConstNeg');
  LLVMConstNot := GetProcAddress(aDLLHandle, 'LLVMConstNot');
  LLVMConstNSWAdd := GetProcAddress(aDLLHandle, 'LLVMConstNSWAdd');
  LLVMConstNSWNeg := GetProcAddress(aDLLHandle, 'LLVMConstNSWNeg');
  LLVMConstNSWSub := GetProcAddress(aDLLHandle, 'LLVMConstNSWSub');
  LLVMConstNull := GetProcAddress(aDLLHandle, 'LLVMConstNull');
  LLVMConstNUWAdd := GetProcAddress(aDLLHandle, 'LLVMConstNUWAdd');
  LLVMConstNUWNeg := GetProcAddress(aDLLHandle, 'LLVMConstNUWNeg');
  LLVMConstNUWSub := GetProcAddress(aDLLHandle, 'LLVMConstNUWSub');
  LLVMConstPointerCast := GetProcAddress(aDLLHandle, 'LLVMConstPointerCast');
  LLVMConstPointerNull := GetProcAddress(aDLLHandle, 'LLVMConstPointerNull');
  LLVMConstPtrToInt := GetProcAddress(aDLLHandle, 'LLVMConstPtrToInt');
  LLVMConstReal := GetProcAddress(aDLLHandle, 'LLVMConstReal');
  LLVMConstRealGetDouble := GetProcAddress(aDLLHandle, 'LLVMConstRealGetDouble');
  LLVMConstRealOfString := GetProcAddress(aDLLHandle, 'LLVMConstRealOfString');
  LLVMConstRealOfStringAndSize := GetProcAddress(aDLLHandle, 'LLVMConstRealOfStringAndSize');
  LLVMConstShuffleVector := GetProcAddress(aDLLHandle, 'LLVMConstShuffleVector');
  LLVMConstString := GetProcAddress(aDLLHandle, 'LLVMConstString');
  LLVMConstStringInContext := GetProcAddress(aDLLHandle, 'LLVMConstStringInContext');
  LLVMConstStringInContext2 := GetProcAddress(aDLLHandle, 'LLVMConstStringInContext2');
  LLVMConstStruct := GetProcAddress(aDLLHandle, 'LLVMConstStruct');
  LLVMConstStructInContext := GetProcAddress(aDLLHandle, 'LLVMConstStructInContext');
  LLVMConstSub := GetProcAddress(aDLLHandle, 'LLVMConstSub');
  LLVMConstTrunc := GetProcAddress(aDLLHandle, 'LLVMConstTrunc');
  LLVMConstTruncOrBitCast := GetProcAddress(aDLLHandle, 'LLVMConstTruncOrBitCast');
  LLVMConstVector := GetProcAddress(aDLLHandle, 'LLVMConstVector');
  LLVMConstXor := GetProcAddress(aDLLHandle, 'LLVMConstXor');
  LLVMConsumeError := GetProcAddress(aDLLHandle, 'LLVMConsumeError');
  LLVMContextCreate := GetProcAddress(aDLLHandle, 'LLVMContextCreate');
  LLVMContextDispose := GetProcAddress(aDLLHandle, 'LLVMContextDispose');
  LLVMContextGetDiagnosticContext := GetProcAddress(aDLLHandle, 'LLVMContextGetDiagnosticContext');
  LLVMContextGetDiagnosticHandler := GetProcAddress(aDLLHandle, 'LLVMContextGetDiagnosticHandler');
  LLVMContextSetDiagnosticHandler := GetProcAddress(aDLLHandle, 'LLVMContextSetDiagnosticHandler');
  LLVMContextSetDiscardValueNames := GetProcAddress(aDLLHandle, 'LLVMContextSetDiscardValueNames');
  LLVMContextSetYieldCallback := GetProcAddress(aDLLHandle, 'LLVMContextSetYieldCallback');
  LLVMContextShouldDiscardValueNames := GetProcAddress(aDLLHandle, 'LLVMContextShouldDiscardValueNames');
  LLVMCopyModuleFlagsMetadata := GetProcAddress(aDLLHandle, 'LLVMCopyModuleFlagsMetadata');
  LLVMCopyStringRepOfTargetData := GetProcAddress(aDLLHandle, 'LLVMCopyStringRepOfTargetData');
  LLVMCountBasicBlocks := GetProcAddress(aDLLHandle, 'LLVMCountBasicBlocks');
  LLVMCountIncoming := GetProcAddress(aDLLHandle, 'LLVMCountIncoming');
  LLVMCountParams := GetProcAddress(aDLLHandle, 'LLVMCountParams');
  LLVMCountParamTypes := GetProcAddress(aDLLHandle, 'LLVMCountParamTypes');
  LLVMCountStructElementTypes := GetProcAddress(aDLLHandle, 'LLVMCountStructElementTypes');
  LLVMCreateBasicBlockInContext := GetProcAddress(aDLLHandle, 'LLVMCreateBasicBlockInContext');
  LLVMCreateBinary := GetProcAddress(aDLLHandle, 'LLVMCreateBinary');
  LLVMCreateBuilder := GetProcAddress(aDLLHandle, 'LLVMCreateBuilder');
  LLVMCreateBuilderInContext := GetProcAddress(aDLLHandle, 'LLVMCreateBuilderInContext');
  LLVMCreateConstantRangeAttribute := GetProcAddress(aDLLHandle, 'LLVMCreateConstantRangeAttribute');
  LLVMCreateDIBuilder := GetProcAddress(aDLLHandle, 'LLVMCreateDIBuilder');
  LLVMCreateDIBuilderDisallowUnresolved := GetProcAddress(aDLLHandle, 'LLVMCreateDIBuilderDisallowUnresolved');
  LLVMCreateDisasm := GetProcAddress(aDLLHandle, 'LLVMCreateDisasm');
  LLVMCreateDisasmCPU := GetProcAddress(aDLLHandle, 'LLVMCreateDisasmCPU');
  LLVMCreateDisasmCPUFeatures := GetProcAddress(aDLLHandle, 'LLVMCreateDisasmCPUFeatures');
  LLVMCreateEnumAttribute := GetProcAddress(aDLLHandle, 'LLVMCreateEnumAttribute');
  LLVMCreateExecutionEngineForModule := GetProcAddress(aDLLHandle, 'LLVMCreateExecutionEngineForModule');
  LLVMCreateFunctionPassManager := GetProcAddress(aDLLHandle, 'LLVMCreateFunctionPassManager');
  LLVMCreateFunctionPassManagerForModule := GetProcAddress(aDLLHandle, 'LLVMCreateFunctionPassManagerForModule');
  LLVMCreateGDBRegistrationListener := GetProcAddress(aDLLHandle, 'LLVMCreateGDBRegistrationListener');
  LLVMCreateGenericValueOfFloat := GetProcAddress(aDLLHandle, 'LLVMCreateGenericValueOfFloat');
  LLVMCreateGenericValueOfInt := GetProcAddress(aDLLHandle, 'LLVMCreateGenericValueOfInt');
  LLVMCreateGenericValueOfPointer := GetProcAddress(aDLLHandle, 'LLVMCreateGenericValueOfPointer');
  LLVMCreateIntelJITEventListener := GetProcAddress(aDLLHandle, 'LLVMCreateIntelJITEventListener');
  LLVMCreateInterpreterForModule := GetProcAddress(aDLLHandle, 'LLVMCreateInterpreterForModule');
  LLVMCreateJITCompilerForModule := GetProcAddress(aDLLHandle, 'LLVMCreateJITCompilerForModule');
  LLVMCreateMCJITCompilerForModule := GetProcAddress(aDLLHandle, 'LLVMCreateMCJITCompilerForModule');
  LLVMCreateMemoryBufferWithContentsOfFile := GetProcAddress(aDLLHandle, 'LLVMCreateMemoryBufferWithContentsOfFile');
  LLVMCreateMemoryBufferWithMemoryRange := GetProcAddress(aDLLHandle, 'LLVMCreateMemoryBufferWithMemoryRange');
  LLVMCreateMemoryBufferWithMemoryRangeCopy := GetProcAddress(aDLLHandle, 'LLVMCreateMemoryBufferWithMemoryRangeCopy');
  LLVMCreateMemoryBufferWithSTDIN := GetProcAddress(aDLLHandle, 'LLVMCreateMemoryBufferWithSTDIN');
  LLVMCreateMessage := GetProcAddress(aDLLHandle, 'LLVMCreateMessage');
  LLVMCreateModuleProviderForExistingModule := GetProcAddress(aDLLHandle, 'LLVMCreateModuleProviderForExistingModule');
  LLVMCreateObjectFile := GetProcAddress(aDLLHandle, 'LLVMCreateObjectFile');
  LLVMCreateOperandBundle := GetProcAddress(aDLLHandle, 'LLVMCreateOperandBundle');
  LLVMCreateOProfileJITEventListener := GetProcAddress(aDLLHandle, 'LLVMCreateOProfileJITEventListener');
  LLVMCreatePassBuilderOptions := GetProcAddress(aDLLHandle, 'LLVMCreatePassBuilderOptions');
  LLVMCreatePassManager := GetProcAddress(aDLLHandle, 'LLVMCreatePassManager');
  LLVMCreatePerfJITEventListener := GetProcAddress(aDLLHandle, 'LLVMCreatePerfJITEventListener');
  LLVMCreateSimpleMCJITMemoryManager := GetProcAddress(aDLLHandle, 'LLVMCreateSimpleMCJITMemoryManager');
  LLVMCreateStringAttribute := GetProcAddress(aDLLHandle, 'LLVMCreateStringAttribute');
  LLVMCreateStringError := GetProcAddress(aDLLHandle, 'LLVMCreateStringError');
  LLVMCreateTargetData := GetProcAddress(aDLLHandle, 'LLVMCreateTargetData');
  LLVMCreateTargetDataLayout := GetProcAddress(aDLLHandle, 'LLVMCreateTargetDataLayout');
  LLVMCreateTargetMachine := GetProcAddress(aDLLHandle, 'LLVMCreateTargetMachine');
  LLVMCreateTargetMachineOptions := GetProcAddress(aDLLHandle, 'LLVMCreateTargetMachineOptions');
  LLVMCreateTargetMachineWithOptions := GetProcAddress(aDLLHandle, 'LLVMCreateTargetMachineWithOptions');
  LLVMCreateTypeAttribute := GetProcAddress(aDLLHandle, 'LLVMCreateTypeAttribute');
  LLVMDebugMetadataVersion := GetProcAddress(aDLLHandle, 'LLVMDebugMetadataVersion');
  LLVMDeleteBasicBlock := GetProcAddress(aDLLHandle, 'LLVMDeleteBasicBlock');
  LLVMDeleteFunction := GetProcAddress(aDLLHandle, 'LLVMDeleteFunction');
  LLVMDeleteGlobal := GetProcAddress(aDLLHandle, 'LLVMDeleteGlobal');
  LLVMDeleteInstruction := GetProcAddress(aDLLHandle, 'LLVMDeleteInstruction');
  LLVMDIBuilderCreateArrayType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateArrayType');
  LLVMDIBuilderCreateArtificialType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateArtificialType');
  LLVMDIBuilderCreateAutoVariable := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateAutoVariable');
  LLVMDIBuilderCreateBasicType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateBasicType');
  LLVMDIBuilderCreateBitFieldMemberType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateBitFieldMemberType');
  LLVMDIBuilderCreateClassType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateClassType');
  LLVMDIBuilderCreateCompileUnit := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateCompileUnit');
  LLVMDIBuilderCreateConstantValueExpression := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateConstantValueExpression');
  LLVMDIBuilderCreateDebugLocation := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateDebugLocation');
  LLVMDIBuilderCreateDynamicArrayType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateDynamicArrayType');
  LLVMDIBuilderCreateEnumerationType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateEnumerationType');
  LLVMDIBuilderCreateEnumerator := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateEnumerator');
  LLVMDIBuilderCreateEnumeratorOfArbitraryPrecision := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateEnumeratorOfArbitraryPrecision');
  LLVMDIBuilderCreateExpression := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateExpression');
  LLVMDIBuilderCreateFile := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateFile');
  LLVMDIBuilderCreateForwardDecl := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateForwardDecl');
  LLVMDIBuilderCreateFunction := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateFunction');
  LLVMDIBuilderCreateGlobalVariableExpression := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateGlobalVariableExpression');
  LLVMDIBuilderCreateImportedDeclaration := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateImportedDeclaration');
  LLVMDIBuilderCreateImportedModuleFromAlias := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateImportedModuleFromAlias');
  LLVMDIBuilderCreateImportedModuleFromModule := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateImportedModuleFromModule');
  LLVMDIBuilderCreateImportedModuleFromNamespace := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateImportedModuleFromNamespace');
  LLVMDIBuilderCreateInheritance := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateInheritance');
  LLVMDIBuilderCreateLabel := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateLabel');
  LLVMDIBuilderCreateLexicalBlock := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateLexicalBlock');
  LLVMDIBuilderCreateLexicalBlockFile := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateLexicalBlockFile');
  LLVMDIBuilderCreateMacro := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateMacro');
  LLVMDIBuilderCreateMemberPointerType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateMemberPointerType');
  LLVMDIBuilderCreateMemberType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateMemberType');
  LLVMDIBuilderCreateModule := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateModule');
  LLVMDIBuilderCreateNameSpace := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateNameSpace');
  LLVMDIBuilderCreateNullPtrType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateNullPtrType');
  LLVMDIBuilderCreateObjCIVar := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateObjCIVar');
  LLVMDIBuilderCreateObjCProperty := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateObjCProperty');
  LLVMDIBuilderCreateObjectPointerType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateObjectPointerType');
  LLVMDIBuilderCreateParameterVariable := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateParameterVariable');
  LLVMDIBuilderCreatePointerType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreatePointerType');
  LLVMDIBuilderCreateQualifiedType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateQualifiedType');
  LLVMDIBuilderCreateReferenceType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateReferenceType');
  LLVMDIBuilderCreateReplaceableCompositeType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateReplaceableCompositeType');
  LLVMDIBuilderCreateSetType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateSetType');
  LLVMDIBuilderCreateStaticMemberType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateStaticMemberType');
  LLVMDIBuilderCreateStructType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateStructType');
  LLVMDIBuilderCreateSubrangeType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateSubrangeType');
  LLVMDIBuilderCreateSubroutineType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateSubroutineType');
  LLVMDIBuilderCreateTempGlobalVariableFwdDecl := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateTempGlobalVariableFwdDecl');
  LLVMDIBuilderCreateTempMacroFile := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateTempMacroFile');
  LLVMDIBuilderCreateTypedef := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateTypedef');
  LLVMDIBuilderCreateUnionType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateUnionType');
  LLVMDIBuilderCreateUnspecifiedType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateUnspecifiedType');
  LLVMDIBuilderCreateVectorType := GetProcAddress(aDLLHandle, 'LLVMDIBuilderCreateVectorType');
  LLVMDIBuilderFinalize := GetProcAddress(aDLLHandle, 'LLVMDIBuilderFinalize');
  LLVMDIBuilderFinalizeSubprogram := GetProcAddress(aDLLHandle, 'LLVMDIBuilderFinalizeSubprogram');
  LLVMDIBuilderGetOrCreateArray := GetProcAddress(aDLLHandle, 'LLVMDIBuilderGetOrCreateArray');
  LLVMDIBuilderGetOrCreateSubrange := GetProcAddress(aDLLHandle, 'LLVMDIBuilderGetOrCreateSubrange');
  LLVMDIBuilderGetOrCreateTypeArray := GetProcAddress(aDLLHandle, 'LLVMDIBuilderGetOrCreateTypeArray');
  LLVMDIBuilderInsertDbgValueRecordAtEnd := GetProcAddress(aDLLHandle, 'LLVMDIBuilderInsertDbgValueRecordAtEnd');
  LLVMDIBuilderInsertDbgValueRecordBefore := GetProcAddress(aDLLHandle, 'LLVMDIBuilderInsertDbgValueRecordBefore');
  LLVMDIBuilderInsertDeclareRecordAtEnd := GetProcAddress(aDLLHandle, 'LLVMDIBuilderInsertDeclareRecordAtEnd');
  LLVMDIBuilderInsertDeclareRecordBefore := GetProcAddress(aDLLHandle, 'LLVMDIBuilderInsertDeclareRecordBefore');
  LLVMDIBuilderInsertLabelAtEnd := GetProcAddress(aDLLHandle, 'LLVMDIBuilderInsertLabelAtEnd');
  LLVMDIBuilderInsertLabelBefore := GetProcAddress(aDLLHandle, 'LLVMDIBuilderInsertLabelBefore');
  LLVMDIFileGetDirectory := GetProcAddress(aDLLHandle, 'LLVMDIFileGetDirectory');
  LLVMDIFileGetFilename := GetProcAddress(aDLLHandle, 'LLVMDIFileGetFilename');
  LLVMDIFileGetSource := GetProcAddress(aDLLHandle, 'LLVMDIFileGetSource');
  LLVMDIGlobalVariableExpressionGetExpression := GetProcAddress(aDLLHandle, 'LLVMDIGlobalVariableExpressionGetExpression');
  LLVMDIGlobalVariableExpressionGetVariable := GetProcAddress(aDLLHandle, 'LLVMDIGlobalVariableExpressionGetVariable');
  LLVMDILocationGetColumn := GetProcAddress(aDLLHandle, 'LLVMDILocationGetColumn');
  LLVMDILocationGetInlinedAt := GetProcAddress(aDLLHandle, 'LLVMDILocationGetInlinedAt');
  LLVMDILocationGetLine := GetProcAddress(aDLLHandle, 'LLVMDILocationGetLine');
  LLVMDILocationGetScope := GetProcAddress(aDLLHandle, 'LLVMDILocationGetScope');
  LLVMDisasmDispose := GetProcAddress(aDLLHandle, 'LLVMDisasmDispose');
  LLVMDisasmInstruction := GetProcAddress(aDLLHandle, 'LLVMDisasmInstruction');
  LLVMDIScopeGetFile := GetProcAddress(aDLLHandle, 'LLVMDIScopeGetFile');
  LLVMDisposeBinary := GetProcAddress(aDLLHandle, 'LLVMDisposeBinary');
  LLVMDisposeBuilder := GetProcAddress(aDLLHandle, 'LLVMDisposeBuilder');
  LLVMDisposeDIBuilder := GetProcAddress(aDLLHandle, 'LLVMDisposeDIBuilder');
  LLVMDisposeErrorMessage := GetProcAddress(aDLLHandle, 'LLVMDisposeErrorMessage');
  LLVMDisposeExecutionEngine := GetProcAddress(aDLLHandle, 'LLVMDisposeExecutionEngine');
  LLVMDisposeGenericValue := GetProcAddress(aDLLHandle, 'LLVMDisposeGenericValue');
  LLVMDisposeMCJITMemoryManager := GetProcAddress(aDLLHandle, 'LLVMDisposeMCJITMemoryManager');
  LLVMDisposeMemoryBuffer := GetProcAddress(aDLLHandle, 'LLVMDisposeMemoryBuffer');
  LLVMDisposeMessage := GetProcAddress(aDLLHandle, 'LLVMDisposeMessage');
  LLVMDisposeModule := GetProcAddress(aDLLHandle, 'LLVMDisposeModule');
  LLVMDisposeModuleFlagsMetadata := GetProcAddress(aDLLHandle, 'LLVMDisposeModuleFlagsMetadata');
  LLVMDisposeModuleProvider := GetProcAddress(aDLLHandle, 'LLVMDisposeModuleProvider');
  LLVMDisposeObjectFile := GetProcAddress(aDLLHandle, 'LLVMDisposeObjectFile');
  LLVMDisposeOperandBundle := GetProcAddress(aDLLHandle, 'LLVMDisposeOperandBundle');
  LLVMDisposePassBuilderOptions := GetProcAddress(aDLLHandle, 'LLVMDisposePassBuilderOptions');
  LLVMDisposePassManager := GetProcAddress(aDLLHandle, 'LLVMDisposePassManager');
  LLVMDisposeRelocationIterator := GetProcAddress(aDLLHandle, 'LLVMDisposeRelocationIterator');
  LLVMDisposeSectionIterator := GetProcAddress(aDLLHandle, 'LLVMDisposeSectionIterator');
  LLVMDisposeSymbolIterator := GetProcAddress(aDLLHandle, 'LLVMDisposeSymbolIterator');
  LLVMDisposeTargetData := GetProcAddress(aDLLHandle, 'LLVMDisposeTargetData');
  LLVMDisposeTargetMachine := GetProcAddress(aDLLHandle, 'LLVMDisposeTargetMachine');
  LLVMDisposeTargetMachineOptions := GetProcAddress(aDLLHandle, 'LLVMDisposeTargetMachineOptions');
  LLVMDisposeTemporaryMDNode := GetProcAddress(aDLLHandle, 'LLVMDisposeTemporaryMDNode');
  LLVMDisposeValueMetadataEntries := GetProcAddress(aDLLHandle, 'LLVMDisposeValueMetadataEntries');
  LLVMDISubprogramGetLine := GetProcAddress(aDLLHandle, 'LLVMDISubprogramGetLine');
  LLVMDISubprogramReplaceType := GetProcAddress(aDLLHandle, 'LLVMDISubprogramReplaceType');
  LLVMDITypeGetAlignInBits := GetProcAddress(aDLLHandle, 'LLVMDITypeGetAlignInBits');
  LLVMDITypeGetFlags := GetProcAddress(aDLLHandle, 'LLVMDITypeGetFlags');
  LLVMDITypeGetLine := GetProcAddress(aDLLHandle, 'LLVMDITypeGetLine');
  LLVMDITypeGetName := GetProcAddress(aDLLHandle, 'LLVMDITypeGetName');
  LLVMDITypeGetOffsetInBits := GetProcAddress(aDLLHandle, 'LLVMDITypeGetOffsetInBits');
  LLVMDITypeGetSizeInBits := GetProcAddress(aDLLHandle, 'LLVMDITypeGetSizeInBits');
  LLVMDIVariableGetFile := GetProcAddress(aDLLHandle, 'LLVMDIVariableGetFile');
  LLVMDIVariableGetLine := GetProcAddress(aDLLHandle, 'LLVMDIVariableGetLine');
  LLVMDIVariableGetScope := GetProcAddress(aDLLHandle, 'LLVMDIVariableGetScope');
  LLVMDoubleType := GetProcAddress(aDLLHandle, 'LLVMDoubleType');
  LLVMDoubleTypeInContext := GetProcAddress(aDLLHandle, 'LLVMDoubleTypeInContext');
  LLVMDumpModule := GetProcAddress(aDLLHandle, 'LLVMDumpModule');
  LLVMDumpType := GetProcAddress(aDLLHandle, 'LLVMDumpType');
  LLVMDumpValue := GetProcAddress(aDLLHandle, 'LLVMDumpValue');
  LLVMElementAtOffset := GetProcAddress(aDLLHandle, 'LLVMElementAtOffset');
  LLVMEnablePrettyStackTrace := GetProcAddress(aDLLHandle, 'LLVMEnablePrettyStackTrace');
  LLVMEraseGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMEraseGlobalIFunc');
  LLVMExecutionEngineGetErrMsg := GetProcAddress(aDLLHandle, 'LLVMExecutionEngineGetErrMsg');
  LLVMFinalizeFunctionPassManager := GetProcAddress(aDLLHandle, 'LLVMFinalizeFunctionPassManager');
  LLVMFindFunction := GetProcAddress(aDLLHandle, 'LLVMFindFunction');
  LLVMFloatType := GetProcAddress(aDLLHandle, 'LLVMFloatType');
  LLVMFloatTypeInContext := GetProcAddress(aDLLHandle, 'LLVMFloatTypeInContext');
  LLVMFP128Type := GetProcAddress(aDLLHandle, 'LLVMFP128Type');
  LLVMFP128TypeInContext := GetProcAddress(aDLLHandle, 'LLVMFP128TypeInContext');
  LLVMFreeMachineCodeForFunction := GetProcAddress(aDLLHandle, 'LLVMFreeMachineCodeForFunction');
  LLVMFunctionType := GetProcAddress(aDLLHandle, 'LLVMFunctionType');
  LLVMGenericValueIntWidth := GetProcAddress(aDLLHandle, 'LLVMGenericValueIntWidth');
  LLVMGenericValueToFloat := GetProcAddress(aDLLHandle, 'LLVMGenericValueToFloat');
  LLVMGenericValueToInt := GetProcAddress(aDLLHandle, 'LLVMGenericValueToInt');
  LLVMGenericValueToPointer := GetProcAddress(aDLLHandle, 'LLVMGenericValueToPointer');
  LLVMGEPGetNoWrapFlags := GetProcAddress(aDLLHandle, 'LLVMGEPGetNoWrapFlags');
  LLVMGEPSetNoWrapFlags := GetProcAddress(aDLLHandle, 'LLVMGEPSetNoWrapFlags');
  LLVMGetAggregateElement := GetProcAddress(aDLLHandle, 'LLVMGetAggregateElement');
  LLVMGetAlignment := GetProcAddress(aDLLHandle, 'LLVMGetAlignment');
  LLVMGetAllocatedType := GetProcAddress(aDLLHandle, 'LLVMGetAllocatedType');
  LLVMGetArgOperand := GetProcAddress(aDLLHandle, 'LLVMGetArgOperand');
  LLVMGetArrayLength := GetProcAddress(aDLLHandle, 'LLVMGetArrayLength');
  LLVMGetArrayLength2 := GetProcAddress(aDLLHandle, 'LLVMGetArrayLength2');
  LLVMGetAsString := GetProcAddress(aDLLHandle, 'LLVMGetAsString');
  LLVMGetAtomicRMWBinOp := GetProcAddress(aDLLHandle, 'LLVMGetAtomicRMWBinOp');
  LLVMGetAtomicSyncScopeID := GetProcAddress(aDLLHandle, 'LLVMGetAtomicSyncScopeID');
  LLVMGetAttributeCountAtIndex := GetProcAddress(aDLLHandle, 'LLVMGetAttributeCountAtIndex');
  LLVMGetAttributesAtIndex := GetProcAddress(aDLLHandle, 'LLVMGetAttributesAtIndex');
  LLVMGetBasicBlockName := GetProcAddress(aDLLHandle, 'LLVMGetBasicBlockName');
  LLVMGetBasicBlockParent := GetProcAddress(aDLLHandle, 'LLVMGetBasicBlockParent');
  LLVMGetBasicBlocks := GetProcAddress(aDLLHandle, 'LLVMGetBasicBlocks');
  LLVMGetBasicBlockTerminator := GetProcAddress(aDLLHandle, 'LLVMGetBasicBlockTerminator');
  LLVMGetBitcodeModule := GetProcAddress(aDLLHandle, 'LLVMGetBitcodeModule');
  LLVMGetBitcodeModule2 := GetProcAddress(aDLLHandle, 'LLVMGetBitcodeModule2');
  LLVMGetBitcodeModuleInContext := GetProcAddress(aDLLHandle, 'LLVMGetBitcodeModuleInContext');
  LLVMGetBitcodeModuleInContext2 := GetProcAddress(aDLLHandle, 'LLVMGetBitcodeModuleInContext2');
  LLVMGetBlockAddressBasicBlock := GetProcAddress(aDLLHandle, 'LLVMGetBlockAddressBasicBlock');
  LLVMGetBlockAddressFunction := GetProcAddress(aDLLHandle, 'LLVMGetBlockAddressFunction');
  LLVMGetBufferSize := GetProcAddress(aDLLHandle, 'LLVMGetBufferSize');
  LLVMGetBufferStart := GetProcAddress(aDLLHandle, 'LLVMGetBufferStart');
  LLVMGetBuilderContext := GetProcAddress(aDLLHandle, 'LLVMGetBuilderContext');
  LLVMGetCallBrDefaultDest := GetProcAddress(aDLLHandle, 'LLVMGetCallBrDefaultDest');
  LLVMGetCallBrIndirectDest := GetProcAddress(aDLLHandle, 'LLVMGetCallBrIndirectDest');
  LLVMGetCallBrNumIndirectDests := GetProcAddress(aDLLHandle, 'LLVMGetCallBrNumIndirectDests');
  LLVMGetCalledFunctionType := GetProcAddress(aDLLHandle, 'LLVMGetCalledFunctionType');
  LLVMGetCalledValue := GetProcAddress(aDLLHandle, 'LLVMGetCalledValue');
  LLVMGetCallSiteAttributeCount := GetProcAddress(aDLLHandle, 'LLVMGetCallSiteAttributeCount');
  LLVMGetCallSiteAttributes := GetProcAddress(aDLLHandle, 'LLVMGetCallSiteAttributes');
  LLVMGetCallSiteEnumAttribute := GetProcAddress(aDLLHandle, 'LLVMGetCallSiteEnumAttribute');
  LLVMGetCallSiteStringAttribute := GetProcAddress(aDLLHandle, 'LLVMGetCallSiteStringAttribute');
  LLVMGetCastOpcode := GetProcAddress(aDLLHandle, 'LLVMGetCastOpcode');
  LLVMGetClause := GetProcAddress(aDLLHandle, 'LLVMGetClause');
  LLVMGetCmpXchgFailureOrdering := GetProcAddress(aDLLHandle, 'LLVMGetCmpXchgFailureOrdering');
  LLVMGetCmpXchgSuccessOrdering := GetProcAddress(aDLLHandle, 'LLVMGetCmpXchgSuccessOrdering');
  LLVMGetComdat := GetProcAddress(aDLLHandle, 'LLVMGetComdat');
  LLVMGetComdatSelectionKind := GetProcAddress(aDLLHandle, 'LLVMGetComdatSelectionKind');
  LLVMGetCondition := GetProcAddress(aDLLHandle, 'LLVMGetCondition');
  LLVMGetConstantPtrAuthAddrDiscriminator := GetProcAddress(aDLLHandle, 'LLVMGetConstantPtrAuthAddrDiscriminator');
  LLVMGetConstantPtrAuthDiscriminator := GetProcAddress(aDLLHandle, 'LLVMGetConstantPtrAuthDiscriminator');
  LLVMGetConstantPtrAuthKey := GetProcAddress(aDLLHandle, 'LLVMGetConstantPtrAuthKey');
  LLVMGetConstantPtrAuthPointer := GetProcAddress(aDLLHandle, 'LLVMGetConstantPtrAuthPointer');
  LLVMGetConstOpcode := GetProcAddress(aDLLHandle, 'LLVMGetConstOpcode');
  LLVMGetCurrentDebugLocation := GetProcAddress(aDLLHandle, 'LLVMGetCurrentDebugLocation');
  LLVMGetCurrentDebugLocation2 := GetProcAddress(aDLLHandle, 'LLVMGetCurrentDebugLocation2');
  LLVMGetDataLayout := GetProcAddress(aDLLHandle, 'LLVMGetDataLayout');
  LLVMGetDataLayoutStr := GetProcAddress(aDLLHandle, 'LLVMGetDataLayoutStr');
  LLVMGetDebugLocColumn := GetProcAddress(aDLLHandle, 'LLVMGetDebugLocColumn');
  LLVMGetDebugLocDirectory := GetProcAddress(aDLLHandle, 'LLVMGetDebugLocDirectory');
  LLVMGetDebugLocFilename := GetProcAddress(aDLLHandle, 'LLVMGetDebugLocFilename');
  LLVMGetDebugLocLine := GetProcAddress(aDLLHandle, 'LLVMGetDebugLocLine');
  LLVMGetDefaultTargetTriple := GetProcAddress(aDLLHandle, 'LLVMGetDefaultTargetTriple');
  LLVMGetDiagInfoDescription := GetProcAddress(aDLLHandle, 'LLVMGetDiagInfoDescription');
  LLVMGetDiagInfoSeverity := GetProcAddress(aDLLHandle, 'LLVMGetDiagInfoSeverity');
  LLVMGetDINodeTag := GetProcAddress(aDLLHandle, 'LLVMGetDINodeTag');
  LLVMGetDLLStorageClass := GetProcAddress(aDLLHandle, 'LLVMGetDLLStorageClass');
  LLVMGetElementAsConstant := GetProcAddress(aDLLHandle, 'LLVMGetElementAsConstant');
  LLVMGetElementType := GetProcAddress(aDLLHandle, 'LLVMGetElementType');
  LLVMGetEntryBasicBlock := GetProcAddress(aDLLHandle, 'LLVMGetEntryBasicBlock');
  LLVMGetEnumAttributeAtIndex := GetProcAddress(aDLLHandle, 'LLVMGetEnumAttributeAtIndex');
  LLVMGetEnumAttributeKind := GetProcAddress(aDLLHandle, 'LLVMGetEnumAttributeKind');
  LLVMGetEnumAttributeKindForName := GetProcAddress(aDLLHandle, 'LLVMGetEnumAttributeKindForName');
  LLVMGetEnumAttributeValue := GetProcAddress(aDLLHandle, 'LLVMGetEnumAttributeValue');
  LLVMGetErrorMessage := GetProcAddress(aDLLHandle, 'LLVMGetErrorMessage');
  LLVMGetErrorTypeId := GetProcAddress(aDLLHandle, 'LLVMGetErrorTypeId');
  LLVMGetExact := GetProcAddress(aDLLHandle, 'LLVMGetExact');
  LLVMGetExecutionEngineTargetData := GetProcAddress(aDLLHandle, 'LLVMGetExecutionEngineTargetData');
  LLVMGetExecutionEngineTargetMachine := GetProcAddress(aDLLHandle, 'LLVMGetExecutionEngineTargetMachine');
  LLVMGetFastMathFlags := GetProcAddress(aDLLHandle, 'LLVMGetFastMathFlags');
  LLVMGetFCmpPredicate := GetProcAddress(aDLLHandle, 'LLVMGetFCmpPredicate');
  LLVMGetFirstBasicBlock := GetProcAddress(aDLLHandle, 'LLVMGetFirstBasicBlock');
  LLVMGetFirstDbgRecord := GetProcAddress(aDLLHandle, 'LLVMGetFirstDbgRecord');
  LLVMGetFirstFunction := GetProcAddress(aDLLHandle, 'LLVMGetFirstFunction');
  LLVMGetFirstGlobal := GetProcAddress(aDLLHandle, 'LLVMGetFirstGlobal');
  LLVMGetFirstGlobalAlias := GetProcAddress(aDLLHandle, 'LLVMGetFirstGlobalAlias');
  LLVMGetFirstGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMGetFirstGlobalIFunc');
  LLVMGetFirstInstruction := GetProcAddress(aDLLHandle, 'LLVMGetFirstInstruction');
  LLVMGetFirstNamedMetadata := GetProcAddress(aDLLHandle, 'LLVMGetFirstNamedMetadata');
  LLVMGetFirstParam := GetProcAddress(aDLLHandle, 'LLVMGetFirstParam');
  LLVMGetFirstTarget := GetProcAddress(aDLLHandle, 'LLVMGetFirstTarget');
  LLVMGetFirstUse := GetProcAddress(aDLLHandle, 'LLVMGetFirstUse');
  LLVMGetFunctionAddress := GetProcAddress(aDLLHandle, 'LLVMGetFunctionAddress');
  LLVMGetFunctionCallConv := GetProcAddress(aDLLHandle, 'LLVMGetFunctionCallConv');
  LLVMGetGC := GetProcAddress(aDLLHandle, 'LLVMGetGC');
  LLVMGetGEPSourceElementType := GetProcAddress(aDLLHandle, 'LLVMGetGEPSourceElementType');
  LLVMGetGlobalContext := GetProcAddress(aDLLHandle, 'LLVMGetGlobalContext');
  LLVMGetGlobalIFuncResolver := GetProcAddress(aDLLHandle, 'LLVMGetGlobalIFuncResolver');
  LLVMGetGlobalParent := GetProcAddress(aDLLHandle, 'LLVMGetGlobalParent');
  LLVMGetGlobalValueAddress := GetProcAddress(aDLLHandle, 'LLVMGetGlobalValueAddress');
  LLVMGetHandlers := GetProcAddress(aDLLHandle, 'LLVMGetHandlers');
  LLVMGetHostCPUFeatures := GetProcAddress(aDLLHandle, 'LLVMGetHostCPUFeatures');
  LLVMGetHostCPUName := GetProcAddress(aDLLHandle, 'LLVMGetHostCPUName');
  LLVMGetICmpPredicate := GetProcAddress(aDLLHandle, 'LLVMGetICmpPredicate');
  LLVMGetICmpSameSign := GetProcAddress(aDLLHandle, 'LLVMGetICmpSameSign');
  LLVMGetIncomingBlock := GetProcAddress(aDLLHandle, 'LLVMGetIncomingBlock');
  LLVMGetIncomingValue := GetProcAddress(aDLLHandle, 'LLVMGetIncomingValue');
  LLVMGetIndices := GetProcAddress(aDLLHandle, 'LLVMGetIndices');
  LLVMGetInitializer := GetProcAddress(aDLLHandle, 'LLVMGetInitializer');
  LLVMGetInlineAsm := GetProcAddress(aDLLHandle, 'LLVMGetInlineAsm');
  LLVMGetInlineAsmAsmString := GetProcAddress(aDLLHandle, 'LLVMGetInlineAsmAsmString');
  LLVMGetInlineAsmCanUnwind := GetProcAddress(aDLLHandle, 'LLVMGetInlineAsmCanUnwind');
  LLVMGetInlineAsmConstraintString := GetProcAddress(aDLLHandle, 'LLVMGetInlineAsmConstraintString');
  LLVMGetInlineAsmDialect := GetProcAddress(aDLLHandle, 'LLVMGetInlineAsmDialect');
  LLVMGetInlineAsmFunctionType := GetProcAddress(aDLLHandle, 'LLVMGetInlineAsmFunctionType');
  LLVMGetInlineAsmHasSideEffects := GetProcAddress(aDLLHandle, 'LLVMGetInlineAsmHasSideEffects');
  LLVMGetInlineAsmNeedsAlignedStack := GetProcAddress(aDLLHandle, 'LLVMGetInlineAsmNeedsAlignedStack');
  LLVMGetInsertBlock := GetProcAddress(aDLLHandle, 'LLVMGetInsertBlock');
  LLVMGetInstructionCallConv := GetProcAddress(aDLLHandle, 'LLVMGetInstructionCallConv');
  LLVMGetInstructionOpcode := GetProcAddress(aDLLHandle, 'LLVMGetInstructionOpcode');
  LLVMGetInstructionParent := GetProcAddress(aDLLHandle, 'LLVMGetInstructionParent');
  LLVMGetIntrinsicDeclaration := GetProcAddress(aDLLHandle, 'LLVMGetIntrinsicDeclaration');
  LLVMGetIntrinsicID := GetProcAddress(aDLLHandle, 'LLVMGetIntrinsicID');
  LLVMGetIntTypeWidth := GetProcAddress(aDLLHandle, 'LLVMGetIntTypeWidth');
  LLVMGetIsDisjoint := GetProcAddress(aDLLHandle, 'LLVMGetIsDisjoint');
  LLVMGetLastBasicBlock := GetProcAddress(aDLLHandle, 'LLVMGetLastBasicBlock');
  LLVMGetLastDbgRecord := GetProcAddress(aDLLHandle, 'LLVMGetLastDbgRecord');
  LLVMGetLastEnumAttributeKind := GetProcAddress(aDLLHandle, 'LLVMGetLastEnumAttributeKind');
  LLVMGetLastFunction := GetProcAddress(aDLLHandle, 'LLVMGetLastFunction');
  LLVMGetLastGlobal := GetProcAddress(aDLLHandle, 'LLVMGetLastGlobal');
  LLVMGetLastGlobalAlias := GetProcAddress(aDLLHandle, 'LLVMGetLastGlobalAlias');
  LLVMGetLastGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMGetLastGlobalIFunc');
  LLVMGetLastInstruction := GetProcAddress(aDLLHandle, 'LLVMGetLastInstruction');
  LLVMGetLastNamedMetadata := GetProcAddress(aDLLHandle, 'LLVMGetLastNamedMetadata');
  LLVMGetLastParam := GetProcAddress(aDLLHandle, 'LLVMGetLastParam');
  LLVMGetLinkage := GetProcAddress(aDLLHandle, 'LLVMGetLinkage');
  LLVMGetMaskValue := GetProcAddress(aDLLHandle, 'LLVMGetMaskValue');
  LLVMGetMDKindID := GetProcAddress(aDLLHandle, 'LLVMGetMDKindID');
  LLVMGetMDKindIDInContext := GetProcAddress(aDLLHandle, 'LLVMGetMDKindIDInContext');
  LLVMGetMDNodeNumOperands := GetProcAddress(aDLLHandle, 'LLVMGetMDNodeNumOperands');
  LLVMGetMDNodeOperands := GetProcAddress(aDLLHandle, 'LLVMGetMDNodeOperands');
  LLVMGetMDString := GetProcAddress(aDLLHandle, 'LLVMGetMDString');
  LLVMGetMetadata := GetProcAddress(aDLLHandle, 'LLVMGetMetadata');
  LLVMGetMetadataKind := GetProcAddress(aDLLHandle, 'LLVMGetMetadataKind');
  LLVMGetModuleContext := GetProcAddress(aDLLHandle, 'LLVMGetModuleContext');
  LLVMGetModuleDataLayout := GetProcAddress(aDLLHandle, 'LLVMGetModuleDataLayout');
  LLVMGetModuleDebugMetadataVersion := GetProcAddress(aDLLHandle, 'LLVMGetModuleDebugMetadataVersion');
  LLVMGetModuleFlag := GetProcAddress(aDLLHandle, 'LLVMGetModuleFlag');
  LLVMGetModuleIdentifier := GetProcAddress(aDLLHandle, 'LLVMGetModuleIdentifier');
  LLVMGetModuleInlineAsm := GetProcAddress(aDLLHandle, 'LLVMGetModuleInlineAsm');
  LLVMGetNamedFunction := GetProcAddress(aDLLHandle, 'LLVMGetNamedFunction');
  LLVMGetNamedFunctionWithLength := GetProcAddress(aDLLHandle, 'LLVMGetNamedFunctionWithLength');
  LLVMGetNamedGlobal := GetProcAddress(aDLLHandle, 'LLVMGetNamedGlobal');
  LLVMGetNamedGlobalAlias := GetProcAddress(aDLLHandle, 'LLVMGetNamedGlobalAlias');
  LLVMGetNamedGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMGetNamedGlobalIFunc');
  LLVMGetNamedGlobalWithLength := GetProcAddress(aDLLHandle, 'LLVMGetNamedGlobalWithLength');
  LLVMGetNamedMetadata := GetProcAddress(aDLLHandle, 'LLVMGetNamedMetadata');
  LLVMGetNamedMetadataName := GetProcAddress(aDLLHandle, 'LLVMGetNamedMetadataName');
  LLVMGetNamedMetadataNumOperands := GetProcAddress(aDLLHandle, 'LLVMGetNamedMetadataNumOperands');
  LLVMGetNamedMetadataOperands := GetProcAddress(aDLLHandle, 'LLVMGetNamedMetadataOperands');
  LLVMGetNextBasicBlock := GetProcAddress(aDLLHandle, 'LLVMGetNextBasicBlock');
  LLVMGetNextDbgRecord := GetProcAddress(aDLLHandle, 'LLVMGetNextDbgRecord');
  LLVMGetNextFunction := GetProcAddress(aDLLHandle, 'LLVMGetNextFunction');
  LLVMGetNextGlobal := GetProcAddress(aDLLHandle, 'LLVMGetNextGlobal');
  LLVMGetNextGlobalAlias := GetProcAddress(aDLLHandle, 'LLVMGetNextGlobalAlias');
  LLVMGetNextGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMGetNextGlobalIFunc');
  LLVMGetNextInstruction := GetProcAddress(aDLLHandle, 'LLVMGetNextInstruction');
  LLVMGetNextNamedMetadata := GetProcAddress(aDLLHandle, 'LLVMGetNextNamedMetadata');
  LLVMGetNextParam := GetProcAddress(aDLLHandle, 'LLVMGetNextParam');
  LLVMGetNextTarget := GetProcAddress(aDLLHandle, 'LLVMGetNextTarget');
  LLVMGetNextUse := GetProcAddress(aDLLHandle, 'LLVMGetNextUse');
  LLVMGetNNeg := GetProcAddress(aDLLHandle, 'LLVMGetNNeg');
  LLVMGetNormalDest := GetProcAddress(aDLLHandle, 'LLVMGetNormalDest');
  LLVMGetNSW := GetProcAddress(aDLLHandle, 'LLVMGetNSW');
  LLVMGetNumArgOperands := GetProcAddress(aDLLHandle, 'LLVMGetNumArgOperands');
  LLVMGetNumClauses := GetProcAddress(aDLLHandle, 'LLVMGetNumClauses');
  LLVMGetNumContainedTypes := GetProcAddress(aDLLHandle, 'LLVMGetNumContainedTypes');
  LLVMGetNumHandlers := GetProcAddress(aDLLHandle, 'LLVMGetNumHandlers');
  LLVMGetNumIndices := GetProcAddress(aDLLHandle, 'LLVMGetNumIndices');
  LLVMGetNumMaskElements := GetProcAddress(aDLLHandle, 'LLVMGetNumMaskElements');
  LLVMGetNumOperandBundleArgs := GetProcAddress(aDLLHandle, 'LLVMGetNumOperandBundleArgs');
  LLVMGetNumOperandBundles := GetProcAddress(aDLLHandle, 'LLVMGetNumOperandBundles');
  LLVMGetNumOperands := GetProcAddress(aDLLHandle, 'LLVMGetNumOperands');
  LLVMGetNumSuccessors := GetProcAddress(aDLLHandle, 'LLVMGetNumSuccessors');
  LLVMGetNUW := GetProcAddress(aDLLHandle, 'LLVMGetNUW');
  LLVMGetOperand := GetProcAddress(aDLLHandle, 'LLVMGetOperand');
  LLVMGetOperandBundleArgAtIndex := GetProcAddress(aDLLHandle, 'LLVMGetOperandBundleArgAtIndex');
  LLVMGetOperandBundleAtIndex := GetProcAddress(aDLLHandle, 'LLVMGetOperandBundleAtIndex');
  LLVMGetOperandBundleTag := GetProcAddress(aDLLHandle, 'LLVMGetOperandBundleTag');
  LLVMGetOperandUse := GetProcAddress(aDLLHandle, 'LLVMGetOperandUse');
  LLVMGetOrdering := GetProcAddress(aDLLHandle, 'LLVMGetOrdering');
  LLVMGetOrInsertComdat := GetProcAddress(aDLLHandle, 'LLVMGetOrInsertComdat');
  LLVMGetOrInsertNamedMetadata := GetProcAddress(aDLLHandle, 'LLVMGetOrInsertNamedMetadata');
  LLVMGetParam := GetProcAddress(aDLLHandle, 'LLVMGetParam');
  LLVMGetParamParent := GetProcAddress(aDLLHandle, 'LLVMGetParamParent');
  LLVMGetParams := GetProcAddress(aDLLHandle, 'LLVMGetParams');
  LLVMGetParamTypes := GetProcAddress(aDLLHandle, 'LLVMGetParamTypes');
  LLVMGetParentCatchSwitch := GetProcAddress(aDLLHandle, 'LLVMGetParentCatchSwitch');
  LLVMGetPersonalityFn := GetProcAddress(aDLLHandle, 'LLVMGetPersonalityFn');
  LLVMGetPointerAddressSpace := GetProcAddress(aDLLHandle, 'LLVMGetPointerAddressSpace');
  LLVMGetPointerToGlobal := GetProcAddress(aDLLHandle, 'LLVMGetPointerToGlobal');
  LLVMGetPoison := GetProcAddress(aDLLHandle, 'LLVMGetPoison');
  LLVMGetPrefixData := GetProcAddress(aDLLHandle, 'LLVMGetPrefixData');
  LLVMGetPreviousBasicBlock := GetProcAddress(aDLLHandle, 'LLVMGetPreviousBasicBlock');
  LLVMGetPreviousDbgRecord := GetProcAddress(aDLLHandle, 'LLVMGetPreviousDbgRecord');
  LLVMGetPreviousFunction := GetProcAddress(aDLLHandle, 'LLVMGetPreviousFunction');
  LLVMGetPreviousGlobal := GetProcAddress(aDLLHandle, 'LLVMGetPreviousGlobal');
  LLVMGetPreviousGlobalAlias := GetProcAddress(aDLLHandle, 'LLVMGetPreviousGlobalAlias');
  LLVMGetPreviousGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMGetPreviousGlobalIFunc');
  LLVMGetPreviousInstruction := GetProcAddress(aDLLHandle, 'LLVMGetPreviousInstruction');
  LLVMGetPreviousNamedMetadata := GetProcAddress(aDLLHandle, 'LLVMGetPreviousNamedMetadata');
  LLVMGetPreviousParam := GetProcAddress(aDLLHandle, 'LLVMGetPreviousParam');
  LLVMGetPrologueData := GetProcAddress(aDLLHandle, 'LLVMGetPrologueData');
  LLVMGetRawDataValues := GetProcAddress(aDLLHandle, 'LLVMGetRawDataValues');
  LLVMGetRelocationOffset := GetProcAddress(aDLLHandle, 'LLVMGetRelocationOffset');
  LLVMGetRelocations := GetProcAddress(aDLLHandle, 'LLVMGetRelocations');
  LLVMGetRelocationSymbol := GetProcAddress(aDLLHandle, 'LLVMGetRelocationSymbol');
  LLVMGetRelocationType := GetProcAddress(aDLLHandle, 'LLVMGetRelocationType');
  LLVMGetRelocationTypeName := GetProcAddress(aDLLHandle, 'LLVMGetRelocationTypeName');
  LLVMGetRelocationValueString := GetProcAddress(aDLLHandle, 'LLVMGetRelocationValueString');
  LLVMGetReturnType := GetProcAddress(aDLLHandle, 'LLVMGetReturnType');
  LLVMGetSection := GetProcAddress(aDLLHandle, 'LLVMGetSection');
  LLVMGetSectionAddress := GetProcAddress(aDLLHandle, 'LLVMGetSectionAddress');
  LLVMGetSectionContainsSymbol := GetProcAddress(aDLLHandle, 'LLVMGetSectionContainsSymbol');
  LLVMGetSectionContents := GetProcAddress(aDLLHandle, 'LLVMGetSectionContents');
  LLVMGetSectionName := GetProcAddress(aDLLHandle, 'LLVMGetSectionName');
  LLVMGetSections := GetProcAddress(aDLLHandle, 'LLVMGetSections');
  LLVMGetSectionSize := GetProcAddress(aDLLHandle, 'LLVMGetSectionSize');
  LLVMGetSourceFileName := GetProcAddress(aDLLHandle, 'LLVMGetSourceFileName');
  LLVMGetStringAttributeAtIndex := GetProcAddress(aDLLHandle, 'LLVMGetStringAttributeAtIndex');
  LLVMGetStringAttributeKind := GetProcAddress(aDLLHandle, 'LLVMGetStringAttributeKind');
  LLVMGetStringAttributeValue := GetProcAddress(aDLLHandle, 'LLVMGetStringAttributeValue');
  LLVMGetStringErrorTypeId := GetProcAddress(aDLLHandle, 'LLVMGetStringErrorTypeId');
  LLVMGetStructElementTypes := GetProcAddress(aDLLHandle, 'LLVMGetStructElementTypes');
  LLVMGetStructName := GetProcAddress(aDLLHandle, 'LLVMGetStructName');
  LLVMGetSubprogram := GetProcAddress(aDLLHandle, 'LLVMGetSubprogram');
  LLVMGetSubtypes := GetProcAddress(aDLLHandle, 'LLVMGetSubtypes');
  LLVMGetSuccessor := GetProcAddress(aDLLHandle, 'LLVMGetSuccessor');
  LLVMGetSwitchDefaultDest := GetProcAddress(aDLLHandle, 'LLVMGetSwitchDefaultDest');
  LLVMGetSymbolAddress := GetProcAddress(aDLLHandle, 'LLVMGetSymbolAddress');
  LLVMGetSymbolName := GetProcAddress(aDLLHandle, 'LLVMGetSymbolName');
  LLVMGetSymbols := GetProcAddress(aDLLHandle, 'LLVMGetSymbols');
  LLVMGetSymbolSize := GetProcAddress(aDLLHandle, 'LLVMGetSymbolSize');
  LLVMGetSyncScopeID := GetProcAddress(aDLLHandle, 'LLVMGetSyncScopeID');
  LLVMGetTailCallKind := GetProcAddress(aDLLHandle, 'LLVMGetTailCallKind');
  LLVMGetTarget := GetProcAddress(aDLLHandle, 'LLVMGetTarget');
  LLVMGetTargetDescription := GetProcAddress(aDLLHandle, 'LLVMGetTargetDescription');
  LLVMGetTargetExtTypeIntParam := GetProcAddress(aDLLHandle, 'LLVMGetTargetExtTypeIntParam');
  LLVMGetTargetExtTypeName := GetProcAddress(aDLLHandle, 'LLVMGetTargetExtTypeName');
  LLVMGetTargetExtTypeNumIntParams := GetProcAddress(aDLLHandle, 'LLVMGetTargetExtTypeNumIntParams');
  LLVMGetTargetExtTypeNumTypeParams := GetProcAddress(aDLLHandle, 'LLVMGetTargetExtTypeNumTypeParams');
  LLVMGetTargetExtTypeTypeParam := GetProcAddress(aDLLHandle, 'LLVMGetTargetExtTypeTypeParam');
  LLVMGetTargetFromName := GetProcAddress(aDLLHandle, 'LLVMGetTargetFromName');
  LLVMGetTargetFromTriple := GetProcAddress(aDLLHandle, 'LLVMGetTargetFromTriple');
  LLVMGetTargetMachineCPU := GetProcAddress(aDLLHandle, 'LLVMGetTargetMachineCPU');
  LLVMGetTargetMachineFeatureString := GetProcAddress(aDLLHandle, 'LLVMGetTargetMachineFeatureString');
  LLVMGetTargetMachineTarget := GetProcAddress(aDLLHandle, 'LLVMGetTargetMachineTarget');
  LLVMGetTargetMachineTriple := GetProcAddress(aDLLHandle, 'LLVMGetTargetMachineTriple');
  LLVMGetTargetName := GetProcAddress(aDLLHandle, 'LLVMGetTargetName');
  LLVMGetThreadLocalMode := GetProcAddress(aDLLHandle, 'LLVMGetThreadLocalMode');
  LLVMGetTypeAttributeValue := GetProcAddress(aDLLHandle, 'LLVMGetTypeAttributeValue');
  LLVMGetTypeByName := GetProcAddress(aDLLHandle, 'LLVMGetTypeByName');
  LLVMGetTypeByName2 := GetProcAddress(aDLLHandle, 'LLVMGetTypeByName2');
  LLVMGetTypeContext := GetProcAddress(aDLLHandle, 'LLVMGetTypeContext');
  LLVMGetTypeKind := GetProcAddress(aDLLHandle, 'LLVMGetTypeKind');
  LLVMGetUndef := GetProcAddress(aDLLHandle, 'LLVMGetUndef');
  LLVMGetUndefMaskElem := GetProcAddress(aDLLHandle, 'LLVMGetUndefMaskElem');
  LLVMGetUnnamedAddress := GetProcAddress(aDLLHandle, 'LLVMGetUnnamedAddress');
  LLVMGetUnwindDest := GetProcAddress(aDLLHandle, 'LLVMGetUnwindDest');
  LLVMGetUsedValue := GetProcAddress(aDLLHandle, 'LLVMGetUsedValue');
  LLVMGetUser := GetProcAddress(aDLLHandle, 'LLVMGetUser');
  LLVMGetValueContext := GetProcAddress(aDLLHandle, 'LLVMGetValueContext');
  LLVMGetValueKind := GetProcAddress(aDLLHandle, 'LLVMGetValueKind');
  LLVMGetValueName := GetProcAddress(aDLLHandle, 'LLVMGetValueName');
  LLVMGetValueName2 := GetProcAddress(aDLLHandle, 'LLVMGetValueName2');
  LLVMGetVectorSize := GetProcAddress(aDLLHandle, 'LLVMGetVectorSize');
  LLVMGetVersion := GetProcAddress(aDLLHandle, 'LLVMGetVersion');
  LLVMGetVisibility := GetProcAddress(aDLLHandle, 'LLVMGetVisibility');
  LLVMGetVolatile := GetProcAddress(aDLLHandle, 'LLVMGetVolatile');
  LLVMGetWeak := GetProcAddress(aDLLHandle, 'LLVMGetWeak');
  LLVMGlobalClearMetadata := GetProcAddress(aDLLHandle, 'LLVMGlobalClearMetadata');
  LLVMGlobalCopyAllMetadata := GetProcAddress(aDLLHandle, 'LLVMGlobalCopyAllMetadata');
  LLVMGlobalEraseMetadata := GetProcAddress(aDLLHandle, 'LLVMGlobalEraseMetadata');
  LLVMGlobalGetValueType := GetProcAddress(aDLLHandle, 'LLVMGlobalGetValueType');
  LLVMGlobalSetMetadata := GetProcAddress(aDLLHandle, 'LLVMGlobalSetMetadata');
  LLVMHalfType := GetProcAddress(aDLLHandle, 'LLVMHalfType');
  LLVMHalfTypeInContext := GetProcAddress(aDLLHandle, 'LLVMHalfTypeInContext');
  LLVMHasMetadata := GetProcAddress(aDLLHandle, 'LLVMHasMetadata');
  LLVMHasPersonalityFn := GetProcAddress(aDLLHandle, 'LLVMHasPersonalityFn');
  LLVMHasPrefixData := GetProcAddress(aDLLHandle, 'LLVMHasPrefixData');
  LLVMHasPrologueData := GetProcAddress(aDLLHandle, 'LLVMHasPrologueData');
  LLVMHasUnnamedAddr := GetProcAddress(aDLLHandle, 'LLVMHasUnnamedAddr');
  LLVMInitializeAArch64AsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeAArch64AsmParser');
  LLVMInitializeAArch64AsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeAArch64AsmPrinter');
  LLVMInitializeAArch64Disassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeAArch64Disassembler');
  LLVMInitializeAArch64Target := GetProcAddress(aDLLHandle, 'LLVMInitializeAArch64Target');
  LLVMInitializeAArch64TargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeAArch64TargetInfo');
  LLVMInitializeAArch64TargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeAArch64TargetMC');
  LLVMInitializeAMDGPUAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeAMDGPUAsmParser');
  LLVMInitializeAMDGPUAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeAMDGPUAsmPrinter');
  LLVMInitializeAMDGPUDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeAMDGPUDisassembler');
  LLVMInitializeAMDGPUTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeAMDGPUTarget');
  LLVMInitializeAMDGPUTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeAMDGPUTargetInfo');
  LLVMInitializeAMDGPUTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeAMDGPUTargetMC');
  LLVMInitializeARMAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeARMAsmParser');
  LLVMInitializeARMAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeARMAsmPrinter');
  LLVMInitializeARMDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeARMDisassembler');
  LLVMInitializeARMTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeARMTarget');
  LLVMInitializeARMTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeARMTargetInfo');
  LLVMInitializeARMTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeARMTargetMC');
  LLVMInitializeAVRAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeAVRAsmParser');
  LLVMInitializeAVRAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeAVRAsmPrinter');
  LLVMInitializeAVRDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeAVRDisassembler');
  LLVMInitializeAVRTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeAVRTarget');
  LLVMInitializeAVRTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeAVRTargetInfo');
  LLVMInitializeAVRTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeAVRTargetMC');
  LLVMInitializeBPFAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeBPFAsmParser');
  LLVMInitializeBPFAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeBPFAsmPrinter');
  LLVMInitializeBPFDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeBPFDisassembler');
  LLVMInitializeBPFTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeBPFTarget');
  LLVMInitializeBPFTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeBPFTargetInfo');
  LLVMInitializeBPFTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeBPFTargetMC');
  LLVMInitializeFunctionPassManager := GetProcAddress(aDLLHandle, 'LLVMInitializeFunctionPassManager');
  LLVMInitializeHexagonAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeHexagonAsmParser');
  LLVMInitializeHexagonAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeHexagonAsmPrinter');
  LLVMInitializeHexagonDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeHexagonDisassembler');
  LLVMInitializeHexagonTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeHexagonTarget');
  LLVMInitializeHexagonTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeHexagonTargetInfo');
  LLVMInitializeHexagonTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeHexagonTargetMC');
  LLVMInitializeLanaiAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeLanaiAsmParser');
  LLVMInitializeLanaiAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeLanaiAsmPrinter');
  LLVMInitializeLanaiDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeLanaiDisassembler');
  LLVMInitializeLanaiTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeLanaiTarget');
  LLVMInitializeLanaiTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeLanaiTargetInfo');
  LLVMInitializeLanaiTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeLanaiTargetMC');
  LLVMInitializeLoongArchAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeLoongArchAsmParser');
  LLVMInitializeLoongArchAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeLoongArchAsmPrinter');
  LLVMInitializeLoongArchDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeLoongArchDisassembler');
  LLVMInitializeLoongArchTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeLoongArchTarget');
  LLVMInitializeLoongArchTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeLoongArchTargetInfo');
  LLVMInitializeLoongArchTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeLoongArchTargetMC');
  LLVMInitializeMCJITCompilerOptions := GetProcAddress(aDLLHandle, 'LLVMInitializeMCJITCompilerOptions');
  LLVMInitializeMipsAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeMipsAsmParser');
  LLVMInitializeMipsAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeMipsAsmPrinter');
  LLVMInitializeMipsDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeMipsDisassembler');
  LLVMInitializeMipsTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeMipsTarget');
  LLVMInitializeMipsTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeMipsTargetInfo');
  LLVMInitializeMipsTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeMipsTargetMC');
  LLVMInitializeMSP430AsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeMSP430AsmParser');
  LLVMInitializeMSP430AsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeMSP430AsmPrinter');
  LLVMInitializeMSP430Disassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeMSP430Disassembler');
  LLVMInitializeMSP430Target := GetProcAddress(aDLLHandle, 'LLVMInitializeMSP430Target');
  LLVMInitializeMSP430TargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeMSP430TargetInfo');
  LLVMInitializeMSP430TargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeMSP430TargetMC');
  LLVMInitializeNVPTXAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeNVPTXAsmPrinter');
  LLVMInitializeNVPTXTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeNVPTXTarget');
  LLVMInitializeNVPTXTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeNVPTXTargetInfo');
  LLVMInitializeNVPTXTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeNVPTXTargetMC');
  LLVMInitializePowerPCAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializePowerPCAsmParser');
  LLVMInitializePowerPCAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializePowerPCAsmPrinter');
  LLVMInitializePowerPCDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializePowerPCDisassembler');
  LLVMInitializePowerPCTarget := GetProcAddress(aDLLHandle, 'LLVMInitializePowerPCTarget');
  LLVMInitializePowerPCTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializePowerPCTargetInfo');
  LLVMInitializePowerPCTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializePowerPCTargetMC');
  LLVMInitializeRISCVAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeRISCVAsmParser');
  LLVMInitializeRISCVAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeRISCVAsmPrinter');
  LLVMInitializeRISCVDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeRISCVDisassembler');
  LLVMInitializeRISCVTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeRISCVTarget');
  LLVMInitializeRISCVTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeRISCVTargetInfo');
  LLVMInitializeRISCVTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeRISCVTargetMC');
  LLVMInitializeSparcAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeSparcAsmParser');
  LLVMInitializeSparcAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeSparcAsmPrinter');
  LLVMInitializeSparcDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeSparcDisassembler');
  LLVMInitializeSparcTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeSparcTarget');
  LLVMInitializeSparcTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeSparcTargetInfo');
  LLVMInitializeSparcTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeSparcTargetMC');
  LLVMInitializeSPIRVAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeSPIRVAsmPrinter');
  LLVMInitializeSPIRVTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeSPIRVTarget');
  LLVMInitializeSPIRVTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeSPIRVTargetInfo');
  LLVMInitializeSPIRVTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeSPIRVTargetMC');
  LLVMInitializeSystemZAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeSystemZAsmParser');
  LLVMInitializeSystemZAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeSystemZAsmPrinter');
  LLVMInitializeSystemZDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeSystemZDisassembler');
  LLVMInitializeSystemZTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeSystemZTarget');
  LLVMInitializeSystemZTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeSystemZTargetInfo');
  LLVMInitializeSystemZTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeSystemZTargetMC');
  LLVMInitializeVEAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeVEAsmParser');
  LLVMInitializeVEAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeVEAsmPrinter');
  LLVMInitializeVEDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeVEDisassembler');
  LLVMInitializeVETarget := GetProcAddress(aDLLHandle, 'LLVMInitializeVETarget');
  LLVMInitializeVETargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeVETargetInfo');
  LLVMInitializeVETargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeVETargetMC');
  LLVMInitializeWebAssemblyAsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeWebAssemblyAsmParser');
  LLVMInitializeWebAssemblyAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeWebAssemblyAsmPrinter');
  LLVMInitializeWebAssemblyDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeWebAssemblyDisassembler');
  LLVMInitializeWebAssemblyTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeWebAssemblyTarget');
  LLVMInitializeWebAssemblyTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeWebAssemblyTargetInfo');
  LLVMInitializeWebAssemblyTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeWebAssemblyTargetMC');
  LLVMInitializeX86AsmParser := GetProcAddress(aDLLHandle, 'LLVMInitializeX86AsmParser');
  LLVMInitializeX86AsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeX86AsmPrinter');
  LLVMInitializeX86Disassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeX86Disassembler');
  LLVMInitializeX86Target := GetProcAddress(aDLLHandle, 'LLVMInitializeX86Target');
  LLVMInitializeX86TargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeX86TargetInfo');
  LLVMInitializeX86TargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeX86TargetMC');
  LLVMInitializeXCoreAsmPrinter := GetProcAddress(aDLLHandle, 'LLVMInitializeXCoreAsmPrinter');
  LLVMInitializeXCoreDisassembler := GetProcAddress(aDLLHandle, 'LLVMInitializeXCoreDisassembler');
  LLVMInitializeXCoreTarget := GetProcAddress(aDLLHandle, 'LLVMInitializeXCoreTarget');
  LLVMInitializeXCoreTargetInfo := GetProcAddress(aDLLHandle, 'LLVMInitializeXCoreTargetInfo');
  LLVMInitializeXCoreTargetMC := GetProcAddress(aDLLHandle, 'LLVMInitializeXCoreTargetMC');
  LLVMInsertBasicBlock := GetProcAddress(aDLLHandle, 'LLVMInsertBasicBlock');
  LLVMInsertBasicBlockInContext := GetProcAddress(aDLLHandle, 'LLVMInsertBasicBlockInContext');
  LLVMInsertExistingBasicBlockAfterInsertBlock := GetProcAddress(aDLLHandle, 'LLVMInsertExistingBasicBlockAfterInsertBlock');
  LLVMInsertIntoBuilder := GetProcAddress(aDLLHandle, 'LLVMInsertIntoBuilder');
  LLVMInsertIntoBuilderWithName := GetProcAddress(aDLLHandle, 'LLVMInsertIntoBuilderWithName');
  LLVMInstallFatalErrorHandler := GetProcAddress(aDLLHandle, 'LLVMInstallFatalErrorHandler');
  LLVMInstructionClone := GetProcAddress(aDLLHandle, 'LLVMInstructionClone');
  LLVMInstructionEraseFromParent := GetProcAddress(aDLLHandle, 'LLVMInstructionEraseFromParent');
  LLVMInstructionGetAllMetadataOtherThanDebugLoc := GetProcAddress(aDLLHandle, 'LLVMInstructionGetAllMetadataOtherThanDebugLoc');
  LLVMInstructionGetDebugLoc := GetProcAddress(aDLLHandle, 'LLVMInstructionGetDebugLoc');
  LLVMInstructionRemoveFromParent := GetProcAddress(aDLLHandle, 'LLVMInstructionRemoveFromParent');
  LLVMInstructionSetDebugLoc := GetProcAddress(aDLLHandle, 'LLVMInstructionSetDebugLoc');
  LLVMInt128Type := GetProcAddress(aDLLHandle, 'LLVMInt128Type');
  LLVMInt128TypeInContext := GetProcAddress(aDLLHandle, 'LLVMInt128TypeInContext');
  LLVMInt16Type := GetProcAddress(aDLLHandle, 'LLVMInt16Type');
  LLVMInt16TypeInContext := GetProcAddress(aDLLHandle, 'LLVMInt16TypeInContext');
  LLVMInt1Type := GetProcAddress(aDLLHandle, 'LLVMInt1Type');
  LLVMInt1TypeInContext := GetProcAddress(aDLLHandle, 'LLVMInt1TypeInContext');
  LLVMInt32Type := GetProcAddress(aDLLHandle, 'LLVMInt32Type');
  LLVMInt32TypeInContext := GetProcAddress(aDLLHandle, 'LLVMInt32TypeInContext');
  LLVMInt64Type := GetProcAddress(aDLLHandle, 'LLVMInt64Type');
  LLVMInt64TypeInContext := GetProcAddress(aDLLHandle, 'LLVMInt64TypeInContext');
  LLVMInt8Type := GetProcAddress(aDLLHandle, 'LLVMInt8Type');
  LLVMInt8TypeInContext := GetProcAddress(aDLLHandle, 'LLVMInt8TypeInContext');
  LLVMIntPtrType := GetProcAddress(aDLLHandle, 'LLVMIntPtrType');
  LLVMIntPtrTypeForAS := GetProcAddress(aDLLHandle, 'LLVMIntPtrTypeForAS');
  LLVMIntPtrTypeForASInContext := GetProcAddress(aDLLHandle, 'LLVMIntPtrTypeForASInContext');
  LLVMIntPtrTypeInContext := GetProcAddress(aDLLHandle, 'LLVMIntPtrTypeInContext');
  LLVMIntrinsicCopyOverloadedName := GetProcAddress(aDLLHandle, 'LLVMIntrinsicCopyOverloadedName');
  LLVMIntrinsicCopyOverloadedName2 := GetProcAddress(aDLLHandle, 'LLVMIntrinsicCopyOverloadedName2');
  LLVMIntrinsicGetName := GetProcAddress(aDLLHandle, 'LLVMIntrinsicGetName');
  LLVMIntrinsicGetType := GetProcAddress(aDLLHandle, 'LLVMIntrinsicGetType');
  LLVMIntrinsicIsOverloaded := GetProcAddress(aDLLHandle, 'LLVMIntrinsicIsOverloaded');
  LLVMIntType := GetProcAddress(aDLLHandle, 'LLVMIntType');
  LLVMIntTypeInContext := GetProcAddress(aDLLHandle, 'LLVMIntTypeInContext');
  LLVMIsAAddrSpaceCastInst := GetProcAddress(aDLLHandle, 'LLVMIsAAddrSpaceCastInst');
  LLVMIsAAllocaInst := GetProcAddress(aDLLHandle, 'LLVMIsAAllocaInst');
  LLVMIsAArgument := GetProcAddress(aDLLHandle, 'LLVMIsAArgument');
  LLVMIsAAtomicCmpXchgInst := GetProcAddress(aDLLHandle, 'LLVMIsAAtomicCmpXchgInst');
  LLVMIsAAtomicRMWInst := GetProcAddress(aDLLHandle, 'LLVMIsAAtomicRMWInst');
  LLVMIsABasicBlock := GetProcAddress(aDLLHandle, 'LLVMIsABasicBlock');
  LLVMIsABinaryOperator := GetProcAddress(aDLLHandle, 'LLVMIsABinaryOperator');
  LLVMIsABitCastInst := GetProcAddress(aDLLHandle, 'LLVMIsABitCastInst');
  LLVMIsABlockAddress := GetProcAddress(aDLLHandle, 'LLVMIsABlockAddress');
  LLVMIsABranchInst := GetProcAddress(aDLLHandle, 'LLVMIsABranchInst');
  LLVMIsACallBrInst := GetProcAddress(aDLLHandle, 'LLVMIsACallBrInst');
  LLVMIsACallInst := GetProcAddress(aDLLHandle, 'LLVMIsACallInst');
  LLVMIsACastInst := GetProcAddress(aDLLHandle, 'LLVMIsACastInst');
  LLVMIsACatchPadInst := GetProcAddress(aDLLHandle, 'LLVMIsACatchPadInst');
  LLVMIsACatchReturnInst := GetProcAddress(aDLLHandle, 'LLVMIsACatchReturnInst');
  LLVMIsACatchSwitchInst := GetProcAddress(aDLLHandle, 'LLVMIsACatchSwitchInst');
  LLVMIsACleanupPadInst := GetProcAddress(aDLLHandle, 'LLVMIsACleanupPadInst');
  LLVMIsACleanupReturnInst := GetProcAddress(aDLLHandle, 'LLVMIsACleanupReturnInst');
  LLVMIsACmpInst := GetProcAddress(aDLLHandle, 'LLVMIsACmpInst');
  LLVMIsAConstant := GetProcAddress(aDLLHandle, 'LLVMIsAConstant');
  LLVMIsAConstantAggregateZero := GetProcAddress(aDLLHandle, 'LLVMIsAConstantAggregateZero');
  LLVMIsAConstantArray := GetProcAddress(aDLLHandle, 'LLVMIsAConstantArray');
  LLVMIsAConstantDataArray := GetProcAddress(aDLLHandle, 'LLVMIsAConstantDataArray');
  LLVMIsAConstantDataSequential := GetProcAddress(aDLLHandle, 'LLVMIsAConstantDataSequential');
  LLVMIsAConstantDataVector := GetProcAddress(aDLLHandle, 'LLVMIsAConstantDataVector');
  LLVMIsAConstantExpr := GetProcAddress(aDLLHandle, 'LLVMIsAConstantExpr');
  LLVMIsAConstantFP := GetProcAddress(aDLLHandle, 'LLVMIsAConstantFP');
  LLVMIsAConstantInt := GetProcAddress(aDLLHandle, 'LLVMIsAConstantInt');
  LLVMIsAConstantPointerNull := GetProcAddress(aDLLHandle, 'LLVMIsAConstantPointerNull');
  LLVMIsAConstantPtrAuth := GetProcAddress(aDLLHandle, 'LLVMIsAConstantPtrAuth');
  LLVMIsAConstantStruct := GetProcAddress(aDLLHandle, 'LLVMIsAConstantStruct');
  LLVMIsAConstantTokenNone := GetProcAddress(aDLLHandle, 'LLVMIsAConstantTokenNone');
  LLVMIsAConstantVector := GetProcAddress(aDLLHandle, 'LLVMIsAConstantVector');
  LLVMIsADbgDeclareInst := GetProcAddress(aDLLHandle, 'LLVMIsADbgDeclareInst');
  LLVMIsADbgInfoIntrinsic := GetProcAddress(aDLLHandle, 'LLVMIsADbgInfoIntrinsic');
  LLVMIsADbgLabelInst := GetProcAddress(aDLLHandle, 'LLVMIsADbgLabelInst');
  LLVMIsADbgVariableIntrinsic := GetProcAddress(aDLLHandle, 'LLVMIsADbgVariableIntrinsic');
  LLVMIsAExtractElementInst := GetProcAddress(aDLLHandle, 'LLVMIsAExtractElementInst');
  LLVMIsAExtractValueInst := GetProcAddress(aDLLHandle, 'LLVMIsAExtractValueInst');
  LLVMIsAFCmpInst := GetProcAddress(aDLLHandle, 'LLVMIsAFCmpInst');
  LLVMIsAFenceInst := GetProcAddress(aDLLHandle, 'LLVMIsAFenceInst');
  LLVMIsAFPExtInst := GetProcAddress(aDLLHandle, 'LLVMIsAFPExtInst');
  LLVMIsAFPToSIInst := GetProcAddress(aDLLHandle, 'LLVMIsAFPToSIInst');
  LLVMIsAFPToUIInst := GetProcAddress(aDLLHandle, 'LLVMIsAFPToUIInst');
  LLVMIsAFPTruncInst := GetProcAddress(aDLLHandle, 'LLVMIsAFPTruncInst');
  LLVMIsAFreezeInst := GetProcAddress(aDLLHandle, 'LLVMIsAFreezeInst');
  LLVMIsAFuncletPadInst := GetProcAddress(aDLLHandle, 'LLVMIsAFuncletPadInst');
  LLVMIsAFunction := GetProcAddress(aDLLHandle, 'LLVMIsAFunction');
  LLVMIsAGetElementPtrInst := GetProcAddress(aDLLHandle, 'LLVMIsAGetElementPtrInst');
  LLVMIsAGlobalAlias := GetProcAddress(aDLLHandle, 'LLVMIsAGlobalAlias');
  LLVMIsAGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMIsAGlobalIFunc');
  LLVMIsAGlobalObject := GetProcAddress(aDLLHandle, 'LLVMIsAGlobalObject');
  LLVMIsAGlobalValue := GetProcAddress(aDLLHandle, 'LLVMIsAGlobalValue');
  LLVMIsAGlobalVariable := GetProcAddress(aDLLHandle, 'LLVMIsAGlobalVariable');
  LLVMIsAICmpInst := GetProcAddress(aDLLHandle, 'LLVMIsAICmpInst');
  LLVMIsAIndirectBrInst := GetProcAddress(aDLLHandle, 'LLVMIsAIndirectBrInst');
  LLVMIsAInlineAsm := GetProcAddress(aDLLHandle, 'LLVMIsAInlineAsm');
  LLVMIsAInsertElementInst := GetProcAddress(aDLLHandle, 'LLVMIsAInsertElementInst');
  LLVMIsAInsertValueInst := GetProcAddress(aDLLHandle, 'LLVMIsAInsertValueInst');
  LLVMIsAInstruction := GetProcAddress(aDLLHandle, 'LLVMIsAInstruction');
  LLVMIsAIntrinsicInst := GetProcAddress(aDLLHandle, 'LLVMIsAIntrinsicInst');
  LLVMIsAIntToPtrInst := GetProcAddress(aDLLHandle, 'LLVMIsAIntToPtrInst');
  LLVMIsAInvokeInst := GetProcAddress(aDLLHandle, 'LLVMIsAInvokeInst');
  LLVMIsALandingPadInst := GetProcAddress(aDLLHandle, 'LLVMIsALandingPadInst');
  LLVMIsALoadInst := GetProcAddress(aDLLHandle, 'LLVMIsALoadInst');
  LLVMIsAMDNode := GetProcAddress(aDLLHandle, 'LLVMIsAMDNode');
  LLVMIsAMDString := GetProcAddress(aDLLHandle, 'LLVMIsAMDString');
  LLVMIsAMemCpyInst := GetProcAddress(aDLLHandle, 'LLVMIsAMemCpyInst');
  LLVMIsAMemIntrinsic := GetProcAddress(aDLLHandle, 'LLVMIsAMemIntrinsic');
  LLVMIsAMemMoveInst := GetProcAddress(aDLLHandle, 'LLVMIsAMemMoveInst');
  LLVMIsAMemSetInst := GetProcAddress(aDLLHandle, 'LLVMIsAMemSetInst');
  LLVMIsAPHINode := GetProcAddress(aDLLHandle, 'LLVMIsAPHINode');
  LLVMIsAPoisonValue := GetProcAddress(aDLLHandle, 'LLVMIsAPoisonValue');
  LLVMIsAPtrToIntInst := GetProcAddress(aDLLHandle, 'LLVMIsAPtrToIntInst');
  LLVMIsAResumeInst := GetProcAddress(aDLLHandle, 'LLVMIsAResumeInst');
  LLVMIsAReturnInst := GetProcAddress(aDLLHandle, 'LLVMIsAReturnInst');
  LLVMIsASelectInst := GetProcAddress(aDLLHandle, 'LLVMIsASelectInst');
  LLVMIsASExtInst := GetProcAddress(aDLLHandle, 'LLVMIsASExtInst');
  LLVMIsAShuffleVectorInst := GetProcAddress(aDLLHandle, 'LLVMIsAShuffleVectorInst');
  LLVMIsASIToFPInst := GetProcAddress(aDLLHandle, 'LLVMIsASIToFPInst');
  LLVMIsAStoreInst := GetProcAddress(aDLLHandle, 'LLVMIsAStoreInst');
  LLVMIsASwitchInst := GetProcAddress(aDLLHandle, 'LLVMIsASwitchInst');
  LLVMIsATerminatorInst := GetProcAddress(aDLLHandle, 'LLVMIsATerminatorInst');
  LLVMIsAtomic := GetProcAddress(aDLLHandle, 'LLVMIsAtomic');
  LLVMIsAtomicSingleThread := GetProcAddress(aDLLHandle, 'LLVMIsAtomicSingleThread');
  LLVMIsATruncInst := GetProcAddress(aDLLHandle, 'LLVMIsATruncInst');
  LLVMIsAUIToFPInst := GetProcAddress(aDLLHandle, 'LLVMIsAUIToFPInst');
  LLVMIsAUnaryInstruction := GetProcAddress(aDLLHandle, 'LLVMIsAUnaryInstruction');
  LLVMIsAUnaryOperator := GetProcAddress(aDLLHandle, 'LLVMIsAUnaryOperator');
  LLVMIsAUndefValue := GetProcAddress(aDLLHandle, 'LLVMIsAUndefValue');
  LLVMIsAUnreachableInst := GetProcAddress(aDLLHandle, 'LLVMIsAUnreachableInst');
  LLVMIsAUser := GetProcAddress(aDLLHandle, 'LLVMIsAUser');
  LLVMIsAVAArgInst := GetProcAddress(aDLLHandle, 'LLVMIsAVAArgInst');
  LLVMIsAValueAsMetadata := GetProcAddress(aDLLHandle, 'LLVMIsAValueAsMetadata');
  LLVMIsAZExtInst := GetProcAddress(aDLLHandle, 'LLVMIsAZExtInst');
  LLVMIsCleanup := GetProcAddress(aDLLHandle, 'LLVMIsCleanup');
  LLVMIsConditional := GetProcAddress(aDLLHandle, 'LLVMIsConditional');
  LLVMIsConstant := GetProcAddress(aDLLHandle, 'LLVMIsConstant');
  LLVMIsConstantString := GetProcAddress(aDLLHandle, 'LLVMIsConstantString');
  LLVMIsDeclaration := GetProcAddress(aDLLHandle, 'LLVMIsDeclaration');
  LLVMIsEnumAttribute := GetProcAddress(aDLLHandle, 'LLVMIsEnumAttribute');
  LLVMIsExternallyInitialized := GetProcAddress(aDLLHandle, 'LLVMIsExternallyInitialized');
  LLVMIsFunctionVarArg := GetProcAddress(aDLLHandle, 'LLVMIsFunctionVarArg');
  LLVMIsGlobalConstant := GetProcAddress(aDLLHandle, 'LLVMIsGlobalConstant');
  LLVMIsInBounds := GetProcAddress(aDLLHandle, 'LLVMIsInBounds');
  LLVMIsLiteralStruct := GetProcAddress(aDLLHandle, 'LLVMIsLiteralStruct');
  LLVMIsMultithreaded := GetProcAddress(aDLLHandle, 'LLVMIsMultithreaded');
  LLVMIsNewDbgInfoFormat := GetProcAddress(aDLLHandle, 'LLVMIsNewDbgInfoFormat');
  LLVMIsNull := GetProcAddress(aDLLHandle, 'LLVMIsNull');
  LLVMIsOpaqueStruct := GetProcAddress(aDLLHandle, 'LLVMIsOpaqueStruct');
  LLVMIsPackedStruct := GetProcAddress(aDLLHandle, 'LLVMIsPackedStruct');
  LLVMIsPoison := GetProcAddress(aDLLHandle, 'LLVMIsPoison');
  LLVMIsRelocationIteratorAtEnd := GetProcAddress(aDLLHandle, 'LLVMIsRelocationIteratorAtEnd');
  LLVMIsSectionIteratorAtEnd := GetProcAddress(aDLLHandle, 'LLVMIsSectionIteratorAtEnd');
  LLVMIsStringAttribute := GetProcAddress(aDLLHandle, 'LLVMIsStringAttribute');
  LLVMIsSymbolIteratorAtEnd := GetProcAddress(aDLLHandle, 'LLVMIsSymbolIteratorAtEnd');
  LLVMIsTailCall := GetProcAddress(aDLLHandle, 'LLVMIsTailCall');
  LLVMIsThreadLocal := GetProcAddress(aDLLHandle, 'LLVMIsThreadLocal');
  LLVMIsTypeAttribute := GetProcAddress(aDLLHandle, 'LLVMIsTypeAttribute');
  LLVMIsUndef := GetProcAddress(aDLLHandle, 'LLVMIsUndef');
  LLVMLabelType := GetProcAddress(aDLLHandle, 'LLVMLabelType');
  LLVMLabelTypeInContext := GetProcAddress(aDLLHandle, 'LLVMLabelTypeInContext');
  LLVMLinkInInterpreter := GetProcAddress(aDLLHandle, 'LLVMLinkInInterpreter');
  LLVMLinkInMCJIT := GetProcAddress(aDLLHandle, 'LLVMLinkInMCJIT');
  LLVMLinkModules2 := GetProcAddress(aDLLHandle, 'LLVMLinkModules2');
  LLVMLoadLibraryPermanently := GetProcAddress(aDLLHandle, 'LLVMLoadLibraryPermanently');
  LLVMLookupIntrinsicID := GetProcAddress(aDLLHandle, 'LLVMLookupIntrinsicID');
  LLVMMachOUniversalBinaryCopyObjectForArch := GetProcAddress(aDLLHandle, 'LLVMMachOUniversalBinaryCopyObjectForArch');
  LLVMMDNode := GetProcAddress(aDLLHandle, 'LLVMMDNode');
  LLVMMDNodeInContext := GetProcAddress(aDLLHandle, 'LLVMMDNodeInContext');
  LLVMMDNodeInContext2 := GetProcAddress(aDLLHandle, 'LLVMMDNodeInContext2');
  LLVMMDString := GetProcAddress(aDLLHandle, 'LLVMMDString');
  LLVMMDStringInContext := GetProcAddress(aDLLHandle, 'LLVMMDStringInContext');
  LLVMMDStringInContext2 := GetProcAddress(aDLLHandle, 'LLVMMDStringInContext2');
  LLVMMetadataAsValue := GetProcAddress(aDLLHandle, 'LLVMMetadataAsValue');
  LLVMMetadataReplaceAllUsesWith := GetProcAddress(aDLLHandle, 'LLVMMetadataReplaceAllUsesWith');
  LLVMMetadataTypeInContext := GetProcAddress(aDLLHandle, 'LLVMMetadataTypeInContext');
  LLVMModuleCreateWithName := GetProcAddress(aDLLHandle, 'LLVMModuleCreateWithName');
  LLVMModuleCreateWithNameInContext := GetProcAddress(aDLLHandle, 'LLVMModuleCreateWithNameInContext');
  LLVMModuleFlagEntriesGetFlagBehavior := GetProcAddress(aDLLHandle, 'LLVMModuleFlagEntriesGetFlagBehavior');
  LLVMModuleFlagEntriesGetKey := GetProcAddress(aDLLHandle, 'LLVMModuleFlagEntriesGetKey');
  LLVMModuleFlagEntriesGetMetadata := GetProcAddress(aDLLHandle, 'LLVMModuleFlagEntriesGetMetadata');
  LLVMMoveBasicBlockAfter := GetProcAddress(aDLLHandle, 'LLVMMoveBasicBlockAfter');
  LLVMMoveBasicBlockBefore := GetProcAddress(aDLLHandle, 'LLVMMoveBasicBlockBefore');
  LLVMMoveToContainingSection := GetProcAddress(aDLLHandle, 'LLVMMoveToContainingSection');
  LLVMMoveToNextRelocation := GetProcAddress(aDLLHandle, 'LLVMMoveToNextRelocation');
  LLVMMoveToNextSection := GetProcAddress(aDLLHandle, 'LLVMMoveToNextSection');
  LLVMMoveToNextSymbol := GetProcAddress(aDLLHandle, 'LLVMMoveToNextSymbol');
  LLVMNormalizeTargetTriple := GetProcAddress(aDLLHandle, 'LLVMNormalizeTargetTriple');
  LLVMObjectFileCopySectionIterator := GetProcAddress(aDLLHandle, 'LLVMObjectFileCopySectionIterator');
  LLVMObjectFileCopySymbolIterator := GetProcAddress(aDLLHandle, 'LLVMObjectFileCopySymbolIterator');
  LLVMObjectFileIsSectionIteratorAtEnd := GetProcAddress(aDLLHandle, 'LLVMObjectFileIsSectionIteratorAtEnd');
  LLVMObjectFileIsSymbolIteratorAtEnd := GetProcAddress(aDLLHandle, 'LLVMObjectFileIsSymbolIteratorAtEnd');
  LLVMOffsetOfElement := GetProcAddress(aDLLHandle, 'LLVMOffsetOfElement');
  LLVMOrcAbsoluteSymbols := GetProcAddress(aDLLHandle, 'LLVMOrcAbsoluteSymbols');
  LLVMOrcCreateCustomCAPIDefinitionGenerator := GetProcAddress(aDLLHandle, 'LLVMOrcCreateCustomCAPIDefinitionGenerator');
  LLVMOrcCreateCustomMaterializationUnit := GetProcAddress(aDLLHandle, 'LLVMOrcCreateCustomMaterializationUnit');
  LLVMOrcCreateDumpObjects := GetProcAddress(aDLLHandle, 'LLVMOrcCreateDumpObjects');
  LLVMOrcCreateDynamicLibrarySearchGeneratorForPath := GetProcAddress(aDLLHandle, 'LLVMOrcCreateDynamicLibrarySearchGeneratorForPath');
  LLVMOrcCreateDynamicLibrarySearchGeneratorForProcess := GetProcAddress(aDLLHandle, 'LLVMOrcCreateDynamicLibrarySearchGeneratorForProcess');
  LLVMOrcCreateLLJIT := GetProcAddress(aDLLHandle, 'LLVMOrcCreateLLJIT');
  LLVMOrcCreateLLJITBuilder := GetProcAddress(aDLLHandle, 'LLVMOrcCreateLLJITBuilder');
  LLVMOrcCreateLocalIndirectStubsManager := GetProcAddress(aDLLHandle, 'LLVMOrcCreateLocalIndirectStubsManager');
  LLVMOrcCreateLocalLazyCallThroughManager := GetProcAddress(aDLLHandle, 'LLVMOrcCreateLocalLazyCallThroughManager');
  LLVMOrcCreateNewThreadSafeContext := GetProcAddress(aDLLHandle, 'LLVMOrcCreateNewThreadSafeContext');
  LLVMOrcCreateNewThreadSafeContextFromLLVMContext := GetProcAddress(aDLLHandle, 'LLVMOrcCreateNewThreadSafeContextFromLLVMContext');
  LLVMOrcCreateNewThreadSafeModule := GetProcAddress(aDLLHandle, 'LLVMOrcCreateNewThreadSafeModule');
  LLVMOrcCreateRTDyldObjectLinkingLayerWithMCJITMemoryManagerLikeCallbacks := GetProcAddress(aDLLHandle, 'LLVMOrcCreateRTDyldObjectLinkingLayerWithMCJITMemoryManagerLikeCallbacks');
  LLVMOrcCreateRTDyldObjectLinkingLayerWithSectionMemoryManager := GetProcAddress(aDLLHandle, 'LLVMOrcCreateRTDyldObjectLinkingLayerWithSectionMemoryManager');
  LLVMOrcCreateStaticLibrarySearchGeneratorForPath := GetProcAddress(aDLLHandle, 'LLVMOrcCreateStaticLibrarySearchGeneratorForPath');
  LLVMOrcDisposeCSymbolFlagsMap := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeCSymbolFlagsMap');
  LLVMOrcDisposeDefinitionGenerator := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeDefinitionGenerator');
  LLVMOrcDisposeDumpObjects := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeDumpObjects');
  LLVMOrcDisposeIndirectStubsManager := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeIndirectStubsManager');
  LLVMOrcDisposeJITTargetMachineBuilder := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeJITTargetMachineBuilder');
  LLVMOrcDisposeLazyCallThroughManager := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeLazyCallThroughManager');
  LLVMOrcDisposeLLJIT := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeLLJIT');
  LLVMOrcDisposeLLJITBuilder := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeLLJITBuilder');
  LLVMOrcDisposeMaterializationResponsibility := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeMaterializationResponsibility');
  LLVMOrcDisposeMaterializationUnit := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeMaterializationUnit');
  LLVMOrcDisposeObjectLayer := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeObjectLayer');
  LLVMOrcDisposeSymbols := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeSymbols');
  LLVMOrcDisposeThreadSafeContext := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeThreadSafeContext');
  LLVMOrcDisposeThreadSafeModule := GetProcAddress(aDLLHandle, 'LLVMOrcDisposeThreadSafeModule');
  LLVMOrcDumpObjects_CallOperator := GetProcAddress(aDLLHandle, 'LLVMOrcDumpObjects_CallOperator');
  LLVMOrcExecutionSessionCreateBareJITDylib := GetProcAddress(aDLLHandle, 'LLVMOrcExecutionSessionCreateBareJITDylib');
  LLVMOrcExecutionSessionCreateJITDylib := GetProcAddress(aDLLHandle, 'LLVMOrcExecutionSessionCreateJITDylib');
  LLVMOrcExecutionSessionGetJITDylibByName := GetProcAddress(aDLLHandle, 'LLVMOrcExecutionSessionGetJITDylibByName');
  LLVMOrcExecutionSessionGetSymbolStringPool := GetProcAddress(aDLLHandle, 'LLVMOrcExecutionSessionGetSymbolStringPool');
  LLVMOrcExecutionSessionIntern := GetProcAddress(aDLLHandle, 'LLVMOrcExecutionSessionIntern');
  LLVMOrcExecutionSessionLookup := GetProcAddress(aDLLHandle, 'LLVMOrcExecutionSessionLookup');
  LLVMOrcExecutionSessionSetErrorReporter := GetProcAddress(aDLLHandle, 'LLVMOrcExecutionSessionSetErrorReporter');
  LLVMOrcIRTransformLayerEmit := GetProcAddress(aDLLHandle, 'LLVMOrcIRTransformLayerEmit');
  LLVMOrcIRTransformLayerSetTransform := GetProcAddress(aDLLHandle, 'LLVMOrcIRTransformLayerSetTransform');
  LLVMOrcJITDylibAddGenerator := GetProcAddress(aDLLHandle, 'LLVMOrcJITDylibAddGenerator');
  LLVMOrcJITDylibClear := GetProcAddress(aDLLHandle, 'LLVMOrcJITDylibClear');
  LLVMOrcJITDylibCreateResourceTracker := GetProcAddress(aDLLHandle, 'LLVMOrcJITDylibCreateResourceTracker');
  LLVMOrcJITDylibDefine := GetProcAddress(aDLLHandle, 'LLVMOrcJITDylibDefine');
  LLVMOrcJITDylibGetDefaultResourceTracker := GetProcAddress(aDLLHandle, 'LLVMOrcJITDylibGetDefaultResourceTracker');
  LLVMOrcJITTargetMachineBuilderCreateFromTargetMachine := GetProcAddress(aDLLHandle, 'LLVMOrcJITTargetMachineBuilderCreateFromTargetMachine');
  LLVMOrcJITTargetMachineBuilderDetectHost := GetProcAddress(aDLLHandle, 'LLVMOrcJITTargetMachineBuilderDetectHost');
  LLVMOrcJITTargetMachineBuilderGetTargetTriple := GetProcAddress(aDLLHandle, 'LLVMOrcJITTargetMachineBuilderGetTargetTriple');
  LLVMOrcJITTargetMachineBuilderSetTargetTriple := GetProcAddress(aDLLHandle, 'LLVMOrcJITTargetMachineBuilderSetTargetTriple');
  LLVMOrcLazyReexports := GetProcAddress(aDLLHandle, 'LLVMOrcLazyReexports');
  LLVMOrcLLJITAddLLVMIRModule := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITAddLLVMIRModule');
  LLVMOrcLLJITAddLLVMIRModuleWithRT := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITAddLLVMIRModuleWithRT');
  LLVMOrcLLJITAddObjectFile := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITAddObjectFile');
  LLVMOrcLLJITAddObjectFileWithRT := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITAddObjectFileWithRT');
  LLVMOrcLLJITBuilderSetJITTargetMachineBuilder := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITBuilderSetJITTargetMachineBuilder');
  LLVMOrcLLJITBuilderSetObjectLinkingLayerCreator := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITBuilderSetObjectLinkingLayerCreator');
  LLVMOrcLLJITEnableDebugSupport := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITEnableDebugSupport');
  LLVMOrcLLJITGetDataLayoutStr := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITGetDataLayoutStr');
  LLVMOrcLLJITGetExecutionSession := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITGetExecutionSession');
  LLVMOrcLLJITGetGlobalPrefix := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITGetGlobalPrefix');
  LLVMOrcLLJITGetIRTransformLayer := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITGetIRTransformLayer');
  LLVMOrcLLJITGetMainJITDylib := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITGetMainJITDylib');
  LLVMOrcLLJITGetObjLinkingLayer := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITGetObjLinkingLayer');
  LLVMOrcLLJITGetObjTransformLayer := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITGetObjTransformLayer');
  LLVMOrcLLJITGetTripleString := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITGetTripleString');
  LLVMOrcLLJITLookup := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITLookup');
  LLVMOrcLLJITMangleAndIntern := GetProcAddress(aDLLHandle, 'LLVMOrcLLJITMangleAndIntern');
  LLVMOrcLookupStateContinueLookup := GetProcAddress(aDLLHandle, 'LLVMOrcLookupStateContinueLookup');
  LLVMOrcMaterializationResponsibilityDefineMaterializing := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityDefineMaterializing');
  LLVMOrcMaterializationResponsibilityDelegate := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityDelegate');
  LLVMOrcMaterializationResponsibilityFailMaterialization := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityFailMaterialization');
  LLVMOrcMaterializationResponsibilityGetExecutionSession := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityGetExecutionSession');
  LLVMOrcMaterializationResponsibilityGetInitializerSymbol := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityGetInitializerSymbol');
  LLVMOrcMaterializationResponsibilityGetRequestedSymbols := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityGetRequestedSymbols');
  LLVMOrcMaterializationResponsibilityGetSymbols := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityGetSymbols');
  LLVMOrcMaterializationResponsibilityGetTargetDylib := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityGetTargetDylib');
  LLVMOrcMaterializationResponsibilityNotifyEmitted := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityNotifyEmitted');
  LLVMOrcMaterializationResponsibilityNotifyResolved := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityNotifyResolved');
  LLVMOrcMaterializationResponsibilityReplace := GetProcAddress(aDLLHandle, 'LLVMOrcMaterializationResponsibilityReplace');
  LLVMOrcObjectLayerAddObjectFile := GetProcAddress(aDLLHandle, 'LLVMOrcObjectLayerAddObjectFile');
  LLVMOrcObjectLayerAddObjectFileWithRT := GetProcAddress(aDLLHandle, 'LLVMOrcObjectLayerAddObjectFileWithRT');
  LLVMOrcObjectLayerEmit := GetProcAddress(aDLLHandle, 'LLVMOrcObjectLayerEmit');
  LLVMOrcObjectTransformLayerSetTransform := GetProcAddress(aDLLHandle, 'LLVMOrcObjectTransformLayerSetTransform');
  LLVMOrcReleaseResourceTracker := GetProcAddress(aDLLHandle, 'LLVMOrcReleaseResourceTracker');
  LLVMOrcReleaseSymbolStringPoolEntry := GetProcAddress(aDLLHandle, 'LLVMOrcReleaseSymbolStringPoolEntry');
  LLVMOrcResourceTrackerRemove := GetProcAddress(aDLLHandle, 'LLVMOrcResourceTrackerRemove');
  LLVMOrcResourceTrackerTransferTo := GetProcAddress(aDLLHandle, 'LLVMOrcResourceTrackerTransferTo');
  LLVMOrcRetainSymbolStringPoolEntry := GetProcAddress(aDLLHandle, 'LLVMOrcRetainSymbolStringPoolEntry');
  LLVMOrcRTDyldObjectLinkingLayerRegisterJITEventListener := GetProcAddress(aDLLHandle, 'LLVMOrcRTDyldObjectLinkingLayerRegisterJITEventListener');
  LLVMOrcSymbolStringPoolClearDeadEntries := GetProcAddress(aDLLHandle, 'LLVMOrcSymbolStringPoolClearDeadEntries');
  LLVMOrcSymbolStringPoolEntryStr := GetProcAddress(aDLLHandle, 'LLVMOrcSymbolStringPoolEntryStr');
  LLVMOrcThreadSafeModuleWithModuleDo := GetProcAddress(aDLLHandle, 'LLVMOrcThreadSafeModuleWithModuleDo');
  LLVMParseBitcode := GetProcAddress(aDLLHandle, 'LLVMParseBitcode');
  LLVMParseBitcode2 := GetProcAddress(aDLLHandle, 'LLVMParseBitcode2');
  LLVMParseBitcodeInContext := GetProcAddress(aDLLHandle, 'LLVMParseBitcodeInContext');
  LLVMParseBitcodeInContext2 := GetProcAddress(aDLLHandle, 'LLVMParseBitcodeInContext2');
  LLVMParseCommandLineOptions := GetProcAddress(aDLLHandle, 'LLVMParseCommandLineOptions');
  LLVMParseIRInContext := GetProcAddress(aDLLHandle, 'LLVMParseIRInContext');
  LLVMPassBuilderOptionsSetAAPipeline := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetAAPipeline');
  LLVMPassBuilderOptionsSetCallGraphProfile := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetCallGraphProfile');
  LLVMPassBuilderOptionsSetDebugLogging := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetDebugLogging');
  LLVMPassBuilderOptionsSetForgetAllSCEVInLoopUnroll := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetForgetAllSCEVInLoopUnroll');
  LLVMPassBuilderOptionsSetInlinerThreshold := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetInlinerThreshold');
  LLVMPassBuilderOptionsSetLicmMssaNoAccForPromotionCap := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetLicmMssaNoAccForPromotionCap');
  LLVMPassBuilderOptionsSetLicmMssaOptCap := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetLicmMssaOptCap');
  LLVMPassBuilderOptionsSetLoopInterleaving := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetLoopInterleaving');
  LLVMPassBuilderOptionsSetLoopUnrolling := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetLoopUnrolling');
  LLVMPassBuilderOptionsSetLoopVectorization := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetLoopVectorization');
  LLVMPassBuilderOptionsSetMergeFunctions := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetMergeFunctions');
  LLVMPassBuilderOptionsSetSLPVectorization := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetSLPVectorization');
  LLVMPassBuilderOptionsSetVerifyEach := GetProcAddress(aDLLHandle, 'LLVMPassBuilderOptionsSetVerifyEach');
  LLVMPointerSize := GetProcAddress(aDLLHandle, 'LLVMPointerSize');
  LLVMPointerSizeForAS := GetProcAddress(aDLLHandle, 'LLVMPointerSizeForAS');
  LLVMPointerType := GetProcAddress(aDLLHandle, 'LLVMPointerType');
  LLVMPointerTypeInContext := GetProcAddress(aDLLHandle, 'LLVMPointerTypeInContext');
  LLVMPointerTypeIsOpaque := GetProcAddress(aDLLHandle, 'LLVMPointerTypeIsOpaque');
  LLVMPositionBuilder := GetProcAddress(aDLLHandle, 'LLVMPositionBuilder');
  LLVMPositionBuilderAtEnd := GetProcAddress(aDLLHandle, 'LLVMPositionBuilderAtEnd');
  LLVMPositionBuilderBefore := GetProcAddress(aDLLHandle, 'LLVMPositionBuilderBefore');
  LLVMPositionBuilderBeforeDbgRecords := GetProcAddress(aDLLHandle, 'LLVMPositionBuilderBeforeDbgRecords');
  LLVMPositionBuilderBeforeInstrAndDbgRecords := GetProcAddress(aDLLHandle, 'LLVMPositionBuilderBeforeInstrAndDbgRecords');
  LLVMPPCFP128Type := GetProcAddress(aDLLHandle, 'LLVMPPCFP128Type');
  LLVMPPCFP128TypeInContext := GetProcAddress(aDLLHandle, 'LLVMPPCFP128TypeInContext');
  LLVMPreferredAlignmentOfGlobal := GetProcAddress(aDLLHandle, 'LLVMPreferredAlignmentOfGlobal');
  LLVMPreferredAlignmentOfType := GetProcAddress(aDLLHandle, 'LLVMPreferredAlignmentOfType');
  LLVMPrintDbgRecordToString := GetProcAddress(aDLLHandle, 'LLVMPrintDbgRecordToString');
  LLVMPrintModuleToFile := GetProcAddress(aDLLHandle, 'LLVMPrintModuleToFile');
  LLVMPrintModuleToString := GetProcAddress(aDLLHandle, 'LLVMPrintModuleToString');
  LLVMPrintTypeToString := GetProcAddress(aDLLHandle, 'LLVMPrintTypeToString');
  LLVMPrintValueToString := GetProcAddress(aDLLHandle, 'LLVMPrintValueToString');
  LLVMRecompileAndRelinkFunction := GetProcAddress(aDLLHandle, 'LLVMRecompileAndRelinkFunction');
  LLVMRemarkArgGetDebugLoc := GetProcAddress(aDLLHandle, 'LLVMRemarkArgGetDebugLoc');
  LLVMRemarkArgGetKey := GetProcAddress(aDLLHandle, 'LLVMRemarkArgGetKey');
  LLVMRemarkArgGetValue := GetProcAddress(aDLLHandle, 'LLVMRemarkArgGetValue');
  LLVMRemarkDebugLocGetSourceColumn := GetProcAddress(aDLLHandle, 'LLVMRemarkDebugLocGetSourceColumn');
  LLVMRemarkDebugLocGetSourceFilePath := GetProcAddress(aDLLHandle, 'LLVMRemarkDebugLocGetSourceFilePath');
  LLVMRemarkDebugLocGetSourceLine := GetProcAddress(aDLLHandle, 'LLVMRemarkDebugLocGetSourceLine');
  LLVMRemarkEntryDispose := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryDispose');
  LLVMRemarkEntryGetDebugLoc := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetDebugLoc');
  LLVMRemarkEntryGetFirstArg := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetFirstArg');
  LLVMRemarkEntryGetFunctionName := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetFunctionName');
  LLVMRemarkEntryGetHotness := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetHotness');
  LLVMRemarkEntryGetNextArg := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetNextArg');
  LLVMRemarkEntryGetNumArgs := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetNumArgs');
  LLVMRemarkEntryGetPassName := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetPassName');
  LLVMRemarkEntryGetRemarkName := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetRemarkName');
  LLVMRemarkEntryGetType := GetProcAddress(aDLLHandle, 'LLVMRemarkEntryGetType');
  LLVMRemarkParserCreateBitstream := GetProcAddress(aDLLHandle, 'LLVMRemarkParserCreateBitstream');
  LLVMRemarkParserCreateYAML := GetProcAddress(aDLLHandle, 'LLVMRemarkParserCreateYAML');
  LLVMRemarkParserDispose := GetProcAddress(aDLLHandle, 'LLVMRemarkParserDispose');
  LLVMRemarkParserGetErrorMessage := GetProcAddress(aDLLHandle, 'LLVMRemarkParserGetErrorMessage');
  LLVMRemarkParserGetNext := GetProcAddress(aDLLHandle, 'LLVMRemarkParserGetNext');
  LLVMRemarkParserHasError := GetProcAddress(aDLLHandle, 'LLVMRemarkParserHasError');
  LLVMRemarkStringGetData := GetProcAddress(aDLLHandle, 'LLVMRemarkStringGetData');
  LLVMRemarkStringGetLen := GetProcAddress(aDLLHandle, 'LLVMRemarkStringGetLen');
  LLVMRemarkVersion := GetProcAddress(aDLLHandle, 'LLVMRemarkVersion');
  LLVMRemoveBasicBlockFromParent := GetProcAddress(aDLLHandle, 'LLVMRemoveBasicBlockFromParent');
  LLVMRemoveCallSiteEnumAttribute := GetProcAddress(aDLLHandle, 'LLVMRemoveCallSiteEnumAttribute');
  LLVMRemoveCallSiteStringAttribute := GetProcAddress(aDLLHandle, 'LLVMRemoveCallSiteStringAttribute');
  LLVMRemoveEnumAttributeAtIndex := GetProcAddress(aDLLHandle, 'LLVMRemoveEnumAttributeAtIndex');
  LLVMRemoveGlobalIFunc := GetProcAddress(aDLLHandle, 'LLVMRemoveGlobalIFunc');
  LLVMRemoveModule := GetProcAddress(aDLLHandle, 'LLVMRemoveModule');
  LLVMRemoveStringAttributeAtIndex := GetProcAddress(aDLLHandle, 'LLVMRemoveStringAttributeAtIndex');
  LLVMReplaceAllUsesWith := GetProcAddress(aDLLHandle, 'LLVMReplaceAllUsesWith');
  LLVMReplaceArrays := GetProcAddress(aDLLHandle, 'LLVMReplaceArrays');
  LLVMReplaceMDNodeOperandWith := GetProcAddress(aDLLHandle, 'LLVMReplaceMDNodeOperandWith');
  LLVMResetFatalErrorHandler := GetProcAddress(aDLLHandle, 'LLVMResetFatalErrorHandler');
  LLVMRunFunction := GetProcAddress(aDLLHandle, 'LLVMRunFunction');
  LLVMRunFunctionAsMain := GetProcAddress(aDLLHandle, 'LLVMRunFunctionAsMain');
  LLVMRunFunctionPassManager := GetProcAddress(aDLLHandle, 'LLVMRunFunctionPassManager');
  LLVMRunPasses := GetProcAddress(aDLLHandle, 'LLVMRunPasses');
  LLVMRunPassesOnFunction := GetProcAddress(aDLLHandle, 'LLVMRunPassesOnFunction');
  LLVMRunPassManager := GetProcAddress(aDLLHandle, 'LLVMRunPassManager');
  LLVMRunStaticConstructors := GetProcAddress(aDLLHandle, 'LLVMRunStaticConstructors');
  LLVMRunStaticDestructors := GetProcAddress(aDLLHandle, 'LLVMRunStaticDestructors');
  LLVMScalableVectorType := GetProcAddress(aDLLHandle, 'LLVMScalableVectorType');
  LLVMSearchForAddressOfSymbol := GetProcAddress(aDLLHandle, 'LLVMSearchForAddressOfSymbol');
  LLVMSetAlignment := GetProcAddress(aDLLHandle, 'LLVMSetAlignment');
  LLVMSetArgOperand := GetProcAddress(aDLLHandle, 'LLVMSetArgOperand');
  LLVMSetAtomicRMWBinOp := GetProcAddress(aDLLHandle, 'LLVMSetAtomicRMWBinOp');
  LLVMSetAtomicSingleThread := GetProcAddress(aDLLHandle, 'LLVMSetAtomicSingleThread');
  LLVMSetAtomicSyncScopeID := GetProcAddress(aDLLHandle, 'LLVMSetAtomicSyncScopeID');
  LLVMSetCleanup := GetProcAddress(aDLLHandle, 'LLVMSetCleanup');
  LLVMSetCmpXchgFailureOrdering := GetProcAddress(aDLLHandle, 'LLVMSetCmpXchgFailureOrdering');
  LLVMSetCmpXchgSuccessOrdering := GetProcAddress(aDLLHandle, 'LLVMSetCmpXchgSuccessOrdering');
  LLVMSetComdat := GetProcAddress(aDLLHandle, 'LLVMSetComdat');
  LLVMSetComdatSelectionKind := GetProcAddress(aDLLHandle, 'LLVMSetComdatSelectionKind');
  LLVMSetCondition := GetProcAddress(aDLLHandle, 'LLVMSetCondition');
  LLVMSetCurrentDebugLocation := GetProcAddress(aDLLHandle, 'LLVMSetCurrentDebugLocation');
  LLVMSetCurrentDebugLocation2 := GetProcAddress(aDLLHandle, 'LLVMSetCurrentDebugLocation2');
  LLVMSetDataLayout := GetProcAddress(aDLLHandle, 'LLVMSetDataLayout');
  LLVMSetDisasmOptions := GetProcAddress(aDLLHandle, 'LLVMSetDisasmOptions');
  LLVMSetDLLStorageClass := GetProcAddress(aDLLHandle, 'LLVMSetDLLStorageClass');
  LLVMSetExact := GetProcAddress(aDLLHandle, 'LLVMSetExact');
  LLVMSetExternallyInitialized := GetProcAddress(aDLLHandle, 'LLVMSetExternallyInitialized');
  LLVMSetFastMathFlags := GetProcAddress(aDLLHandle, 'LLVMSetFastMathFlags');
  LLVMSetFunctionCallConv := GetProcAddress(aDLLHandle, 'LLVMSetFunctionCallConv');
  LLVMSetGC := GetProcAddress(aDLLHandle, 'LLVMSetGC');
  LLVMSetGlobalConstant := GetProcAddress(aDLLHandle, 'LLVMSetGlobalConstant');
  LLVMSetGlobalIFuncResolver := GetProcAddress(aDLLHandle, 'LLVMSetGlobalIFuncResolver');
  LLVMSetICmpSameSign := GetProcAddress(aDLLHandle, 'LLVMSetICmpSameSign');
  LLVMSetInitializer := GetProcAddress(aDLLHandle, 'LLVMSetInitializer');
  LLVMSetInstDebugLocation := GetProcAddress(aDLLHandle, 'LLVMSetInstDebugLocation');
  LLVMSetInstrParamAlignment := GetProcAddress(aDLLHandle, 'LLVMSetInstrParamAlignment');
  LLVMSetInstructionCallConv := GetProcAddress(aDLLHandle, 'LLVMSetInstructionCallConv');
  LLVMSetIsDisjoint := GetProcAddress(aDLLHandle, 'LLVMSetIsDisjoint');
  LLVMSetIsInBounds := GetProcAddress(aDLLHandle, 'LLVMSetIsInBounds');
  LLVMSetIsNewDbgInfoFormat := GetProcAddress(aDLLHandle, 'LLVMSetIsNewDbgInfoFormat');
  LLVMSetLinkage := GetProcAddress(aDLLHandle, 'LLVMSetLinkage');
  LLVMSetMetadata := GetProcAddress(aDLLHandle, 'LLVMSetMetadata');
  LLVMSetModuleDataLayout := GetProcAddress(aDLLHandle, 'LLVMSetModuleDataLayout');
  LLVMSetModuleIdentifier := GetProcAddress(aDLLHandle, 'LLVMSetModuleIdentifier');
  LLVMSetModuleInlineAsm := GetProcAddress(aDLLHandle, 'LLVMSetModuleInlineAsm');
  LLVMSetModuleInlineAsm2 := GetProcAddress(aDLLHandle, 'LLVMSetModuleInlineAsm2');
  LLVMSetNNeg := GetProcAddress(aDLLHandle, 'LLVMSetNNeg');
  LLVMSetNormalDest := GetProcAddress(aDLLHandle, 'LLVMSetNormalDest');
  LLVMSetNSW := GetProcAddress(aDLLHandle, 'LLVMSetNSW');
  LLVMSetNUW := GetProcAddress(aDLLHandle, 'LLVMSetNUW');
  LLVMSetOperand := GetProcAddress(aDLLHandle, 'LLVMSetOperand');
  LLVMSetOrdering := GetProcAddress(aDLLHandle, 'LLVMSetOrdering');
  LLVMSetParamAlignment := GetProcAddress(aDLLHandle, 'LLVMSetParamAlignment');
  LLVMSetParentCatchSwitch := GetProcAddress(aDLLHandle, 'LLVMSetParentCatchSwitch');
  LLVMSetPersonalityFn := GetProcAddress(aDLLHandle, 'LLVMSetPersonalityFn');
  LLVMSetPrefixData := GetProcAddress(aDLLHandle, 'LLVMSetPrefixData');
  LLVMSetPrologueData := GetProcAddress(aDLLHandle, 'LLVMSetPrologueData');
  LLVMSetSection := GetProcAddress(aDLLHandle, 'LLVMSetSection');
  LLVMSetSourceFileName := GetProcAddress(aDLLHandle, 'LLVMSetSourceFileName');
  LLVMSetSubprogram := GetProcAddress(aDLLHandle, 'LLVMSetSubprogram');
  LLVMSetSuccessor := GetProcAddress(aDLLHandle, 'LLVMSetSuccessor');
  LLVMSetTailCall := GetProcAddress(aDLLHandle, 'LLVMSetTailCall');
  LLVMSetTailCallKind := GetProcAddress(aDLLHandle, 'LLVMSetTailCallKind');
  LLVMSetTarget := GetProcAddress(aDLLHandle, 'LLVMSetTarget');
  LLVMSetTargetMachineAsmVerbosity := GetProcAddress(aDLLHandle, 'LLVMSetTargetMachineAsmVerbosity');
  LLVMSetTargetMachineFastISel := GetProcAddress(aDLLHandle, 'LLVMSetTargetMachineFastISel');
  LLVMSetTargetMachineGlobalISel := GetProcAddress(aDLLHandle, 'LLVMSetTargetMachineGlobalISel');
  LLVMSetTargetMachineGlobalISelAbort := GetProcAddress(aDLLHandle, 'LLVMSetTargetMachineGlobalISelAbort');
  LLVMSetTargetMachineMachineOutliner := GetProcAddress(aDLLHandle, 'LLVMSetTargetMachineMachineOutliner');
  LLVMSetThreadLocal := GetProcAddress(aDLLHandle, 'LLVMSetThreadLocal');
  LLVMSetThreadLocalMode := GetProcAddress(aDLLHandle, 'LLVMSetThreadLocalMode');
  LLVMSetUnnamedAddr := GetProcAddress(aDLLHandle, 'LLVMSetUnnamedAddr');
  LLVMSetUnnamedAddress := GetProcAddress(aDLLHandle, 'LLVMSetUnnamedAddress');
  LLVMSetUnwindDest := GetProcAddress(aDLLHandle, 'LLVMSetUnwindDest');
  LLVMSetValueName := GetProcAddress(aDLLHandle, 'LLVMSetValueName');
  LLVMSetValueName2 := GetProcAddress(aDLLHandle, 'LLVMSetValueName2');
  LLVMSetVisibility := GetProcAddress(aDLLHandle, 'LLVMSetVisibility');
  LLVMSetVolatile := GetProcAddress(aDLLHandle, 'LLVMSetVolatile');
  LLVMSetWeak := GetProcAddress(aDLLHandle, 'LLVMSetWeak');
  LLVMShutdown := GetProcAddress(aDLLHandle, 'LLVMShutdown');
  LLVMSizeOf := GetProcAddress(aDLLHandle, 'LLVMSizeOf');
  LLVMSizeOfTypeInBits := GetProcAddress(aDLLHandle, 'LLVMSizeOfTypeInBits');
  LLVMStartMultithreaded := GetProcAddress(aDLLHandle, 'LLVMStartMultithreaded');
  LLVMStopMultithreaded := GetProcAddress(aDLLHandle, 'LLVMStopMultithreaded');
  LLVMStoreSizeOfType := GetProcAddress(aDLLHandle, 'LLVMStoreSizeOfType');
  LLVMStripModuleDebugInfo := GetProcAddress(aDLLHandle, 'LLVMStripModuleDebugInfo');
  LLVMStructCreateNamed := GetProcAddress(aDLLHandle, 'LLVMStructCreateNamed');
  LLVMStructGetTypeAtIndex := GetProcAddress(aDLLHandle, 'LLVMStructGetTypeAtIndex');
  LLVMStructSetBody := GetProcAddress(aDLLHandle, 'LLVMStructSetBody');
  LLVMStructType := GetProcAddress(aDLLHandle, 'LLVMStructType');
  LLVMStructTypeInContext := GetProcAddress(aDLLHandle, 'LLVMStructTypeInContext');
  LLVMTargetExtTypeInContext := GetProcAddress(aDLLHandle, 'LLVMTargetExtTypeInContext');
  LLVMTargetHasAsmBackend := GetProcAddress(aDLLHandle, 'LLVMTargetHasAsmBackend');
  LLVMTargetHasJIT := GetProcAddress(aDLLHandle, 'LLVMTargetHasJIT');
  LLVMTargetHasTargetMachine := GetProcAddress(aDLLHandle, 'LLVMTargetHasTargetMachine');
  LLVMTargetMachineEmitToFile := GetProcAddress(aDLLHandle, 'LLVMTargetMachineEmitToFile');
  LLVMTargetMachineEmitToMemoryBuffer := GetProcAddress(aDLLHandle, 'LLVMTargetMachineEmitToMemoryBuffer');
  LLVMTargetMachineOptionsSetABI := GetProcAddress(aDLLHandle, 'LLVMTargetMachineOptionsSetABI');
  LLVMTargetMachineOptionsSetCodeGenOptLevel := GetProcAddress(aDLLHandle, 'LLVMTargetMachineOptionsSetCodeGenOptLevel');
  LLVMTargetMachineOptionsSetCodeModel := GetProcAddress(aDLLHandle, 'LLVMTargetMachineOptionsSetCodeModel');
  LLVMTargetMachineOptionsSetCPU := GetProcAddress(aDLLHandle, 'LLVMTargetMachineOptionsSetCPU');
  LLVMTargetMachineOptionsSetFeatures := GetProcAddress(aDLLHandle, 'LLVMTargetMachineOptionsSetFeatures');
  LLVMTargetMachineOptionsSetRelocMode := GetProcAddress(aDLLHandle, 'LLVMTargetMachineOptionsSetRelocMode');
  LLVMTemporaryMDNode := GetProcAddress(aDLLHandle, 'LLVMTemporaryMDNode');
  LLVMTokenTypeInContext := GetProcAddress(aDLLHandle, 'LLVMTokenTypeInContext');
  LLVMTypeIsSized := GetProcAddress(aDLLHandle, 'LLVMTypeIsSized');
  LLVMTypeOf := GetProcAddress(aDLLHandle, 'LLVMTypeOf');
  LLVMValueAsBasicBlock := GetProcAddress(aDLLHandle, 'LLVMValueAsBasicBlock');
  LLVMValueAsMetadata := GetProcAddress(aDLLHandle, 'LLVMValueAsMetadata');
  LLVMValueIsBasicBlock := GetProcAddress(aDLLHandle, 'LLVMValueIsBasicBlock');
  LLVMValueMetadataEntriesGetKind := GetProcAddress(aDLLHandle, 'LLVMValueMetadataEntriesGetKind');
  LLVMValueMetadataEntriesGetMetadata := GetProcAddress(aDLLHandle, 'LLVMValueMetadataEntriesGetMetadata');
  LLVMVectorType := GetProcAddress(aDLLHandle, 'LLVMVectorType');
  LLVMVerifyFunction := GetProcAddress(aDLLHandle, 'LLVMVerifyFunction');
  LLVMVerifyModule := GetProcAddress(aDLLHandle, 'LLVMVerifyModule');
  LLVMViewFunctionCFG := GetProcAddress(aDLLHandle, 'LLVMViewFunctionCFG');
  LLVMViewFunctionCFGOnly := GetProcAddress(aDLLHandle, 'LLVMViewFunctionCFGOnly');
  LLVMVoidType := GetProcAddress(aDLLHandle, 'LLVMVoidType');
  LLVMVoidTypeInContext := GetProcAddress(aDLLHandle, 'LLVMVoidTypeInContext');
  LLVMWriteBitcodeToFD := GetProcAddress(aDLLHandle, 'LLVMWriteBitcodeToFD');
  LLVMWriteBitcodeToFile := GetProcAddress(aDLLHandle, 'LLVMWriteBitcodeToFile');
  LLVMWriteBitcodeToFileHandle := GetProcAddress(aDLLHandle, 'LLVMWriteBitcodeToFileHandle');
  LLVMWriteBitcodeToMemoryBuffer := GetProcAddress(aDLLHandle, 'LLVMWriteBitcodeToMemoryBuffer');
  LLVMX86AMXType := GetProcAddress(aDLLHandle, 'LLVMX86AMXType');
  LLVMX86AMXTypeInContext := GetProcAddress(aDLLHandle, 'LLVMX86AMXTypeInContext');
  LLVMX86FP80Type := GetProcAddress(aDLLHandle, 'LLVMX86FP80Type');
  LLVMX86FP80TypeInContext := GetProcAddress(aDLLHandle, 'LLVMX86FP80TypeInContext');
end;

{ =========================================================================== }

{$R libLLVM.API.res}

var
  DepsDLLHandle: THandle = 0;

procedure LoadDLL();
var
  LResStream: TResourceStream;

  function d925494b631743969ed659f137d1c647(): string;
  const
    CValue = 'e100b89682944756b9e11b03fc7e8d8f';
  begin
    Result := CValue;
  end;

  procedure AbortDLL(const AText: string; const AArgs: array of const);
  begin
    MessageBox(0, System.PWideChar(Format(AText, AArgs)), 'Critial Error', MB_ICONERROR);
    Halt(1);
  end;

begin
  // load deps DLL
  if DepsDLLHandle <> 0 then Exit;
  if not Boolean((FindResource(HInstance, PChar(d925494b631743969ed659f137d1c647()), RT_RCDATA) <> 0)) then AbortDLL('Deps DLL was not found in resource', []);
  LResStream := TResourceStream.Create(HInstance, d925494b631743969ed659f137d1c647(), RT_RCDATA);
  try
    LResStream.Position := 0;
    DepsDLLHandle := Dlluminator.LoadLibrary(LResStream.Memory, LResStream.Size);
    if DepsDLLHandle = 0 then AbortDLL('Was not able to load Deps DLL from memory', []);
  finally
    LResStream.Free();
  end;
  GetExports(DepsDLLHandle);
end;

procedure UnloadDLL();
begin
  // unload deps DLL
  if DepsDLLHandle <> 0 then
  begin
    FreeLibrary(DepsDLLHandle);
    DepsDLLHandle := 0;
  end;
end;

initialization
begin
  // turn on memory leak detection
  ReportMemoryLeaksOnShutdown := True;

  // load libLLVM DLL
  LoadDLL();
end;

finalization
begin
  // Unload libLLVM DLL
  UnloadDLL();
end;

end.
