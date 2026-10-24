module rv32i_cpu (
    input wire clk,
    input wire reset
);

reg [31:0] pc;

wire [31:0] instruction;

wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;

assign opcode = instruction[6:0];
assign funct3 = instruction[14:12];
assign funct7 = instruction[31:25];


// =====================================================
// Instruction Memory
// =====================================================

instruction_memory imem (
    .address(pc),
    .instruction(instruction)
);


// =====================================================
// Register File
// =====================================================

wire [31:0] rs1_data;
wire [31:0] rs2_data;

reg reg_write;

reg [4:0] write_rd;

reg [31:0] write_back_data;

register_file regs (
    .clk(clk),
    .reset(reset),

    .reg_write(reg_write),

    .rs1(instruction[19:15]),
    .rs2(instruction[24:20]),
    .rd(write_rd),

    .write_data(write_back_data),

    .read_data1(rs1_data),
    .read_data2(rs2_data)
);


// =====================================================
// Immediate Generator
// =====================================================

wire [31:0] immediate;

immediate_generator imm_gen (
    .instruction(instruction),
    .immediate(immediate)
);


// =====================================================
// ALU
// =====================================================

reg [31:0] alu_A;
reg [31:0] alu_B;

reg [3:0] alu_control;

wire [31:0] alu_result;

wire alu_zero;
wire alu_less_signed;
wire alu_less_unsigned;

alu alu_unit (
    .A(alu_A),
    .B(alu_B),

    .alu_control(alu_control),

    .result(alu_result),
    .zero(alu_zero),

    .less_signed(alu_less_signed),
    .less_unsigned(alu_less_unsigned)
);


// =====================================================
// Data Memory
// =====================================================

reg mem_read;
reg mem_write;

wire [31:0] memory_read_data;

data_memory dmem (
    .clk(clk),

    .mem_read(mem_read),
    .mem_write(mem_write),

    .funct3(funct3),

    .address(alu_result),
    .write_data(rs2_data),

    .read_data(memory_read_data)
);


// =====================================================
// Next PC
// =====================================================

reg [31:0] next_pc;

reg branch_taken;


// =====================================================
// Main Combinational Logic
// =====================================================

always @(*) begin

    // Default values

    alu_A = rs1_data;
    alu_B = rs2_data;

    alu_control = 4'd0;

    reg_write = 1'b0;

    write_rd = instruction[11:7];

    write_back_data = alu_result;

    mem_read = 1'b0;
    mem_write = 1'b0;

    next_pc = pc + 32'd4;

    branch_taken = 1'b0;


    // =================================================
    // R-TYPE
    // =================================================

    if (opcode == 7'b0110011) begin

        reg_write = 1'b1;

        alu_A = rs1_data;
        alu_B = rs2_data;

        case (funct3)

            3'b000: begin
                if (funct7 == 7'b0100000)
                    alu_control = 4'd1; // SUB
                else
                    alu_control = 4'd0; // ADD
            end

            3'b001:
                alu_control = 4'd5; // SLL

            3'b010:
                alu_control = 4'd8; // SLT

            3'b011:
                alu_control = 4'd9; // SLTU

            3'b100:
                alu_control = 4'd4; // XOR

            3'b101: begin
                if (funct7 == 7'b0100000)
                    alu_control = 4'd7; // SRA
                else
                    alu_control = 4'd6; // SRL
            end

            3'b110:
                alu_control = 4'd3; // OR

            3'b111:
                alu_control = 4'd2; // AND

            default:
                alu_control = 4'd0;

        endcase

        write_back_data = alu_result;

    end


    // =================================================
    // I-TYPE ALU
    // =================================================

    else if (opcode == 7'b0010011) begin

        reg_write = 1'b1;

        alu_A = rs1_data;
        alu_B = immediate;

        case (funct3)

            3'b000:
                alu_control = 4'd0; // ADDI

            3'b010:
                alu_control = 4'd8; // SLTI

            3'b011:
                alu_control = 4'd9; // SLTIU

            3'b100:
                alu_control = 4'd4; // XORI

            3'b110:
                alu_control = 4'd3; // ORI

            3'b111:
                alu_control = 4'd2; // ANDI

            3'b001:
                alu_control = 4'd5; // SLLI

            3'b101: begin
                if (instruction[30])
                    alu_control = 4'd7; // SRAI
                else
                    alu_control = 4'd6; // SRLI
            end

            default:
                alu_control = 4'd0;

        endcase

        write_back_data = alu_result;

    end


    // =================================================
    // LOAD
    // =================================================

    else if (opcode == 7'b0000011) begin

        reg_write = 1'b1;

        alu_A = rs1_data;
        alu_B = immediate;

        alu_control = 4'd0;

        mem_read = 1'b1;

        write_back_data = memory_read_data;

    end


    // =================================================
    // STORE
    // =================================================

    else if (opcode == 7'b0100011) begin

        alu_A = rs1_data;
        alu_B = immediate;

        alu_control = 4'd0;

        mem_write = 1'b1;

    end


    // =================================================
    // BRANCH
    // =================================================

    else if (opcode == 7'b1100011) begin

        case (funct3)

            // BEQ
            3'b000:
                branch_taken = (rs1_data == rs2_data);

            // BNE
            3'b001:
                branch_taken = (rs1_data != rs2_data);

            // BLT
            3'b100:
                branch_taken =
                    ($signed(rs1_data) < $signed(rs2_data));

            // BGE
            3'b101:
                branch_taken =
                    ($signed(rs1_data) >= $signed(rs2_data));

            // BLTU
            3'b110:
                branch_taken =
                    (rs1_data < rs2_data);

            // BGEU
            3'b111:
                branch_taken =
                    (rs1_data >= rs2_data);

            default:
                branch_taken = 1'b0;

        endcase

        if (branch_taken)
            next_pc = pc + immediate;

    end


    // =================================================
    // LUI
    // =================================================

    else if (opcode == 7'b0110111) begin

        reg_write = 1'b1;

        write_back_data = immediate;

    end


    // =================================================
    // AUIPC
    // =================================================

    else if (opcode == 7'b0010111) begin

        reg_write = 1'b1;

        write_back_data = pc + immediate;

    end


    // =================================================
    // JAL
    // =================================================

    else if (opcode == 7'b1101111) begin

        reg_write = 1'b1;

        write_back_data = pc + 32'd4;

        next_pc = pc + immediate;

    end


    // =================================================
    // JALR
    // =================================================

    else if (opcode == 7'b1100111) begin

        reg_write = 1'b1;

        write_back_data = pc + 32'd4;

        next_pc = (rs1_data + immediate) & 32'hFFFFFFFE;

    end


    // =================================================
    // FENCE / SYSTEM
    // =================================================

    else begin

        // Educational implementation:
        // FENCE / ECALL / EBREAK do not alter
        // the basic datapath here.

        reg_write = 1'b0;

    end

end


// =====================================================
// PC
// =====================================================

always @(posedge clk) begin

    if (reset)
        pc <= 32'b0;
    else
        pc <= next_pc;

end

endmodule