// Dual-Port RAM: 8192 words x 8 bits (8KB)
module dual_port_ram (
	input logic clk,
	// Port A Interface
	input logic [12:0] addr_a,
	input logic [7:0] din_a,
	input logic we_a,
	output logic [7:0] dout_a,
	// Port B Interface
	input logic [12:0] addr_b,
	input logic [7:0] din_b,
	input logic we_b,
	output logic [7:0] dout_b
	);
  
	// Memory array: 8192 entries of 8-bit width
	logic [7:0] mem [0:8191];
  
	// Port A Logic
	always_ff @(posedge clk) begin
		if (we_a) begin
			mem[addr_a] <= din_a;
		end
		dout_a <= mem[addr_a];
		end
  
	// Port B Logic
	always_ff @(posedge clk) begin
		if (we_b) begin
			mem[addr_b] <= din_b;
		end
		dout_b <= mem[addr_b];
		end
endmodule