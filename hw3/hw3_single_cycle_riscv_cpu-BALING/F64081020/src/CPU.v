
// Please include verilog file if you write module in other file
module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,
    input      [31:0] instr_out,
    output            instr_read,
    output            data_read,
    output     [31:0] instr_addr,
    output     [31:0] data_addr,
    output reg [3:0]  data_write,
    output reg [31:0] data_in
);
/* Add your design */
reg [4:0]shamt;
reg signed [63:0]result;
reg unsigned [63:0]result2;
reg	[31:0]pc,data_a,rs1,rs2;
reg	[31:0]file[31:0];
reg	[6:0]op;
reg	[1:0]count;
reg	instr_r,data_r;

reg [6:0] funct7, opcode;
reg [4:0] rs22, rs11, rd;
reg [2:0] funct3;
reg [31:0] imm;

integer	i;
assign instr_addr=pc;
assign data_addr=data_a;
assign instr_read=instr_r;
assign data_read=data_r;
always@(count)
begin
//-------------
if(count==2'b01)
begin
	instr_r=1'b1;
	opcode = instr_out[6:0];
	if(opcode == 7'b0110011 || opcode == 7'b0000011 || opcode == 7'b0010011 || opcode == 7'b0100011 || opcode == 7'b0010111 || opcode == 7'b0110111)//R-type, I-type except JALR, S-type, U-type
		pc=pc+4;
	case(opcode)
	//B-Type
		7'b1100011:
		begin
			funct3 = instr_out[14:12];
			imm = {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
			case(funct3)
				3'b000 : pc = (file[instr_out[19:15]] == file[instr_out[24:20]]) ? (pc + imm) : (pc + 4);
				3'b001 : pc = (file[instr_out[19:15]] != file[instr_out[24:20]]) ? (pc + imm) : (pc + 4);
				3'b100 : pc = ($signed(file[instr_out[19:15]]) < $signed(file[instr_out[24:20]])) ? (pc + imm) : (pc + 4);
				3'b101 : pc = ($signed(file[instr_out[19:15]]) >= $signed(file[instr_out[24:20]])) ? (pc + imm) : (pc + 4);
				3'b110 : pc = ($unsigned(file[instr_out[19:15]]) < $unsigned(file[instr_out[24:20]])) ? (pc + imm) : (pc + 4);
				3'b111 : pc = ($unsigned(file[instr_out[19:15]]) >= $unsigned(file[instr_out[24:20]])) ? (pc + imm) : (pc + 4);
			endcase
		end
		//I-3
		7'b1100111:
		begin
			pc = rs1 + {{20{instr_out[31]}}, instr_out[31:20]};
			pc[0] = 1'b0;
		end
		//J-type
		7'b1101111:
		begin
			pc = pc + {{11{instr_out[31]}},instr_out[31],instr_out[19:12],instr_out[20],instr_out[30:21],1'b0};
		end
	endcase
end
//-------------
if(count==2'b01)
begin
	if(instr_out[6:0]==7'b0000011)
	begin
		funct3 = instr_out[14:12];
		case(funct3)	
			3'b010 : file[instr_out[11:7]]=data_out;
			3'b000 : file[instr_out[11:7]]={{24{data_out[7]}},data_out[7:0]};
			3'b001 : file[instr_out[11:7]]={{16{data_out[15]}},data_out[15:0]};
			3'b100 : file[instr_out[11:7]]={24'b0,data_out[7:0]};
			3'b101 : file[instr_out[11:7]]={16'b0,data_out[15:0]};
		endcase
	end
end
//-------------
//
if(count==2'b11)
begin
	op=instr_out[6:0];
	if(instr_out[6:0]==7'b0110011)//R-type
	begin
		if(instr_out[31:25]==7'b0000000)
		begin
			{funct7,rs22,rs11,funct3,rd,opcode} <= instr_out;
			if(instr_out[14:12]==3'b000)
			begin
				file[instr_out[11:7]]=file[instr_out[19:15]]+file[instr_out[24:20]];
			end
			else if(instr_out[14:12]==3'b001)
			begin
				file[instr_out[11:7]]=file[instr_out[19:15]]<<file[instr_out[24:20]][4:0];
				rs1=file[instr_out[19:15]];
				rs2=file[instr_out[24:20]];
			end
			else if(instr_out[14:12]==3'b010)
				file[instr_out[11:7]]=$signed(file[instr_out[19:15]])<$signed(file[instr_out[24:20]])?32'b1:32'b0;
			else if(instr_out[14:12]==3'b011)
				file[instr_out[11:7]]=$unsigned(file[instr_out[19:15]])<$unsigned(file[instr_out[24:20]])?32'b1:32'b0;
			else if(instr_out[14:12]==3'b100)
				file[instr_out[11:7]]=file[instr_out[19:15]]^file[instr_out[24:20]];
			else if(instr_out[14:12]==3'b101)
				file[instr_out[11:7]]=$unsigned(file[instr_out[19:15]])>>file[instr_out[24:20]][4:0];
			else if(instr_out[14:12]==3'b110)
				file[instr_out[11:7]]=file[instr_out[19:15]]|file[instr_out[24:20]];
			else if(instr_out[14:12]==3'b111)
				file[instr_out[11:7]]=file[instr_out[19:15]]&file[instr_out[24:20]];
		end
		else if (instr_out[31:25]==7'b000001)
		begin
			{funct7,rs22,rs11,funct3,rd,opcode} <= instr_out;
			//MUL
            if(instr_out[14:12] == 3'b000)
			begin
                assign result = $signed(file[rs11]) * $signed(file[rs22]);
            	file[rd] <= result[31:0];
            end
            //MULH
            else if(instr_out[14:12] == 3'b001)
			begin
                assign result = $signed(file[rs11]) * $signed(file[rs22]);
                file[rd] <= result[63:32];
            end
            //MULHU
            else begin
                assign result2 = $unsigned(file[rs11]) * $unsigned(file[rs22]);
                file[rd] <= result2[63:32];
            end
		end
		else if(instr_out[31:25]==7'b0100000)
		begin
			if(instr_out[14:12]==3'b000)
				file[instr_out[11:7]]=file[instr_out[19:15]]-file[instr_out[24:20]];
			else if(instr_out[14:12]==3'b101)
				file[instr_out[11:7]]=$signed(file[instr_out[19:15]])>>>file[instr_out[24:20]][4:0];
		end
	end
	else if(instr_out[6:0]==7'b0000011)//I-1
	begin	
		data_a=file[instr_out[19:15]]+{{20{instr_out[31]}},instr_out[31:20]};
	end
	else if(instr_out[6:0]==7'b0010011)//I-2
	begin
		if(instr_out[14:12]==3'b000)
			file[instr_out[11:7]]=file[instr_out[19:15]]+{{20{instr_out[31]}},instr_out[31:20]};
		else if(instr_out[14:12]==3'b010)
			file[instr_out[11:7]]=$signed(file[instr_out[19:15]])<$signed({{20{instr_out[31]}},instr_out[31:20]})?32'b1:32'b0;
		else if(instr_out[14:12]==3'b011)
			file[instr_out[11:7]]=$unsigned(file[instr_out[19:15]])<$unsigned({{20{instr_out[31]}},instr_out[31:20]})?32'b1:32'b0;
		else if(instr_out[14:12]==3'b100)
			file[instr_out[11:7]]=file[instr_out[19:15]]^{{20{instr_out[31]}},instr_out[31:20]};
		else if(instr_out[14:12]==3'b110)
		begin
			file[instr_out[11:7]]=file[instr_out[19:15]]|{{20{instr_out[31]}},instr_out[31:20]};
		end
		else if(instr_out[14:12]==3'b111)
			file[instr_out[11:7]]=file[instr_out[19:15]]&{{20{instr_out[31]}},instr_out[31:20]};
		else if(instr_out[14:12]==3'b001)
		begin
			if(instr_out[31:25]==7'b0000000)
				file[instr_out[11:7]]=$unsigned(file[instr_out[19:15]])<<instr_out[24:20];
		end
		else if(instr_out[14:12]==3'b101)
		begin
			if(instr_out[31:25]==7'b0000000)
				file[instr_out[11:7]]=$unsigned(file[instr_out[19:15]])>>instr_out[24:20];
			else if(instr_out[31:25]==7'b0100000)
				file[instr_out[11:7]]=$signed(file[instr_out[19:15]])>>>instr_out[24:20];
		end
	end
	else if(instr_out[6:0]==7'b1100111)
	begin
		rs1=file[instr_out[19:15]];
		file[instr_out[11:7]]=pc+4;
	end
	else if(instr_out[6:0]==7'b0100011)//S
	begin
		data_a=file[instr_out[19:15]]+{{20{instr_out[31]}},instr_out[31:25],instr_out[11:7]};
		if(instr_out[14:12]==3'b010)			//SW
		begin
			data_write=4'b1111;
			data_in=file[instr_out[24:20]];
		end
		else if(instr_out[14:12]==3'b000)		//SB
		begin
			if(data_a[1:0]==2'b00)
			begin
				data_write=4'b0001;
				data_in={24'b0,file[instr_out[24:20]][7:0]};
			end
			else if(data_a[1:0]==2'b01)
			begin
				data_write=4'b0010;
				data_in={16'b0,file[instr_out[24:20]][7:0],8'b0};
			end
			else if(data_a[1:0]==2'b10)
			begin
				data_write=4'b0100;
				data_in={8'b0,file[instr_out[24:20]][7:0],16'b0};
			end
			else if(data_a[1:0]==2'b11)
			begin
				data_write=4'b1000;
				data_in={file[instr_out[24:20]][7:0],24'b0};
			end			
		end
		else if(instr_out[14:12]==3'b001)		//SH
		begin
			if(data_a[1:0]==2'b00)
			begin
				data_write=4'b0011;
				data_in={16'b0,file[instr_out[24:20]][15:0]};
			end
			else if(data_a[1:0]==2'b01)
			begin
				data_write=4'b0110;
				data_in={18'b0,file[instr_out[24:20]][15:0],8'b0};
			end
			else if(data_a[1:0]==2'b10)
			begin
				data_write=4'b1100;
				data_in={file[instr_out[24:20]][15:0],16'b0};
			end
		end
	end
	else if(instr_out[6:0]==7'b0010111)
	begin
		file[instr_out[11:7]]=pc+{instr_out[31:12],12'b0};
	end
	else if(instr_out[6:0]==7'b0110111)
	begin
		file[instr_out[11:7]]={instr_out[31:12],12'b0};
	end
	else if(instr_out[6:0]==7'b1101111)
	begin
		file[instr_out[11:7]]=pc+4;
	end
	//還沒考慮
	if(instr_out[6:0]==7'b0000011)
	begin
		data_r=1'b1;
	end
	else
	begin
		data_r=1'b0;
	end
	//
	if(instr_out[6:0]!=7'b0100011)
	begin
		data_write=4'b0000;
	end	
	if(instr_out[11:7]==5'b0)
	begin
		file[instr_out[11:7]]=32'b0;
	end	
end
end
always@(posedge clk)
begin
	if(rst)
	begin
		count=2'b0;
		for (i=0; i<32; i=i+1) 
		begin
    			file [i] = 32'b0; 
		end
		pc=32'b0;
	end
	else
	begin
		count=count+2'b1;
	end
end
endmodule 
