//Change

`timescale 1ns/1ns
`include "Intergrator.v"

module testbench();
	
	reg clk_50, reset;
    //outputs x_out,y_out,z_out
    reg signed [26:0] InitialX,InitialY,InitialZ,delta,sigma,beta,rho;
	
	//reg [31:0] index;
	wire signed [26:0]  x_out,y_out,z_out;
	
	//Initialize clocks and index
	initial begin
		clk_50 = 1'b0;
		//index  = 32'd0;
		//testbench_out = 15'd0 ;
	end
	
	//Toggle the clocks
	always begin
		#10
		clk_50  = !clk_50;
	end

	//Intialize and drive signals
	initial begin
		reset = 1'b0;
		#10
		reset  = 1'b1;
		#50 
		reset  = 1'b0;
		


        //dt = (1./256)
        // x = [-1.]
        // y = [0.1]
        // z = [25.]
        // sigma = 10.0
        // beta = 8./3.
        // rho = 28.0
        //https://vha3.github.io/FixedPoint/FixedPoint.html
        //ints
        InitialX =  -27'sb0000001_00000000000000000000;
        InitialY = 27'b0000000_00011001100110011001;
        InitialZ = 27'b0011001_00000000000000000000;
        delta = 27'b0000000_00000001000000000000;
        sigma = 27'b0001010_00000000000000000000;
        beta = 27'b0000010_10101010101010101010;
        rho = 27'b0011100_00000000000000000000;
	end
	
	// //Increment index
	// always @ (posedge clk_50) begin
	// 	index  <= index + 32'd1;
	// end

	//Instantiation of Device Under Test
	// hook up the sine wave generators
integrator DUT   (
		.clk(clk_50), 
        .reset(reset),
		.x_out(x_out), 
		.y_out(y_out),
		.z_out(z_out),
		.InitialX(InitialX), 
		.InitialY(InitialY),
		.InitialZ(InitialZ),
		.delta(delta),
		.sigma(sigma),
		.beta(beta),
		.rho(rho)
);

//x_out,y_out,z_out,InitialX,InitialY,InitialZ, clk,reset,delta,sigma,beta,rho
endmodule