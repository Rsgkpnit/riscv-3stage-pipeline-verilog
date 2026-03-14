`timescale 1ns / 1ps
module register_file(
    input clk, reset, reg_write_enable,
    input [4:0] read_reg_num1, read_reg_num2, write_reg_num1,
    input [31:0] write_data_dm,
    input lb, lui_control, jump, sw,
    input [31:0] lui_imm_val,
    output [31:0] read_data1, read_data2
);
    reg [31:0] reg_mem [31:0];
    integer i;

    // Combinational Forwarding: Read the data being written in the same cycle
    assign read_data1 = (read_reg_num1 == 5'b0) ? 32'b0 : 
                        ((read_reg_num1 == write_reg_num1) && reg_write_enable) ? write_data_dm : reg_mem[read_reg_num1];
    assign read_data2 = (read_reg_num2 == 5'b0) ? 32'b0 : 
                        ((read_reg_num2 == write_reg_num1) && reg_write_enable) ? write_data_dm : reg_mem[read_reg_num2];

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) reg_mem[i] <= 32'b0;
        end else if (reg_write_enable && write_reg_num1 != 5'b0) begin
            reg_mem[write_reg_num1] <= (lui_control) ? lui_imm_val : write_data_dm;
        end
    end
endmodule
