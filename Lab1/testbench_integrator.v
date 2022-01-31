//Change

`timescale 1ns/1ns
`include "Integrator.v"

module testbench();
	
	reg clk_50, clk_25, reset;
    //outputs x_out,y_out,z_out
    reg InitialX,InitialY,funct,InitialZ,reset,delta,sigma,beta,rho;
	
	//reg [31:0] index;
	wire signed [15:0]  testbench_out;
	
	//Initialize clocks and index
	initial begin
		clk_50 = 1'b0;
		clk_25 = 1'b0;
		//index  = 32'd0;
		//testbench_out = 15'd0 ;
	end
	
	//Toggle the clocks
	always begin
		#10
		clk_50  = !clk_50;
	end
	
	always begin
		#20
		clk_25  = !clk_25;
	end
	
	//Intialize and drive signals
	initial begin
		reset  = 1'b1;
		#10 
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
        InitialX =  -27'b0000001_00000000000000000000;
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
integrator DUT   (.clock(clk_50), 
                .reset(reset),
				.increment({18'h02000, 14'b0}), 
				.phase(8'd0),
				.sine_out(testbench_out));
endmodule