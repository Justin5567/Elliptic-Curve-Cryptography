`timescale 1ns/10ps
//`include "ecc_sign.v"
`define CYCLE_TIME 10
`define End_CYCLE  30000000


module PATTERN_sign(
	clk,
	rst_n,
	hash,
	k,
	privateKey,
	r,
	s,
	in_valid,
	out_valid,
	fail
);

//---------------------------------------------------------------------
// Input Output Declare
//---------------------------------------------------------------------
output reg	clk, rst_n;
output reg [255:0]	hash, k, privateKey;
input [255:0]	r, s;
output reg in_valid;
input out_valid;
input fail;
//---------------------------------------------------------------------
// Register, parameter declaration
//---------------------------------------------------------------------
integer patcount;
parameter PATNUM = 1;

integer golden_read;
integer i,j,a,gap;

integer counter;
integer curr_cycle, cycles, total_cycles;

reg [255:0] hash_reg;
reg [255:0] k_reg;
reg [255:0] privateKey_reg;
reg [255:0] r_reg;
reg [255:0] s_reg;


reg [31:0] clock;
//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		clock<=0;
	else
		clock<=clock+1;
end

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
	golden_read = $fopen("./sign.txt", "r");
	
	// initial signal
	in_valid = 0;
	
	hash = 'bx;
	k = 'bx;
	privateKey = 'bx;

	// reset task
	reset_task;

	for(patcount=0;patcount<PATNUM;patcount=patcount+1)begin
		load_input;
		//if(1)begin
		input_task;
		check_answer;
		@(negedge clk);
		//end
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
	a = $fscanf(golden_read, "%h\n", hash_reg );
	a = $fscanf(golden_read, "%h\n", k_reg );
	a = $fscanf(golden_read, "%h\n", privateKey_reg );
	a = $fscanf(golden_read, "%h\n", r_reg );
	a = $fscanf(golden_read, "%h\n", s_reg );
	
	
	
end endtask

task input_task;begin
	@(negedge clk);
	in_valid = 1;
	hash = hash_reg;
	k = k_reg;
	privateKey = privateKey_reg;


	@(negedge clk);
	in_valid = 0;
	hash = 'bx;
	k = 'bx;
	privateKey = 'bx;

end endtask

task check_answer;begin
	// wait out_valid raise
	while(out_valid==0)begin
		@(negedge clk);
	end
	
	// check answer
	if(r!==r_reg || s!==s_reg)begin
		$display ("----------------------------------------------------------------------");
		$display ("  FAIL %2d\n                						                     ",patcount);
		$display ("  Oops! Your Answer is Wrong                						     ");
		$display ("  [Correct r]     %h\n                 					             ",r_reg);
		$display ("  [Your Answer r] %h\n                 						         ",r);
		$display ("  [Correct s]     %h\n                 					             ",s_reg);
		$display ("  [Your Answer s] %h\n                 						         ",s);
		$display ("--------------------------------------------------------------------- ");
		$finish;
	end
	else begin
		$display("\033[1;32mPass \033[1;0mNo. %2d\n",patcount);
		$display ("  [Your Answer Rx] %h\n                 						         ",r);
		$display ("  [Your Answer Ry] %h\n                 						         ",s);
		$display ("----------------------------------------------------------------------");
	end
end endtask



endmodule