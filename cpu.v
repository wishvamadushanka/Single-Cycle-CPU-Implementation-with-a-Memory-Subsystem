`timescale 1ns/100ps
module cpu(read_memory, write_memory, memory_address, memory_writedata, PC, memory_readdata, read_ins, busywait, busywait_ins, INSTRUCTION, CLK, RESET);

	//this is the cpu module which connect whith all other module and get results lots of wire here because all module connect
	
	
	//`timescale 1ns/100ps
	
	//output pc 
	output reg [31:0] PC;
	output reg read_ins;
	
	
	input busywait_ins;
	//inputs
	input [31:0] INSTRUCTION;
	input CLK,RESET;
	
	//fpr decode part 
	reg [7:0] readreg1, readreg2, writereg, immediate, opcode;
	
	//wire for connect out to in in different module

	wire [31:0] pc_add_out;	//wire that out 4 added pc valu from adder module
	//regout1 is output to register_file input for alu
	//regout2 is output to register_file input for mux which 2s complementing or not
	//mux_out_cmplmnt is output to mux_cmplmt input to mux_immd
	//cmplmnt_reg2 is the 2s complemented regout2
	wire [7:0] regout1, regout2, mux_out_cmplmnt,cmplmnt_reg2;
	//operand2 is output of mux_immd input to alu
	//alu_result is result of alu
	wire [7:0] operand2, alu_result;
	//these are write enable signal,select signl for mux_cmplmt and mux_immd
	wire wrten, mux_cmplmnt_select, mux_immd_select, jump, branch;
	//alu_op is select signal for alu
	wire [2:0] alu_op;
	
	//this is address out of pc+4+immediate
	wire [31:0] jumpadrress;
	
	//pc_final_out is valu that should update pc value in next clock
	//out_branch is branch mux out
	wire [31:0] pc_final_out, out_branch;
	
	//branch_en enabling of branch in mux_branch
	wire branch_en, zero;
	
	wire mux_writedata_select;
	
	input busywait;
	
	input [7:0] memory_readdata; 
	
	output wire read_memory, write_memory;
	
	output wire [7:0] memory_address, memory_writedata;
	
	wire [7:0] write_data; 
	
	// output reg [7:0] write_data;
	
	//pc is update with priveous out put of pc+4
	//new value is updated
	
	//pc adding part paralel to instrtion read this is adder module
	//adder myadder(pc_add_out, PC);
	
	//this is control module which generate control signals
	control mycontrol(mux_writedata_select, read_memory, write_memory, jump, branch, wrten, mux_cmplmnt_select, mux_immd_select, alu_op, opcode, busywait, busywait_ins, INSTRUCTION);
	
	//chose write data is memory read or alu result 
	mux mux_writedata(write_data, memory_readdata, alu_result, mux_writedata_select);
	
	
	//data_memory mydata_memory(CLK, RESET, read_memory, write_memory, memory_address, regout1, memory_readdata, busywait);
	
	//then reg_file which deal with registers
	reg_file myreg_file(regout1, regout2, write_data, writereg[2:0], readreg1[2:0], readreg2[2:0], wrten, CLK, RESET);
	
	//then regout2 2s complement
	//complement mycomplement(cmplmnt_reg2, regout2);
	
	//this is mux whether instrtion tell positive or negetive if negetive it select 2s complement output else regout2
	//if mux_cmplmnt_select 1 out register value else negetive value
	mux mux_cmplmt(mux_out_cmplmnt, regout2, cmplmnt_reg2,mux_cmplmnt_select);
	
	//this is mux which choose immediate vale or register output
	mux mux_immd(operand2, immediate, mux_out_cmplmnt, mux_immd_select);
	
	//addadrress for jump and beq
	addadrress myaddadrress(jumpadrress, pc_add_out, writereg);
	
	//and operation for get branch_en signal
	and and1(branch_en, branch, zero);
	
	//mux for branch which out pc+4 or branchaddress
	mux32 mux_branch(out_branch, jumpadrress, pc_add_out, branch_en);
	
	//mux for jump which out output of branch mux or jump address
	mux32 mux_jump(pc_final_out, jumpadrress, out_branch, jump);
	
	//this is alu
	alu myalu(memory_address, zero, alu_result, regout1, operand2, alu_op);
	
	// always @ (regout1)
	// begin
	assign memory_writedata = regout1;
	//pc + 4
	assign #1 pc_add_out = PC + 4;
	//2's complement
	assign #1 cmplmnt_reg2 = ~regout2 + 1;
	//assign #2 jumpadrress = pc_add_out + writereg;
	// end
	
	
	//this is reset part if reset is 1 reset will happen and pc value set to reset mode
	always @ (RESET)
	begin
		//pc set to reset mode
		if(RESET)
		begin
			#1 PC = -32'd4;
			read_ins = 0;
		end
	end
	
	 
	//this is pc update
	always @ (posedge CLK)
	begin
		//if not reset
		#1
		if(~RESET && !busywait && !busywait_ins)  //if instruction memroy or data memry is not busy
		begin
			//update pc
			PC = pc_final_out;
			read_ins = 1;
			//decoding
			// #3 {opcode[7:0],writereg[7:0], readreg1[7:0], readreg2[7:0]} = INSTRUCTION[31:0];
			// immediate[7:0] = INSTRUCTION[7:0];
			
		end
		
		
	end	
		
	
	//decode here
	always @ (INSTRUCTION)
	begin
		if(~RESET)
		begin
			//decode
			{opcode[7:0],writereg[7:0], readreg1[7:0], readreg2[7:0]} = INSTRUCTION[31:0];
			immediate[7:0] = INSTRUCTION[7:0];
		end
	end
	
endmodule


module mux32(out, in1, in2, select);

	//inputs
	input [31:0] in1,in2;
	//select bit
	input select;
	//out put mux
	output reg [31:0] out;
	
	always @(*)
	begin
	
		//if selecggt == 1 out --> in1
		//else out in2
		if(select)
			begin
				out = in1;
			end
		else
			begin
				out = in2;
			end
			
	end
endmodule



//this is the module which do 2s complement
module complement(out,in);
	//input
	input [7:0] in;
	//output
	output reg [7:0] out;

	//if in is availabel out = ~in + 1;
	always @ (in)
	begin
		#1
		out = ~in + 8'd1;
	end
	
endmodule


//this is module which add pc vale paralel to instrtion read
module adder(out,pc);
	//input
	input [31:0] pc;
	//output
	output reg [31:0] out;
	
	//pc = pc +4 done if pc is availeble
	always @ (pc)
	begin
		#1
		out = pc + 32'd4;
	end
	
	
endmodule

//this is module which get pc + 4 value and out pc+4+immediate
module addadrress(out, pc, immediate);
	//input
	input [31:0] pc;
	input [7:0] immediate;
	
	//output
	output wire [31:0] out;
	
	//for temaparally
	reg [31:0] temp;
	assign #2 out = pc + temp;
	
	always @ (*)
	begin
		if(immediate[7] == 1'b1)
		begin
			//negetive extenction
			temp = {22'b1111111111111111111111, immediate[7:0], 2'b00};
		end
		else
		begin
			//possitive extention
			temp = {22'b0000000000000000000000, immediate[7:0], 2'b00};
		end
		
		//out
		//out = pc + temp;
	end
	
endmodule



//mux 8 bit 
module mux(out, in1, in2, select);
	
	//mux 8 bit
	
	//inputs
	input [7:0] in1,in2;
	//select bit
	input select;
	//out put mux
	output reg [7:0] out;
	
	always @(*)
	begin
	
		//if selecggt == 1 out --> in1
		//else out in2
		if(select)
			begin
				out = in1;
			end
		else
			begin
				out = in2;
			end
			
	end
endmodule


//cache memory
// module cache_memory(out, memory_cache);

	//input
	// input memory_cache;
	
	//output is address for data_memory
	// output reg out;
	
	// always @ (memory_cache)
	// begin
		// #2 out = memory_cache;			//cache have not yet
		
	// end

// endmodule
	
	
	
	
	
	








	