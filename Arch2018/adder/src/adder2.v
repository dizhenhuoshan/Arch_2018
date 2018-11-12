/* ACM Class System (I) 2018 Fall Assignment 1
 *
 * Part I: Write an adder in Verilog
 *
 * Implement your Carry Look Ahead Adder here
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

module four_bit_adder (a, b, p, g, cin, s);
	//This is a 4 bit lookahead adder;
	input 	[3:0] a;
	input 	[3:0] b;
	input 	[3:0] p;
	input 	[3:0] g;
	input 	cin;
	output 	[3:0] s;
	wire 	[3:0] c;
	assign 	c[0] = cin;
	assign 	c[1] = g[0] | (p[0] & cin);
	assign 	c[2] = g[1] | (p[1] & (g[0] | (p[0] & cin)));
	assign 	c[3] = g[2] | (p[2] & (g[1] | (p[1] & (g[0] | (p[0] & cin)))));
	assign 	s = a^b^c;

endmodule // four_bit_adder

// TODO: Write the ports of this module here
//
// Hint:
//   The module needs 4 ports,
//     the first 2 ports input two 16-bit unsigned numbers as the addends
//     the third port outputs a 16-bit unsigned number as the sum
//	   the forth port outputs a 1-bit carry flag as the overflow
//
module adder(adder_opr1, adder_opr2, adder_ans, adder_carry);
	// TODO: Implement this module here
	// Hint: You can use generate statement in Verilog to create multiple instantiations of modules and code.
	input 	[15:0] 	adder_opr1;
	input 	[15:0] 	adder_opr2;
	output 	[15:0] 	adder_ans;
	output 			adder_carry;
	wire 	[15:0] 	p, g;
	wire 	[3:0] 	P, G, c;

	assign p = adder_opr1 | adder_opr2;
	assign g = adder_opr1 & adder_opr2;

	assign P[0] = p[3] & p[2] & p[1] & p[0];
	assign P[1] = p[7] & p[6] & p[5] & p[4];
	assign P[2] = p[11] & p[10] & p[9] & p[8];
	assign P[3] = p[15] & p[14] & p[13] & p[12];
	assign G[0] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
	assign G[1] = g[7] | (p[7] & g[6]) | (p[7] & p[6] & g[5]) | (p[7] & p[6] & p[5] & g[4]);
	assign G[2] = g[11] | (p[11] & g[10]) | (p[11] & p[10] & g[9]) | (p[11] & p[10] & p[9] & g[8]);
	assign G[3] = g[15] | (p[15] & g[14]) | (p[15] & p[14] & g[13]) | (p[15] & p[14] & p[13] & g[12]);

	assign c[0] = G[0];
	assign c[1] = G[1] | (P[1] & c[0]);
	assign c[2] = G[2] | (P[2] & c[1]);
	assign adder_carry = G[3] | (P[3] & c[2]);

	four_bit_adder four_adder1(adder_opr1[3:0], adder_opr2[3:0], p[3:0], g[3:0], 1'b0, adder_ans[3:0]);
	four_bit_adder four_adder2(adder_opr1[7:4], adder_opr2[7:4], p[7:4], g[7:4], c[0], adder_ans[7:4]);
	four_bit_adder four_adder3(adder_opr1[11:8], adder_opr2[11:8], p[11:8], g[11:8], c[1], adder_ans[11:8]);
	four_bit_adder four_adder4(adder_opr1[15:12], adder_opr2[15:12], p[15:12], g[15:12], c[2], adder_ans[15:12]);

endmodule
