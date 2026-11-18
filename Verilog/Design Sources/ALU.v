
`timescale 1ns / 1ps

module ALU #(parameter N = 32) (
    input [N-1:0] in1, in2,
    input [3:0] aluSel,
    output reg [N-1:0] result,
    output zero
);

wire [31:0] adderB;
wire [31:0] addersum;
wire addercout;

assign adderB = (aluSel == 4'b0110) ? ~in2 + 1'b1 : in2;

RCA32Bit R(
    in1,
    adderB,
    1'b0,
    addersum,
    addercout
);

assign zero = (result == 0);

always @(*) begin
    case (aluSel)
        4'b0010: result = addersum;             // ADD
        4'b0110: result = addersum;             // SUB
        4'b0000: result = in1 & in2;            // AND
        4'b0001: result = in1 | in2;            // OR
        4'b0011: result = in1 ^ in2;            // XOR
        4'b0100: result = in1 << in2[4:0];      // SLL
        4'b0101: result = in1 >> in2[4:0];      // SRL
        4'b0111: result = $signed(in1) >>> in2[4:0]; // SRA
        4'b1000: result = ($signed(in1) < $signed(in2)) ? 32'd1 : 32'd0; // SLT
        4'b1001: result = (in1 < in2) ? 32'd1 : 32'd0; // SLTU

        default: result = 0;
    endcase
end

endmodule
