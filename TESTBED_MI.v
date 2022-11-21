`include "PATTERN_MI.v"
`include "modular.v"

module TESTBED_MI();




wire clk;
wire rst_n;
wire [255:0]opA;
wire [255:0]opM;
wire [255:0]out_data;
wire in_valid;
wire out_valid;

modularInv U_MI
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(opA),
	.opM(opM),
	.out_data(out_data),
	.in_valid(in_valid),
	.out_valid(out_valid)
);


PATTERN_MI U_PATTERN
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(opA),
	.opM(opM),
	.out_data(out_data),
	.in_valid(in_valid),
	.out_valid(out_valid)
);


initial begin
	//$fsdbDumpfile("modularInv.fsdb");
	//$fsdbDumpvars(0,"+mda");
	//$fsdbDumpvars();
end




endmodule