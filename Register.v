module Register_and_mux_pair(D, clk, rst, CE, SELECTOR, out);

	parameter WIDTH = 18;
	parameter RSTTYPE = "SYNC";
	input [WIDTH-1:0] D;
	input clk, rst, CE, SELECTOR;
	output [WIDTH-1:0] out;
	reg [WIDTH-1:0] out_seq;
	wire [WIDTH-1:0] out_comb;
	// design sequential part when SELECTOR = 1
	generate
		if (RSTTYPE == "SYNC") begin
			always @(posedge clk) begin
				if (rst) 
					out_seq <= 0;
				else if (CE)
					out_seq <= D;
			end
		end
		else if (RSTTYPE == "ASYNC") begin
			always @(posedge clk or posedge rst) begin
				if (rst) 
					out_seq <= 0;
				else if (CE)
					out_seq <= D;
			end
		end
	endgenerate
	// assign out depinding on SELECTOR 
	assign out = (SELECTOR == 0) ? D : out_seq ;
endmodule