`timescale 1ns/1ps

module rv32i_cpu_tb;

reg clk;
reg reset;


// =====================================================
// DUT
// =====================================================

rv32i_cpu dut (
    .clk(clk),
    .reset(reset)
);


// =====================================================
// Clock
// =====================================================

initial begin

    clk = 1'b0;

    forever #5 clk = ~clk;

end


// =====================================================
// Instruction Encoding Functions
// =====================================================

// I-type

function [31:0] make_i;
    input [11:0] imm;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;

    begin

        make_i =
            {imm, rs1, funct3, rd, opcode};

    end
endfunction


// R-type

function [31:0] make_r;
    input [6:0] funct7;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;

    begin

        make_r =
            {funct7, rs2, rs1, funct3, rd, opcode};

    end
endfunction


// S-type

function [31:0] make_s;
    input [11:0] imm;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [6:0] opcode;

    begin

        make_s =
            {imm[11:5],
             rs2,
             rs1,
             funct3,
             imm[4:0],
             opcode};

    end
endfunction


// B-type

function [31:0] make_b;
    input [12:0] imm;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    input [6:0] opcode;

    begin

        make_b =
            {imm[12],
             imm[10:5],
             rs2,
             rs1,
             funct3,
             imm[4:1],
             imm[11],
             opcode};

    end
endfunction


// U-type

function [31:0] make_u;
    input [19:0] imm;
    input [4:0] rd;
    input [6:0] opcode;

    begin

        make_u =
            {imm, rd, opcode};

    end
endfunction


// J-type

function [31:0] make_j;
    input [20:0] imm;
    input [4:0] rd;
    input [6:0] opcode;

    begin

        make_j =
            {imm[20],
             imm[10:1],
             imm[11],
             imm[19:12],
             rd,
             opcode};

    end
endfunction


// =====================================================
// Program
// =====================================================

 integer i;

initial begin

    reset = 1'b1;

    // Initialize all instruction memory entries to NOP
    for (i = 0; i < 256; i = i + 1) begin
        dut.imem.memory[i] = 32'h00000013;
    end

    // -------------------------------------------------
    // ADDI x1,x0,10
    // -------------------------------------------------

    dut.imem.memory[0] =
        make_i(12'd10, 5'd0, 3'b000,
               5'd1, 7'b0010011);


    // -------------------------------------------------
    // ADDI x2,x0,20
    // -------------------------------------------------

    dut.imem.memory[1] =
        make_i(12'd20, 5'd0, 3'b000,
               5'd2, 7'b0010011);


    // -------------------------------------------------
    // ADD x3,x1,x2
    // -------------------------------------------------

    dut.imem.memory[2] =
        make_r(7'b0000000,
               5'd2,
               5'd1,
               3'b000,
                 5'd3,
               7'b0110011);


    // -------------------------------------------------
    // SUB x4,x3,x1
    // -------------------------------------------------

    dut.imem.memory[3] =
        make_r(7'b0100000,
               5'd1,
               5'd3,
               3'b000,
               5'd4,
               7'b0110011);


    // -------------------------------------------------
    // AND x5,x3,x4
    // -------------------------------------------------

    dut.imem.memory[4] =
        make_r(7'b0000000,
               5'd4,
               5'd3,
               3'b111,
               5'd5,
               7'b0110011);


    // -------------------------------------------------
    // OR x6,x3,x4
    // -------------------------------------------------

    dut.imem.memory[5] =
        make_r(7'b0000000,
               5'd4,
               5'd3,
               3'b110,
               5'd6,
               7'b0110011);


    // -------------------------------------------------
    // XOR x7,x3,x4
    // -------------------------------------------------

    dut.imem.memory[6] =
        make_r(7'b0000000,
               5'd4,
               5'd3,
               3'b100,
               5'd7,
               7'b0110011);


    // -------------------------------------------------
    // SW x3,0(x0)
    // -------------------------------------------------

    dut.imem.memory[7] =
        make_s(12'd0,
               5'd3,
               5'd0,
               3'b010,
               7'b0100011);


    // -------------------------------------------------
    // LW x8,0(x0)
    // -------------------------------------------------

    dut.imem.memory[8] =
        make_i(12'd0,
               5'd0,
               3'b010,
               5'd8,
               7'b0000011);


    // -------------------------------------------------
    // BEQ x8,x3,+8
    // Skip next instruction if equal
    // -------------------------------------------------

    dut.imem.memory[9] =
        make_b(13'd8,
               5'd3,
               5'd8,
               3'b000,
               7'b1100011);


    // -------------------------------------------------
    // ADDI x9,x0,99
    // This should be skipped
    // -------------------------------------------------

    dut.imem.memory[10] =
        make_i(12'd99,
               5'd0,
               3'b000,
               5'd9,
               7'b0010011);


    // -------------------------------------------------
    // ADDI x10,x0,55
    // -------------------------------------------------

    dut.imem.memory[11] =
        make_i(12'd55,
               5'd0,
               3'b000,
               5'd10,
               7'b0010011);


    // Release reset

    #20;

    reset = 1'b0;


    // Run

    #300;

    $display("=================================");
    $display("RV32I CPU TEST COMPLETE");
    $display("=================================");

    $display("x1  = %d", dut.regs.registers[1]);
    $display("x2  = %d", dut.regs.registers[2]);
    $display("x3  = %d", dut.regs.registers[3]);
    $display("x4  = %d", dut.regs.registers[4]);
    $display("x5  = %d", dut.regs.registers[5]);
    $display("x6  = %d", dut.regs.registers[6]);
    $display("x7  = %d", dut.regs.registers[7]);
    $display("x8  = %d", dut.regs.registers[8]);
    $display("x9  = %d", dut.regs.registers[9]);
    $display("x10 = %d", dut.regs.registers[10]);

    $finish;

end

endmodule