`include "uvm_macros.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2026 03:24:35 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ============================================================================
// File: top.sv
// Description: UVM Top-Level Module
// ============================================================================

module top;
    import uvm_pkg::*;
    import mem_pkg::*;

    logic clk;

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Interface Instantiation
    mem_if vif(clk);

    // DUT Instantiation
    dual_port_ram dut (
        .clk(vif.clk),
        .addr_a(vif.addr_a), .din_a(vif.din_a), .we_a(vif.we_a), .dout_a(vif.dout_a),
        .addr_b(vif.addr_b), .din_b(vif.din_b), .we_b(vif.we_b), .dout_b(vif.dout_b)
    );

    // Start UVM
    initial begin
        uvm_config_db#(virtual mem_if)::set(null, "*", "vif", vif);
        run_test("mem_test");
    end

endmodule