`include "modular.v"
module add
(
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

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input [255:0] Px;
input [255:0] Py;
input [255:0] Qx;
input [255:0] Qy;
output reg [255:0] Rx;
output reg [255:0] Ry;
input in_valid;
output reg out_valid;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter IDLE  = 5'd0;
parameter RD 	= 5'd1;
parameter SET	= 5'd2;
parameter STAGE_1_IDLE = 5'd3;
parameter STAGE_1_1_1 = 5'd4;
parameter STAGE_1_1_IDLE2 = 5'd18;
parameter STAGE_1_1_2 = 5'd5;
parameter STAGE_1_1_IDLE3 = 5'd19;
parameter STAGE_1_1_3 = 5'd6;
parameter STAGE_1_2_1 = 5'd7;
parameter STAGE_1_2_2 = 5'd29;
parameter STAGE_1_12_DONE = 5'd20;
parameter MI	= 5'd8;
parameter MI_DONE = 5'd21;
parameter PM	= 5'd9;
parameter PM_DONE = 5'd22;
parameter PM2	= 5'd10;
parameter PM2_DONE = 5'd23;
parameter SM1	= 5'd11;
parameter SM1_DONE = 5'd24;
parameter SM2	= 5'd12;
parameter SM2_DONE = 5'd25;
parameter SM3 	= 5'd13;
parameter SM3_DONE = 5'd26;
parameter PM3	= 5'd14;
parameter PM3_DONE = 5'd27;
parameter SM4	= 5'd15;
parameter SM4_DONE = 5'd28;
parameter DONE 	= 5'd17;

parameter p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

//================================================================
// Wire & Reg Declaration
//================================================================
reg [4:0] state_cs, state_ns;

reg [255:0] Px_reg;
reg [255:0] Py_reg;
reg [255:0] Qx_reg;
reg [255:0] Qy_reg;

// lamda
reg [255:0] lamda;
reg [255:0] lamda_d;


//productMod signal
reg [255:0] pm_opA;
reg [255:0] pm_opB;
reg [255:0] pm_opM;
wire [255:0] pm_out_data;
wire pm_in_valid;
wire pm_out_valid;
//addMod signal
reg [255:0] am_opA;
reg [255:0] am_opB;
reg [255:0] am_opM;
wire [255:0] am_out_data;
//subMod signal
reg [255:0] sm_opA;
reg [255:0] sm_opB;
reg [255:0] sm_opM;
wire [255:0] sm_out_data;
//modularInv signal
reg [255:0] mi_opA;
reg [255:0] mi_opM;
wire [255:0] mi_out_data;
wire mi_in_valid;
wire mi_out_valid;

//================================================================
// DESIGN
//================================================================

// soft module
productMod pm
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(pm_opA),
	.opB(pm_opB),
	.opM(pm_opM),
	.out_data(pm_out_data),
	.in_valid(pm_in_valid),
	.out_valid(pm_out_valid)
);

addMod am
(
	.clk(clk),
	.opA(am_opA),
	.opB(am_opB),
	.opM(am_opM),
	.out_data(am_out_data)
);

subMod sm
(
	.clk(clk),
	.opA(sm_opA),
	.opB(sm_opB),
	.opM(sm_opM),
	.out_data(sm_out_data)

);

modularInv mi
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(mi_opA),
	.opM(mi_opM),
	.in_valid(mi_in_valid),
	.out_valid(mi_out_valid),
	.out_data(mi_out_data)
);

assign mi_in_valid = (state_cs==STAGE_1_12_DONE && state_ns==MI);

assign pm_in_valid = (state_cs==STAGE_1_IDLE &&state_ns==STAGE_1_1_1)
					||(state_cs==STAGE_1_1_IDLE2 &&state_ns==STAGE_1_1_2)
					||(state_cs==STAGE_1_1_IDLE3 &&state_ns==STAGE_1_1_3)
					||(state_cs==MI_DONE && state_ns==PM)
					||(state_cs==PM_DONE && state_ns==PM2)
					||(state_cs==SM3_DONE && state_ns==PM3);

always@(*)begin
	if(pm_in_valid)begin
		if(state_cs==STAGE_1_IDLE &&state_ns==STAGE_1_1_1)begin
			pm_opA = Px_reg;
			pm_opB = Px_reg;
			pm_opM = p;
		end
		else if(state_cs==STAGE_1_1_IDLE2 &&state_ns==STAGE_1_1_2)begin
			pm_opA = lamda;
			pm_opB = 3;
			pm_opM = p;
		end
		else if(state_cs==STAGE_1_1_IDLE3 &&state_ns==STAGE_1_1_3)begin
			pm_opA = Py_reg;
			pm_opB = 2;
			pm_opM = p;
		end
		else if(state_cs==MI_DONE && state_ns==PM)begin
			pm_opA = lamda;
			pm_opB = lamda_d;
			pm_opM = p;
		end
		else if(state_cs==PM_DONE && state_ns==PM2)begin
			pm_opA = lamda;
			pm_opB = lamda;
			pm_opM = p;
		end
		else if(state_cs==SM3_DONE && state_ns==PM3)begin
			pm_opA = lamda;
			pm_opB = Ry;
			pm_opM = p;
		end
		else begin
			pm_opA = 0;
			pm_opB = 0;
			pm_opM = 0;
		end
	end
	else begin
		pm_opA = 0;
		pm_opB = 0;
		pm_opM = 0;
	end
end

always@(*)begin
	if(mi_in_valid)begin
		mi_opA=lamda_d;
		mi_opM=p;
	end
	else begin
		mi_opA=0;
		mi_opM=0;
	end
end

always@(*)begin
	if(state_ns==STAGE_1_1_3)begin
		am_opA=lamda;
		am_opB=0;
		am_opM=p;
	end
	else begin
		am_opA=0;
		am_opB=0;
		am_opM=0;
	end
end

always@(*)begin
	if(state_ns==STAGE_1_2_1)begin
		sm_opA = Qy_reg;
		sm_opB = Py_reg;
		sm_opM = p;
	end
	else if(state_ns==STAGE_1_2_2)begin
		sm_opA = Qx_reg;
		sm_opB = Px_reg;
		sm_opM = p;
	end
	else if(state_ns==SM1)begin
		sm_opA = lamda_d;
		sm_opB = Px_reg;
		sm_opM = p;
	end
	else if(state_ns==SM2)begin
		sm_opA = Rx;
		sm_opB = Qx_reg;
		sm_opM = p;
	end
	else if(state_ns==SM3)begin
		sm_opA = Px_reg;
		sm_opB = Rx;
		sm_opM = p;
	end
	else if(state_ns==SM4)begin
		sm_opA = Ry;
		sm_opB = Py_reg;
		sm_opM = p;
	end
	else begin
		sm_opA = 0;
		sm_opB = 0;
		sm_opM = 0;
	end
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_cs<=IDLE;
	else
		state_cs<=state_ns;
end

wire case1 = (Qx_reg==0 && Qy_reg==0);
wire case2 = (Px_reg == Qx_reg && (Py_reg+Qy_reg)== p);

always@(*)begin
	case(state_cs)
		IDLE:			state_ns = (in_valid)?RD:IDLE;
		RD:				state_ns = SET;
		SET: begin
			if(case1)
				state_ns = DONE;
			else if(case2)
				state_ns = DONE;
			else
				state_ns = STAGE_1_IDLE;
		end
		STAGE_1_IDLE: 	state_ns = (Px_reg==Qx_reg && Py_reg == Qy_reg)?STAGE_1_1_1:STAGE_1_2_1;
		STAGE_1_1_1:	state_ns = (pm_out_valid)?STAGE_1_1_IDLE2:STAGE_1_1_1;
		STAGE_1_1_IDLE2:state_ns = STAGE_1_1_2;
		STAGE_1_1_2:	state_ns = (pm_out_valid)?STAGE_1_1_IDLE3:STAGE_1_1_2;
		STAGE_1_1_IDLE3:state_ns = STAGE_1_1_3;
		STAGE_1_1_3:	state_ns = (pm_out_valid)?STAGE_1_12_DONE:STAGE_1_1_3;
		STAGE_1_2_1: 	state_ns = STAGE_1_2_2;
		STAGE_1_2_2:	state_ns = STAGE_1_12_DONE;
		STAGE_1_12_DONE:state_ns = MI;
		MI:			 	state_ns = (mi_out_valid)?MI_DONE:MI;
		MI_DONE:		state_ns = PM;
		PM:				state_ns = (pm_out_valid)?PM_DONE:PM;
		PM_DONE:		state_ns = PM2;
		PM2:			state_ns = (pm_out_valid)?PM2_DONE:PM2;
		PM2_DONE:		state_ns = SM1;
		SM1:			state_ns = SM1_DONE;
		SM1_DONE:		state_ns = SM2;
		SM2:			state_ns = SM2_DONE;
		SM2_DONE:		state_ns = SM3;
		SM3:			state_ns = SM3_DONE;
		SM3_DONE:		state_ns = PM3;
		PM3:			state_ns = (pm_out_valid)?PM3_DONE:PM3;
		PM3_DONE:		state_ns = SM4;
		SM4:			state_ns = SM4_DONE;
		SM4_DONE:		state_ns = DONE;
		DONE:			state_ns = IDLE;
	endcase
end



always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		Px_reg<=0;
	else if(state_ns==RD)
		Px_reg<=Px;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		Py_reg<=0;
	else if(state_ns==RD)
		Py_reg<=Py;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		Qx_reg<=0;
	else if(state_ns==RD)
		Qx_reg<=Qx;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		Qy_reg<=0;
	else if(state_ns==RD)
		Qy_reg<=Qy;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		out_valid<=0;
	else if(state_ns==IDLE)
		out_valid<=0;
	else if(state_ns==DONE)
		out_valid<=1;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		lamda<=0;
	else if(state_ns==IDLE)
		lamda<=0;
	else if(state_ns==STAGE_1_1_IDLE2 || state_ns==STAGE_1_1_IDLE3 || state_ns==PM_DONE)
		lamda<=pm_out_data;
	else if(state_ns==STAGE_1_1_3)
		lamda<=am_out_data;
	else if(state_ns==STAGE_1_2_1)
		lamda<=sm_out_data;
	
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		lamda_d<=0;
	else if(state_ns==IDLE)
		lamda_d<=0;
	else if(state_ns==PM2_DONE)
		lamda_d<=pm_out_data; //lamda_sqr
	else if(state_cs==STAGE_1_1_3 && state_ns==STAGE_1_12_DONE)
		lamda_d<=pm_out_data;
	else if(state_ns==STAGE_1_2_2)
		lamda_d<=sm_out_data;	
	else if(state_ns==MI_DONE)
		lamda_d<=mi_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		Rx<=0;
	else if(state_ns==IDLE)
		Rx<=0;
	else if(state_cs==SET && state_ns==DONE)begin
		if(case1)
			Rx<=Px;
		else
			Rx<=0;
	end
	else if(state_ns==SM1 || state_ns==SM2)
		Rx<=sm_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		Ry<=0;
	else if(state_ns==IDLE)
		Ry<=0;
	else if(state_cs==SET && state_ns==DONE)begin
		if(case1)
			Ry<=Py;
		else
			Ry<=0;
	end
	else if(state_ns==PM3_DONE)
		Ry<=pm_out_data;
	else if(state_ns==SM3 || state_ns==SM4)
		Ry<=sm_out_data;
end

endmodule