`timescale 1ns / 1ps
`include "defines.vh"

module control_unit(
    input reset,
    input [6:0] funct7,
    input [2:0] funct3,
    input [6:0] opcode,
    output reg alu_src,       // 0 for Reg, 1 for Imm
    output reg [5:0] alu_control,
    output reg lb,
    output reg mem_to_reg,
    output reg bneq_control,
    output reg beq_control,
    output reg bgeq_control,
    output reg blt_control,
    output reg jump,
    output reg sw,
    output reg lui_control,
    output reg reg_write
);

    always @(*) begin
        // Default Assignments
        alu_control  = 6'b0;
        lb           = 0;
        mem_to_reg   = 0;
        bneq_control = 0;
        beq_control  = 0;
        bgeq_control = 0;
        blt_control  = 0;
        jump         = 0;
        sw           = 0;
        lui_control  = 0;
        alu_src      = 0; 
        reg_write    =0;
        if (reset) begin
            alu_control = 6'b0;
        end else begin
            case (opcode)
                `OPCODE_R_TYPE: begin
                    alu_src = 0;
                    reg_write=1; // Use Register
                    case (funct3)
                        3'b000: alu_control = (funct7 == 7'd32) ? `ALU_SUB : `ALU_ADD;
                        3'b001: alu_control = `ALU_SLL;
                        3'b010: alu_control = `ALU_SLT;
                        3'b011: alu_control = `ALU_SLTU;
                        3'b100: alu_control = `ALU_XOR;
                        3'b101: alu_control = (funct7 == 7'd32) ? `ALU_SRA : `ALU_SRL;
                        3'b110: alu_control = `ALU_OR;
                        3'b111: alu_control = `ALU_AND;
                    endcase
                end

                `OPCODE_I_TYPE: begin
                    alu_src = 1; // Use Immediate
                    reg_write=1;
                    case (funct3)
                        3'b000: alu_control = `ALU_ADDI;
                        3'b001: alu_control = `ALU_SLLI;
                        3'b010: alu_control = `ALU_SLTI;
                        3'b100: alu_control = `ALU_XORI;
                        3'b101: alu_control = `ALU_SRLI;
                        3'b110: alu_control = `ALU_ORI;
                        3'b111: alu_control = `ALU_ANDI;
                    endcase
                end

                `OPCODE_LOAD: begin
    alu_src   = 1;
    lb        = 1;          // 🔥 THIS IS THE IMPORTANT FIX
    reg_write = 1;
    alu_control = `ALU_L_WORD;
end

                `OPCODE_STORE: begin
                    alu_src = 1;
                    sw = 1;
                    reg_write=0;
                    case (funct3)
                        3'b010: alu_control = `ALU_S_WORD; // ALU must ADD for address
                        default: alu_control = `ALU_S_WORD;
                    endcase
                end

                `OPCODE_BRANCH: begin
                    alu_src = 0;
                    reg_write=0;
                    case (funct3)
                        3'b000: begin alu_control = `ALU_BEQ; beq_control = 1; end
                        3'b001: begin alu_control = `ALU_BNE; bneq_control = 1; end
                    endcase
                end

                `OPCODE_LUI: begin
                    alu_control = `ALU_LUI;
                    lui_control = 1;
                    reg_write=1;
                end

                `OPCODE_JAL: begin
                    alu_control = `ALU_JAL;
                    jump = 1;
                    reg_write=1;
                end
            endcase
        end
    end
endmodule
