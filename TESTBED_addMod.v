`include "PATTERN_addMod.v"
`include "modular.v"
module TESTBED_addMod();

wire clk;
wire [255:0]opA;
wire [255:0]opB;
wire [255:0]opM;
wire [255:0]out_data;

addMod U_addMod
(
	.clk(clk),
	.opA(opA),
	.opB(opB),
	.opM(opM),
	.out_data(out_data)
);


PATTERN U_PATTERN
(
	.clk(clk),
	.opA(opA),
	.opB(opB),
	.opM(opM),
	.out_data(out_data)
);


initial begin
	$fsdbDumpfile("addMod.fsdb");
	$fsdbDumpvars(0,"+mda");
	$fsdbDumpvars();
end




endmodule