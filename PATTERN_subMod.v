`timescale 1ns/10ps
`include "modular.v"
`define CYCLE_TIME 10



module PATTERN(
	clk,
	opA,
	opB,
	opM,
	out_data
);

//---------------------------------------------------------------------
// Input Output Declare
//---------------------------------------------------------------------
output reg	clk;
output reg [255:0]	opA,opB,opM;
input [255:0]	out_data;

//---------------------------------------------------------------------
// Register, parameter declaration
//---------------------------------------------------------------------
integer patcount;
parameter PATNUM = 10;

integer in_read,out_read;
integer i,j,a,gap;

integer counter;
integer curr_cycle, cycles, total_cycles;


//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

reg [255:0]golden;



initial begin
	
	for(patcount = 0;patcount<PATNUM; patcount++){
		
		@(negedge clk);
		if(out_data!=golden) $display("Error!\n");
	}
	else $display("Pass!!\n");
	$finish;
end


endmodule