`include "PATTERN_add.v"
`include "add.v"
`include "modular.v"
module TESTBED_add();




wire clk;
wire rst_n;
wire [255:0]Px;
wire [255:0]Py;
wire [255:0]Qx;
wire [255:0]Qy;
wire [255:0]Rx;
wire [255:0]Ry;
wire in_valid;
wire out_valid;

add U_add
(
	.clk(clk),
	.rst_n(rst_n),
	.Px(Px),
	.Py(Py),
	.Qx(Qx),
	.Qy(Qy),
	.Rx(Rx),
	.Ry(Ry),
	.in_valid(in_valid),
	.out_valid(out_valid)
);


PATTERN_add U_PATTERN
(
	.clk(clk),
	.rst_n(rst_n),
	.Px(Px),
	.Py(Py),
	.Qx(Qx),
	.Qy(Qy),
	.Rx(Rx),
	.Ry(Ry),
	.in_valid(in_valid),
	.out_valid(out_valid)
);


initial begin
	//$fsdbDumpfile("add.fsdb");
	//$fsdbDumpvars(0,"+mda");
	//$fsdbDumpvars();
end




endmodule