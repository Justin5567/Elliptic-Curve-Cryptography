`timescale 1ns/10ps
`include "modular.v"
`define CYCLE_TIME 10
`define End_CYCLE  100000000


module PATTERN_add(
	clk,
	rst_n,
	Px,
	Py,
	Qx,
	Qy,
	Rx,
	Ry,
	in_valid,
	out_valid
);

//---------------------------------------------------------------------
// Input Output Declare
//---------------------------------------------------------------------
output reg	clk, rst_n;
output reg [255:0]	Px, Py, Qx, Qy;
input [255:0]	Rx, Ry;
output reg in_valid;
input out_valid;

//---------------------------------------------------------------------
// Register, parameter declaration
//---------------------------------------------------------------------
integer patcount;
parameter PATNUM = 256;

integer golden_read;
integer i,j,a,gap;

integer counter;
integer curr_cycle, cycles, total_cycles;

reg [255:0] Px_reg;
reg [255:0] Py_reg;
reg [255:0] Qx_reg;
reg [255:0] Qy_reg;
reg [255:0] Rx_reg;
reg [255:0] Ry_reg;


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
	golden_read = $fopen("./add.txt", "r");
	
	// initial signal
	in_valid = 0;
	
	Px = 'bx;
	Py = 'bx;
	Qx = 'bx;
	Qy = 'bx;

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
	a = $fscanf(golden_read, "%h\n", Px_reg );
	a = $fscanf(golden_read, "%h\n", Py_reg );
	a = $fscanf(golden_read, "%h\n", Qx_reg );
	a = $fscanf(golden_read, "%h\n", Qy_reg );
	a = $fscanf(golden_read, "%h\n", Rx_reg );
	a = $fscanf(golden_read, "%h\n", Ry_reg );
	
	
	
end endtask

task input_task;begin
	@(negedge clk);
	in_valid = 1;
	Px = Px_reg;
	Py = Py_reg;
	Qx = Qx_reg;
	Qy = Qy_reg;

	@(negedge clk);
	in_valid = 0;
	Px = 'bx;
	Py = 'bx;
	Qx = 'bx;
	Qy = 'bx;

end endtask

task check_answer;begin
	// wait out_valid raise
	while(out_valid==0)begin
		@(negedge clk);
	end
	
	// check answer
	if(Rx!==Rx_reg || Ry!==Ry_reg)begin
		$display ("----------------------------------------------------------------------------------------------------------------------");
		$display ("                                                  FAIL %2d\n                						                     ",patcount);
		$display ("                                                  Oops! Your Answer is Wrong                						     ");
		$display ("                                                  [Correct Rx]     %h\n                 					             ",Rx_reg);
		$display ("                                                  [Your Answer Rx] %h\n                 						         ",Rx);
		$display ("                                                  [Correct Ry]     %h\n                 					             ",Ry_reg);
		$display ("                                                  [Your Answer Ry] %h\n                 						         ",Ry);
		$display ("----------------------------------------------------------------------------------------------------------------------");
		$finish;
	end
	else begin
		$display("\033[1;32mPass \033[1;0mNo. %2d\n",patcount);
		$display ("                                                  [Your Answer Rx] %h\n                 						         ",Rx);
		$display ("                                                  [Your Answer Ry] %h\n                 						         ",Ry);
		$display ("----------------------------------------------------------------------------------------------------------------------");
	end
end endtask



endmodule