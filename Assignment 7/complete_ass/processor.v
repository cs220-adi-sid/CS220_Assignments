`timescale 1ns / 1ps
`include "PC.v"
`include "VEDA_I.v"
`include "VEDA_R.v"
`include "ALU.v"
`include "ALU_control.v"
`include "Control.v"
`include "VEDA_D.v"
`include "NEXT_PC.v"

module processor (
    input clk  // clock signal for PC and RD
);

  wire [31:0] pc_in, pc_out;

  wire [ 5:0] im_ctr;
  wire [ 5:0] im_funcode;
  wire [31:0] im_instruction;

  wire [31:0] r_wbdata,  // dm_out
  r_read1, r_read2;

  wire c_RegDst, c_Jump, c_Branch, c_Bne, c_MemRead, c_MemtoReg, c_MemWrite, c_ALUSrc, c_RegWrite;
  wire [1:0] c_ALUOp;

  wire [3:0] c_ALUcontrol;

  wire c_zero;
  wire [31:0] alu_result;

  PC u_Program_counter (
      .clk (clk),
      .next(pc_in),
      .out (pc_out)
  );

  VEDA_I u_Instruction_memory (
      .addr       (pc_out),
      .ctr        (im_ctr),
      .funcode    (im_funcode),
      .instruction(im_instruction)
  );


  VEDA_R u_Register (
      .clk        (clk),
      .instruction(im_instruction),
      .RegWrite   (c_RegWrite),
      .RegDst     (c_RegDst),
      .WriteData  (r_wbdata),
      .ReadData1  (r_read1),
      .ReadData2  (r_read2)
  );


  ALU u_ALU (
      .data1      (r_read1),
      .read2      (r_read2),
      .instruction(im_instruction),
      .ALUSrc     (c_ALUSrc),
      .ALUcontrol (c_ALUcontrol),
      .zero       (c_zero),
      .ALUresult  (alu_result)
  );


  ALU_control u_ALU_control (
      .ALUOp      (c_ALUOp),
      .instruction(im_funcode),
      .ALUcontrol (c_ALUcontrol)
  );

  Control u_Control (
      .instruction(im_instruction),
      .RegDst     (c_RegDst),
      .Jump       (c_Jump),
      .Branch     (c_Branch),
      .Bne        (c_Bne),
      .MemRead    (c_MemRead),
      .MemtoReg   (c_MemtoReg),
      .ALUOp      (c_ALUOp),
      .MemWrite   (c_MemWrite),
      .ALUSrc     (c_ALUSrc),
      .RegWrite   (c_RegWrite)
  );


  VEDA_D u_Data_memory (
      .clk      (clk),
      .addr     (alu_result),  // im_instruction
      .wData    (r_read2),
      .ALUresult(alu_result),
      .MemWrite (c_MemWrite),
      .MemRead  (c_MemRead),
      .MemtoReg (c_MemtoReg),
      .rData    (r_wbdata)
  );


  NEXT_PC u_Next_pc (
      .old        (pc_out),
      .instruction(im_instruction),
      .Jump       (c_Jump),
      .Branch     (c_Branch),
      .Bne        (c_Bne),
      .zero       (c_zero),
      .next       (pc_in)
  );

endmodule

