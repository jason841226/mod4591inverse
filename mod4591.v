`timescale 1ns / 1ps
//3Clk for computing.
//can do pipeline every Clk.
module mod4591(
	Clk,
	Reset,
	In,
	Out
    );

//14617 = (2^12/4591)* 2^14
parameter RED_COEF = 14617;
parameter NTRU_Q = 4591;
parameter P_WIDTH = 16;

input					Clk;
input					Reset;
input		[P_WIDTH*2-1 : 0]	In;
output reg	[P_WIDTH-1 : 0]		Out;

reg		[P_WIDTH*2-1 : 0]	In_reg;

reg 		[31 : 0]	d;

wire 		[31 : 0]	e;

reg 		[31 : 0]	f;

wire 		[31 : 0]	g;

always@(posedge Clk)
begin
	if(Reset)
		In_reg <= {P_WIDTH*2{1'b0}};
	else
		In_reg <= In;
end

always@(posedge Clk)
begin
	if(Reset)
		d <= 32'b0;
	else
		d <= (In>>12)*RED_COEF;
end

assign e = (d>>14)*NTRU_Q;

always@(posedge Clk)
begin
	if(Reset)
		f <= 32'b0;
	else
		f <= In_reg-e;
end

assign g = f[15:0];

always@(posedge Clk)
begin
	if(Reset)
		Out <= 16'b0;
	else if(g>=2*NTRU_Q)
		Out <= g-2*NTRU_Q;
	else if(g>=NTRU_Q)
		Out <= g-NTRU_Q;
	else
		Out <= g;
end
endmodule
