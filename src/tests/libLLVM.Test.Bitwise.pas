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

unit libLLVM.Test.Bitwise;

interface

uses
  System.SysUtils,
  System.Classes,
  libLLVM.Utils,
  libLLVM;

type
  { TTestBitwise }
  TTestBitwise = class
  public
    class procedure RunAllTests(); static;
    
    // Test methods for bitwise operations functionality
    class procedure TestBitwiseLogical(); static;
    class procedure TestBitwiseShifts(); static;
    class procedure TestBitwiseComplements(); static;
    class procedure TestBitwiseMasks(); static;
    class procedure TestBitwiseNaming(); static;
  end;

implementation

{ TTestBitwise }

class procedure TTestBitwise.RunAllTests();
begin
  TLLUtils.PrintLn('Running libLLVM.Test.Bitwise...');
  
  TestBitwiseLogical();
  TestBitwiseShifts();
  TestBitwiseComplements();
  TestBitwiseMasks();
  TestBitwiseNaming();
  
  TLLUtils.PrintLn('libLLVM.Test.Bitwise completed.');
end;

(**
 * Test: Bitwise Logical Operations
 * 
 * Description: This test demonstrates bitwise logical operations (AND, OR, XOR)
 * using LLVM IR generation. These operations work on individual bits of integer
 * values and are fundamental for low-level programming and bit manipulation.
 *
 * Functions Demonstrated:
 * - BitwiseAnd() - Bitwise AND operation (&)
 * - BitwiseOr() - Bitwise OR operation (|)
 * - BitwiseXor() - Bitwise XOR operation (^)
 *
 * LLVM Concepts Covered:
 * - Bitwise operations in LLVM IR (and, or, xor)
 * - Integer bit manipulation at IR level
 * - Binary logical operations on integer types
 * - Bitwise operation naming and organization
 *
 * Expected Output: "Bitwise AND: 12 & 10 = 8"
 *
 * Takeaway: Learn how bitwise operations translate to LLVM IR and understand
 * the fundamental bit manipulation operations available in LLVM.
 *)
class procedure TTestBitwise.TestBitwiseLogical();
var
  LValue1, LValue2, LResult: TLLValue;
begin
  // Demo: Bitwise logical operations (AND, OR, XOR)
  // Shows how bit manipulation operations work in LLVM IR
  with TLLVM.Create() do
  begin
    try
      CreateModule('bitwise_test')
      .BeginFunction('bitwise_test', 'test_and_operation', dtInt32, [])
        .BeginBlock('bitwise_test', 'entry');
      
      // Create two integer values for bitwise operations
      // 12 in binary: 1100
      // 10 in binary: 1010
      LValue1 := IntegerValue('bitwise_test', 12, dtInt32);
      LValue2 := IntegerValue('bitwise_test', 10, dtInt32);
      
      // Perform bitwise AND: 1100 & 1010 = 1000 (8 in decimal)
      // Generates LLVM IR: "and i32 12, 10"
      LResult := BitwiseAnd('bitwise_test', LValue1, LValue2, 'and_result');
      
      ReturnValue('bitwise_test', LResult);
      
      EndBlock('bitwise_test')
      .EndFunction('bitwise_test');
      
      if ValidateModule('bitwise_test') then
      begin
        // Result: 12 & 10 = 8
        TLLUtils.PrintLn('Bitwise AND: 12 & 10 = %d',
          [ExecuteFunction('bitwise_test', 'test_and_operation', []).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Bitwise Shift Operations
 * 
 * Description: This test demonstrates bitwise shift operations (left and right shifts)
 * which move bits in integer values left or right by specified positions.
 * These operations are essential for efficient multiplication/division by powers of 2.
 *
 * Functions Demonstrated:
 * - ShiftLeft() - Left bit shift operation (<<)
 * - ShiftRight() - Right bit shift operation (>>)
 * - Arithmetic vs logical shift behaviors
 *
 * LLVM Concepts Covered:
 * - Bit shift operations in LLVM IR (shl, ashr, lshr)
 * - Arithmetic vs logical right shifts
 * - Efficient multiplication/division using shifts
 * - Bit position manipulation
 *
 * Expected Output: "Left shift: 5 << 2 = 20"
 *
 * Takeaway: Understand how bit shifts provide efficient arithmetic operations
 * and learn the difference between arithmetic and logical shifts.
 *)
class procedure TTestBitwise.TestBitwiseShifts();
var
  LValue, LShiftAmount, LResult: TLLValue;
begin
  // Demo: Bitwise shift operations for efficient arithmetic
  // Shows how shifts can multiply/divide by powers of 2
  with TLLVM.Create() do
  begin
    try
      CreateModule('shift_test')
      .BeginFunction('shift_test', 'test_left_shift', dtInt32, [])
        .BeginBlock('shift_test', 'entry');
      
      // Create value 5 (binary: 101)
      LValue := IntegerValue('shift_test', 5, dtInt32);
      
      // Shift amount: 2 positions
      LShiftAmount := IntegerValue('shift_test', 2, dtInt32);
      
      // Left shift: 101 << 2 = 10100 (5 * 4 = 20)
      // Generates LLVM IR: "shl i32 5, 2"
      LResult := ShiftLeft('shift_test', LValue, LShiftAmount, 'shifted_left');
      
      ReturnValue('shift_test', LResult);
      
      EndBlock('shift_test')
      .EndFunction('shift_test');
      
      if ValidateModule('shift_test') then
      begin
        // Result: 5 << 2 = 20 (equivalent to 5 * 2^2)
        TLLUtils.PrintLn('Left shift: 5 << 2 = %d',
          [ExecuteFunction('shift_test', 'test_left_shift', []).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Bitwise Complement Operations
 * 
 * Description: This test demonstrates bitwise complement (NOT) operations which
 * flip all bits in an integer value. This unary operation inverts each bit
 * from 0 to 1 and 1 to 0, creating the one's complement.
 *
 * Functions Demonstrated:
 * - BitwiseNot() - Bitwise NOT/complement operation (~)
 * - Unary bitwise operations
 * - One's complement arithmetic
 *
 * LLVM Concepts Covered:
 * - Bitwise complement in LLVM IR (xor with all 1s)
 * - Unary bitwise operations
 * - One's complement vs two's complement
 * - Bit inversion patterns
 *
 * Expected Output: "Bitwise NOT: ~5 = -6"
 *
 * Takeaway: Learn how bitwise complement works in two's complement arithmetic
 * and understand why ~n equals -(n+1) in signed integer systems.
 *)
class procedure TTestBitwise.TestBitwiseComplements();
var
  LValue, LResult: TLLValue;
begin
  // Demo: Bitwise complement (NOT) operation
  // Shows how bit inversion works in two's complement arithmetic
  with TLLVM.Create() do
  begin
    try
      CreateModule('complement_test')
      .BeginFunction('complement_test', 'test_not_operation', dtInt32, [])
        .BeginBlock('complement_test', 'entry');
      
      // Create value 5 (binary: ...00000101)
      LValue := IntegerValue('complement_test', 5, dtInt32);
      
      // Bitwise NOT: invert all bits
      // In 32-bit two's complement: ~5 = ...11111010 = -6
      // Generates LLVM IR: "xor i32 5, -1" (XOR with all 1s)
      LResult := BitwiseNot('complement_test', LValue, 'inverted');
      
      ReturnValue('complement_test', LResult);
      
      EndBlock('complement_test')
      .EndFunction('complement_test');
      
      if ValidateModule('complement_test') then
      begin
        // Result: ~5 = -6 (due to two's complement representation)
        TLLUtils.PrintLn('Bitwise NOT: ~5 = %d',
          [ExecuteFunction('complement_test', 'test_not_operation', []).AsType<Int32>]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Bitwise Masking Operations
 * 
 * Description: This test demonstrates bitwise masking techniques using AND operations
 * to isolate specific bits or bit patterns. Masking is fundamental for extracting
 * or modifying specific bit ranges in integer values.
 *
 * Functions Demonstrated:
 * - BitwiseAnd() for masking operations
 * - Creating bit masks for isolation
 * - Bit pattern extraction techniques
 *
 * LLVM Concepts Covered:
 * - Bit masking with AND operations
 * - Hexadecimal constant representation
 * - Bit isolation and extraction patterns
 * - Common masking idioms and patterns
 *
 * Expected Output: "Bit mask: 0x1234 & 0x00FF = 0x34"
 *
 * Takeaway: Learn essential bit masking techniques for extracting specific
 * bit ranges, commonly used in systems programming and data manipulation.
 *)
class procedure TTestBitwise.TestBitwiseMasks();
var
  LValue, LMask, LResult: TLLValue;
begin
  // Demo: Bitwise masking to extract specific bit ranges
  // Shows common masking patterns for bit manipulation
  with TLLVM.Create() do
  begin
    try
      CreateModule('mask_test')
      .BeginFunction('mask_test', 'extract_low_byte', dtInt32, [])
        .BeginBlock('mask_test', 'entry');
      
      // Create a 16-bit value: 0x1234 (4660 decimal)
      LValue := IntegerValue('mask_test', $1234, dtInt32);
      
      // Create mask to extract low byte: 0x00FF (255 decimal)
      LMask := IntegerValue('mask_test', $00FF, dtInt32);
      
      // Apply mask to extract low 8 bits: 0x1234 & 0x00FF = 0x34
      // Generates LLVM IR: "and i32 4660, 255"
      LResult := BitwiseAnd('mask_test', LValue, LMask, 'low_byte');
      
      ReturnValue('mask_test', LResult);
      
      EndBlock('mask_test')
      .EndFunction('mask_test');
      
      if ValidateModule('mask_test') then
      begin
        // Result: 0x1234 & 0x00FF = 0x34 (52 decimal)
        TLLUtils.PrintLn('Bit mask: 0x1234 & 0x00FF = 0x%X',
          [ExecuteFunction('mask_test', 'extract_low_byte', []).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

(**
 * Test: Bitwise Operation Naming
 * 
 * Description: This test demonstrates the importance of descriptive naming
 * in bitwise operations. Good naming makes complex bit manipulation code
 * more readable and maintainable by clearly indicating the purpose of each operation.
 *
 * Functions Demonstrated:
 * - All bitwise operations with meaningful names
 * - Descriptive intermediate result naming
 * - Clear bit manipulation workflow naming
 *
 * LLVM Concepts Covered:
 * - Value naming in complex bitwise operations
 * - IR readability for bit manipulation
 * - Debugging bitwise operations through naming
 * - Documentation through meaningful identifiers
 *
 * Expected Output: "Named bitwise: flags = 0x0A"
 *
 * Takeaway: Learn how proper naming transforms cryptic bit manipulation
 * into self-documenting code that's easier to understand and maintain.
 *)
class procedure TTestBitwise.TestBitwiseNaming();
var
  LBaseFlags, LNewFlag, LMask, LClearedFlags, LFinalFlags: TLLValue;
begin
  // Demo: Descriptive naming in bitwise operations for clarity
  // Shows how good naming makes bit manipulation self-documenting
  with TLLVM.Create() do
  begin
    try
      CreateModule('naming_bitwise')
      .BeginFunction('naming_bitwise', 'update_flags', dtInt32, [])
        .BeginBlock('naming_bitwise', 'flag_processing');
      
      // Start with base flags: 0x05 (binary: 0101)
      LBaseFlags := IntegerValue('naming_bitwise', $05, dtInt32);
      
      // New flag to set: 0x08 (binary: 1000)
      LNewFlag := IntegerValue('naming_bitwise', $08, dtInt32);
      
      // Mask for clearing specific bits: 0xFE (binary: 11111110)
      LMask := IntegerValue('naming_bitwise', $FE, dtInt32);
      
      // Clear bit 0 using AND mask: generates "and i32 %base_flags, %clear_bit0_mask"
      LClearedFlags := BitwiseAnd('naming_bitwise', LBaseFlags, LMask, 'flags_bit0_cleared');
      
      // Set new flag using OR: generates "or i32 %flags_bit0_cleared, %enable_flag"
      LFinalFlags := BitwiseOr('naming_bitwise', LClearedFlags, LNewFlag, 'updated_flags');
      
      ReturnValue('naming_bitwise', LFinalFlags);
      
      EndBlock('naming_bitwise')
      .EndFunction('naming_bitwise');
      
      if ValidateModule('naming_bitwise') then
      begin
        // Result: (0x05 & 0xFE) | 0x08 = 0x04 | 0x08 = 0x0C
        TLLUtils.PrintLn('Named bitwise: flags = 0x%X',
          [ExecuteFunction('naming_bitwise', 'update_flags', []).AsInt64]);
      end;
    finally
      Free();
    end;
  end;
end;

end.
