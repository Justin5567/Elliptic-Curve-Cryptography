
/* TODO*/
// BOTH CHECK and CHECK2 haven't finish


module ecc_sign
(
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

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;
input rst_n;
input [255:0] hash;
input [255:0] k;
input [255:0] privateKey;
output reg[255:0] r;
output reg[255:0] s;
input in_valid;
output reg out_valid;
output reg fail;
// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter IDLE  	= 5'd0;
parameter RD 		= 5'd1;
parameter IDLE2		= 5'd2;
parameter DP		= 5'd16;
parameter IDLE3 	= 5'd17;
parameter CHECK 	= 5'd3;
parameter IDLE4 	= 5'd4;
parameter MI		= 5'd5;
parameter MI_DONE 	= 5'd6;
parameter PM		= 5'd7;
parameter PM_DONE 	= 5'd8;
parameter AM		= 5'd9;
parameter AM_DONE 	= 5'd10;
parameter PM2		= 5'd11;
parameter PM2_DONE 	= 5'd12;
parameter CHECK2 	= 5'd13;
parameter IDLE5 	= 5'd14;
parameter DONE 		= 5'd15;
parameter FAIL 		= 5'd18;



//Gx Gy
parameter Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
parameter Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
// n
parameter n =  256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
//================================================================
// Wire & Reg Declaration
//================================================================
reg [4:0] state_cs,state_ns;

reg [255:0] hash_reg;
reg [255:0] k_reg;
reg [255:0] privateKey_reg;

reg [255:0] x;
reg [255:0] y;
reg [255:0] z;
reg [255:0] kInv;
// sub module declaration


// check signal
reg [255:0] tmp_z;
reg [255:0] tmp_privateKey;
wire tmp_z_valid;
wire tmp_privateKey_valid;

assign tmp_z_valid = z>=n;
assign tmp_privateKey_valid = privateKey_reg>=n;

/* DP */
reg [255:0] dp_Px;
reg [255:0] dp_Py;
reg [255:0] dp_k;
wire [255:0] dp_Rx;
wire [255:0] dp_Ry;
reg dp_in_valid;
wire dp_out_valid;
/* MI */
reg mi_in_valid;
wire mi_out_valid;
reg [255:0] mi_opA;
reg [255:0] mi_opM;
wire [255:0] mi_out_data;
/* PM */
reg pm_in_valid;
wire pm_out_valid;
reg [255:0] pm_opA;
reg [255:0] pm_opB;
reg [255:0] pm_opM;
wire [255:0] pm_out_data;
/* AM */
reg [255:0] am_opA;
reg [255:0] am_opB;
reg [255:0] am_opM;
wire [255:0] am_out_data;
//================================================================
// DESIGN
//================================================================

// sub module declaration

dotProduct dp_sign
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

productMod pm_sign
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

addMod am_sign
(
	.clk(clk),
	.opA(am_opA),
	.opB(am_opB),
	.opM(am_opM),
	.out_data(am_out_data)
);

modularInv mi_sign
(
	.clk(clk),
	.rst_n(rst_n),
	.opA(mi_opA),
	.opM(mi_opM),
	.in_valid(mi_in_valid),
	.out_valid(mi_out_valid),
	.out_data(mi_out_data)
);

always@(*)begin
	if(state_cs!=DP && state_ns==DP)
		dp_in_valid = 1;
	else
		dp_in_valid = 0;
end

always@(*)begin
	if(state_cs!=MI && state_ns==MI)
		mi_in_valid = 1;
	else
		mi_in_valid = 0;
end

always@(*)begin
	if((state_cs!=PM && state_ns==PM)||(state_cs!=PM2 && state_ns==PM2))
		pm_in_valid = 1;
	else
		pm_in_valid = 0;
end

always@(*)begin
	if(mi_in_valid)begin
		mi_opA = k_reg;
		mi_opM = n;
	end
	else begin
		mi_opA = 0;
		mi_opM = 0;
	end
end

always@(*)begin
	if(dp_in_valid)begin
		dp_Px = Gx;
		dp_Py = Gy;
		dp_k = k_reg;
	end
	else begin
		dp_Px = 0;
		dp_Py = 0;
		dp_k = 0;
	end
end

always@(*)begin
	if(pm_in_valid)begin
		if(state_ns==PM)begin
			pm_opA = x;
			pm_opB = privateKey_reg;
			pm_opM = n;
		end
		else begin
			pm_opA = kInv;
			pm_opB = s;
			pm_opM = n;
		end
	end
	else begin
		pm_opA = 0;
		pm_opB = 0;
		pm_opM = 0;
	end
end

always@(*)begin
	if(state_cs!=AM && state_ns==AM)begin
		am_opA = s; //rda
		am_opB = z;
		am_opM = n;
	end
	else begin
		am_opA = 0;
		am_opB = 0;
		am_opM = 0;
	end
end

// tmp signal
always@(*)begin
	if(state_ns==CHECK)begin
		if(tmp_z_valid)
			tmp_z = z - n;
	end
	else begin
		tmp_z = 0;
	end
end

always@(*)begin
	if(state_ns==CHECK)begin
		if(tmp_privateKey_valid)
			tmp_privateKey = privateKey - n;
	end
	else begin
		tmp_privateKey = 0;
	end
end


// FSM
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_cs<=IDLE;
	else
		state_cs<=state_ns;
end

always@(*)begin
	case(state_cs)
		IDLE: 	state_ns = (in_valid)?RD:IDLE;
		RD:		state_ns = IDLE2;
		IDLE2:	state_ns = DP;
		DP:		state_ns = (dp_out_valid)?IDLE3:DP;
		IDLE3:	state_ns = CHECK;
		CHECK:	state_ns = (x==0)?FAIL:IDLE4;
		IDLE4:	state_ns = MI;
		MI:		state_ns = (mi_out_valid)?MI_DONE:MI;
		MI_DONE:state_ns = PM;
		PM:		state_ns = (pm_out_valid)?PM_DONE:PM;
		PM_DONE:state_ns = AM;
		AM:		state_ns = AM_DONE;
		AM_DONE:state_ns = PM2;
		PM2:	state_ns = (pm_out_valid)?PM2_DONE:PM2;
		PM2_DONE:state_ns = IDLE5;
		CHECK2:	state_ns = IDLE5;// we skip check2 first
		IDLE5:	state_ns = (s==0)?FAIL:DONE;
		DONE:	state_ns = IDLE;
		FAIL:	state_ns = IDLE;
	endcase
end



// register
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		k_reg<=0;
	else if(state_ns==IDLE)
		k_reg<=0;
	else if(state_ns==RD)
		k_reg<=k;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		privateKey_reg<=0;
	else if(state_ns==IDLE)
		privateKey_reg<=0;
	else if(state_ns==CHECK && privateKey>=n)
		privateKey_reg<=privateKey_reg - n;
	else if(state_ns==RD)
		privateKey_reg<=privateKey;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		hash_reg<=0;
	else if(state_ns==IDLE)
		hash_reg<=0;
	else if(state_ns==CHECK && hash_reg>=n)
		hash_reg<= hash_reg - n;
	else if(state_ns==RD)
		hash_reg<=hash;
end

/*
hash
if (HashW >= 256) {
	z = hash.range(HashW - 1, HashW - 256);
} else {
	z = hash;
}
if (z >= n) {
	z -= n;
}

*/

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		x<=0;
		y<=0;
	end
	else if(state_ns==IDLE)begin
		x<=0;
		y<=0;
	end
	else if(dp_out_valid)begin
		x<=dp_Rx;
		y<=dp_Ry;
	end
end	

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		z<=0;
		
	else if(state_ns==RD)
		z<=hash;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		kInv<=0;
	else if(state_ns==IDLE)
		kInv<=0;
	else if(mi_out_valid)
		kInv<=mi_out_data;
end

// output
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
		fail<=0;
	else if(state_ns==FAIL)
		fail<=1;
	else
		fail<=0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		s<=0;
		r<=0;
	end
	else if(state_ns==IDLE)begin
		r<=0;
		s<=0;
	end
	else if(dp_out_valid)
		r<=dp_Rx;
	else if(state_ns==AM)
		s<=am_out_data;
	else if(state_ns==PM2_DONE)
		s<=pm_out_data;
	else if(state_ns==PM_DONE)begin
		s<=pm_out_data; //rda
	end
end

endmodule