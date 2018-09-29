/* ACM Class System (I) 2018 Fall Assignment 1
 *
 * Part I: Write an adder in Verilog
 *
 * Implement your naive adder here
 *
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put this file into `Sources'
 *   3. Put `test_adder.v' into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */

module full_adder(a, b, cin, cout, s);
	input 	a;
	input 	b;
	input 	cin;
	output 	cout;
	output 	s;
	wire axorb, abcin, aandb;
	xor u1(axorb, a, b);
	xor u2(s, axorb, cin);
	and u3(abcin, axorb, cin);
	and u4(aandb, a, b);
	or u5(cout, abcin, aandb);
	// assign s = (a ^ b) ^ cin;
	// assign cout = ((a ^ b) & cin) | (a & b);
endmodule // full_adder

// TODO: Write the ports of this module here
//
// Hint:
//   The module needs 4 ports,
//     the first 2 ports input two 16-bit unsigned numbers as the addends
//     the third port outputs a 16-bit unsigned number as the sum
//	   the forth port outputs a 1-bit carry flag as the overflow
//

module adder(op1, op2, result, overflow_flag);
	// TODO: Implement this module here
	// Hint: You can use generate statement in Verilog to create multiple instantiations of modules and code.
	input [15:0] 	op1;
	input [15:0] 	op2;
	output [15:0] 	result;
	output 			overflow_flag;
	wire [15:0] c;
	full_adder full_adder1(op1[0], op2[0], 1'b0, c[0], result[0]);
	full_adder full_adder2(op1[1], op2[1], c[0], c[1], result[1]);
	full_adder full_adder3(op1[2], op2[2], c[1], c[2], result[2]);
	full_adder full_adder4(op1[3], op2[3], c[2], c[3], result[3]);
	full_adder full_adder5(op1[4], op2[4], c[3], c[4], result[4]);
	full_adder full_adder6(op1[5], op2[5], c[4], c[5], result[5]);
	full_adder full_adder7(op1[6], op2[6], c[5], c[6], result[6]);
	full_adder full_adder8(op1[7], op2[7], c[6], c[7], result[7]);
	full_adder full_adder9(op1[8], op2[8], c[7], c[8], result[8]);
	full_adder full_adder10(op1[9], op2[9], c[8], c[9], result[9]);
	full_adder full_adder11(op1[10], op2[10], c[9], c[10], result[10]);
	full_adder full_adder12(op1[11], op2[11], c[10], c[11], result[11]);
	full_adder full_adder13(op1[12], op2[12], c[11], c[12], result[12]);
	full_adder full_adder14(op1[13], op2[13], c[12], c[13], result[13]);
	full_adder full_adder15(op1[14], op2[14], c[13], c[14], result[14]);
	full_adder full_adder16(op1[15], op2[15], c[14], overflow_flag, result[15]);
endmodule
