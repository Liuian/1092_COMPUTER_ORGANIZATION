module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output R,//不能用reg
    output G,
    output Y
);
	wire [11:0]clock_counter;
	Traffic_control Traffic_control(//！要加名字 前面的是檔案的type
		.clk(clk),
		.rst(rst),
		.pass(pass),
		.clock_counter(clock_counter),
		.R(R),
		.G(G),
		.Y(Y)
	);
	Datapath Datapath(
		.clk(clk),
		.rst(rst),
		.pass(pass),
		.clock_counter(clock_counter)
	);
endmodule

module Traffic_control(
	input pass,
	input rst,
	input clk,
	input [11:0]clock_counter,
	output reg R = 1'b0,
	output reg G = 1'b1,
	output reg Y = 1'b0
);
	reg [1:0] current_state = 2'b01;
	reg [1:0] next_state = 2'b00;
	parameter[1:0] red_light = 2'b00, green_light = 2'b01, yellow_light = 2'b10, none_light = 2'b11;
	//state register
	always @(posedge clk or posedge rst)
	begin
		if(rst)                                     //rst就回第0個cycle
			current_state = green_light;
		else if(pass == 1 && clock_counter > 1023)  //clock counter大於1023（不是起始綠燈）且 pass = 1 時，換成起始綠燈第一個cycle
			current_state = green_light;
		else if(clock_counter == 0)
			current_state = green_light;
		else
			current_state = next_state;
	end
	//next state logic
	always @(clock_counter)                        
	begin
		if(clock_counter < 1023)
			next_state = green_light;
		else if(clock_counter >= 1023 && clock_counter < 1151)
			next_state = none_light;
		else if(clock_counter >= 1151 && clock_counter < 1279)
			next_state = green_light;
		else if(clock_counter >= 1279 && clock_counter < 1407)
			next_state = none_light;
		else if(clock_counter >= 1407 && clock_counter < 1535)
			next_state = green_light;
		else if(clock_counter >= 1535 && clock_counter < 2047)
			next_state = yellow_light;
		else if(clock_counter >= 2047 && clock_counter < 3071)
			next_state = red_light;
		else
			next_state = green_light;
	end
	//ouput logic
	always @(clock_counter)//current_state 不會變
	begin
		case(current_state)
			red_light:
			begin
				R = 1'b1;
				G = 1'b0;
				Y = 1'b0; 
			end
			green_light:
			begin
				R = 1'b0;
				G = 1'b1;
				Y = 1'b0; 
			end
			yellow_light:
			begin
				R = 1'b0;
				G = 1'b0;
				Y = 1'b1; 
			end
			none_light:
			begin
				R = 1'b0;
				G = 1'b0;
				Y = 1'b0; 
			end
		endcase
	end
endmodule

module Datapath(
	input clk,
	input rst,
	input pass,
	output reg [11:0]clock_counter = 0
);
	always @(posedge clk or posedge rst)
	begin
		if(rst)
			clock_counter = 0;
		else
		begin//??
			if(clock_counter == 3071)
				clock_counter = 0;
			else
			begin//??
				if(pass == 1 && clock_counter > 1023)
					clock_counter = 0;
				else//??
					clock_counter = clock_counter + 1;
			end
		end
	end
endmodule
