module instruction_memory(
        input [31:0] pc , 
        output [31:0] instruction_code
    );
    
    reg[31:0] mem [0:1023];
    
   initial begin
   $readmemh("program.mem",mem);
   end
   
    assign instruction_code = mem[pc[31:2]]; //Pc div by 4
    
endmodule
