module CPU(clk, rst, instr_read, instr_addr, instr_out, data_read, data_write, data_addr, data_in, data_out);
    input         clk;
    input         rst;
    output        instr_read;
    output [31:0] instr_addr;
    input  [31:0] instr_out;
    output        data_read;
    output        data_write;
    output [31:0] data_addr;
    output [31:0] data_in;
    input  [31:0] data_out;
    integer index = 0;
    parameter INSTR_READ = 3'b000, LOAD = 3'b001, HALF = 3'b010, NEXT_INSTR = 3'b011, INSTR_DECODE = 3'b100; 

	reg [2:0] State;
    reg        instr_read;
    reg [31:0] instr_addr, data_addr, data_in, pc, imm;
    reg        data_read, data_write;
    reg [6:0] funct7, opcode;
    reg [4:0] rs1, rs2, rd, shamt;
    reg [2:0] funct3;
    reg [31:0] x[0:31];
always@(posedge clk)
begin
	if(rst == 1'b1) begin
		pc <= 32'h0;
		instr_addr <= 32'h0;
		instr_read <= 1'b1;
		data_read <= 1'b0;
		data_write <= 1'b0;
		imm <= 32'b0;
		for(index = 0; index < 32; index = index + 1) 
		    x[index] <= 32'h0;
		State <= INSTR_READ;
	end
	else begin
		case(State) 
			/*-----------------------------------*/
			INSTR_READ: 
			begin
				instr_read <= 1'b0;
				pc <= instr_addr;
				{funct7, rs2, rs1, funct3, rd, opcode} <= instr_out;
				State <= INSTR_DECODE;
			end
			/*-----------------------------------*/
			INSTR_DECODE:
			begin
				case(opcode)
					7'b0110011:	// R-TYPE
					begin 
						case({funct7, funct3})
							10'b0000000000: x[rd] <= x[rs1] + x[rs2];	//ADD #ian: rs1存在某一列reg, 去那一列取數字, 加起來丟到rd
							10'b0100000000: x[rd] <= x[rs1] - x[rs2];	//SUB
							10'b0000000001: x[rd] <= $unsigned(x[rs1]) << x[rs2][4:0];	//SLL
							10'b0000000010: x[rd] <= ($signed(x[rs1]) < $signed(x[rs2])) ? 32'd1 : 32'd0;	//SLT
							10'b0000000011: x[rd] <= ($unsigned(x[rs1]) < $unsigned(x[rs2])) ? 32'd1 : 32'd0;	//SLTU
							10'b0000000100: x[rd] <= x[rs1] ^ x[rs2];	//XOR
							10'b0000000101: x[rd] <= $unsigned(x[rs1]) >> x[rs2][4:0];	//SRL
							10'b0100000101: x[rd] <= $signed(x[rs1]) >> x[rs2][4:0];	//SRA
							10'b0000000110: x[rd] <= x[rs1] | x[rs2];	//OR
							10'b0000000111: x[rd] <= x[rs1] & x[rs2];	//AND
						endcase
						pc <= pc + 32'h4;
						State <= NEXT_INSTR;
					end
					7'b0000011:	//LW
					begin
						{rs1, funct3, rd} <= instr_out[19:7];
						imm <= {{20{instr_out[31]}}, instr_out[31:20]};
						State <= HALF;
					end
					7'b0010011:	//I-TYPE
					begin
						{rs1, funct3, rd} <= instr_out[19:7];
						imm <= {{20{instr_out[31]}}, instr_out[31:20]};
						shamt <= instr_out[24:20];
						State <= HALF;
					end
					7'b1100111:	//JALR
					begin
						{rs1, funct3, rd} <= instr_out[19:7];
						imm <= {{20{instr_out[31]}}, instr_out[31:20]};
						State <= HALF;
					end
					7'b0100011: //SW
					begin
						{rs2, rs1, funct3} <= instr_out[24:12];
						imm <= {{20{instr_out[31]}}, instr_out[31:25], instr_out[11:7]};
						State <= HALF;
					end
					7'b1100011:	//B-TYPE
					begin
						{rs2, rs1, funct3} <= instr_out[24:12];
						imm <= {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
						State <= HALF;
					end
					7'b0010111:	//AUIPC
					begin
						imm <= {instr_out[31:12], 12'b0};
						rd <= instr_out[11:7];
						State <= HALF;
					end
					7'b0110111:	//LUI
					begin
						imm <= {instr_out[31:12], 12'b0};
						rd <= instr_out[11:7];
						State <= HALF;
					end
					7'b1101111:	//J-TYPE
					begin
						imm <= {{11{instr_out[31]}}, instr_out[31], instr_out[19:12], instr_out[20], instr_out[30:21], 1'b0};
						rd <= instr_out[11:7];
						State <= HALF;
					end
				endcase
			end
			/*----------------------------------*/
			LOAD:
			begin
				x[rd] <= data_out;
				instr_addr <= pc;
				data_read <= 1'b0;
				instr_read <= 1'b1;
				State <= INSTR_READ;
			end
			/*----------------------------------*/
			HALF:
			begin
				case(opcode)
					7'b0000011:	//LW
					begin
						data_read <= 1'b1;
						data_addr <= x[rs1] + imm;
						pc <= pc + 32'h4;
						State <= LOAD;
					end
					7'b0010011:	//I-TYPE
					begin
						case(funct3)
							3'b000: x[rd] <= x[rs1] + imm;	//ADDI
							3'b010: x[rd] <= ($signed(x[rs1]) < $signed(imm)) ? 32'h1 : 32'h0;	//SLTI
							3'b011: x[rd] <= ($unsigned(x[rs1]) < $unsigned(imm)) ? 32'h1 : 32'h0;	//SLTIU
							3'b100: x[rd] <= x[rs1] ^ imm;	//XORI
							3'b110: x[rd] <= x[rs1] | imm;	//ORI
							3'b111: x[rd] <= x[rs1] & imm;	//ANDI
							3'b001: x[rd] <= $unsigned(x[rs1]) << shamt;	//SLLI
							3'b101:
							begin
								if(instr_out[31:25] == 7'b0000000)
									x[rd] <= $unsigned(x[rs1]) >> shamt;	//SRLI
								else
									x[rd] <= $signed(x[rs1]) >>> shamt;		//SRAI
							end
						endcase
						pc <= pc + 32'h4;
						State <= NEXT_INSTR;
					end
					7'b1100011:	//B-TYPE
					begin
						case(funct3)
							3'b000: pc <= (x[rs1] == x[rs2]) ? (pc + imm) : (pc + 32'h4);	//BEQ
							3'b001: pc <= (x[rs1] != x[rs2]) ? (pc + imm) : (pc + 32'h4);	//BNE
							3'b100: pc <= ($signed(x[rs1]) < $signed(x[rs2])) ? (pc + imm) : (pc + 32'h4);	//BLT
							3'b101: pc <= ($signed(x[rs1]) >= $signed(x[rs2])) ? (pc + imm) : (pc + 32'h4);	//BGE
							3'b110: pc <= ($unsigned(x[rs1]) < $unsigned(x[rs2])) ? (pc + imm) : (pc + 32'h4);	//BLTU
							3'b111: pc <= ($unsigned(x[rs1]) >= $unsigned(x[rs2])) ? (pc + imm) : (pc + 32'h4);	//BGEU
						endcase
						State <= NEXT_INSTR;
					end
					7'b0010111:	//AUIPC
					begin
						x[rd] <= pc + imm;
						pc <= pc + 32'h4;
						State <= NEXT_INSTR;
					end
					7'b0110111:	//LUI
					begin
						x[rd] = imm;
						pc <= pc + 32'h4;
						State <= NEXT_INSTR;
					end
					7'b1101111:	//J-TYPE
					begin
						x[rd] <= pc + 32'h4;
						pc <= pc + imm;
						State <= NEXT_INSTR;
					end
					7'b1100111:	//JALR
					begin
						x[rd] <= pc + 32'h4;
						pc <= imm + x[rs1];
						State <= NEXT_INSTR;
					end
					7'b0100011:	//SW
					begin
						data_write <= 1'b1;
						data_addr <= x[rs1] + imm;
						data_in <= x[rs2];
						pc <= pc + 32'h4;
						State <= NEXT_INSTR;
					end
				endcase
			end
			/*----------------------------------*/
			NEXT_INSTR:
			begin
				x[5'd0] <= 32'h0;
				instr_addr <= pc;
				instr_read <= 1'b1;
				data_read <= 1'b0;
				data_write <= 1'b0;
				imm <= 32'h0;
				State <= INSTR_READ;
			end
		endcase
	end
end
endmodule
