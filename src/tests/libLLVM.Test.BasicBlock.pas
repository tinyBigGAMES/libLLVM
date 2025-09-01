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

unit libLLVM.Test.BasicBlock;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestBasicBlock }
  TTestBasicBlock = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for basic block management functionality
    class procedure TestBlockCreation(); static;
    class procedure TestBlockLifecycle(); static;
    class procedure TestBlockNaming(); static;
    class procedure TestBlockContext(); static;
    class procedure TestBlockNavigation(); static;
  end;

implementation

{ TTestBasicBlock }

class procedure TTestBasicBlock.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.BasicBlock...');
  
  TestBlockCreation();
  TestBlockLifecycle();
  TestBlockNaming();
  TestBlockContext();
  TestBlockNavigation();
  
  TLLUtils.PrintLn('libLLVM.Test.BasicBlock completed.');
end;

(**
 * Test: Basic Block Creation
 * 
 * Description: This test demonstrates how to create and manage basic blocks in LLVM IR.
 * Basic blocks are fundamental building blocks that contain sequences of instructions
 * with a single entry point and single exit point.
 *
 * Functions Demonstrated:
 * - BeginBlock() - Creates and starts a new basic block
 * - EndBlock() - Completes the current basic block
 * - Basic block naming and organization
 *
 * LLVM Concepts Covered:
 * - Basic block structure and requirements
 * - Single entry/single exit principle
 * - Basic block naming conventions
 * - Control flow graph fundamentals
 *
 * Expected Output: "Block creation test: success"
 *
 * Takeaway: Learn how basic blocks form the foundation of LLVM IR structure
 * and how they organize instructions for control flow analysis.
 *)
class procedure TTestBasicBlock.TestBlockCreation();
var
  LConstant, LResult: TLLValue;
begin
  // Demo: Creating and using basic blocks
  // Shows the fundamental structure of LLVM basic blocks
  with TLLVM.Create() do
  begin
    try
      CreateModule('block_test')
      .BeginFunction('block_test', 'simple_function', dtInt32, [])
        // Create the main entry basic block
        .BeginBlock('block_test', 'entry');
      
      // Add some instructions to the basic block
      LConstant := IntegerValue('block_test', 42, dtInt32);
      LResult := Add('block_test', LConstant, LConstant, 'doubled');
      
      ReturnValue('block_test', LResult);
      
      // End the basic block - every block must be properly closed
      EndBlock('block_test')
      .EndFunction('block_test');
      
      if ValidateModule('block_test') then
      begin
        TLLUtils.PrintLn('Block creation test: success');
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Basic Block Lifecycle Management
 * 
 * Description: This test demonstrates the complete lifecycle of basic blocks,
 * including creation, population with instructions, proper termination,
 * and cleanup. It shows the required flow for managing block states.
 *
 * Functions Demonstrated:
 * - BeginBlock() - Initialize new basic block
 * - EndBlock() - Properly terminate basic block
 * - Block state management during function construction
 *
 * LLVM Concepts Covered:
 * - Basic block lifecycle (create -> populate -> terminate)
 * - Proper block termination requirements
 * - Block state transitions in function building
 * - Memory management for basic blocks
 *
 * Expected Output: "Block lifecycle: 100"
 *
 * Takeaway: Understand the proper sequence for creating, using, and terminating
 * basic blocks to ensure valid LLVM IR generation.
 *)
class procedure TTestBasicBlock.TestBlockLifecycle();
var
  LValue: TLLValue;
begin
  // Demo: Complete basic block lifecycle from creation to termination
  // Shows proper sequence of block management operations
  with TLLVM.Create() do
  begin
    try
      CreateModule('lifecycle_test')
      .BeginFunction('lifecycle_test', 'block_lifecycle', dtInt32, [])
        // Phase 1: Create and begin new block
        .BeginBlock('lifecycle_test', 'start');
      
      // Phase 2: Populate block with instructions
      LValue := IntegerValue('lifecycle_test', 100, dtInt32);
      
      // Phase 3: Provide proper termination (return instruction)
      ReturnValue('lifecycle_test', LValue);
      
      // Phase 4: End the block (completes the lifecycle)
      EndBlock('lifecycle_test')
      .EndFunction('lifecycle_test');
      
      if ValidateModule('lifecycle_test') then
      begin
        // Execute to verify complete lifecycle worked correctly
        TLLUtils.PrintLn('Block lifecycle: %d', [ExecuteFunction('lifecycle_test', 'block_lifecycle', []).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Basic Block Naming Conventions
 *
 * Description: This test demonstrates best practices for naming basic blocks
 * in LLVM IR. Proper naming is crucial for debugging, optimization analysis,
 * and maintaining readable intermediate representation.
 *
 * Functions Demonstrated:
 * - BeginBlock() with descriptive names
 * - Multiple blocks with meaningful identifiers
 * - Block naming conventions and standards
 * - Jump() calls to connect basic blocks
 *
 * LLVM Concepts Covered:
 * - Basic block identification in IR
 * - Naming conventions for different block types
 * - How block names appear in generated LLVM IR
 * - Best practices for maintainable IR code
 * - Control flow between basic blocks
 *
 * Expected Output: "Block naming: entry -> calculation -> return = 25"
 *
 * Takeaway: Learn how meaningful block names improve IR readability
 * and make complex control flow easier to understand and debug.
 *)
class procedure TTestBasicBlock.TestBlockNaming();
var
  LParam, LSquared: TLLValue;
begin
  // Demo: Proper naming conventions for basic blocks
  // Shows how descriptive names improve IR readability
  with TLLVM.Create() do
  begin
    try
      CreateModule('naming_test')
      .BeginFunction('naming_test', 'square_number', dtInt32, [Param('input', dtInt32)])

       // Pre-create all blocks so Jump() can resolve names
        .DeclareBlock('naming_test', 'function_entry')
        .DeclareBlock('naming_test', 'calculation_block')
        .DeclareBlock('naming_test', 'function_return')

        // *** Create and fill blocks in sequential order ***
        // Each block is created once and immediately filled
        .BeginBlock('naming_test', 'function_entry');

      // Get the input parameter
      LParam := GetParameter('naming_test', 'input');

      // Move to calculation block
      Jump('naming_test', 'calculation_block');

      EndBlock('naming_test')

      // *** Create calculation block ***
      .BeginBlock('naming_test', 'calculation_block');

      // Perform the square calculation
      LSquared := Multiply('naming_test', LParam, LParam, 'squared_result');

      // Move to return block
      Jump('naming_test', 'function_return');

      EndBlock('naming_test')

      // *** Create return block ***
      .BeginBlock('naming_test', 'function_return');

      // Return the calculated result (this is a terminator instruction)
      ReturnValue('naming_test', LSquared);

      EndBlock('naming_test')
      .EndFunction('naming_test');

      if ValidateModule('naming_test') then
      begin
        // Test with input value 5: 5² = 25
        TLLUtils.PrintLn('Block naming: entry -> calculation -> return = %d',
          [ExecuteFunction('naming_test', 'square_number', [5]).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Basic Block Context Management
 * 
 * Description: This test demonstrates how basic blocks maintain context within
 * functions and modules, including how the current block context affects
 * instruction placement and IR generation.
 *
 * Functions Demonstrated:
 * - Block context switching between different blocks
 * - Instruction placement within specific block contexts
 * - Context preservation during block transitions
 *
 * LLVM Concepts Covered:
 * - Current block context in IR builder
 * - Instruction insertion point management
 * - Block context switching mechanics
 * - Context isolation between different blocks
 *
 * Expected Output: "Block context: 15"
 *
 * Takeaway: Understand how LLVM maintains context when working with
 * multiple basic blocks and how instructions are placed correctly.
 *)
class procedure TTestBasicBlock.TestBlockContext();
var
  LParam, LDoubled, LResult: TLLValue;
begin
  // Demo: Basic block context management and switching
  // Shows how context determines where instructions are placed
  with TLLVM.Create() do
  begin
    try
      CreateModule('context_test')

      .BeginFunction('context_test', 'context_demo', dtInt32, [Param('value', dtInt32)])

        // Declare all blocks first
        .DeclareBlock('context_test', 'entry_context')
        .DeclareBlock('context_test', 'processing_context')
        .DeclareBlock('context_test', 'exit_context')

        // Context 1: Entry block for initial processing
        .BeginBlock('context_test', 'entry_context');
      
      LParam := GetParameter('context_test', 'value');
      LDoubled := Multiply('context_test', LParam, IntegerValue('context_test', 2, dtInt32), 'doubled');

      Jump('context_test', 'processing_context');

      // Switch context to processing block
      EndBlock('context_test')
      .BeginBlock('context_test', 'processing_context');
      
      // Instructions now placed in processing context
      LResult := Add('context_test', LDoubled, IntegerValue('context_test', 5, dtInt32), 'final');

      Jump('context_test', 'exit_context');

      // Switch context to exit block
      EndBlock('context_test')
      .BeginBlock('context_test', 'exit_context');
      
      // Final instruction in exit context
      ReturnValue('context_test', LResult);
      
      EndBlock('context_test')
      .EndFunction('context_test');

      if ValidateModule('context_test') then
      begin
        // Test: (5 * 2) + 5 = 15
        TLLUtils.PrintLn('Block context: %d', [ExecuteFunction('context_test', 'context_demo', [5]).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Basic Block Navigation
 * 
 * Description: This test demonstrates navigation between basic blocks using
 * control flow instructions. It shows how to create branches and jumps
 * that connect different basic blocks in a control flow graph.
 *
 * Functions Demonstrated:
 * - Jump() - Unconditional branch between blocks
 * - JumpIf() - Conditional branching based on conditions
 * - Basic block connectivity and flow control
 *
 * LLVM Concepts Covered:
 * - Control flow between basic blocks
 * - Unconditional and conditional branching
 * - Basic block connectivity in control flow graphs
 * - Terminator instructions (br, br conditional)
 *
 * Expected Output: "Block navigation: true path taken, result = 100"
 *
 * Takeaway: Learn how to connect basic blocks with control flow instructions
 * to create complex program logic and branching structures.
 *)
class procedure TTestBasicBlock.TestBlockNavigation();
var
  LCondition, LTrueValue, LFalseValue: TLLValue;
  LResult: Int32;
begin
  // Demo: Navigation between basic blocks using control flow
  // Shows how to connect blocks with jumps and conditional branches
  with TLLVM.Create() do
  begin
    try
      CreateModule('navigation_test')
      .BeginFunction('navigation_test', 'navigate_blocks', dtInt32, [Param('condition', dtInt32)])
        // FIRST: Declare all blocks that will be referenced by JumpIf()
        .DeclareBlock('navigation_test', 'entry')
        .DeclareBlock('navigation_test', 'true_path')
        .DeclareBlock('navigation_test', 'false_path')

        // NOW: Begin using the blocks
        .BeginBlock('navigation_test', 'entry');

      LCondition := GetParameter('navigation_test', 'condition');

      // Create condition check: is parameter > 0?
      LCondition := IsGreater('navigation_test', LCondition,
        IntegerValue('navigation_test', 0, dtInt32), 'is_positive');

      // Conditional jump: go to true_path if condition is true, false_path otherwise
      // This terminates the current block with a conditional branch
      JumpIf('navigation_test', LCondition, 'true_path', 'false_path');

      EndBlock('navigation_test')
      .BeginBlock('navigation_test', 'true_path');

      // True path: return a positive value
      LTrueValue := IntegerValue('navigation_test', 100, dtInt32);
      ReturnValue('navigation_test', LTrueValue);

      EndBlock('navigation_test')
      .BeginBlock('navigation_test', 'false_path');

      // False path: return a negative value
      LFalseValue := IntegerValue('navigation_test', -100, dtInt32);
      ReturnValue('navigation_test', LFalseValue);

      EndBlock('navigation_test')
      .EndFunction('navigation_test');

      if ValidateModule('navigation_test') then
      begin
        // Test with zero (0) - should take false path
        LResult := ExecuteFunction('navigation_test', 'navigate_blocks', [5]).AsType<Int32>;
        if LResult = 100 then
          TLLUtils.PrintLn('Block navigation: true path taken, result = %d', [LResult])
        else
          TLLUtils.PrintLn('Block navigation: false path taken, result = %d', [LResult]);
      end;
    finally
      Free();
    end;
  end;
end;

end.
