`timescale 1ns / 1ps
// --- DATA MEMORY (4K words) ---
module data_memory(
    input clk,
    input rst,
    input [11:0] wr_addr,      // 12-bit index -> 4096 words (addr bits [13:2])
    input [31:0] wr_data,
    input sw,
    input [11:0] rd_addr,      // 12-bit index
    output [31:0] data_out
);
    // 4096 x 32-bit RAM
    reg [31:0] data_mem [0:4095];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            // zero init (costly for big mems, ok for simulation)
            for (i = 0; i < 4096; i = i + 1)
                data_mem[i] <= 32'b0;
        end else begin
            if (sw) begin
                data_mem[wr_addr] <= wr_data;
                // debug print for simulator console:
                $display("MEM WRITE: time=%0t addr=0x%03h data=%h", $time, wr_addr, wr_data);
            end
        end
    end

    assign data_out = data_mem[rd_addr];
endmodule
