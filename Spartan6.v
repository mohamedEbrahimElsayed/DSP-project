module Spartan6(A, B, C, D, CLK, CARRYIN, OPMODE, BCIN, RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCARRYIN, RSTOPMODE, CEA, CEB, CEC, CED, CEM, CEP, CECARRYIN, CEOPMODE, PCIN, BCOUT, PCOUT, P, M, CARRYOUT, CARRYOUTF);
	
	// parameter declaration
	parameter A0REG = 0;
	parameter B0REG = 0;
	parameter A1REG = 1;
	parameter B1REG = 1;
	parameter CREG = 1;
	parameter DREG = 1;
	parameter MREG = 1;
	parameter PREG = 1;
	parameter CARRYINREG = 1;
	parameter CARRYOUTREG = 1;
	parameter OPMODEREG = 1;
	parameter CARRYINSEL = "OPMODE5";
	parameter B_INPUT = "DIRECT";
	parameter RSTTYPE = "SYNC";
	// input declaration
	input [17:0] A, B, D, BCIN;
	input [47:0] C, PCIN;
	input [7:0] OPMODE; 
	input CLK, CARRYIN, RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCARRYIN, RSTOPMODE, CEA, CEB, CEC, CED, CEM, CEP, CECARRYIN, CEOPMODE;
	// output declaration 
	output [17:0] BCOUT;
	output [35:0] M;
	output [47:0] P, PCOUT;
	output CARRYOUT, CARRYOUTF;
	// wires declaration
	wire [17:0] A0_OUT, B0_in, B0_OUT, D_OUT, Pre_add_sub_out, B1_in, A1_OUT, B1_OUT;
	wire [7:0] OPMODE_OUT;
	wire [47:0] C_OUT, X_OUT, Z_OUT, Post_add_sub_out, P_OUT;
	wire [35:0] mult_out, M_OUT;
	wire CY1_in, CY1_OUT, CY0_in, CY0_OUT;
	// before first stage, assign the input to the B port depending on parameter B_INPUT
	assign B0_in = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 0 ;
	// first stage
	Register_and_mux_pair #(.WIDTH(18), .RSTTYPE(RSTTYPE)) R_A0(.D(A), .clk(CLK), .rst(RSTA), .CE(CEA), .SELECTOR(A0REG), .out(A0_OUT));
	Register_and_mux_pair #(.WIDTH(18), .RSTTYPE(RSTTYPE)) R_B0(.D(B0_in), .clk(CLK), .rst(RSTB), .CE(CEB), .SELECTOR(B0REG), .out(B0_OUT));
	Register_and_mux_pair #(.WIDTH(48), .RSTTYPE(RSTTYPE)) R_C(.D(C), .clk(CLK), .rst(RSTC), .CE(CEC), .SELECTOR(CREG), .out(C_OUT));
	Register_and_mux_pair #(.WIDTH(18), .RSTTYPE(RSTTYPE)) R_D(.D(D), .clk(CLK), .rst(RSTD), .CE(CED), .SELECTOR(DREG), .out(D_OUT));
	Register_and_mux_pair #(.WIDTH(8), .RSTTYPE(RSTTYPE)) R_OPMODE(.D(OPMODE), .clk(CLK), .rst(RSTOPMODE), .CE(CEOPMODE), .SELECTOR(OPMODEREG), .out(OPMODE_OUT));
	// assign Pre adder subtractor
	assign Pre_add_sub_out = (~OPMODE_OUT[6]) ? (D_OUT + B0_OUT) : (D_OUT - B0_OUT) ;
	// before second stage, assign the input to the B1 REG
	assign B1_in = (~OPMODE_OUT[4]) ? B0_OUT : Pre_add_sub_out ;
	// second stage
	Register_and_mux_pair #(.WIDTH(18), .RSTTYPE(RSTTYPE)) R_A1(.D(A0_OUT), .clk(CLK), .rst(RSTA), .CE(CEA), .SELECTOR(A1REG), .out(A1_OUT));
	Register_and_mux_pair #(.WIDTH(18), .RSTTYPE(RSTTYPE)) R_B1(.D(B1_in), .clk(CLK), .rst(RSTB), .CE(CEB), .SELECTOR(B1REG), .out(B1_OUT));
	// Multplication output
	assign mult_out = A1_OUT * B1_OUT ;
	// assign the carry cascade1 (CY1) input
	assign CY1_in = (CARRYINSEL == "OPMODE5") ? OPMODE_OUT[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 0 ;
	// third stage
	Register_and_mux_pair #(.WIDTH(36), .RSTTYPE(RSTTYPE)) R_M(.D(mult_out), .clk(CLK), .rst(RSTM), .CE(CEM), .SELECTOR(MREG), .out(M_OUT));
	Register_and_mux_pair #(.WIDTH(1), .RSTTYPE(RSTTYPE)) R_CY1(.D(CY1_in), .clk(CLK), .rst(RSTCARRYIN), .CE(CECARRYIN), .SELECTOR(CARRYINREG), .out(CY1_OUT));
	// assign output of muxs X and Z
	assign X_OUT = (OPMODE_OUT[1:0] == 2'b00) ? 0 : (OPMODE_OUT[1:0] == 2'b01) ? M_OUT : (OPMODE_OUT[1:0] == 2'b10) ? P_OUT : {D_OUT[11:0], A1_OUT, B1_OUT} ;
	assign Z_OUT = (OPMODE_OUT[3:2] == 2'b00) ? 0 : (OPMODE_OUT[3:2] == 2'b01) ? PCIN : (OPMODE_OUT[3:2] == 2'b10) ? P_OUT : C_OUT ;
	// assign post adder subtractor and carry cascade0 (CY0)
	assign {CY0_in, Post_add_sub_out} = (~OPMODE_OUT[7]) ? (Z_OUT + X_OUT + CY1_OUT) : (Z_OUT - (X_OUT + CY1_OUT)) ;
	// last stage
	Register_and_mux_pair #(.WIDTH(48), .RSTTYPE(RSTTYPE)) R_P(.D(Post_add_sub_out), .clk(CLK), .rst(RSTP), .CE(CEP), .SELECTOR(PREG), .out(P_OUT));
	Register_and_mux_pair #(.WIDTH(1), .RSTTYPE(RSTTYPE)) R_CY0(.D(CY0_in), .clk(CLK), .rst(RSTCARRYIN), .CE(CECARRYIN), .SELECTOR(CARRYOUTREG), .out(CY0_OUT));
	// outputs
	assign BCOUT = B1_OUT ;
	assign PCOUT = P_OUT ;
	assign P = P_OUT ;
	assign M = M_OUT ;
	assign CARRYOUT = CY0_OUT ;
	assign CARRYOUTF = CY0_OUT ;

endmodule

