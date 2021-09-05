`timescale 1ns/100ps
module control(mux_writedata_select, read_memory, write_memory, jump, branch, wrten, mux_cmplmnt_select, mux_immd_select, alu_op, op_code, busy_wait, busywait_ins, instration);
	
	//`timescale 1ns/100ps
	//control units decode control signals only
	//all signals are generated here and give out to cpu
	
	//input opcode part of the instration
	input [7:0] op_code;
	
	input busy_wait, busywait_ins;
	
	input [31:0] instration;
	
	wire [7:0] opcode;
	//alu_op is the output which select for the alu
	output reg [2:0] alu_op;
	//wrten is write enable signal 
	//mux_immd_select for select signal for the immediate or register output
	//mux_cmplmnt_select for mux select for whether the negetive or possitive vale
	output reg wrten, mux_immd_select, mux_cmplmnt_select, branch, jump, read_memory, write_memory, mux_writedata_select;
	
	assign #1 opcode = op_code;
	//opcode decoding 
			// 0 for add
			// 1 for sub
			// 2 for and
			// 3 for or
			// 4 for mov
			// 5 for lodai
			// 6 for jump
			// 7 for branch
			// 8 for lwd
			// 9 for lwi
			// 10 for swd
			// 11 for swi
			
	//mux_cmplmnt_select 1 means its register value not negetive value
	//mux_immd_select 1 means get immediate part
	
	
	
	always @ (negedge busy_wait)
	begin
		
		read_memory = 0;
		write_memory = 0;
	
	end
	
	
	//if instruction memory is busy all operation will be stall
	//this is come from ins_cache
	always @ (*)
	begin
	
		if(busywait_ins)
		begin
			wrten = 0;
			read_memory = 0;
			write_memory = 0;
			jump = 0;
			branch = 0;
		
		end
	
	end
	
	
	always @ (*)
	begin
		
			case(opcode)
			
				//add
				8'd0: begin
					wrten = 1'b1;					//write enable
					mux_cmplmnt_select = 1'b1;		//chose register output
					mux_immd_select = 1'b0;			//chose not immediate
					alu_op = 3'd1;					//1 select to alu
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'b0;    //alu result
					
				end
				//sub
				8'd1: begin
					wrten = 1'b1;					//write enable
					mux_cmplmnt_select = 1'b0;		//chose register output's 2s complement
					mux_immd_select = 1'b0;			//chose not immediate
					alu_op = 3'd1;					//select for alu 1
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'b0;    //alu result
					
				end
				//and
				8'd2: begin
					wrten = 1'b1;					//write enable
					mux_cmplmnt_select = 1'b1;		//chose register output
					mux_immd_select = 1'b0;			//chose not immediate
					alu_op = 3'd2;					//select for alu 2
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'b0;    //alu result
					
				end
				//or
				8'd3: begin
					wrten = 1'b1;					//write enable
					mux_cmplmnt_select = 1'b1;		//chose register output
					mux_immd_select = 1'b0;			//chose not immediate
					alu_op = 3'd3;					//select for alu 3
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'b0;    //alu result
					
				end
				//mov
				8'd4: begin
					wrten = 1'b1;					//write enable
					mux_cmplmnt_select = 1'b1;		//chose register output
					mux_immd_select = 1'b0;			//chose not immediate
					alu_op = 3'd0;					//select for alu 0
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'b0;    //alu result
					
				end
				//loadi
				8'd5: begin
					wrten = 1'b1;					//write enable
					mux_cmplmnt_select = 1'bx;		//register out is dont care
					mux_immd_select = 1'b1;			//chose immediate
					alu_op = 3'd0;					//select for alu 0
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'b0;    //alu result
					
				end
				//j
				8'd6: begin
					wrten = 1'b0;					//write desable
					mux_cmplmnt_select = 1'bx;		//register out is dont care
					mux_immd_select = 1'bx;			//chose immediate dont care
					alu_op = 3'dx;					//select for alu dont care
					jump = 1'b1;					//jump ennable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'b0;    //alu result
					
				end
				//branch beq
				8'd7: begin
					wrten = 1'b0;					//write desable
					mux_cmplmnt_select = 1'b0;		//register out complement
					mux_immd_select = 1'b0;			//chose immediate 0
					alu_op = 3'd1;					//select for alu 1
					jump = 1'b0;					//jump desable
					branch = 1'b1;					//branch enable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'b0;    //alu result
					
				end
				
				//lwd
				8'd8: begin
					wrten <= 1'b1;					//write desable
					//wrten <= #40 1'b1;				//write enable
					mux_cmplmnt_select <= 1'b1;		//register out complement
					mux_immd_select <= 1'b0;		//chose immediate 0
					alu_op <= 3'd4;					//select for alu 4
					jump <= 1'b0;					//jump desable
					branch <= 1'b0;					//branch desable
					read_memory <= 1'b1;			//read from memory  enable
					write_memory <= 1'b0;			//write to memory desable
					mux_writedata_select <= 1'b1;    //memory out
					
					//read_memory <= #40 1'b0;			//read from memory  desable
				
					
				end
				
				//lwi
				8'd9: begin
					wrten <= 1'b1;					//write desable
					mux_cmplmnt_select <= 1'b0;		//register out complement
					mux_immd_select <= 1'b1;		//chose immediate 0
					alu_op <= 3'd4;					//select for alu 4
					jump <= 1'b0;					//jump desable
					branch <= 1'b0;					//branch desable
					read_memory <= 1'b1;			//read from memory  enable
					write_memory <= 1'b0;			//write to memory desable
					mux_writedata_select <= 1'b1;   //memory out
					
					//wrten <= #40 1'b1;				//write enable
					
					//read_memory <= #40 1'b0;			//read from memory  desable
					
				end
				
				//swd
				8'd10: begin
					wrten = 1'b0;					//write desable
					mux_cmplmnt_select = 1'b1;		//register out complement
					mux_immd_select = 1'b0;			//chose immediate 0
					alu_op = 3'd4;					//select for alu 4
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b1;			//write to memory enable
					mux_writedata_select = 1'bx;    //memory out
					
					//write_memory = #40 1'b0;			//write to memory desable
					
				end
				
				//swi
				8'd11: begin
					wrten = 1'b0;					//write desable
					mux_cmplmnt_select = 1'b0;		//register out complement
					mux_immd_select = 1'b1;			//chose immediate 0
					alu_op = 3'd4;					//select for alu 4
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  enable
					write_memory = 1'b1;			//write to memory desable
					mux_writedata_select = 1'bx;    //memory out
					
					//write_memory = #40 1'b0;			//write to memory desable
					
				end
				
				//default
				default: begin
					wrten = 1'b0;					//write desable
					mux_cmplmnt_select = 1'bx;		//register out is dont care
					mux_immd_select = 1'bx;			//chose immediate dont care
					alu_op = 3'dx;					//select for alu dont care
					jump = 1'b0;					//jump desable
					branch = 1'b0;					//branch desable
					read_memory = 1'b0;				//read from memory  desable
					write_memory = 1'b0;			//write to memory desable
					mux_writedata_select = 1'bx;    //memory out don't care
					
				end
				
			endcase
	
	end
			
			
endmodule