`timescale 1ns / 1ps
`include "defines.vh"

module top(
    input clk,
    input reset
);

wire [31:0] pc, current_pc, instruction_out;
wire stall, branch_taken, jump; // Added jump declaration
wire [31:0] imm_val_r, ex_mem_pc, ex_mem_imm; 
wire reg_write, ex_mem_regwrite, ex_mem_lb;
wire [4:0] ex_mem_rd;
wire beq, bneq, bge, blt;

assign branch_taken = beq | bneq | bge | blt;

// ================= IF STAGE =================
instruction_fetch_unit ifu (
    .clk(clk), .reset(reset), .stall(stall),
    .beq(beq), .bneq(bneq), .bge(bge), .blt(blt),
    .jump(jump), // Connected jump
    .imm_address(ex_mem_imm),
    .imm_address_jump(imm_val_r),
    .branch_base_pc(ex_mem_pc),   
    .pc(pc),
    .current_pc(current_pc)
);

instruction_memory imu (.pc(pc), .instruction_code(instruction_out));

// ================= IF/ID REGISTER (With Flush) =================
reg [31:0] IF_ID_instruction;

always @(posedge clk or posedge reset) begin
    if (reset)
        IF_ID_instruction <= 32'h00000013; // NOP
    else if (branch_taken || jump)         // FLUSH on Branch OR Jump
        IF_ID_instruction <= 32'h00000013; 
    else if (!stall)
        IF_ID_instruction <= instruction_out;
end

// ================= ID/EX STAGE =================
imm_gen ig (.instr_memory(IF_ID_instruction), .imm_val_r(imm_val_r));

wire [5:0] alu_control;
wire lb, sw, lui_control, alu_src;
wire bneq_control, beq_control, bgeq_control, blt_control;

control_unit cu (
    .reset(reset),
    .funct7(IF_ID_instruction[31:25]), .funct3(IF_ID_instruction[14:12]),
    .opcode(IF_ID_instruction[6:0]),
    .alu_control(alu_control), .lb(lb),
    .bneq_control(bneq_control), .beq_control(beq_control),
    .bgeq_control(bgeq_control), .blt_control(blt_control),
    .jump(jump), // Connected jump output from Control Unit
    .sw(sw), .lui_control(lui_control), .alu_src(alu_src), .reg_write(reg_write)
);

wire [4:0] rs1 = IF_ID_instruction[19:15];
wire [4:0] rs2 = IF_ID_instruction[24:20];

assign stall = (ex_mem_lb) && (ex_mem_rd != 0) && ((ex_mem_rd == rs1) || (ex_mem_rd == rs2));

data_path dpu (
    .clk(clk), .rst(reset),
    .read_reg_num1(rs1), .read_reg_num2(rs2),
    .write_reg_num1(IF_ID_instruction[11:7]),
    .input_pc(current_pc),
    .reg_write(reg_write), .alu_control(alu_control), .alu_src(alu_src),
    .jump(jump), .stall(stall), .branch_flush(branch_taken),
    .beq_control(beq_control), .bne_control(bneq_control),
    .bgeq_control(bgeq_control), .blt_control(blt_control),
    .imm_val(imm_val_r), .sh_amt(IF_ID_instruction[24:21]),
    .lb(lb), .sw(sw), .lui_control(lui_control), .imm_val_lui(imm_val_r),
    .EX_MEM_regwrite(ex_mem_regwrite), .EX_MEM_rd(ex_mem_rd),
    .EX_MEM_lb(ex_mem_lb), .EX_MEM_pc(ex_mem_pc), .EX_MEM_imm(ex_mem_imm),
    .beq(beq), .bneq(bneq), .bge(bge), .blt(blt)
);

endmodule
