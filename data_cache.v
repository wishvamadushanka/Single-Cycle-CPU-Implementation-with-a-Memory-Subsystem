`timescale 1ns/100ps
module data_cache(
	clock,
    reset,
    read,
    write,
    address,
    writedata,
	busywait_memory,
	memory_readdata, 
    readdata,
	busywait,
	read_memory,
	write_memory,
	memory_address,
	memory_writedata
	
);
	//`timescale 1ns/100ps
	//initialize input outputs
	input busywait_memory;
	input [31:0] memory_readdata;
	
	output reg read_memory, write_memory;
	
	output reg [5:0] memory_address;
	output wire [31:0] memory_writedata;

	input clock, reset, read, write;
	
	input [7:0] address, writedata;
	
	output wire [7:0] readdata;
	
	output reg busywait;
	
	
	wire [2:0] index;
	
	wire [2:0] tag;
	wire [1:0] offset;
	
	//reg valid, dirty , tag_comparison;//, readaccess, writeaccess;
	wire valid, dirty , tag_comparison;
	
	wire hit;
	
	//reg [2:0] tag_cache;
	wire [2:0] tag_cache;
	//reg [7:0] word1, word2, word3, word4;
	wire [7:0] word1, word2, word3, word4;
	
	//reg [31:0] block;
	
	wire [31:0] block;
	
	
	//cache memory and dirty vlid tag
	reg [31:0] cache [7:0];
	reg dirty_bit [7:0];
	reg valid_bit [7:0];
	reg [2:0] tag_bits [7:0];
	
	reg write_back, read_back;
	
	reg write_cache;
	
	reg write_do, read_do;
	
	//for data memory
	//reg read_memory, write_memory;
	//wire busywait_memory;
	
	//reg [5:0] memory_address;
	
	//wire [31:0] memory_readdata, memory_writedata;
	
	//wire memory_readaccsess;
	
	reg cache_access;
	
	
	//mux for select data word from block data
	mux_4_8 mux_select_word(readdata, offset, word1, word2, word3, word4); 
	
	
	//for get hit signal
	and a1(hit, tag_comparison, valid);
	
	
	//data memory
	//assign memory_address = {tag_cache[2:0], index[2:0]};
	
	
	//get valu for index tag offset
	assign {tag[2:0], index[2:0], offset[1:0]} = address;
	
	//set memory write data
	assign memory_writedata = block;
	
	
	//getting value from cache
	assign #1 {valid, dirty, tag_cache, block} = {valid_bit[index], dirty_bit[index], tag_bits[index], cache[index]};
	
	//tag comparrison
	assign #0.9 tag_comparison = (tag_cache == tag)? 1 : 0;
	
	//seperate word from block in cache
	assign #1 {word4, word3, word2, word1} = block;
	
	//mux mux_select_cache(readdata, out_word, memory_readdata, hit);
	
	
	//data memory
	// data_memory mydata_memory(clock, reset, read_memory, write_memory, memory_address, memory_writedata, memory_readdata, busywait_memory, memory_readaccsess);
	
	
	integer i;
	//Reset cache
	always @(posedge reset)
	begin
	
		//resetting
		for (i = 0; i < 8; i= i+1)
		begin
			cache[i] = 0;
			valid_bit[i] = 0;
			dirty_bit[i] = 0;
			tag_bits[i] = 0;		
		end
		
		busywait = 0;
		read_memory = 0;
		write_memory = 0;
		
	end
	
	
	//set busywait signal
	always @(read, write)
	begin
		busywait = (read || write)? 1 : 0;
		
	end
	
	//de-asserting busywait signal
	always @ (posedge clock)
	begin
	
		if(hit) busywait = 0;
	
	end
	
	//read cache
	// always @ (*)
	// begin
		
		// if(read || write)
		// begin
			
			// valid <= #1 valid_bit[index];
			// dirty <= #1 dirty_bit[index];
			// tag_cache <= #1 tag_bits[index];
			// block <= #1 cache[index];
			
		// end	
	
	// end
	
	// always @ (*)
	// begin
	
		
		// tag_comparison = #1 (tag_cache == tag)? 1 : 0;
	
	// end
	
	
	//when the block available break it into words
	// always @ (block)
	// begin
		
		// #1 {word4, word3, word2, word1} = block;
		
	// end
	

	
	always @ (*)
	begin
	
		//if hit
		if(hit)
		begin
			
			read_memory = 0;		//desable memory read
			write_memory = 0;		//desable memory write
			write_cache = 0;		//desable write cache
			read_back = 0;			//desable read back (it is for when memory write is complete the memory read should be do)
			read_do = 0;
			write_do = 0;
		
		end
		
		//if not dirt and miss
		if(!dirty && !hit && (read || write))
		begin
			
			read_memory = 1;
			write_memory = 0;
			//write_cache = 1;
			
		end
		
		//if dirty and mis
		if(dirty && !hit && !read_back && !write_memory && (read || write))
		begin
			
			write_memory = 1;
			read_memory = 0;
			
		end
		
		
	end
	
	
	//set memory address for memory write
	always @ (posedge write_memory)
	begin
	
		memory_address = {tag_cache, index};
	
	end
	
	//set memory address for memory read
	always @ (posedge read_memory)
	begin
	
		memory_address = {tag, index};
	
	end
	
	
	//if dirt and miss after write back memory read signal be asserting
	always @ (negedge write_memory)
	begin
		if(read_back) begin
				read_memory = 1;
		end
		
	end
	
	//when data memeory busywait signal de-asserting 
	always @ (negedge busywait_memory)
	begin
		
		//if data memory write happen
		if(write_do)
		begin
		
			read_back = 1;
			write_memory = 0;
			write_do = 0;
			
		end
		
		//if memory read happen
		if(read_do)
		begin
			
			write_cache = 1;
			read_memory = 0;
			read_do = 0;
		
		end
	
	end
	
	
	//here set curruntly working on signals and writting to cache
	always @ (posedge clock)
	begin
		
		//if memory write happen
		if(write_memory)
		begin
			
			write_do = 1;
		
		end
		
		//if memory read happen
		if(read_memory)
		begin
		
			read_do = 1;
		
		end
		
		//write from memory
		if(write_cache && !busywait_memory)
		begin
			
			cache[index] =#1 memory_readdata;		//set cache data
			valid_bit[index] = 1;					//set valid bit
			dirty_bit[index] = 0;					//set  dirty bit
			tag_bits[index] = tag;					//set tag
			write_cache = 0;						//write cache accsess desable
		
		end
		
		//write data to the cache from cpu
		if(write && hit)
		begin
		
			dirty_bit[index] =#1 1;			//set dirty bit
			valid_bit[index] = 1;			//set valid bit
			
			//according to offset data that should update will be setting here
			case(offset)
			
				2'd0: cache[index][7:0] = writedata;
				2'd1: cache[index][15:8] = writedata;
				2'd2: cache[index][23:16] = writedata;
				2'd3: cache[index][31:24] = writedata;
			
			endcase
			
		end
	
	end
	
endmodule


//mux for select data from word
module mux_4_8(out, select, data1, data2, data3, data4);

	input [1:0] select;
	input [7:0] data1, data2, data3, data4;
	
	output reg [7:0] out;
	
	always @ (*)
	begin
		
		//selecting data
		case(select)
		
		2'd0:  out = data1;
		2'd1:  out = data2;
		2'd2:  out = data3;
		2'd3:  out = data4;
		
		endcase
		
	end

endmodule


	// always @ (negedge busywait_memory)
	// begin
	
		// if(read_memory)
		// begin
			
			// read_memory = 0;	
		
		// end
		
		// if(write_back && read)
		// begin
			
			// write_back = 0;
			// read_memory = 1;
			// writeaccess = 1;
			
		// end
	
	// end



// module cache_controll(busywait, write_cache, select_write_cache, read_memory, write_memory, busywait_memory, );

	


// endmodule


	// always @ (*)
	// begin
		
		// if(hit)
		// begin
			// if(read)
			// begin
				
				
			// end
			
			// if(write)
			// begin
				
				// cache_access = 1;
				// writeaccess = 1;
				// busywait = 0;
				
			// end
			
			
		// end
		/////////////////////////////////////////
		// if(!hit)
		// begin
			
			// if(!dirty)
			// begin
				///////////////////////////
				// if(read)
				// begin
					
					// read_memory = 1;
					
				// end
				
				// if(write)
				// begin
					
					// read_memory = 1;
					// writeaccess = 1;
					
				// end
				
			
			// end
			
			// if(dirty)
			// begin
			
				// write_back = 1;
				// write_memory = 1;
			
				// if(read)
				// begin
					
					
					
					
				// end
				
				// if(write)
				// begin
					
					
				
				// end
			
			// end
			
		// end
		
		
	
	// end





// module tag_comparison(same, data1, data2);

	// input [7:0] data1, data2;
	
	// output wire same;
	
	// wire out[13:0];
	
	// always @ (*)
	// begin
		// #1 same = (data1)
	// end
	
	// xor x1(out[0], data1[0], data2[0]);
	// xor x2(out[1], data1[1], data2[1]);
	// xor x3(out[2], data1[2], data2[2]);
	// xor x4(out[3], data1[3], data2[3]);
	// xor x5(out[4], data1[4], data2[4]);
	// xor x6(out[5], data1[5], data2[5]);
	// xor x7(out[6], data1[6], data2[6]);
	// xor x8(out[7], data1[7], data2[7]);
	
	// and a1(out[8], out[0], out[1]);
	// and a2(out[9], out[2], out[3]);
	// and a3(out[10], out[4], out[5]);
	// and a4(out[11], out[6], out[7]);
	
	// and a5(out[12], out[8], out[9]);
	// and a6(out[13], out[10], out[11]);
	
	// and a6(same, out[12], out[13]);
	

// endmodule



