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
        //ints
        //InitialX =  -27'sb0000001_00000000000000000000;
        //InitialY = 27'b0000000_00011001100110011001;
        //InitialZ = 27'b0011001_00000000000000000000;
        //delta = 27'b0000000_00000001000000000000;
        //sigma = 27'b0001010_00000000000000000000;
        //beta = 27'b0000010_10101010101010101010;
        //rho = 27'b0011100_00000000000000000000;
	end
	
	// //Increment index
	// always @ (posedge clk_50) begin
	// 	index  <= index + 32'd1;
	// end

	//Instantiation of Device Under Test
	// hook up the sine wave generators
integrator DUT   (

		.x_out(x_out), 
		.y_out(y_out),
		.z_out(z_out),
		.InitialX(-27'sb0000001_00000000000000000000), 
		.InitialY(27'b0000000_00011001100110011001),
		.InitialZ(27'b0011001_00000000000000000000),
		.clk(clk_50), 
        .reset(reset),
		.delta(27'b0000000_00000001000000000000),
		.sigma(27'b0001010_00000000000000000000),
		.beta(27'b0000010_10101010101010101010),
		.rho(27'b0011100_00000000000000000000)
);

//x_out,y_out,z_out,InitialX,InitialY,InitialZ, clk,reset,delta,sigma,beta,rho
endmodule

module integrator(x_out,y_out,z_out,InitialX,InitialY,InitialZ, clk,reset,delta,sigma,beta,rho);
    output signed [26:0] x_out; 	//the state variable x
    output signed [26:0] y_out;
    output signed [26:0] z_out;
	//input signed [26:0] funct;     //the dV/dt function
    input clk, reset;
    input signed [26:0] delta;

    input signed [26:0] InitialX;
    input signed [26:0] InitialY;
    input signed [26:0] InitialZ; 

    input signed [26:0] sigma;
    input signed [26:0] beta;
    input signed [26:0] rho;

	//input signed [26:0] InitialOut;  //the initial state variable V

    //wire signed [26:0] InitialX = 
    //wire signed [26:0] InitialY = 
    //wire signed [26:0] InitialZ = 
    
	wire signed [26:0] x_int_out, y_int_out, z_int_out;
    wire signed	[26:0] x_out, y_out, z_out, x_new, y_new, z_new  ;
    reg signed	[26:0] x_reg ,y_reg ,z_reg  ;


	always @ (posedge clk) 
	begin
        if (reset==1) begin
		    x_reg <= InitialX ; // 
            y_reg <= InitialY ; //
            z_reg <= InitialZ ; //
		end
	else begin
	    	x_reg <= x_new ;
            y_reg <= y_new ;
            z_reg <= z_new ;
		end
	end    
    integration_logic int_logic(
        .x_out (x_int_out), //outputs of the intergration combinational logic
        .y_out (y_int_out),
        .z_out (z_int_out),
        .x_reg (x_reg),
        .y_reg (y_reg),
        .z_reg (z_reg),
        .delta (delta), //dt
        .sigma (sigma),
        .beta (beta),
        .rho (rho)
    );
    
    assign x_new = x_reg + x_int_out; //integration_logic()
    assign y_new = y_reg + y_int_out;
    assign z_new = z_reg + z_int_out;
    assign x_out = x_reg ;
    assign y_out = y_reg ;
    assign z_out = z_reg ;
    
endmodule




module integration_logic(x_out, y_out, z_out, x_reg, y_reg, z_reg,delta, sigma, beta, rho);
    output signed [26:0] x_out;
    output signed [26:0] y_out;
    output signed [26:0] z_out;
    input signed [26:0] x_reg;
    input signed [26:0] y_reg;
    input signed [26:0] z_reg;
    input signed [26:0] delta;
    

    input signed [26:0] sigma;
    input signed [26:0] beta;
    input signed [26:0] rho;

    //x(k+1) = x(k) + dt*x'(k)
    
    //wire signed [26:0] add_x, add_y, add_z;
    wire signed	[26:0] x_w0,x_w1;
    wire signed [26:0] y_w0,y_w1,y_w2;
    wire signed [26:0] z_w0,z_w1;


    //need to optimize first
    //replace * with signed mult
    //Add delta (i.e. dt) 
    //always @(*) begin
        // assign add_x = (y_reg - x_reg)*sigma;
        // assign add_x = x_reg*(rho-z_reg)-y_reg;
        // assign add_z = x_reg*y_reg-beta*z_reg;
        

        //assign add_x = ((y_reg - x_reg) * sigma )*delta;
        //assign add_x = ((y_reg*delta - x_reg*delta) * sigma );
        // assign add_x = (x_reg*(rho-z_reg)-y_reg)*delta;
        // add_y = (x_reg*(rho*delta-z_reg*delta)-y_reg*delta);
        // assign add_z = (x_reg*y_reg-beta*z_reg)*delta;
        //assign add_z = x_reg*(y_reg*delta)-beta*(z_reg*delta);

        //signed_mult K_M(v1xK_M, v1, 18'h10000);

        //X
        
        signed_mult X_M0(.out(x_w0),.a(y_reg),.b(delta)); //y_reg*delta
        signed_mult X_M1(x_w1,x_reg,delta); //x_reg*delta
        signed_mult X_M2(x_out,x_w0-x_w1,sigma); //((y_reg*delta - x_reg*delta) * sigma )
        
        //Y
        signed_mult Y_M0(y_w0,rho,delta); //rho*delta
        signed_mult Y_M1(y_w1,z_reg,delta); //z_reg*delta
        signed_mult Y_M2(y_w2,x_reg,y_w0-y_w1); //x_reg*(rho*delta-z_reg*delta)
        assign y_out = y_w2-x_w0;//(x_reg*(rho*delta-z_reg*delta)-y_reg*delta)

        //Z
        signed_mult Z_M0(z_w0,x_reg,x_w0); //x_reg*(y_reg*delta)
        signed_mult Z_M1(z_w1,beta,y_w1); //beta*(z_reg*delta)
        assign z_out = z_w0 - z_w1;

        
    //end 
        
    
endmodule



//////////////////////////////////////////////////
//// signed mult of 7.20 format 2'comp////////////
//////////////////////////////////////////////////


module signed_mult (out, a, b);
	output 	signed  [26:0]	out;
	input 	signed	[26:0] 	a;
	input 	signed	[26:0] 	b;
	// intermediate full bit length
	wire 	signed	[53:0]	mult_out;
	assign mult_out = a * b;
	// select bits for 7.20 fixed point
	assign out = {mult_out[53], mult_out[45:20]};
endmodule
//////////////////////////////////////////////////
