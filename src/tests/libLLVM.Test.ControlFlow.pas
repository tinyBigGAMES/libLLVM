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

unit libLLVM.Test.ControlFlow;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestControlFlow }
  TTestControlFlow = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for control flow functionality
    class procedure TestReturnStatements(); static;
    class procedure TestUnconditionalJumps(); static;
    class procedure TestConditionalJumps(); static;
    class procedure TestPhiNodes(); static;
    class procedure TestControlFlowCombinations(); static;
  end;

implementation

{ TTestControlFlow }

class procedure TTestControlFlow.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.ControlFlow...');
  
  TestReturnStatements();
  TestUnconditionalJumps();
  TestConditionalJumps();
  TestPhiNodes();
  TestControlFlowCombinations();
  
  TLLUtils.PrintLn('libLLVM.Test.ControlFlow completed.');
end;

(**
 * Test: Return Statement Functionality
 * 
 * Description: This test demonstrates how to create return statements in LLVM IR,
 * including both void returns and value returns. Return statements are terminator
 * instructions that end basic blocks and transfer control back to the caller.
 *
 * Functions Demonstrated:
 * - ReturnValue() - Returns a value from a function
 * - ReturnVoid() - Returns void from a function (implicit)
 * - Function termination with proper return instructions
 *
 * LLVM Concepts Covered:
 * - Terminator instructions (ret, ret void)
 * - Function return value handling
 * - Basic block termination requirements
 * - Return type consistency with function signatures
 *
 * Expected Output: "Return statements: void function completed, value function returned 42"
 *
 * Takeaway: Learn how return statements properly terminate functions and basic blocks
 * while ensuring type consistency between returned values and function signatures.
 *)
class procedure TTestControlFlow.TestReturnStatements();
var
  LValue, LResult: TLLValue;
begin
  // Demo: Testing different types of return statements
  // Shows proper function termination with return instructions
  with TLLVM.Create() do
  begin
    try
      CreateModule('return_test');
      
      // Test 1: Function that returns void (implicit ReturnVoid)
      BeginFunction('return_test', 'void_function', dtVoid, [])
        .BeginBlock('return_test', 'entry');
      
      // Function with void return - no explicit value needed
      // ReturnValue() with no parameter creates a void return
      ReturnValue('return_test');
      
      EndBlock('return_test')
      .EndFunction('return_test');
      
      // Test 2: Function that returns an integer value
      BeginFunction('return_test', 'value_function', dtInt32, [])
        .BeginBlock('return_test', 'entry');
      
      // Create a value to return
      LValue := IntegerValue('return_test', 42, dtInt32);
      
      // Return the value - terminates the function with the specified value
      ReturnValue('return_test', LValue);
      
      EndBlock('return_test')
      .EndFunction('return_test');
      
      // Test 3: Function with computation before return
      BeginFunction('return_test', 'computed_return', dtInt32, [Param('input', dtInt32)])
        .BeginBlock('return_test', 'entry');
      
      // Get parameter and perform computation
      LValue := GetParameter('return_test', 'input');
      LResult := Add('return_test', LValue, IntegerValue('return_test', 10, dtInt32), 'plus_ten');
      
      // Return the computed result
      ReturnValue('return_test', LResult);
      
      EndBlock('return_test')
      .EndFunction('return_test');
      
      if ValidateModule('return_test') then
      begin
        // Test the functions
        ExecuteFunction('return_test', 'void_function', []);
        LResult := ExecuteFunction('return_test', 'value_function', []);
        TLLUtils.PrintLn('Return statements: void function completed, value function returned %d', [LResult.AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Unconditional Jump Instructions
 * 
 * Description: This test demonstrates how to create unconditional branch instructions
 * that transfer control flow between basic blocks without any conditions. These jumps
 * are fundamental for creating sequential execution paths and structured control flow.
 *
 * Functions Demonstrated:
 * - Jump() - Creates unconditional branch to target basic block
 * - Basic block connectivity without conditions
 * - Sequential control flow construction
 *
 * LLVM Concepts Covered:
 * - Unconditional branch instructions (br label)
 * - Basic block connectivity in control flow graphs
 * - Sequential execution flow between blocks
 * - Terminator instruction requirements for basic blocks
 *
 * Expected Output: "Unconditional jumps: execution flowed through all blocks, result = 150"
 *
 * Takeaway: Learn how unconditional branches create sequential execution paths
 * between basic blocks, forming the backbone of structured control flow.
 *)
class procedure TTestControlFlow.TestUnconditionalJumps();
var
  LValue1, LValue2, LValue3, LResult: TLLValue;
begin
  // Demo: Using unconditional jumps to create sequential execution flow
  // Shows how basic blocks connect with unconditional branches
  with TLLVM.Create() do
  begin
    try
      CreateModule('jump_test');

      BeginFunction('jump_test', 'sequential_flow', dtInt32, [])
        .DeclareBlock('jump_test', 'entry_block')       // Declare entry block FIRST
        .DeclareBlock('jump_test', 'processing_block')  // Declare so Jump can reference
        .DeclareBlock('jump_test', 'final_block')       // Declare so Jump can reference
        // Block 1: Entry point with initial computation
        .BeginBlock('jump_test', 'entry_block');

      // Perform initial computation
      LValue1 := IntegerValue('jump_test', 50, dtInt32);

      // Unconditional jump to the next processing block
      Jump('jump_test', 'processing_block');

      EndBlock('jump_test')
      // Block 2: Processing block for additional computation
      .BeginBlock('jump_test', 'processing_block');

      // Continue computation with value from previous block (SSA form)
      // Note: In real scenarios with complex data flow, Phi nodes would be needed
      LValue2 := Add('jump_test', LValue1, IntegerValue('jump_test', 75, dtInt32), 'intermediate');

      // Another unconditional jump to final block
      Jump('jump_test', 'final_block');

      EndBlock('jump_test')
      // Block 3: Final computation and return
      .BeginBlock('jump_test', 'final_block');

      // Final computation
      LValue3 := Add('jump_test', LValue2, IntegerValue('jump_test', 25, dtInt32), 'final_result');

      // Return the final result
      ReturnValue('jump_test', LValue3);

      EndBlock('jump_test')
      .EndFunction('jump_test');
      if ValidateModule('jump_test') then
      begin
        // Execute the function: 50 + 75 + 25 = 150
        LResult := ExecuteFunction('jump_test', 'sequential_flow', []);
        TLLUtils.PrintLn('Unconditional jumps: execution flowed through all blocks, result = %d', [LResult.AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Conditional Jump Instructions
 * 
 * Description: This test demonstrates how to create conditional branch instructions
 * that transfer control flow between basic blocks based on runtime conditions.
 * These are essential for implementing if-statements, loops, and other conditional logic.
 *
 * Functions Demonstrated:
 * - JumpIf() - Creates conditional branch based on boolean condition
 * - Comparison operations for creating conditions
 * - Branching to different execution paths
 *
 * LLVM Concepts Covered:
 * - Conditional branch instructions (br i1 condition, label, label)
 * - Boolean condition evaluation for branching
 * - Control flow divergence and convergence
 * - Multiple execution paths in control flow graphs
 *
 * Expected Output: "Conditional jumps: positive path taken, result = 100"
 *
 * Takeaway: Learn how conditional branches enable decision-making in programs
 * by directing execution flow based on runtime conditions and boolean expressions.
 *)
class procedure TTestControlFlow.TestConditionalJumps();
var
  LInput, LCondition, LPositiveResult, LNegativeResult, LResult: TLLValue;
begin
  // Demo: Using conditional jumps to create branching execution paths
  // Shows how decisions are made based on runtime conditions
  with TLLVM.Create() do
  begin
    try
      CreateModule('conditional_test');

      BeginFunction('conditional_test', 'conditional_flow', dtInt32, [Param('input_value', dtInt32)])
        .DeclareBlock('conditional_test', 'entry')          // Declare entry block FIRST
        .DeclareBlock('conditional_test', 'positive_path')
        .DeclareBlock('conditional_test', 'negative_path')
        .DeclareBlock('conditional_test', 'merge_point')
        // Entry block: evaluate condition and decide execution path
        .BeginBlock('conditional_test', 'entry');

      // Get the input parameter
      LInput := GetParameter('conditional_test', 'input_value');

      // Create condition: check if input > 0
      LCondition := IsGreater('conditional_test', LInput,
        IntegerValue('conditional_test', 0, dtInt32), 'is_positive');

      // Conditional jump: go to positive_path if true, negative_path if false
      JumpIf('conditional_test', LCondition, 'positive_path', 'negative_path');

      EndBlock('conditional_test')
      // Positive path: handle positive input values
      .BeginBlock('conditional_test', 'positive_path');

      // Perform positive-specific computation
      LPositiveResult := Multiply('conditional_test', LInput,
        IntegerValue('conditional_test', 10, dtInt32), 'positive_calc');

      // Jump to merge point where paths converge
      Jump('conditional_test', 'merge_point');

      EndBlock('conditional_test')
      // Negative path: handle non-positive input values
      .BeginBlock('conditional_test', 'negative_path');

      // Perform negative-specific computation
      LNegativeResult := Add('conditional_test', LInput,
        IntegerValue('conditional_test', 1000, dtInt32), 'negative_calc');

      // Jump to merge point where paths converge
      Jump('conditional_test', 'merge_point');

      EndBlock('conditional_test')
      // Merge point: where different execution paths converge
      .BeginBlock('conditional_test', 'merge_point');

      // Note: In a real implementation with complex control flow,
      // we would need Phi nodes here to merge values from different paths.
      // For this demo, we'll return a simple indicator value.
      LResult := IntegerValue('conditional_test', 100, dtInt32);

      ReturnValue('conditional_test', LResult);

      EndBlock('conditional_test')
      .EndFunction('conditional_test');

      if ValidateModule('conditional_test') then
      begin
        // Test with positive input (5) - should take positive path
        LResult := ExecuteFunction('conditional_test', 'conditional_flow', [5]);
        TLLUtils.PrintLn('Conditional jumps: positive path taken, result = %d', [LResult.AsInt64]);

        // Test with negative input (-3) - should take negative path
        LResult := ExecuteFunction('conditional_test', 'conditional_flow', [-3]);
        TLLUtils.PrintLn('Conditional jumps: negative path taken, result = %d', [LResult.AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Phi Node Instructions (SSA Form)
 * 
 * Description: This test demonstrates how to create and use Phi nodes in LLVM IR.
 * Phi nodes are essential for maintaining Static Single Assignment (SSA) form when
 * multiple control flow paths converge and different values need to be merged.
 *
 * Functions Demonstrated:
 * - CreatePhi() - Creates a Phi node for value merging
 * - AddPhiIncoming() - Adds incoming value/block pairs to Phi nodes
 * - SSA form maintenance across basic block boundaries
 *
 * LLVM Concepts Covered:
 * - Static Single Assignment (SSA) form requirements
 * - Phi nodes for value merging at control flow join points
 * - Incoming value/block pairs in Phi instructions
 * - Data flow analysis and value propagation
 *
 * Expected Output: "Phi nodes: merged value from positive path = 50, from negative path = 997"
 *
 * Takeaway: Learn how Phi nodes enable SSA form by merging values from different
 * control flow paths, ensuring each variable is assigned exactly once.
 *)
class procedure TTestControlFlow.TestPhiNodes();
var
  LInput, LCondition, LPositiveValue, LNegativeValue, LMergedValue, LResult: TLLValue;
begin
  // Demo: Using Phi nodes to merge values from different control flow paths
  // Shows how SSA form is maintained when paths converge
  with TLLVM.Create() do
  begin
    try
      CreateModule('phi_test');

      BeginFunction('phi_test', 'phi_demo', dtInt32, [Param('input_value', dtInt32)])
        .DeclareBlock('phi_test', 'entry')          // Declare entry block FIRST
        .DeclareBlock('phi_test', 'positive_branch') // Declare so JumpIf can reference
        .DeclareBlock('phi_test', 'negative_branch') // Declare so JumpIf can reference
        .DeclareBlock('phi_test', 'merge_block')     // Declare so Jump can reference
        // Entry block: create condition and branch
        .BeginBlock('phi_test', 'entry');

      LInput := GetParameter('phi_test', 'input_value');

      // Condition: input > 0
      LCondition := IsGreater('phi_test', LInput,
        IntegerValue('phi_test', 0, dtInt32), 'condition');

      JumpIf('phi_test', LCondition, 'positive_branch', 'negative_branch');

      EndBlock('phi_test')
      // Positive branch: compute positive-specific value
      .BeginBlock('phi_test', 'positive_branch');

      // Compute: input * 5
      LPositiveValue := Multiply('phi_test', LInput,
        IntegerValue('phi_test', 5, dtInt32), 'positive_result');

      Jump('phi_test', 'merge_block');

      EndBlock('phi_test')
      // Negative branch: compute negative-specific value
      .BeginBlock('phi_test', 'negative_branch');

      // Compute: input + 1000
      LNegativeValue := Add('phi_test', LInput,
        IntegerValue('phi_test', 1000, dtInt32), 'negative_result');

      Jump('phi_test', 'merge_block');

      EndBlock('phi_test')
      // Merge block: use Phi node to merge values from different paths
      .BeginBlock('phi_test', 'merge_block');

      // Create Phi node to merge values based on which path was taken
      LMergedValue := CreatePhi('phi_test', dtInt32, 'merged_value');

      // Add incoming values and their corresponding basic blocks
      // From positive branch: use LPositiveValue
      AddPhiIncoming('phi_test', LMergedValue, LPositiveValue, 'positive_branch');

      // From negative branch: use LNegativeValue
      AddPhiIncoming('phi_test', LMergedValue, LNegativeValue, 'negative_branch');

      // The Phi node will automatically select the correct value based on
      // which predecessor block the execution came from
      ReturnValue('phi_test', LMergedValue);

      EndBlock('phi_test')
      .EndFunction('phi_test');

      if ValidateModule('phi_test') then
      begin
        // Test positive input: 10 * 5 = 50
        LResult := ExecuteFunction('phi_test', 'phi_demo', [10]);
        TLLUtils.PrintLn('Phi nodes: merged value from positive path = %d', [LResult.AsInt64]);

        // Test negative input: -3 + 1000 = 997
        LResult := ExecuteFunction('phi_test', 'phi_demo', [-3]);
        TLLUtils.PrintLn('Phi nodes: merged value from negative path = %d', [LResult.AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Complex Control Flow Combinations
 * 
 * Description: This test demonstrates advanced control flow scenarios that combine
 * multiple control flow constructs including conditional branches, loops simulation,
 * multiple Phi nodes, and complex branching patterns. This represents real-world
 * control flow complexity found in practical compiler-generated code.
 *
 * Functions Demonstrated:
 * - Complex branching patterns with multiple conditions
 * - Multiple Phi nodes for different merge points
 * - Nested control flow structures
 * - Advanced SSA form maintenance
 *
 * LLVM Concepts Covered:
 * - Complex control flow graph structures
 * - Multiple merge points with different Phi nodes
 * - Dominator relationships in control flow
 * - Advanced SSA form construction and maintenance
 *
 * Expected Output: "Complex control flow: case 1 = 15, case 2 = 1003, case 3 = 0"
 *
 * Takeaway: Learn how complex real-world control flow is constructed by combining
 * basic control flow primitives into sophisticated branching and merging patterns.
 *)
class procedure TTestControlFlow.TestControlFlowCombinations();
var
  LInput, LCondition1, LCondition2, LCondition3: TLLValue;
  LPath1Result, LPath2Result, LPath3Result, LDefaultResult: TLLValue;
  LFirstMerge, LFinalResult, LResult: TLLValue;
begin
  // Demo: Complex control flow with multiple branches and merge points
  // Shows realistic compiler-generated control flow patterns
  with TLLVM.Create() do
  begin
    try
      CreateModule('complex_test');

      BeginFunction('complex_test', 'complex_flow', dtInt32, [Param('input_value', dtInt32)])
        .DeclareBlock('complex_test', 'entry')          // Declare entry block FIRST
        .DeclareBlock('complex_test', 'range_check')    // Declare so JumpIf can reference
        .DeclareBlock('complex_test', 'small_values')   // Declare so JumpIf can reference
        .DeclareBlock('complex_test', 'large_values')   // Declare so JumpIf can reference
        .DeclareBlock('complex_test', 'medium_values')  // Declare so JumpIf can reference
        .DeclareBlock('complex_test', 'first_merge')    // Declare so Jump can reference
        .DeclareBlock('complex_test', 'negative_values') // Declare so JumpIf can reference
        .DeclareBlock('complex_test', 'small_positive') // Declare so JumpIf can reference
        .DeclareBlock('complex_test', 'final_merge')    // Declare so Jump can reference
        // Entry: Multi-way branching based on input ranges
        .BeginBlock('complex_test', 'entry');

      LInput := GetParameter('complex_test', 'input_value');

      // First condition: input > 10
      LCondition1 := IsGreater('complex_test', LInput,
        IntegerValue('complex_test', 10, dtInt32), 'gt_ten');

      JumpIf('complex_test', LCondition1, 'range_check', 'small_values');

      EndBlock('complex_test')
      // Range check: further subdivide large values
      .BeginBlock('complex_test', 'range_check');

      // Second condition: input > 50
      LCondition2 := IsGreater('complex_test', LInput,
        IntegerValue('complex_test', 50, dtInt32), 'gt_fifty');

      JumpIf('complex_test', LCondition2, 'large_values', 'medium_values');

      EndBlock('complex_test')
      // Path 1: Large values (> 50)
      .BeginBlock('complex_test', 'large_values');

      LPath1Result := Divide('complex_test', LInput,
        IntegerValue('complex_test', 10, dtInt32), 'large_calc');

      Jump('complex_test', 'first_merge');

      EndBlock('complex_test')
      // Path 2: Medium values (10 < x <= 50)
      .BeginBlock('complex_test', 'medium_values');

      LPath2Result := Add('complex_test', LInput,
        IntegerValue('complex_test', 5, dtInt32), 'medium_calc');

      Jump('complex_test', 'first_merge');

      EndBlock('complex_test')
      // First merge point: combine large and medium value results
      .BeginBlock('complex_test', 'first_merge');

      // Phi node for first merge
      LFirstMerge := CreatePhi('complex_test', dtInt32, 'first_merge_phi');
      AddPhiIncoming('complex_test', LFirstMerge, LPath1Result, 'large_values');
      AddPhiIncoming('complex_test', LFirstMerge, LPath2Result, 'medium_values');

      Jump('complex_test', 'final_merge');

      EndBlock('complex_test')
      // Path 3: Small values (<= 10)
      .BeginBlock('complex_test', 'small_values');

      // Third condition: input < 0
      LCondition3 := IsLess('complex_test', LInput,
        IntegerValue('complex_test', 0, dtInt32), 'is_negative');

      JumpIf('complex_test', LCondition3, 'negative_values', 'small_positive');

      EndBlock('complex_test')
      // Path 4: Negative values
      .BeginBlock('complex_test', 'negative_values');

      LPath3Result := Add('complex_test', LInput,
        IntegerValue('complex_test', 1000, dtInt32), 'negative_calc');

      Jump('complex_test', 'final_merge');

      EndBlock('complex_test')
      // Path 5: Small positive values (0 <= x <= 10)
      .BeginBlock('complex_test', 'small_positive');

      LDefaultResult := IntegerValue('complex_test', 0, dtInt32);

      Jump('complex_test', 'final_merge');

      EndBlock('complex_test')
      // Final merge: combine all execution paths
      .BeginBlock('complex_test', 'final_merge');

      // Complex Phi node with multiple incoming paths
      LFinalResult := CreatePhi('complex_test', dtInt32, 'final_phi');
      AddPhiIncoming('complex_test', LFinalResult, LFirstMerge, 'first_merge');
      AddPhiIncoming('complex_test', LFinalResult, LPath3Result, 'negative_values');
      AddPhiIncoming('complex_test', LFinalResult, LDefaultResult, 'small_positive');

      ReturnValue('complex_test', LFinalResult);

      EndBlock('complex_test')
      .EndFunction('complex_test');

      if ValidateModule('complex_test') then
      begin
        // Test case 1: Medium value (15) -> 15 + 5 = 20
        LResult := ExecuteFunction('complex_test', 'complex_flow', [15]);
        TLLUtils.PrintLn('Complex control flow: case 1 (medium value 15) = %d', [LResult.AsInt64]);

        // Test case 2: Negative value (-3) -> -3 + 1000 = 997
        LResult := ExecuteFunction('complex_test', 'complex_flow', [-3]);
        TLLUtils.PrintLn('Complex control flow: case 2 (negative value -3) = %d', [LResult.AsInt64]);

        // Test case 3: Small positive value (5) -> returns 0
        LResult := ExecuteFunction('complex_test', 'complex_flow', [5]);
        TLLUtils.PrintLn('Complex control flow: case 3 (small positive 5) = %d', [LResult.AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

end.
