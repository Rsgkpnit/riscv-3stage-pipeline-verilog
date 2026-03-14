`include "defines.vh"

module imm_gen(
    input  wire [31:0] instr_memory,
    output reg  [31:0] imm_val_r
);

    wire [6:0] opcode;

    assign opcode = instr_memory[6:0];

    always @(*) begin
        case (opcode)

            `OPCODE_I_TYPE,
            `OPCODE_LOAD,
            `OPCODE_JALR:
                imm_val_r = {{20{instr_memory[31]}}, instr_memory[31:20]};

            `OPCODE_STORE:
                imm_val_r = {{20{instr_memory[31]}},
                             instr_memory[31:25],
                             instr_memory[11:7]};

            `OPCODE_BRANCH:
                imm_val_r = {{19{instr_memory[31]}},
                             instr_memory[31],
                             instr_memory[7],
                             instr_memory[30:25],
                             instr_memory[11:8],
                             1'b0};

            `OPCODE_LUI,
            `OPCODE_AUIPC:
                imm_val_r = {instr_memory[31:12], 12'b0};

            `OPCODE_JAL:
                imm_val_r = {{11{instr_memory[31]}},
                             instr_memory[31],
                             instr_memory[19:12],
                             instr_memory[20],
                             instr_memory[30:21],
                             1'b0};

            default:
                imm_val_r = 32'b0;

        endcase
    end

endmodule
