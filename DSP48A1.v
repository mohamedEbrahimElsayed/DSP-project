module DSP48A1(A,B,C,D,CARRYIN,M,P,CARRYOUT,CARRYOUTF,CLK,OPMODE,CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP,RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,BCOUT,BCIN,PCIN,PCOUT);
parameter SIZEA = 18;
parameter SIZEC = 48;
parameter SIZECARRY = 1;
parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;
parameter CREG =1;
parameter DREG =1;
parameter MREG =1;
parameter PREG =1;
parameter CARRYINREG =1;
parameter CARRYOUTREG =1;
parameter OPMODEREG =1;
parameter CARRYINSEL = "OPMODE5";
parameter B_INPUT = "DIRECT";
parameter RSTTYPE = "SYNC";
input [SIZEA-1:0] A,B,D,BCIN;
input [SIZEC-1:0] C;
input [7:0] OPMODE;
input CARRYIN,CLK,CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP,RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
input [SIZEC-1:0] PCIN;
output [35:0] M;
output [SIZEC-1:0] P,PCOUT;
output  CARRYOUT,CARRYOUTF;
output  [SIZEA-1:0] BCOUT;
wire [SIZEA-1:0] A_OUT1,B_OUT1,D_OUT1,M_OUT,A_OUT2,B_OUT2;
wire [SIZEC-1:0] C_OUT1,P_out;
wire CYI_in,CARRYOUT1;
reg [SIZEA-1:0] B0,A0,B1,D0,adder_out0,adder_out1,B2,A1,M0;
reg [SIZEC-1:0] C0,mult_out,X_out,Z_out,adder_out2;
reg CIN,CYI_out;
reg_mux #(.SIZE(SIZEA), .RSTTYPE(RSTTYPE)) m1(.in(A),.clk(CLK),.rst(RSTA),.sel(A0REG),.out(A_OUT1));
reg_mux #(.SIZE(SIZEA), .RSTTYPE(RSTTYPE)) m2(.in(B),.clk(CLK),.rst(RSTB),.sel(B0REG),.out(B_OUT1));
reg_mux #(.SIZE(SIZEC), .RSTTYPE(RSTTYPE)) m3(.in(C),.clk(CLK),.rst(RSTC),.sel(CREG),.out(C_OUT1));
reg_mux #(.SIZE(SIZEA), .RSTTYPE(RSTTYPE)) m4(.in(D),.clk(CLK),.rst(RSTD),.sel(DREG),.out(D_OUT1));
reg_mux #(.SIZE(SIZEA), .RSTTYPE(RSTTYPE)) m6(.in(A0),.clk(CLK),.rst(RSTA),.sel(A1REG),.out(A_OUT2));
reg_mux #(.SIZE(SIZEA), .RSTTYPE(RSTTYPE)) m7(.in(adder_out1),.clk(CLK),.rst(RSTB),.sel(B1REG),.out(B_OUT2));
reg_mux #(.SIZE(SIZEC), .RSTTYPE(RSTTYPE)) m8(.in(mult_out),.clk(CLK),.rst(RSTM),.sel(MREG),.out(M_OUT));
reg_mux #(.SIZE(SIZECARRY), .RSTTYPE(RSTTYPE)) m9(.in(CIN),.clk(CLK),.rst(RSTCARRYIN),.sel(CARRYINREG),.out(CYI_in));
reg_mux #(.SIZE(SIZEC), .RSTTYPE(RSTTYPE)) m10(.in(adder_out2),.clk(CLK),.rst(RSTP),.sel(PREG),.out(P_out));
reg_mux #(.SIZE(SIZEC), .RSTTYPE(RSTTYPE)) m11(.in(adder_out2),.clk(CLK),.rst(RSTCARRYIN),.sel(CARRYINREG),.out(CARRYOUT1));
//level 1
always @(*) begin
	if(B_INPUT == "DIRECT")
		B0 = B;
	else if(B_INPUT == "CASCADE") 
		B0 = BCIN;
	else
		B0 = 0;
	if (CEA)
		A0 = A_OUT1;
	else
		A0 = 0;
	if (CEB) 
		B1 = B_OUT1;
	else
		B1 = 0;
	if (CEC)
		C0 = C_OUT1;
	else
		C0 = 0;
	if (CED)
		D0 = D_OUT1;
	else 
		D0 = 0;
end
//level 2
always @(*)begin
	if(OPMODE[6])
		adder_out0 = D0 - B1;
	else 
		adder_out0 = D0 + B1;
	if(OPMODE[4])
		adder_out1 = adder_out0;
	else
		adder_out1 = B1;
end
// level 3
always @(*)begin
	if(CEB)
		B2 = B_OUT2;
	else
		B2 = 0;
	if(CEA)
		A1 = A_OUT2;
	else 
		A1 = 0;
	mult_out = B2 * A1;
end
// level 4
always @(*)begin
	if(CEM)
		M0 = M_OUT;
	else
		M0 = 0;
	if(OPMODE[1:0] == 0)
		X_out = {D0[11:0],A0,B1};
	else if(OPMODE[1:0] == 1)
		X_out = PCOUT;
	else if(OPMODE[1:0] == 2)
		X_out = M0;
	else
		X_out = 0;
	if(CARRYINSEL)
		CIN = OPMODE[5];
	else
		CIN = CARRYIN;
	if(CECARRYIN)
		CYI_out = CYI_in;
	else
		CYI_out = 0;
	if(OPMODE[3:2] == 0)
		Z_out = C0;
	else if(OPMODE[3:2] == 1)
		Z_out = P_out;
	else if(OPMODE[3:2]==2)
		Z_out = PCIN;
	else
		Z_out = 0;
end
//level 5
always @(*)begin
	if(OPMODE[7])
		adder_out2 = Z_out - (X_out + CYI_out);
	else
		adder_out2 = Z_out + X_out + CYI_out;
end
assign BCOUT = B2;
assign M = M0;
assign CARRYOUT = (CECARRYIN)? CARRYOUT1 : 0;
assign CARRYOUTF = CARRYOUT;
assign P = P_out;
assign PCOUT = P;

endmodule








	