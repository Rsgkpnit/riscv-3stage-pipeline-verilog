module data_path(
    input clk, rst,

    input [4:0] read_reg_num1,
    input [4:0] read_reg_num2,
    input [4:0] write_reg_num1,

    input [31:0] input_pc,         

    input reg_write,
    input [5:0] alu_control,
    input alu_src,
    input jump,
    input stall,
    input branch_flush,

    input beq_control, bne_control,
    input bgeq_control, blt_control,

    input [31:0] imm_val,
    input [3:0] sh_amt,

    input lb, sw,
    input lui_control,
    input [31:0] imm_val_lui,

    output EX_MEM_regwrite,
    output [4:0] EX_MEM_rd,
    output EX_MEM_lb,
    output [31:0] EX_MEM_pc,
    output [31:0] EX_MEM_imm,

   // in data_path module header:
    output [11:0] read_data_addr_dm,
    output beq, bneq, bge, blt
);

// ================= STAGE 2 =================

wire [31:0] read_data1, read_data2;
wire [31:0] alu_result;
// Forwarding wires
wire [31:0] forwardA;
wire [31:0] forwardB;  
wire [31:0] alu_input_2;
//Differentitaing SRAM vs Peripheral

wire is_data_mem;
wire is_peripheral;

assign is_data_mem   = (EX_MEM_alu_result_reg[31:28] == 4'h2);
assign is_peripheral = (EX_MEM_alu_result_reg[31:28] == 4'h4);



assign alu_input_2 = (alu_src) ? imm_val : forwardB;

wire [31:0] final_write_back_data;

register_file rfu (
    .clk(clk),
    .reset(rst),
    .reg_write_enable(EX_MEM_regwrite),

    .read_reg_num1(read_reg_num1),
    .read_reg_num2(read_reg_num2),
    .write_reg_num1(EX_MEM_rd),

    .write_data_dm(final_write_back_data),

    .lb(EX_MEM_lb),
    .lui_control(lui_control),
    .jump(jump),
    .sw(sw),
    .lui_imm_val(imm_val_lui),

    .read_data1(read_data1),
    .read_data2(read_data2)
);
  
// Forwarding from EX/MEM stage
// Forward A
assign forwardA =
    (EX_MEM_regwrite_reg &&
     EX_MEM_rd_reg != 0 &&
     EX_MEM_rd_reg == read_reg_num1) // changed check
        ? final_write_back_data
        :
    read_data1;

// Forward B
assign forwardB =
    (EX_MEM_regwrite_reg &&
     EX_MEM_rd_reg != 0 &&
     EX_MEM_rd_reg == read_reg_num2)
        ? final_write_back_data
        :
    read_data2;

alu alu_unit(
    .src1(forwardA),
    .src2(alu_input_2),
    .alu_control(alu_control),
    .imm_val_r(imm_val),
    .sh_amt(sh_amt),
    .result(alu_result)
);

// ================= EX/MEM REGISTER =================

reg [31:0] EX_MEM_alu_result_reg;
reg [31:0] EX_MEM_read_data2_reg;
reg [4:0]  EX_MEM_rd_reg;
reg EX_MEM_lb_reg;
reg EX_MEM_sw_reg;
reg EX_MEM_regwrite_reg;
reg [31:0] EX_MEM_pc_reg;
reg [31:0] EX_MEM_imm_reg;   // ADD THIS  

reg EX_MEM_beq_control;
reg EX_MEM_bne_control;
reg EX_MEM_bgeq_control;
reg EX_MEM_blt_control;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        EX_MEM_alu_result_reg <= 0;
        EX_MEM_read_data2_reg <= 0;
        EX_MEM_rd_reg <= 0;
        EX_MEM_lb_reg <= 0;
        EX_MEM_sw_reg <= 0;
        EX_MEM_regwrite_reg <= 0;
        EX_MEM_pc_reg <= 0;
        EX_MEM_imm_reg <= 0;
        EX_MEM_beq_control <= 0;
        EX_MEM_bne_control <= 0;
        EX_MEM_bgeq_control <= 0;
        EX_MEM_blt_control <= 0;
    end
    else if (branch_flush) begin   
        EX_MEM_regwrite_reg <= 0;
        EX_MEM_rd_reg <= 0;
        EX_MEM_lb_reg <= 0;
        EX_MEM_sw_reg <= 0;
        EX_MEM_beq_control <= 0;
        EX_MEM_bne_control <= 0;
        EX_MEM_bgeq_control <= 0;
        EX_MEM_blt_control <= 0;
    end
    else if (stall) begin          
        EX_MEM_regwrite_reg <= 0;
        EX_MEM_rd_reg <= 0;
        EX_MEM_lb_reg <= 0;
        EX_MEM_sw_reg <= 0;
        EX_MEM_beq_control <= 0;
        EX_MEM_bne_control <= 0;
        EX_MEM_bgeq_control <= 0;
        EX_MEM_blt_control <= 0;
    end
    else begin
        EX_MEM_alu_result_reg <= alu_result;
        EX_MEM_read_data2_reg <= forwardB;// change from this due to one bug ,EX_MEM_read_data2_reg <= read_data2;
        EX_MEM_rd_reg <= write_reg_num1;
        EX_MEM_lb_reg <= lb;
        EX_MEM_sw_reg <= sw;
        EX_MEM_regwrite_reg <= reg_write;
        EX_MEM_pc_reg <= input_pc;
        EX_MEM_imm_reg <= imm_val;   // ADD
        EX_MEM_beq_control <= beq_control;
        EX_MEM_bne_control <= bne_control;
        EX_MEM_bgeq_control <= bgeq_control;
        EX_MEM_blt_control <= blt_control;
    end
end

assign EX_MEM_rd = EX_MEM_rd_reg;
assign EX_MEM_lb = EX_MEM_lb_reg;
assign EX_MEM_regwrite = EX_MEM_regwrite_reg;
assign EX_MEM_pc = EX_MEM_pc_reg;
assign EX_MEM_imm = EX_MEM_imm_reg;   // ADD  


//For Peripherals Temporary
wire peripheral_write;
wire peripheral_read;

assign peripheral_write = EX_MEM_sw_reg & is_peripheral;
assign peripheral_read  = EX_MEM_lb_reg & is_peripheral;


// ================= STAGE 3 =================

wire [31:0] data_out_mem;

data_memory dmu (
    .clk(clk),
    .rst(rst),
    .wr_addr(EX_MEM_alu_result_reg[13:2]),     // use same bits as rd_addr
    .wr_data(EX_MEM_read_data2_reg),
    .sw(EX_MEM_sw_reg & is_data_mem),          // only write if it's data mem
    .rd_addr(EX_MEM_alu_result_reg[13:2]),
    .data_out(data_out_mem)
);

assign final_write_back_data =
    (EX_MEM_lb_reg & is_data_mem) ? data_out_mem :
    EX_MEM_alu_result_reg;


assign read_data_addr_dm = EX_MEM_alu_result_reg[13:2];// new line check

assign beq  = (EX_MEM_alu_result_reg == 1) && EX_MEM_beq_control;
assign bneq = (EX_MEM_alu_result_reg == 1) && EX_MEM_bne_control;
assign bge  = (EX_MEM_alu_result_reg == 1) && EX_MEM_bgeq_control;
assign blt  = (EX_MEM_alu_result_reg == 1) && EX_MEM_blt_control;
  
endmodule

