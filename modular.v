module addMod
(
	clk,
	opA,
	opB,
	opM,
	out_data
);
input clk;
input [255:0] opA;
input [255:0] opB;
input [255:0] opM;
output [255:0]out_data;

wire [256:0]tmp_out_data;

assign tmp_out_data = opA + opB;
assign out_data = (tmp_out_data>=opM)?tmp_out_data-opM:tmp_out_data;

endmodule

// verified
module productMod
(
	clk,
	rst_n,
	opA,
	opB,
	opM,
	out_data,
	in_valid,
	out_valid
);
// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input [255:0] opA;
input [255:0] opB;
input [255:0] opM;
input in_valid;
output reg out_valid;
output reg [255:0] out_data;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter IDLE 		= 3'd0;
parameter STAGE_1 	= 3'd1;
parameter COMPARE 	= 3'd2;
parameter STAGE_2 	= 3'd3;
parameter DONE 		= 3'd4;

//================================================================
// Wire & Reg Declaration
//================================================================
reg [2:0] state_cs, state_ns;
reg [7:0] cnt;

reg [256:0] compare_reg;

reg [255:0] opA_reg;
reg [255:0] opB_reg;
reg [255:0] opM_reg;

wire all_done;

assign all_done = cnt==255;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_cs<=IDLE;
	else 
		state_cs<=state_ns;
end

always@(*)begin
	case(state_cs)
		IDLE:    state_ns = (in_valid)?STAGE_1:IDLE;
		STAGE_1: state_ns = COMPARE;
		COMPARE: state_ns = STAGE_2;
		STAGE_2: state_ns = (all_done)?DONE:STAGE_1;
		DONE: 	 state_ns = IDLE;
	endcase
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt<=0;
	else if(state_ns==IDLE)
		cnt<=0;
	else if(state_cs==STAGE_2 && state_ns==STAGE_1)
		cnt<=cnt+1;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		opA_reg<=0;
		opB_reg<=0;
		opM_reg<=0;
	end
	else if(state_ns==IDLE)begin
		opA_reg<=0;
		opB_reg<=0;
		opM_reg<=0;
	end
	else if(in_valid)begin
		opA_reg<=opA;
		opB_reg<=opB;
		opM_reg<=opM;
	end
end



wire [256:0]compare_shift = {compare_reg[255:0],1'b0};

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		compare_reg<=0;
	else if(state_ns==IDLE)
		compare_reg<=0;
	else if(state_ns==STAGE_1)begin
		if(compare_shift>opM_reg)begin
			compare_reg<=compare_shift-opM_reg;
		end
		else begin
			compare_reg<=compare_shift;
		end
	end
	else if(state_ns==COMPARE)begin
		if(opB_reg[255-cnt])begin
			compare_reg<=compare_reg+opA_reg;
		end
	end
	else if(state_ns==STAGE_2)begin
		if(compare_reg>opM_reg)begin
			compare_reg<=compare_reg-opM_reg;
		end
	end
end



// output signal
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_data<=0;
		out_valid<=0;
	end
	else if(state_ns==IDLE)begin
		out_data<=0;
		out_valid<=0;
	end
	else if(state_ns==DONE)begin
		out_data<=compare_reg[255:0];
		out_valid<=1;
	end
end


endmodule


module subMod
(
	clk,
	opA,
	opB,
	opM,
	out_data,
);
// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input [255:0] opA;
input [255:0] opB;
input [255:0] opM;
output reg[255:0] out_data;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================

//================================================================
// Wire & Reg Declaration
//================================================================
reg [256:0] sum;

wire larger;

assign larger = opA>opB;
//================================================================
// DESIGN
//================================================================
always@(*)begin
	if(larger)begin
		sum = opA - opB;
	end
	else begin
		sum = opA + opM;
	end
end

always@(*)begin
	if(larger)begin
		out_data<=sum;
	end
	else begin
		out_data<=sum - opB;
	end
end


endmodule

module modularInv
(
	clk,
	rst_n,
	opA,
	opM,
	in_valid,
	out_valid,
	out_data
);
// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input [255:0] opA;
input [255:0] opM;
input in_valid;
output reg out_valid;
output reg [255:0]out_data;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter IDLE 		= 4'd0;
parameter RD		= 4'd1;
parameter IDLE2 	= 4'd2;
parameter STAGE_1	= 4'd3;
parameter IDLE3 	= 4'd4;
parameter CHECK_R	= 4'd5;
parameter STAGE_2 	= 4'd6;
parameter IDLE4		= 4'd7;
parameter STAGE_3 	= 4'd8;
parameter IDLE5		= 4'd9;
parameter STAGE_4 	= 4'd10;
parameter IDLE6 	= 4'd11;
parameter DONE 		= 4'd12;
//================================================================
// Wire & Reg Declaration
//================================================================
reg [3:0] state_cs,state_ns;
reg [255:0] u;
reg [255:0] v;
reg [255:0] s;
reg [256:0] r;
reg [31:0] k;
reg [9:0] cnt;
reg [255:0] opM_reg;

wire mp_in_valid;
wire mp_out_valid;
wire [255:0]mp_out_data;

assign mp_in_valid = (state_cs==IDLE5 && state_ns==STAGE_4)?1:0;


wire done_stage1;
wire done_stage3;


assign done_stage1 = v==0;
assign done_stage3 = cnt==k;
//================================================================
// DESIGN
//================================================================
monProduct mp1(	.clk(clk), 
				.rst_n(rst_n),
				.opA(r[255:0]),
				.opB(256'b1),
				.opM(opM_reg),
				.in_valid(mp_in_valid),
				.out_valid(mp_out_valid),
				.out_data(mp_out_data));

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_cs<=IDLE;
	else 
		state_cs<=state_ns;
end

always@(*)begin
	case(state_cs)
		IDLE:	state_ns = (in_valid)?RD:IDLE;
		RD:		state_ns = IDLE2;
		IDLE2: 	state_ns = (done_stage1)?IDLE3:STAGE_1;
		STAGE_1:state_ns = IDLE2;
		IDLE3:	state_ns = CHECK_R;
		CHECK_R:state_ns = STAGE_2;
		STAGE_2:state_ns = IDLE4;
		IDLE4:	state_ns = STAGE_3;
		STAGE_3:state_ns = (done_stage3)?IDLE5:STAGE_3;
		IDLE5:	state_ns = STAGE_4;
		STAGE_4: state_ns = (mp_out_valid)?DONE:STAGE_4;
		DONE:	state_ns = IDLE;
	endcase
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt<=0;
	else if(state_ns==IDLE)
		cnt<=0;
	else if(state_ns==STAGE_3)
		cnt<=cnt+1;
end

reg [255:0] tmp_u;
reg [255:0] tmp_v;
reg [256:0] tmp_r;
always@(*)begin
	if(state_ns==STAGE_1)begin
		tmp_u = u - v;
		tmp_v = v - u;
	end
	else begin
		tmp_u = 0;
		tmp_v = 0;
	end
end

always@(*)begin
	if(state_ns==STAGE_3)begin
		tmp_r = r + opM_reg;
	end
	else begin
		tmp_r = 0 ;
	end	
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		opM_reg<=0;
	else if(state_ns==IDLE)
		opM_reg<=0;
	else if(state_ns==RD)
		opM_reg<=opM;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		u <= 0;
		v <= 0;
		s <= 0;
		r <= 0;
		k <= 0;
	end
	else if(state_ns==RD)begin
		u <= opM;
		v <= opA;
		s <= 1;
		r <= 0;
		k <= 0;
	end
	else if(state_ns==STAGE_1)begin
		if(u[0]==0)begin
			u <= u >> 1;
			s <= s << 1;
		end
		else if(v[0]==0)begin
			v <= v >> 1;
			r <= r << 1;
		end
		else if(u>v)begin
			u <= tmp_u>>1;
			r <= r + s;
			s <= s << 1;
		end
		else begin
			v <= tmp_v >> 1;
			s <= s + r;
			r <= r << 1;
		end
		k <= k + 1;
	end
	else if(state_ns == CHECK_R)begin
		if(r >= opM_reg)begin
			r <= r - opM_reg;
		end
	end
	else if(state_ns == STAGE_2)begin
		r <= opM_reg - r;
		k <= k - 256;
	end
	else if(state_ns == STAGE_3)begin
		if(r[0] == 1)begin
			r <= tmp_r >> 1;
		end
		else begin
			r <= r>>1;
		end
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_valid<=0;
		out_data<=0;
	end
	else if(state_ns==IDLE)begin
		out_valid<=0;
		out_data<=0;
	end	
	else if(state_ns==DONE)begin
		out_valid<=1;
		out_data<=mp_out_data;
	end
end


endmodule

module monProduct
(
	clk,
	rst_n,
	opA,
	opB,
	opM,
	out_data,
	in_valid,
	out_valid
);
// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input [255:0] opA;
input [255:0] opB;
input [255:0] opM;
input in_valid;
output reg [255:0] out_data;
output reg out_valid;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter IDLE = 3'd0;
parameter INPUT = 3'd1;
parameter OP1= 3'd2;
parameter OP2= 3'd3;
parameter DONE = 3'd4;
//================================================================
// Wire & Reg Declaration
//================================================================
reg [2:0] state_cs,state_ns;
reg [8:0] cnt;
wire done_op;

//input register
reg [255:0] opA_reg;
reg [255:0] opB_reg;
reg [255:0] opM_reg;

wire a0 ;
wire qa ;
wire qm ;
wire [255:0]addA = (qa==1'b1)?opA_reg:0;
wire [255:0]addM = (qm==1'b1)?opM_reg:0;
reg [257:0]s;
wire [257:0]tmp_s;
wire [257:0]tmp_ss;

assign a0 = opA_reg[0];
assign qa = opB_reg[cnt];
assign qm = s[0]^(opB_reg[cnt] & a0);


assign tmp_s = s+ addA + addM;
assign tmp_ss = tmp_s>>1;
assign done_op = cnt==256;
//================================================================
// DESIGN
//================================================================

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_cs<=IDLE;
	else
		state_cs<=state_ns;
end

always@(*)begin
	case(state_cs)
		IDLE:	state_ns = (in_valid)?INPUT:IDLE;
		INPUT:	state_ns = OP1;
		OP1:	state_ns=(done_op)?OP2:OP1;
		OP2:	state_ns=DONE;
		DONE:	state_ns=IDLE;
	endcase
end

always@(posedge clk or  negedge rst_n)begin
	if(!rst_n)
		s<=0;
	else if(state_ns==IDLE)
		s<=0;
	else if(state_ns==OP2)begin
		if(s>opM_reg)
			s<=s-opM_reg;
	end
	else if(state_ns==OP1)
		s<=tmp_ss;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt<=0;
	else if(state_ns==IDLE)
		cnt<=0;
	else if(state_ns==OP1)
		cnt<=cnt+1;
end

//input
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		opA_reg<=0;
		opB_reg<=0;
		opM_reg<=0;
	end
	else if(state_ns==IDLE)begin
		opA_reg<=0;
		opB_reg<=0;
		opM_reg<=0;
	end
	else if(state_ns==INPUT)begin
		opA_reg<=opA;
		opB_reg<=opB;
		opM_reg<=opM;
	end
	
end

//output
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_data<=0;
		out_valid<=0;
	end
	else if(state_ns==DONE)begin
		out_data<=s;
		out_valid<=1;
	end
	else begin
		out_data<=0;
		out_valid<=0;
	end
end

endmodule


/*
module
(

);
// ===============================================================
// Input & Output Declaration
// ===============================================================

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================

//================================================================
// Wire & Reg Declaration
//================================================================

//================================================================
// DESIGN
//================================================================

endmodule
*/