module tb_inverse4591;

reg	Clk;
reg	Reset;
reg [15:0] In;
wire [15:0] Out;
wire Valid;

initial begin
	Clk = 1;
end

always #1 Clk <= ~Clk;

initial begin
	$fsdbDumpfile("inverse4591.fsdb");
	$fsdbDumpvars(3, "+mda");
end

initial begin
	#20;
	Reset = 1;
	In = 3;
	#20;
	Reset = 0;

	wait(Valid);
	#1;
	$display("%h",Out);

	
	#20;
	$finish;

end

inverse4591 inverse4591_0(
	.Clk(Clk),
	.Reset(Reset),
	.In(In),
	.En(1'b1),
	.Out(Out),
	.Valid(Valid)
	);

endmodule
