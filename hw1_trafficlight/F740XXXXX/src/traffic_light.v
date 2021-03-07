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
	input clock_counter,
	output reg R = 0,
	output reg G = 0,
	output reg Y = 0
);
	reg [1:0] current_state = 0;
	reg [1:0] next_state = 0;
	parameter[1:0] red_light = 0, green_light = 1, yellow_light = 2, none_light = 3;
	//state register
	always @(posedge clk or posedge rst == 1)
	begin
		if(rst)                                     //rst就回第0個cycle
			current_state = green_light;
		else
		begin
			if(pass == 1 && clock_counter > 1023)  //clock counter大於1023（不是起始綠燈）且 pass = 1 時，換成起始綠燈第一個cycle
			current_state = green_light;
			else
				current_state = next_state;
		end
	end
	//next state logic
	always @(current_state)                        
	begin
		if(clock_counter < 1023)
			next_state = green_light;
		else
		begin
			if(clock_counter >= 1023 && clock_counter < 1151)
				next_state = none_light;
			else
			begin
				if(clock_counter >= 1151 && clock_counter < 1279)
					next_state = green_light;
				else
				begin
					if(clock_counter >= 1279 && clock_counter < 1407)
						next_state = none_light;
					else
					begin
						if(clock_counter >= 1407 && clock_counter < 1535)
							next_state = green_light;
						else
						begin
							if(clock_counter >= 1535 && clock_counter < 2047)
								next_state = yellow_light;
							else
							begin
								if(clock_counter >= 2047 && clock_counter < 3071)
									next_state = red_light;
								else
									next_state = green_light;
							end
						end
					end
				end
			end
		end
	end
	//ouput logic
	always @(current_state)
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
	always @(posedge clk or posedge rst == 1)
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
/*
module Datapath(
	input clk,
	input rst,
	input pass,
	output [11:0]clock_counter
);
	wire recount;
	compare compare(
		.clock_counter(clock_counter),
		.recount(recount)
	);
	counter counter(
		.clk(clk),
		.pass(pass),
		.rst(rst),
		.recount(recount),
		.clock_counter(clock_counter)
	);
endmodule
*/

/*
//換
module compare(
	input [11:0]clock_counter,
	output reg recount
);
	always @(clock_counter)
	begin
		if(clock_counter == 3071)
			recount = 1;
		else
			recount = 0;
	end
endmodule

module counter(
	input clk,
	input pass,
	input rst,
	input recount,//??沒設就是預設[0:1]??
	output reg [11:0]clock_counter
);
	always @(posedge clk or posedge rst == 1)
	begin
		if(rst)
			clock_counter = 0;
		else
		begin//??
			if(recount)
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
*/
