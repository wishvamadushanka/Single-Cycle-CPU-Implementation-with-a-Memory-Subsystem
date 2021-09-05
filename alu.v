`timescale 1ns/100ps
module alu(ADDRESS, ZERO, RESULT, DATA1, DATA2, SELECT);		
	//this is alu module
	//`timescale 1ns/100ps
	//initial input output
	input [7:0] DATA1,DATA2;
	output reg [7:0] RESULT, ADDRESS;
	input [2:0] SELECT;
	output wire ZERO;
	
	wire [7:0] forward_op, add_op, and_op, or_op, address_op;
	//reg [7:0] add_op1;
	
	
	assign #1 forward_op = DATA2; //#1
	assign #2 add_op =  DATA1 + DATA2;	//#2
	assign #1 and_op = DATA1 & DATA2; //#1
	assign #1 or_op = DATA1 | DATA2; //#1
	assign #1 address_op = DATA2; //#1
	
	// always @ (DATA1,DATA2)
	// begin
		
		// #2 add_op = DATA1 + DATA2;
	
	// end

	//always block
	//always @ (DATA1,DATA2,SELECT)
	//always @ (DATA1, DATA2, SELECT)
	always @ (*)
	begin

		case(SELECT)

			//load word
			3'b000 : begin

					 //generate result
					RESULT = forward_op;		//get result

					 end

			//add
			3'b001 : begin

					 //generate result	
					RESULT = add_op;	//result
					 end

			//and
			3'b010 : begin

					 //generate result					//delay 1 unit
					RESULT = and_op;	//get result
					 end

			//or
			3'b011 : begin

					 //generate result						//delay 1 unit
					RESULT = or_op;	//get result

					 end
					 
			//lwd		 
			3'b100 : begin

					 //generate result					//delay 1 unit
					ADDRESS = address_op;			//get result
					 //RESULT = 8'dx;

					 end

			//reserved
			default : begin 
					RESULT = 8'bxxxxxxxx;
					 end
					 

		endcase
		

	end
	
	// always @ (RESULT)
	// begin
		// if(RESULT == 1'b0)
			// begin
				// ZERO = 1'b1;
			// end
		// else
			// begin
				// ZERO = 1'b0;
			// end
	// end
	wire [7:0] out;
	wire [5:0] outand;
	
	//to get zero signal use not and and gates
	not not1(out[0], RESULT[0]);
	not not2(out[1], RESULT[1]);
	not not3(out[2], RESULT[2]);
	not not4(out[3], RESULT[3]);
	not not5(out[4], RESULT[4]);
	not not6(out[5], RESULT[5]);
	not not7(out[6], RESULT[6]);
	not not8(out[7], RESULT[7]);
	
	and and1(outand[0], out[0], out[1]);
	and and2(outand[1], out[2], outand[0]);
	and and3(outand[2], out[3], outand[1]);
	and and4(outand[3], out[4], outand[2]);
	and and5(outand[4], out[5], outand[3]);
	and and6(outand[5], out[6], outand[4]);
	and and7(ZERO, out[7], outand[5]);
	

endmodule










