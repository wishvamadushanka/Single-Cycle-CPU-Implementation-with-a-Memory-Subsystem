`timescale 1ns/100ps
module test;

//`timescale 1ns/100ps
//clk,reset
reg clk,reset;
//for initial memory
reg [7:0] inst_memory [1023:0];
//for pass instraction to cpu
//reg [31:0] instruction;

//wire for pc
wire [31:0] pc;

integer i;

wire read_memory,write_memory,busywait, busywait_memory;

wire [7:0] memory_address, memory_writedata, memory_readdata;

wire read_data_memory, write_data_memory;

wire [5:0] data_memory_address;

wire [31:0] data_memory_readdata, data_memory_writedata;



wire [5:0] ins_memory_address;
wire read_ins_memory, read_ins, busywait_ins, busywait_ins_memory;
wire [31:0] instruction;
wire [127:0] cache_memory_readdata;

//cpu module instantiate
cpu mycpu(read_memory, write_memory, memory_address, memory_writedata, pc, memory_readdata, read_ins, busywait, busywait_ins, instruction, clk, reset);

//data_cache memory 
data_cache mycache_memory(clk, reset, read_memory, write_memory, memory_address, memory_writedata, busywait_memory, data_memory_readdata, memory_readdata, busywait, read_data_memory, write_data_memory, data_memory_address,data_memory_writedata);

//data_memory
data_memory mydata_memory(clk, reset, read_data_memory, write_data_memory, data_memory_address, data_memory_writedata, data_memory_readdata, busywait_memory);


data_memory_ins myins_memory(clk, read_ins_memory, ins_memory_address, cache_memory_readdata, busywait_ins_memory);

ins_cache myins_cache(busywait_ins, instruction, read_ins_memory, ins_memory_address,  pc, cache_memory_readdata, read_ins, busywait_ins_memory, clk, reset);


	//wavedata file
	initial
	begin
		$dumpfile("wavedata.vcd");
		$dumpvars(0,test);
		
		//to see registers value in reg_file
		// for(i = 0;i <8; i = i + 1)begin
			// $dumpvars(0, mycpu.myreg_file.Register[i]);
		// end
		
		// for(i = 0;i <8; i = i + 1)begin
			// $dumpvars(0, mycache_memory.cache[i]);
		// end
		
		// for(i = 0;i <8; i = i + 1)begin
			// $dumpvars(0, mycache_memory.dirty_bit[i]);
		// end
		
		// for(i = 0;i <8; i = i + 1)begin
			// $dumpvars(0, mycache_memory.valid_bit[i]);
		// end
		
		// for(i = 0;i <8; i = i + 1)begin
			// $dumpvars(0, mycache_memory.tag_bits[i]);
		// end
		
		
		
		// for(i = 0;i <8; i = i + 1)begin
			// $dumpvars(0, myins_cache.valid_cache[i]);
		// end
		// for(i = 0;i <8; i = i + 1)begin
			// $dumpvars(0, myins_cache.cache_ins[i]);
		// end
		// for(i = 0;i <8; i = i + 1)begin
			// $dumpvars(0, myins_cache.tag_cache[i]);
		// end
			
	end
	
	//initiate instruction_memory
	/*				--------------------
					MEMORY OF INSTRATION
					--------------------
	*/
	// initial
	// begin
		
		
		// {inst_memory[10'd0],inst_memory[10'd1],inst_memory[10'd2],inst_memory[10'd3]} = 32'b00000101000000000000000000000101;
		// {inst_memory[10'd4],inst_memory[10'd5],inst_memory[10'd6],inst_memory[10'd7]} = 32'b00000101000000010000000000000010;
		// {inst_memory[10'd8],inst_memory[10'd9],inst_memory[10'd10],inst_memory[10'd11]} = 32'b00001010000000000000000000000001;
		// {inst_memory[10'd12],inst_memory[10'd13],inst_memory[10'd14],inst_memory[10'd15]} = 32'b00001011000000000000000100000001;
		// {inst_memory[10'd16],inst_memory[10'd17],inst_memory[10'd18],inst_memory[10'd19]} = 32'b00000101000000100000000000100000;
		// {inst_memory[10'd20],inst_memory[10'd21],inst_memory[10'd22],inst_memory[10'd23]} = 32'b00001010000000000000000100000010;
		// {inst_memory[10'd24],inst_memory[10'd25],inst_memory[10'd26],inst_memory[10'd27]} = 32'b00001001000001000000000000100000;
		// {inst_memory[10'd28],inst_memory[10'd29],inst_memory[10'd30],inst_memory[10'd31]} = 32'b00001010000000000000000000000010;
		// {inst_memory[10'd32],inst_memory[10'd33],inst_memory[10'd34],inst_memory[10'd35]} = 32'b00001000000000110000000000000001;
		// {inst_memory[10'd36],inst_memory[10'd37],inst_memory[10'd38],inst_memory[10'd39]} = 32'b00001000000001010000000000000001;
		
		
	// end
	
	//clock 
	always 
	begin
			#4	clk = ~clk;
	end
	
	//running
	initial
	begin
		clk = 1'b1;
		reset = 1'b0;
		reset = 1'b1;
		
		#1 reset = 1'b0;
		
		// #98 reset = 1'b1;
		// #2 reset = 1'b0;
		
		#2398
		$finish;

	end
	
	//if pc is available send instraction according to pc value
	// always @ (pc)
	// begin
		// #2
		// instruction = {inst_memory[pc], inst_memory[pc + 32'd1], inst_memory[pc + 32'd2], inst_memory[pc + 32'd3]};
	// end
	
	 
endmodule





















