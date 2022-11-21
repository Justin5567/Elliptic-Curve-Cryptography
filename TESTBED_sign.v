`include "PATTERN_sign.v"
`include "ecc_sign.v"

module TESTBED_sign();




wire clk;
wire rst_n;
wire [255:0]hash;
wire [255:0]k;
wire [255:0]privateKey;
wire [255:0]r;
wire [255:0]s;
wire in_valid;
wire out_valid;
wire fail;

ecc_sign U_ecc_sign
(
	.clk(clk),
	.rst_n(rst_n),
	.hash(hash),
	.k(k),
	.privateKey(privateKey),
	.r(r),
	.s(s),
	.in_valid(in_valid),
	.out_valid(out_valid),
	.fail(fail)
);


PATTERN_sign U_PATTERN
(
	.clk(clk),
	.rst_n(rst_n),
	.hash(hash),
	.k(k),
	.privateKey(privateKey),
	.r(r),
	.s(s),
	.in_valid(in_valid),
	.out_valid(out_valid),
	.fail(fail)
);


initial begin
	$fsdbDumpfile("sign.fsdb");
	$fsdbDumpvars(0,"+mda");
	$fsdbDumpvars();
end




endmodule