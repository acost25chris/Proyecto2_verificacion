interface des_if (input bit clk);
	logic [2:0] r_mode;
	logic [31:0] fp_X;
	logic [31:0] fp_Y;
	logic [31:0] fp_Z;
	logic ovrf;
	logic udrf;

	clocking cb @(posedge clk);
		default input #1step output #3ns;
	      	input fp_Z, ovrf, udrf;
	      	output fp_X, fp_Y, r_mode;
	endclocking
endinterface
