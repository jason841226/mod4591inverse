`timescale 1ns / 1ps

module inverse4591(Clk, Reset, In, Out, Valid);

	parameter P_WIDTH = 16;
	input							Clk;
	input							Reset;
	//AAA: Can I assume In hold until Valid?
	input		[P_WIDTH-1 : 0]		In;
	input							En;
	output reg	[P_WIDTH-1 : 0]		Out;
	output							Valid;

	parameter IDLE = 0;
	parameter SQUARE = 1;
	parameter MULT = 2;
	
	reg [12:0] r_4591 = 13'd4589;
	reg [1:0] state;
	reg [1:0] next_state;
	reg [3:0] ptr;
	reg [3:0] next_ptr;
	reg [3:0] cnt;
	reg [3:0] next_cnt;
	reg [P_WIDTH*2-1:0] mul_mod_in;
	wire [P_WIDTH-1:0] mul_mod_out;

	//AAA: need 3 clk
	//1. why 3 clk?
	//2. v.s Valid, En
	mod4591 mod_0(.Clk(Clk), .Reset(Reset), .In(mul_mod_in), .Out(mul_mod_out));
	
	assign SQUARE_FIN = (state==SQUARE)&&(cnt==3);
	assign MULT_FIN = (state==MULT)&&(cnt==3);

	assign Valid = (ptr==0)&&(MULT_FIN);

//AAA: Coding style
//cnt
	always @(*) begin
		if(Reset)
			next_cnt = 0;
		else if(SQUARE_FIN||MULT_FIN)
			next_cnt = 0;
		else if(state==SQUARE||state==MULT)
			next_cnt = cnt + 1;
		else
			next_cnt = 0;
	end
	always @(posedge Clk or posedge Reset) begin
		if(Reset)
			cnt <= 0;
		else
			cnt <= next_cnt;
	end

	// always @(posedge Clk or posedge Reset) begin
	// 	if(Reset)
	// 		cnt <= 0;
	// 	else
	// 		if(SQUARE_FIN||MULT_FIN)
	// 			cnt <= 0;
	// 		else if(state==SQUARE||state==MULT)
	// 			cnt <= cnt +1;
	// 		else
	// 			cnt = 0;
	// end

//state
	always @(posedge Clk or posedge Reset) begin
		if(Reset)
			state <= 0;
		else
			state <= next_state;
	end
	always @(*) begin
		case(state)
			IDLE : next_state = (En) ? SQUARE : IDLE;
			SQUARE : next_state = (SQUARE_FIN && r_4591[ptr-1]) ? MULT : SQUARE;
			MULT : next_state = (MULT_FIN) ? SQUARE : MULT;
			default : next_state = state;
		endcase
	end

//AAA: for all ptr, ptr=ptr-1?
//ptr
	always @(posedge Clk or posedge Reset) begin
		if(Reset) begin
			ptr <= 12;
		end else begin
			ptr <= next_ptr;
		end
	end

	always @(*) begin
		next_ptr = (SQUARE_FIN) ? ptr-1 : ptr;
	end

//AAA: how to initial mul_mod_in
//AAAL Coding Style
//mul_mod_in
	always @(posedge Clk or posedge Reset) begin
		if(Reset) begin
			mul_mod_in <= 0;
		end else begin
			if(ptr==12)
				mul_mod_in <= In*In;
			else if(cnt==0)
				mul_mod_in <= mul_mod_out*((state==SQUARE) ? mul_mod_out : In);
			else
				mul_mod_in <= mul_mod_in;
		end
	end

//AAA: Output need Reset?
//Out
	always @(posedge Clk or posedge Reset) begin
		if(Reset) begin
			Out <= 0;
		end else begin
			if(Valid)
				Out <= mul_mod_out;
		end
	end

endmodule

