module data_memory (
    input wire clk,

    input wire mem_read,
    input wire mem_write,

    input wire [2:0] funct3,

    input wire [31:0] address,
      
		input wire [31:0] write_data,

    output reg [31:0] read_data
);

reg [7:0] memory [0:4095];

integer i;

always @(posedge clk) begin

    if (mem_write) begin

        case (funct3)

            3'b000: begin
                // SB
                memory[address] <= write_data[7:0];
            end

            3'b001: begin
                // SH
                memory[address]     <= write_data[7:0];
                memory[address + 1] <= write_data[15:8];
            end

            3'b010: begin
                // SW
                memory[address]     <= write_data[7:0];
                memory[address + 1] <= write_data[15:8];
                memory[address + 2] <= write_data[23:16];
                memory[address + 3] <= write_data[31:24];
            end

            default: begin
            end

        endcase

    end

end


always @(*) begin

    read_data = 32'b0;

    if (mem_read) begin

        case (funct3)

            3'b000: begin
                // LB
                read_data = {{24{memory[address][7]}},
                             memory[address]};
            end

            3'b001: begin
                // LH
                read_data = {{16{memory[address + 1][7]}},
                             memory[address + 1],
                             memory[address]};
            end

            3'b010: begin
                // LW
                read_data = {
                    memory[address + 3],
                    memory[address + 2],
                    memory[address + 1],
                    memory[address]
                };
            end

            3'b100: begin
                // LBU
                read_data = {
                    24'b0,
                    memory[address]
                };
            end

            3'b101: begin
                // LHU
                read_data = {
                    16'b0,
                    memory[address + 1],
                    memory[address]
                };
            end

            default:
                read_data = 32'b0;

        endcase

    end

end

endmodule