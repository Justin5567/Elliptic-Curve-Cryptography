





module ecc_verify
(
	clk,
	rst_n,
	r,
	s,
	hash,
	Px,
	Py,
	in_valid,
	out_valid,
	fail
);


// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input [255:0] r;
input [255:0] s;
input [255:0] hash;
input [255:0] Px;
input [255:0] Py;
input in_valid;
output reg out_valid;
output reg fail;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter IDLE  	= 6'd0;
parameter RD 		= 6'd1;
parameter IDLE2 	= 6'd2;
parameter CHECK 	= 6'd3;
parameter IDLE3 	= 6'd4;
parameter PM		= 6'd5;  // do tx1 and tx2
parameter PM_DONE 	= 6'd6;
parameter PM2		= 6'd7;
parameter PM2_DONE 	= 6'd8;
parameter AM		= 6'd9;
parameter AM_DONE 	= 6'd10;
parameter PM3		= 6'd11;
parameter PM3_DONE 	= 6'd12;
parameter CHECK2	= 6'd13;
parameter IDLE4		= 6'd14;
parameter DP		= 6'd15;
parameter DP_DONE	= 6'd16; // check if equal zero
parameter CHECK3	= 6'd32;
parameter IDLE5		= 6'd33;
parameter MODIFY	= 6'd17;
parameter IDLE6		= 6'd34;
parameter MI		= 6'd18;
parameter MI_DONE 	= 6'd19;
parameter PM4		= 6'd20;
parameter PM4_DONE	= 6'd21;
parameter PM5		= 6'd22;
parameter PM5_DONE 	= 6'd23;
parameter DP2		= 6'd24;
parameter DP2_DONE 	= 6'd25;
parameter DP3		= 6'd26;
parameter DP3_DONE 	= 6'd27;
parameter ADD		= 6'd28;
parameter VERIFY	= 6'd29;
parameter DONE		= 6'd30;
parameter FAIL		= 6'd31;

//Gx Gy
parameter Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
parameter Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
// n
parameter n =  256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
// p
parameter p =  256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

// curve parameter
parameter a =  256'h0000000000000000000000000000000000000000000000000000000000000000;
parameter b =  256'h0000000000000000000000000000000000000000000000000000000000000007;
//================================================================
// Wire & Reg Declaration
//================================================================
reg [5:0] state_cs, state_ns;

reg [255:0] r_reg, s_reg, hash_reg, Px_reg, Py_reg;


reg [255:0] tx1,tx2,tx3,ty;
reg [255:0] z;
reg [255:0] sInv,u1,u2,t1x,t1y,t2x,t2y,x,y;
reg [255:0] nPx,nPy;

// check signal
reg [255:0] tmp_z;
wire tmp_z_valid;
assign tmp_z_valid = z>=n;
always@(*)begin
	if(state_ns==CHECK)begin
		if(tmp_z_valid)
			tmp_z = z - n;
	end
	else begin
		tmp_z = 0;
	end
end
// submodule signal

//dp
reg [255:0] dp_Px;
reg [255:0] dp_Py;
reg [255:0] dp_k;
wire [255:0] dp_Rx;
wire [255:0] dp_Ry;
reg dp_in_valid;
wire dp_out_valid;
//add
reg 	[255:0] add_Px;
reg 	[255:0] add_Py;
reg 	[255:0] add_Qx;
reg 	[255:0] add_Qy;
wire 	[255:0] add_Rx;
wire 	[255:0] add_Ry;
reg 		    add_in_valid;
wire 		    add_out_valid;
//am
reg [255:0] am_opA;
reg [255:0] am_opB;
reg [255:0] am_opM;
wire [255:0] am_out_data;
//mi
reg [255:0] mi_opA;
reg [255:0] mi_opM;
reg mi_in_valid;
wire mi_out_valid;
wire [255:0] mi_out_data;
//pm1
reg [255:0] pm1_opA;
reg [255:0] pm1_opB;
reg [255:0] pm1_opM;
reg pm1_in_valid;
wire pm1_out_valid;
wire [255:0]pm1_out_data;
reg pm1_flag;
//pm2
reg [255:0] pm2_opA;
reg [255:0] pm2_opB;
reg [255:0] pm2_opM;
reg pm2_in_valid;
wire pm2_out_valid;
wire [255:0]pm2_out_data;
reg pm2_flag;

// fsm check signal
reg check_fail;
reg check2_fail;
reg check3_fail;
assign check_fail = 0;
always@(*)begin
	if(state_ns==CHECK2 && ty!=tx3)
		check2_fail = 1;
	else
		check2_fail = 0;
end
always@(*)begin
	if(state_ns==CHECK3 && (nPx!=0 || nPy!=0 || r==0 || r>=n || s==0 || s>=n))
		check2_fail = 1;
	else
		check2_fail = 0;
end
//================================================================
// DESIGN
//================================================================

// submodule
dotProduct dp_verify
(
	.clk(clk),
	.rst_n(rst_n),
	.Px(dp_Px),
	.Py(dp_Py),
	.k(dp_k),
	.Rx(dp_Rx),
	.Ry(dp_Ry),
	.in_valid(dp_in_valid),
	.out_valid(dp_out_valid)
);

productMod pm1_verify
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(pm1_opA),
	.opB(pm1_opB),
	.opM(pm1_opM),
	.out_data(pm1_out_data),
	.in_valid(pm1_in_valid),
	.out_valid(pm1_out_valid)
);

productMod pm2_verify
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(pm2_opA),
	.opB(pm2_opB),
	.opM(pm2_opM),
	.out_data(pm2_out_data),
	.in_valid(pm2_in_valid),
	.out_valid(pm2_out_valid)
);

addMod am_verify
(
	.clk(clk),
	.opA(am_opA),
	.opB(am_opB),
	.opM(am_opM),
	.out_data(am_out_data)
);

modularInv mi_verify
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(mi_opA),
	.opM(mi_opM),
	.in_valid(mi_in_valid),
	.out_valid(mi_out_valid),
	.out_data(mi_out_data)
);

// submodule control signal




always@(*)begin
	if(state_cs==IDLE3 && state_ns==PM)begin
		pm1_in_valid = 1;
		pm1_opA = Px_reg;
		pm1_opB = Px_reg;
		pm1_opM = p;
	end
	else if(state_cs==PM_DONE && state_ns==PM2)begin
		pm1_in_valid = 1;
		pm1_opA = tx1;
		pm1_opB = Px_reg;
		pm1_opM = p;
	end
	else if(state_cs==AM_DONE && state_ns==PM3)begin
		pm1_in_valid = 1;
		pm1_opA = Py_reg;
		pm1_opB = Py_reg;
		pm1_opM = p;
	end
	else if(state_cs==MI_DONE && state_ns==PM4)begin
		pm1_in_valid = 1;
		pm1_opA = sInv;
		pm1_opB = z;
		pm1_opM = n;
	end
	else begin
		pm1_in_valid = 0;
		pm1_opA = 0;
		pm1_opB = 0;
		pm1_opM = 0;
	end
end

always@(*)begin
	if(state_cs==IDLE3 && state_ns==PM)begin
		pm2_in_valid = 1;
		pm2_opA = Px_reg;
		pm2_opB = a;
		pm2_opM = p;
	end
	else if(state_cs==MI_DONE && state_ns==PM4)begin
		pm2_in_valid = 1;
		pm2_opA = sInv;
		pm2_opB = r;
		pm2_opM = n;
	end
	else begin
		pm2_in_valid = 0;
		pm2_opA = 0;
		pm2_opB = 0;
		pm2_opM = 0;
	end
end

always@(*)begin
	if(state_cs==PM2_DONE && state_ns==AM)begin
		am_opA = tx2;
		am_opB = tx1;
		am_opM = p;
	end
	else if(state_cs==PM_DONE && state_ns==PM2)begin
		am_opA = tx2;
		am_opB = b;
		am_opM = p;
	end
	else begin
		am_opA = 0;
		am_opB = 0;
		am_opM = 0;
	end
end

always@(*)begin
	if(state_cs==IDLE4 && state_ns==DP)
		dp_in_valid = 1;
	else
		dp_in_valid = 0;
end
always@(*)begin
	if(dp_in_valid)begin
		dp_Px = Px_reg;
		dp_Py = Py_reg;
		dp_k = n;
	end
	else begin
		dp_Px = 0;
		dp_Py = 0;
		dp_k = 0;
	end
end

always@(*)begin
	if(state_cs!=MI && state_ns==MI)
		mi_in_valid = 1;
	else
		mi_in_valid = 0;
end

always@(*)begin
	if(mi_in_valid)begin
		mi_opA = s_reg;
		mi_opM = n;
	end
	else begin
		mi_opA = 0;
		mi_opM = 0;
	end
end


//FSM
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_cs<= IDLE;
	else 
		state_cs<= state_ns;
end

always@(*)begin
	case(state_cs)
		IDLE:		state_ns = (in_valid)?RD:IDLE;
		RD:			state_ns = IDLE2;
		IDLE2:		state_ns = CHECK;
		CHECK:		state_ns = (check_fail)?FAIL:IDLE3;
		IDLE3:		state_ns = PM;
		PM:			state_ns = (pm1_out_valid)?PM_DONE:PM;
		PM_DONE:	state_ns = PM2;
		PM2:		state_ns = (pm1_out_valid)?PM2_DONE:PM2;
		PM2_DONE:	state_ns = AM;
		AM:			state_ns = AM_DONE;
		AM_DONE:	state_ns = PM3;
		PM3:		state_ns = (pm1_out_valid)?PM3_DONE:PM3;
		PM3_DONE:	state_ns = CHECK2;
		CHECK2:		state_ns = (check2_fail)?FAIL:IDLE4;
		IDLE4:		state_ns = DP;
		DP:			state_ns = (dp_out_valid)?DP_DONE:DP;
		DP_DONE:	state_ns = CHECK3;
		CHECK3:		state_ns = (check3_fail)?FAIL:IDLE5;
		IDLE5:		state_ns = MODIFY;
		MODIFY:		state_ns = IDLE6;
		IDLE6:		state_ns = MI;
		MI:			state_ns = (mi_out_valid)?MI_DONE:MI;
		MI_DONE:	state_ns = PM4;
		PM4:		state_ns = (pm1_out_valid)?PM4_DONE:PM4;
		PM4_DONE:	state_ns = DP2;
		DP2:		state_ns = (dp_out_valid)?DP2_DONE:DP2;
		//DP2_DONE:	state_ns = DP3;
		//DP3:		state_ns = (dp_out_valid)?DP3:DP3_DONE;
		DP2_DONE:	state_ns = ADD;
		ADD:		state_ns = (add_out_valid)?VERIFY:ADD;
		VERIFY:		state_ns = DONE;
		DONE:		state_ns = IDLE;
		FAIL:		state_ns = IDLE;
	endcase
end


// Register

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		r_reg<=0;
	else if(state_ns==RD)
		r_reg<=r;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		s_reg<=0;
	else if(state_ns==RD)
		s_reg<=s;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		hash_reg<=0;
	else if(state_ns==RD)
		hash_reg<=hash;
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
		tx1<=0;
	else if(state_ns==IDLE)
		tx1<=0;
	else if((state_ns==PM_DONE || state_ns==PM2_DONE) && pm1_out_valid)
		tx1<=pm1_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		tx2<=0;
	else if(state_ns==IDLE)
		tx2<=0;
	else if(state_cs==PM_DONE && state_ns==PM2)
		tx2<=am_out_data;
	else if((state_ns==PM_DONE) && pm2_out_valid)
		tx2<=pm2_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		tx3<=0;
	else if(state_ns==IDLE)
		tx3<=0;
	else if(state_ns==AM)
		tx3<=am_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		ty<=0;
	else if(state_ns==IDLE)
		ty<=0;
	else if(state_ns==PM3_DONE)
		ty<=pm1_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		z<=0;
	else if(state_ns==IDLE)
		z<=0;
	else if(tmp_z_valid)
		z<=tmp_z;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		nPx<=0;
	else if(state_ns==IDLE)
		nPx<=0;
	else if(dp_out_valid)
		nPx<=dp_Rx;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		nPy<=0;
	else if(state_ns==IDLE)
		nPy<=0;
	else if(dp_out_valid)
		nPy<=dp_Ry;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		sInv<=0;
	else if(state_ns==IDLE)
		sInv<=0;
	else if(mi_out_valid)
		sInv<=mi_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		u1<=0;
	else if(state_ns==IDLE)
		u1<=0;
	else if(state_ns==PM4_DONE && pm1_out_valid)
		u1<=pm1_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		u2<=0;
	else if(state_ns==IDLE)
		u2<=0;
	else if(state_ns==PM4_DONE && pm2_out_valid)
		u2<=pm2_out_data;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		t1x<=0;
	else if(state_ns==IDLE)
		t1x<=0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		t1y<=0;
	else if(state_ns==IDLE)
		t1y<=0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		t2x<=0;
	else if(state_ns==IDLE)
		t2x<=0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		t2y<=0;
	else if(state_ns==IDLE)
		t2y<=0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		y<=0;
	else if(state_ns==IDLE)
		y<=0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		x<=0;
	else if(state_ns==IDLE)
		x<=0;
end


//OUTPUT 
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_valid<=0;
		fail<=0;
	end
	else if(state_ns==IDLE)begin
		out_valid<=0;
		fail<=0;
	end
	else if(state_ns==DONE)begin
		out_valid<=1;
		fail<=0;
	end
	else if(state_ns==FAIL)begin
		out_valid<=1;
		fail<=1;
	end
end


endmodule