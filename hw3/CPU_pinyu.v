// Please include verilog file if you write module in other file

module CPU(
    input         clk,
    input         rst,
    output reg      instr_read,
    output reg [31:0] instr_addr,
    input  [31:0] instr_out,
    output reg       data_read,
    output reg       data_write,
    output reg [31:0] data_addr,
    output reg [31:0] data_in,
    input  [31:0] data_out
);

reg [31:0]register[31:0];
reg [31:0]extention;
reg [31:0]ex;
reg [31:0]ee;
reg [31:0]ouu;
integer a=0;
integer mark=0;

initial
begin//inni
register[0]=32'd0;
instr_read=1;
data_read=0;
data_write=0;
instr_addr=0;
ouu=0;
mark=0;
register[2]=0;
end//inni

/* Add your design */
//----------------------1
always@(posedge clk)
begin//always
register[0]=0;
data_write=0;
instr_addr=instr_addr+4;
if(mark==1)
begin//re
register[ee[11:7]]=data_out;
data_read=0;
mark=0;
end//re
//R type
if(instr_out[6:0]==7'b0110011)
begin//Rtype
//ADD
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b000))
begin//add
register[instr_out[11:7]]=register[instr_out[24:20]]+register[instr_out[19:15]];
end//add

//SUB
if((instr_out[31:25]==7'b0100000)&&(instr_out[14:12]==3'b000))
begin//sub
register[instr_out[11:7]]=register[instr_out[19:15]]-register[instr_out[24:20]];
end//sub

//SLL
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b001))
begin//sll
register[instr_out[11:7]]=register[instr_out[19:15]]<<register[instr_out[24:20]][4:0];
end//sll

//SLT
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b010))
begin//slt
if(register[instr_out[19:15]][31]==register[instr_out[24:20]][31])
begin//same sign
register[instr_out[11:7]]=(register[instr_out[19:15]] < register[instr_out[24:20]])?1:0;
end//same sign
else
begin//different sign
if(register[instr_out[19:15]][31]==1)
begin//small
register[instr_out[11:7]]=1;
end//small
else
begin//big
register[instr_out[11:7]]=0;
end//big
end//different sign
end//slt

//SLTU
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b011))
begin//sltu
register[instr_out[11:7]]=(register[instr_out[19:15]] < register[instr_out[24:20]])?1:0;
end//sltu

//XOR
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b100))
begin//xor
register[instr_out[11:7]]=register[instr_out[19:15]]^register[instr_out[24:20]];
end//xor

//SRL
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b101))
begin//srl
register[instr_out[11:7]]=register[instr_out[19:15]]>>register[instr_out[24:20]][4:0];
end//srl

//SRA
if((instr_out[31:25]==7'b0100000)&&(instr_out[14:12]==3'b101))
begin//sra
if(register[instr_out[19:15]][31]==0)
begin//>0
register[instr_out[11:7]]=register[instr_out[19:15]]>>register[instr_out[24:20]][4:0];
end//>0
else
begin//<0
ee=register[instr_out[19:15]];
for(a=0;a<register[instr_out[24:20]][4:0];a=a+1)
begin
ee=ee>>1;
ee[31]=1;
end
register[instr_out[11:7]]=ee;
end//<0
end//sra

//OR
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b110))
begin//or
register[instr_out[11:7]]=register[instr_out[19:15]]|register[instr_out[24:20]];
end//or

//AND
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b111))
begin//and
register[instr_out[11:7]]=register[instr_out[19:15]]&register[instr_out[24:20]];
end//and
end//Rtype

//Itype
if((instr_out[6:0]==7'b0000011)||(instr_out[6:0]==7'b0010011)||(instr_out[6:0]==7'b1100111))
begin//Itype

//LW
if((instr_out[6:0]==7'b0000011)&&(instr_out[14:12]==3'b010))
begin//lw
data_read=1;
extention[11:0]=instr_out[31:20];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
if(extention[31]==0)
begin//>0
data_addr=register[instr_out[19:15]]+extention;
end//>0
else
begin//<0
for(a=0;a<32;a=a+1)begin if(extention[a]==1)begin extention[a]=0;end else begin extention[a]=1; end end
data_addr=register[instr_out[19:15]]-extention-1;
end//<0
ee=instr_out;
mark=1;
end//lw

//ADDI
if((instr_out[6:0]==7'b0010011)&&(instr_out[14:12]==3'b000))
begin//addi
extention[11:0]=instr_out[31:20];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
register[instr_out[11:7]]=register[instr_out[19:15]]+extention;
end//addi

//SLTI
if((instr_out[6:0]==7'b0010011)&&(instr_out[14:12]==3'b010))
begin//slti
extention[11:0]=instr_out[31:20];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
if(register[instr_out[19:15]][31]==extention[31])
begin//same sign
if(register[instr_out[19:15]]<extention)
begin//small
register[instr_out[11:7]]=1;
end//small
else
begin//big
register[instr_out[11:7]]=0;
end//big
end//same sign
else
begin//different sign
if(extention[31]==1)
begin//small
register[instr_out[11:7]]=0;
end//small
else
begin//big
register[instr_out[11:7]]=1;
end//big
end//different sign
end//slti

//SLTIU
if((instr_out[6:0]==7'b0010011)&&(instr_out[14:12]==3'b011))
begin//sltiu
extention[11:0]=instr_out[31:20];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
register[instr_out[11:7]]=(register[instr_out[19:15]]<extention)?1:0;
end//slti

//XORI
if((instr_out[6:0]==7'b0010011)&&(instr_out[14:12]==3'b100))
begin//xori
extention[11:0]=instr_out[31:20];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
register[instr_out[11:7]]=register[instr_out[19:15]]^extention;
end//xori

//ORI
if((instr_out[6:0]==7'b0010011)&&(instr_out[14:12]==3'b110))
begin//ori
extention[11:0]=instr_out[31:20];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
register[instr_out[11:7]]=register[instr_out[19:15]]|extention;
end//ori

//ANDI
if((instr_out[6:0]==7'b0010011)&&(instr_out[14:12]==3'b111))
begin//andi
extention[11:0]=instr_out[31:20];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
register[instr_out[11:7]]=register[instr_out[19:15]]&extention;
end//andi

//SLLI
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b001)&&(instr_out[6:0]==7'b0010011))
begin//slli
register[instr_out[11:7]]=register[instr_out[19:15]]<<instr_out[24:20];
end//slli

//SRLI
if((instr_out[31:25]==7'b0000000)&&(instr_out[14:12]==3'b101)&&(instr_out[6:0]==7'b0010011))
begin//srli
register[instr_out[11:7]]=register[instr_out[19:15]]>>instr_out[24:20];
end//srli

//SRAI
if((instr_out[31:25]==7'b0100000)&&(instr_out[14:12]==3'b101)&&(instr_out[6:0]==7'b0010011))
begin//srai
if(register[instr_out[19:15]][31]==0)
begin//>0
register[instr_out[11:7]]=register[instr_out[19:15]]>>instr_out[24:20];
end//>0
else
begin//<0
ee=register[instr_out[19:15]];
for(a=0;a<instr_out[24:20];a=a+1)
begin//>>
ee=ee>>1;
ee[31]=1;
end//>>
register[instr_out[11:7]]=ee;
end//<0
end//srai

//JALR
if((instr_out[6:0]==7'b1100111)&&(instr_out[14:12]==3'b000))
begin//jalr
extention[11:0]=instr_out[31:20];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
ex=instr_addr;//register[instr_out[11:7]];
//register[instr_out[11:7]]=instr_addr;
instr_addr=extention+register[instr_out[19:15]];
register[instr_out[11:7]]=ex;
end//jalr

end//Itype

//Stype
if((instr_out[6:0]==7'b0100011)&&(instr_out[14:12]==3'b010))
begin//Stype
data_write=1;
extention[11:5]=instr_out[31:25];
extention[4:0]=instr_out[11:7];
for(a=12;a<32;a=a+1)
begin//bit extention
extention[a]=extention[11];
end//bit extention
data_addr=register[instr_out[19:15]]+extention;
data_in=register[instr_out[24:20]];
end//Stype

//Btype
if(instr_out[6:0]==7'b1100011)
begin//Btype

//BEQ
if(instr_out[14:12]==3'b000)
begin//beq
extention[12]=instr_out[31];
extention[10:5]=instr_out[30:25];
extention[4:1]=instr_out[11:8];
extention[11]=instr_out[7];
extention[0]=0;
for(a=13;a<32;a=a+1)
begin//bit extention
extention[a]=extention[12];
end//bit extention
if(register[instr_out[19:15]]==register[instr_out[24:20]])
begin//imm
instr_addr=instr_addr+extention-4;
end//imm
end//beq

//BNE
if(instr_out[14:12]==3'b001)
begin//bne
extention[12]=instr_out[31];
extention[10:5]=instr_out[30:25];
extention[4:1]=instr_out[11:8];
extention[11]=instr_out[7];
extention[0]=0;
for(a=13;a<32;a=a+1)
begin//bit extention
extention[a]=extention[12];
end//bit extention
if(register[instr_out[19:15]]!=register[instr_out[24:20]])
begin//imm
instr_addr=instr_addr+extention-4;
end//imm
end//bne

//BLT
if(instr_out[14:12]==3'b100)
begin//blt
extention[12]=instr_out[31];
extention[10:5]=instr_out[30:25];
extention[4:1]=instr_out[11:8];
extention[11]=instr_out[7];
extention[0]=0;
for(a=13;a<32;a=a+1)
begin//bit extention
extention[a]=extention[12];
end//bit extention
if(register[instr_out[19:15]][31]==register[instr_out[24:20]][31])
begin//same sign
if(register[instr_out[19:15]]<register[instr_out[24:20]])
begin//imm
instr_addr=instr_addr+extention-4;
end//imm
end//same sign
else
begin//different sign
if(register[instr_out[19:15]][31]==1)
begin//small
instr_addr=instr_addr+extention-4;
end//small
end//different sign
end//blt

//BGE
if(instr_out[14:12]==3'b101)
begin//bge
extention[12]=instr_out[31];
extention[10:5]=instr_out[30:25];
extention[4:1]=instr_out[11:8];
extention[11]=instr_out[7];
extention[0]=0;
for(a=13;a<32;a=a+1)
begin//bit extention
extention[a]=extention[12];
end//bit extention
if(register[instr_out[19:15]][31]==register[instr_out[24:20]][31])
begin//same sign
if(register[instr_out[19:15]]>=register[instr_out[24:20]])
begin//imm
instr_addr=instr_addr+extention-4;
end//imm
end//same sign
else
begin//different sign
if(register[instr_out[19:15]][31]==0)
begin//small
instr_addr=instr_addr+extention-4;
end//small
end//different sign
end//bge

//BLTU
if(instr_out[14:12]==3'b110)
begin//bltu
extention[12]=instr_out[31];
extention[10:5]=instr_out[30:25];
extention[4:1]=instr_out[11:8];
extention[11]=instr_out[7];
extention[0]=0;
for(a=13;a<32;a=a+1)
begin//bit extention
extention[a]=extention[12];
end//bit extention
if(register[instr_out[19:15]]<register[instr_out[24:20]])
begin//imm
instr_addr=instr_addr+extention-4;
end//imm
end//bltu

//BGEU
if(instr_out[14:12]==3'b111)
begin//bgeu
extention[12]=instr_out[31];
extention[10:5]=instr_out[30:25];
extention[4:1]=instr_out[11:8];
extention[11]=instr_out[7];
extention[0]=0;
for(a=13;a<32;a=a+1)
begin//bit extention
extention[a]=extention[12];
end//bit extention
if(register[instr_out[19:15]]>=register[instr_out[24:20]])
begin//imm
instr_addr=instr_addr+extention-4;
end//imm
end//bgeu

end//Btype

//Utype
//AUIPC
if(instr_out[6:0]==7'b0010111)
begin//auipc
extention[31:12]=instr_out[31:12];
for(a=11;a>=0;a=a-1)
begin//extention
extention[a]=0;
end//extention
register[instr_out[11:7]]=instr_addr-4+extention;
end//auipc

//LUI
if(instr_out[6:0]==7'b0110111)
begin//lui
extention[31:12]=instr_out[31:12];
for(a=11;a>=0;a=a-1)
begin//extention
extention[a]=0;
end//extention
register[instr_out[11:7]]=extention;
end//lui

//Utype

//Jtype
if(instr_out[6:0]==7'b1101111)
begin//JAL
extention[0]=0;
extention[20]=instr_out[31];
extention[10:1]=instr_out[30:21];
extention[11]=instr_out[20];
extention[19:12]=instr_out[19:12];
for(a=21;a<32;a=a+1)
begin//extend
extention[a]=extention[20];
end//extend
register[instr_out[11:7]]=instr_addr;
instr_addr=instr_addr-4+extention;
end//JAL

end//always
endmodule
