`include "PATTERN_PM.v"
`include "modular.v"

module TESTBED_PM();




wire clk;
wire rst_n;
wire [255:0]opA;
wire [255:0]opB;
wire [255:0]opM;
wire [255:0]out_data;
wire in_valid;
wire out_valid;

productMod U_PM
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(opA),
	.opB(opB),
	.opM(opM),
	.out_data(out_data),
	.in_valid(in_valid),
	.out_valid(out_valid)
);


PATTERN_PM U_PATTERN_PM
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(opA),
	.opB(opB),
	.opM(opM),
	.out_data(out_data),
	.in_valid(in_valid),
	.out_valid(out_valid)
);


initial begin
	$fsdbDumpfile("pm.fsdb");
	$fsdbDumpvars(0,"+mda");
	$fsdbDumpvars();
end




endmodule