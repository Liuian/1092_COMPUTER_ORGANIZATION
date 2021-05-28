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
	//新增變數
	parameter INSTR_READ = 3'b000, LOAD = 3'b001, HALF = 3'b010, NEXT_INSTR = 3'b011, INSTR_DECODE = 3'b100;	//補同的case
	reg [31:0] pc;
	reg [2:0] State;		//決定case
	reg [6:0] funct7;
	reg [4:0] rs2;
	reg [4:0] rs1;
	reg [2:0] funct3;
	reg [4:0] rd;
	reg [6:0] opcode;
	reg [63:0] result;

/* Add your design */
always@(posedge clk)
begin
	if(rst == 1'b1)
	begin
		pc <= 32'h0;		//<= : 賦值, pc初始值設為0
		instr_addr <= 32'h0;
		instr_read <= 1'b1;	//when instr_read == 1, read 32 bit;
		data_read <= 1'b0;	//used when lw
		data_write <= 1'b0;	//used when sw
		for(index = 0; index < 32; index = index + 1)		//32列32bit的register
			x[index] <= 32'h0;	
		State <= INSTR_READ;
	end
	else
	begin
		case(State)
			/*---------------------------------------*/
			INSTR_READ:
			begin
				instr_read <= 1'b0;	//??
				pc <= instr_addr;	//??
				//把每個bit分別放入不同指令內, 先假設是r-type, opcode都一樣. instr_out是input
				{funct7, rs2, rs1, funct3, rd, opcode} <= instr_out;
				State <= INSTR_DECODE;		//跳到解碼的case
			end
			/*---------------------------------------*/
			INSTR_DECODE:
			begin
				case(opcode)
					7'b0110011:		//R-type
					begin
						case({funct7, funct3})
							//rs1存在某一列reg, 去那一列取數字, 加起來丟到rd
							10'b0000000000: x[rd] <= x[rs1] + x[rs2];	//ADD 
							10'b0100000000: x[rd] <= x[rs1] - x[rs2];	//SUB
							10'b0000000001: x[rd] <= $unsigned(x[rs1]) << x[rs2][4:0];	//SLL
							10'b0000000010: x[rd] <= ($signed(x[rs1]) < $signed(x[rs2])) ? 32'd1 : 32'd0;	//SLT
							10'b0000000011: x[rd] <= ($unsigned(x[rs1]) < $unsigned(x[rs2])) ? 32'd1 : 32'd0;	//SLTU
							10'b0000000100: x[rd] <= x[rs1] ^ x[rs2];	//XOR
							10'b0000000101: x[rd] <= $unsigned(x[rs1]) >> x[rs2][4:0];	//SRL
							10'b0100000101: x[rd] <= $signed(x[rs1]) >> x[rs2][4:0];	//SRA
							10'b0000000110: x[rd] <= x[rs1] | x[rs2];|  //OR
							10'b0000000111: x[rd] <= x[rs1] & x[rs2];|  //AND
							10'b0000001000:	//MUL
							begin
								sresult = $signed(x[rs1]) * $signed(x[rs2]);
								x[rd] <= result[31:0];
							end
							10'b0000001001: //MULH
							begin
								assign sresult = $signed(x[rs1]) * $signed(x[rs2]);
								x[rd] <= result[63:32];
							end
							10'b0000001011: //MULHU
							begin
								assign uresult = $unsigned(x[rs1]) * $unsigned(x[rs2]);	
								x[rd] <= result[63:32];
							end
							pc <= pc + 32'h4
							State <= NEXT_INSTR;
						endcase
					end
					7'b0000011:		//I-type
					7'b0010011:		//I-type
					7'b1100111:		//I-type
					7'b0100011:		//S-type
					7'b1100011:		//B-type
					7'b0010111:		//U-type
					7'b0110111:		//U-type
					7'b1101111:		//J-type
			end
			NEXT_INSTR:
			begin
				instr_addr <= pc;
				instr_read <= 1'b1;
				data_read <= 1'b0;
				data_write <= 1'b0;
				//imm <= 32'h0;
				State <= INSTR_READ;
			end
		endcase
	end
end

endmodule
