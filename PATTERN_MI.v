`timescale 1ns/10ps
`include "modular.v"
`define CYCLE_TIME 10
`define End_CYCLE  1000000


module PATTERN_MI(
	clk,
	rst_n,
	opA,
	opM,
	out_data,
	in_valid,
	out_valid
);

//---------------------------------------------------------------------
// Input Output Declare
//---------------------------------------------------------------------
output reg	clk, rst_n;
output reg [255:0]	opA, opM;
input [255:0]	out_data;
output reg in_valid;
input out_valid;

//---------------------------------------------------------------------
// Register, parameter declaration
//---------------------------------------------------------------------
integer patcount;
parameter PATNUM = 500;

integer golden_read;
integer i,j,a,gap;

integer counter;
integer curr_cycle, cycles, total_cycles;

reg [255:0] opA_reg;
reg [255:0] opB_reg;
reg [255:0] opM_reg;
reg [255:0] golden_reg;

reg [15:0]clock_cnt;
//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

initial  begin
 #`End_CYCLE ;
 	$display("-----------------------------------------------------\n");
 	$display("Error!!! Somethings' wrong with your code ...!\n");
 	$display("-------------------------FAIL------------------------\n");
 	$display("-----------------------------------------------------\n");
 	$finish;
end

initial begin
	// read file
	golden_read = $fopen("./mi.txt", "r");
	
	// initial signal
	in_valid = 0;
	opA = 'bx;
	opM = 'bx;
	
	// reset task
	reset_task;

	for(patcount=0;patcount<PATNUM;patcount=patcount+1)begin
		load_input;
		input_task;
		check_answer;
	end
	
	$display("Pass");
	$finish;
end

task reset_task ;  begin
	#(20); rst_n = 0;
	#(20);
	if(0)begin
		reset_fail;
	end
	#(20);rst_n = 1;
	#(6); release clk;
end endtask

task reset_fail ; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Oops! Reset is Wrong                						             ");
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask

task load_input; begin
	a = $fscanf(golden_read, "%h\n", opA_reg);
	a = $fscanf(golden_read, "%h\n", opM_reg);
	a = $fscanf(golden_read, "%h\n", golden_reg);
end endtask

task input_task;begin
	@(negedge clk);
	in_valid = 1;
	opA = opA_reg;
	opM = opM_reg;

	@(negedge clk);
	in_valid = 0;
	opA = 'bx;
	opM = 'bx;

end endtask

task check_answer;begin
	// wait out_valid raise
	while(out_valid==0)begin
		@(negedge clk);
	end
	
	// check answer
	if(out_data!==golden_reg)begin
		$display ("----------------------------------------------------------------------------------------------------------------------");
		$display ("                                                  Oops! Your Answer is Wrong                						     ");
		$display ("                                                  [Correct]     %h\n                 					             ",golden_reg);
		$display ("                                                  [Your Answer] %h\n                 						         ",out_data);
		$display ("----------------------------------------------------------------------------------------------------------------------");
		$finish;
	end
	else begin
		$display("\033[1;32mPass \033[1;0mNo. %2d, Answer %h\n",patcount,golden_reg);
	end
end endtask



endmodule