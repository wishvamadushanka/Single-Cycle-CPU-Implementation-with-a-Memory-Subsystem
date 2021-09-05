`timescale 1ns/100ps
module reg_file (OUT1, OUT2, IN, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);
	
	//`timescale 1ns/100ps
	//register file
	
	//initialize input output
	input [7:0] IN;								//input data to write
	input [2:0] OUT1ADDRESS, OUT2ADDRESS;		//address of register that should read
	input [2:0] INADDRESS;						//address of writting register
	input  WRITE, CLK, RESET;					//enable sigle to write, clock, reset signal
	output reg [7:0] OUT1, OUT2;				//output of readed register
	reg [7:0] Register [7:0];					//8bit 8 register
	integer j;									//for for loop

	//writting part
	always @ (posedge CLK)			
	begin


		//writting part
		if(WRITE)

		#1			//delay 2 unit
		begin
			Register[INADDRESS] <= IN;		//assign
		end


	end



	//this is reading part
	always @ (*)
	begin

		//output
		#2									//delay 2 unit
		OUT1 = Register[OUT1ADDRESS];		//assign
		OUT2 = Register[OUT2ADDRESS];		//assign


	end



	//resetting part
	always @ (*)
	begin 

		//reset part
		if(RESET)
		begin

				//reset regester
				#2									//delay 2 unit
				//Register[7] <= 8'd5;
				for(j = 0; j <= 7; j = j +1 )
				begin
					Register[j] <= 8'b00000000;			//assigning 

				end
				
				//OUT2 <= Register[7];
				
		end
	end

endmodule








