module alu (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [3:0] alu_control,

    output reg [31:0] result,
    output wire zero,

    output wire less_signed,
    output wire less_unsigned
);

always @(*) begin

    case (alu_control)

        4'd0: result = A + B;                  // ADD

        4'd1: result = A - B;                  // SUB

        4'd2: result = A & B;                  // AND

        4'd3: result = A | B;                  // OR

        4'd4: result = A ^ B;                  // XOR

        4'd5: result = A << B[4:0];            // SLL

        4'd6: result = A >> B[4:0];            // SRL

        4'd7: result = $signed(A) >>> B[4:0];  // SRA

        4'd8: result =
            ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT

        4'd9: result =
            (A < B) ? 32'd1 : 32'd0;            // SLTU

        default: result = 32'b0;

    endcase

end

assign zero = (result == 32'b0);

assign less_signed =
    ($signed(A) < $signed(B));

assign less_unsigned =
    (A < B);

endmodule 