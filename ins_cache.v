`timescale 1ns/100ps
module ins_cache(busywait_ins, instruction, read_ins_memory, ins_memory_address,  pc, memory_readdata, read_ins, busywait_ins_memory, clk, reset);
	
	input busywait_ins_memory, read_ins, clk, reset;
	input [31:0] pc;
	input [127:0] memory_readdata;
	
	output reg busywait_ins, read_ins_memory;
	output wire [5:0] ins_memory_address;
	output wire [31:0] instruction;
	
	integer i;
	//ins_cache
	
	reg valid_cache [7:0];
	reg [2:0] tag_cache [7:0];
	reg [127:0] cache_ins [7:0];
	
	
	wire [2:0] tag, index;
	wire [1:0] offset;
	
	wire valid;
	wire [2:0] tag_read;
	wire [127:0] block;
	
	wire tag_comparison;
	wire hit;
	
	wire [31:0] word [3:0]; //, word2, word3, word4;
	
	
	reg memory_access, write_cache;
	
	
	//when the pc is resived decode bits according to pc
	assign {tag, index, offset} = pc[9:2];
	//assign memory address for miss
	assign ins_memory_address = pc[9:4];
	//store value that are in cache
	assign #1 {tag_read, valid, block} = {tag_cache[index], valid_cache[index], cache_ins[index]};
	//tag comparison
	assign #0.9 tag_comparison = (tag == tag_read)? 1:0;
	//get word from the block
	assign {word[3], word[2], word[1], word[0]} = block;
	//get hit signal
	assign hit = (tag_comparison && valid)? 1:0;
	//forward instruction if its not hit instruction will be unknown
	assign #1 instruction = (hit)? word[offset]:32'dx;
	
	
	/*
	****************************************************************
	busywait signal work on cpu and also control unit
	
	cpu  ----> for deal with pc 
	control ----> for deassert signal that are writ,read and etc.
	
	****************************************************************
	*/
	
	
	//if reset
	always @ (*)
	begin
	
		if(reset)
		begin
		
			for (i=0;i<7; i=i+1)
			begin
				cache_ins[i] = 0;
				tag_cache[i] = 0;
				valid_cache[i] = 0;
				
			end
			busywait_ins = 0;
		
		end
	
	end
	
	//if miss
	always @ (*)
	begin
	
		if(!hit && read_ins)
		begin
			
			busywait_ins = 1;		//set busywait signal
			read_ins_memory = 1;	//read instruction from memory
		
		end
	
	end
	
	//if hit
	always @ (*)
	begin
	
		if(hit && read_ins)
		begin
			
			busywait_ins = 0;		//deasserted busywait
			read_ins_memory = 0;	//deasserted memory read
			memory_access = 0;		//not going to memory access
		
		end
	
		
	
	end
	
	//new signal for if memory read going on
	always @ (posedge clk)
	begin
	
		if(read_ins_memory)
		begin
			
			memory_access = 1;
		
		end
	
	end
	
	//when the read is done by memory write it to cache
	always @ (negedge busywait_ins_memory)
	begin
	
		if(memory_access)
		begin
			
			write_cache = 1;	//write signal
		
		end
	
	end
	
	//writting
	always @ (posedge clk)
	begin
	
		if(write_cache)
		begin
			#1
			tag_cache[index] = tag;					//tag
			cache_ins[index] = memory_readdata;		//cache block
			valid_cache[index] = 1;					//valid
			write_cache = 0;						//deasserted cache write signal
		
		end
	
	end

endmodule