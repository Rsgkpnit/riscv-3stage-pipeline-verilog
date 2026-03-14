`include "defines.vh"

module alu(
    input  [31:0] src1,
    input  [31:0] src2,
    input  [5:0]  alu_control,
    input  [31:0] imm_val_r,
    input  [3:0]  sh_amt,
    output reg [31:0] result
);

    always @(*) begin
        case (alu_control)
            // Load and Store need the ALU to perform an ADD (Base + Offset)
            `ALU_ADD, `ALU_ADDI, `ALU_L_WORD, `ALU_S_WORD: result = src1 + src2;
            `ALU_SUB: result = src1 - src2;
            `ALU_AND, `ALU_ANDI: result = src1 & src2;
            `ALU_OR,  `ALU_ORI:  result = src1 | src2;
            `ALU_XOR, `ALU_XORI: result = src1 ^ src2;
            `ALU_SLL, `ALU_SLLI: result = src1 << src2[4:0];
            `ALU_SRL, `ALU_SRLI: result = src1 >> src2[4:0];
            `ALU_SRA: result = $signed(src1) >>> src2[4:0];
            `ALU_SLT, `ALU_SLTI: result = ($signed(src1) < $signed(src2)) ? 1 : 0;
            `ALU_BEQ:  result = (src1 == src2) ? 1 : 0;
            `ALU_BNE:  result = (src1 != src2) ? 1 : 0;
            `ALU_LUI:result = imm_val_r;
    
            default: result = 32'b0;
        endcase
    end
endmodule


`timescale 1ns 
