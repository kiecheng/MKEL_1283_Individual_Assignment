`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2026 03:24:35 PM
// Design Name: 
// Module Name: mem_pkg
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

interface mem_if(input logic clk);
    logic [12:0] addr_a, addr_b;
    logic [7:0]  din_a, din_b, dout_a, dout_b;
    logic        we_a, we_b;
endinterface