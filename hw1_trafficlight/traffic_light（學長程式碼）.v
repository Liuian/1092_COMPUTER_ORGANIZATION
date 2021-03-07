module traffic_light (clk, rst, pass, R, G, Y);
    input  clk;
    input  rst;
    input  pass;
    output R;
    output G;
    output Y;
    reg R = 1'b0,
        G = 1'b1,
        Y = 1'b0;
    reg [11:0] count = 12'd0;
    reg [1:0] State = 2'b00;
    parameter S0 = 2'b00, // Green_Light
	      S1 = 2'b01, // Red_Light
	      S2 = 2'b10, // Yellow_Light
	      S3 = 2'b11; //No_Light

    always@(posedge clk)
    begin
	count <= count + 12'd1;
    end

    always@(State)
    begin
	case(State)
	    S0:
	    begin
		R = 0;
		G = 1;
		Y = 0;
	    end
	    S1:
	    begin
		R = 1;
		G = 0;
		Y = 0;
	    end
	    S2:
	    begin
		R = 0;
		G = 0;
		Y = 1;
	    end
	    S3:
	    begin
		R = 0;
		G = 0;
		Y = 0;
	    end
	endcase
    end 

    always@(posedge clk or posedge rst)
    begin
	if(rst == 1'b1)
	begin
	    State <= S0;
	    count <= 1;
	end
	else
	begin
	    if(pass == 1'b1)
	    begin
	        if(State != S0 || count >= 1024)
	        begin
	    	    State <= S0;
		    count <= 1;
	        end  
	        else
	        begin
		    if(count >= 0 && count < 1024)
		        State <= S0;
		    else if(count >= 1024 && count < 1152)
		        State <= S3;
		    else if(count >= 1152 && count < 1280)
		        State <= S0;
		    else if(count >= 1280 && count < 1408)
		        State <= S3;
		    else if(count >= 1408 && count < 1536)
		        State <= S0;
		    else if(count >= 1536 && count < 2048)
		        State <= S2;
		    else if(count >= 2048 && count < 3072)
		        State <= S1;
		    else
		        count <= 12'd1; 
	        end
	    end  
	    else
	    begin
	        if(count >= 0 && count < 1024)
    	            State <= S0;
	        else if(count >= 1024 && count < 1152)
	    	    State <= S3;
	        else if(count >= 1152 && count < 1280)
		    State <= S0;
	        else if(count >= 1280 && count < 1408)
		    State <= S3;
	        else if(count >= 1408 && count < 1536)
		    State <= S0;
	        else if(count >= 1536 && count < 2048)
		    State <= S2;
	        else if(count >= 2048 && count < 3072)
		    State <= S1;
	        else
	        begin
		    State <= S0;
		    count <= 12'd1; 
	        end
	    end  
	end
    end
endmodule
