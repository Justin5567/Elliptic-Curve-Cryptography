`include "PATTERN_verify.v"
`include "ecc_verify.v"

module TESTBED_verify();




wire clk;
wire rst_n;
wire [255:0]r;
wire [255:0]s;
wire [255:0]hash;
wire [255:0]Px;
wire [255:0]Py;
wire in_valid;
wire out_valid;
wire fail;

ecc_verify U_ecc_verify
(
	.clk(clk),
	.rst_n(rst_n),
	.r(r),
	.s(s),
	.hash(hash),
	.Px(Px),
	.Py(Py),
	.in_valid(in_valid),
	.out_valid(out_valid),
	.fail(fail)
);


PATTERN_verify U_PATTERN
(
	.clk(clk),
	.rst_n(rst_n),
	.r(r),
	.s(s),
	.hash(hash),
	.Px(Px),
	.Py(Py),
	.in_valid(in_valid),
	.out_valid(out_valid),
	.fail(fail)
);


initial begin
	$fsdbDumpfile("verify.fsdb");
	$fsdbDumpvars(0,"+mda");
	$fsdbDumpvars();
end




endmodule