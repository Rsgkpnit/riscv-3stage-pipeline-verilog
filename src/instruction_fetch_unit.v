`timescale 1ns / 1ps

module instruction_fetch_unit(
    input clk, 
    input reset, 
    input stall,
    input beq, bneq, bge, blt, jump,
    input [31:0] imm_address,
    input [31:0] imm_address_jump,
    input [31:0] branch_base_pc,
    output reg [31:0] pc,         
    output reg [31:0] current_pc  
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0;
            current_pc <= 32'b0;
        end 
        else if (!stall) begin
            current_pc <= pc; // Store the PC of the instruction that just entered the pipe
            if (jump) begin
                pc <= pc + imm_address_jump;
            end 
            else if (beq || bneq || bge || blt) begin
                pc <= branch_base_pc + imm_address;
            end 
            else begin
                pc <= pc + 4;
            end
        end
    end
endmodule
