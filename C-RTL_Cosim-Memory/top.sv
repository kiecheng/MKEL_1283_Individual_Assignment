// ============================================================================
// File: tb_dpi.sv
// Description: Methodology 3 - Hardware Interface for C++ Simulation
// ============================================================================

module top;

    logic clk;
    
    // Hardware Pins
    logic [12:0] tb_addr_a, tb_addr_b;
    logic [7:0]  tb_din_a,  tb_din_b;
    logic        tb_we_a,   tb_we_b;
    logic [7:0]  tb_dout_a, tb_dout_b;

    // Instantiation
    dual_port_ram dut (
        .clk(clk),
        .addr_a(tb_addr_a), .din_a(tb_din_a), .we_a(tb_we_a), .dout_a(tb_dout_a),
        .addr_b(tb_addr_b), .din_b(tb_din_b), .we_b(tb_we_b), .dout_b(tb_dout_b)
    );

    // Physical Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // EXPORT TO C++: The Tick Function
    // ---------------------------------------------------------
    export "DPI-C" task sv_tick;

    task sv_tick(
        input  byte unsigned     c_we_a, 
        input  shortint unsigned c_addr_a, 
        input  byte unsigned     c_din_a, 
        output byte unsigned     c_dout_a,
        
        input  byte unsigned     c_we_b, 
        input  shortint unsigned c_addr_b, 
        input  byte unsigned     c_din_b, 
        output byte unsigned     c_dout_b
    );

        // Drive Inputs
        tb_we_a   = c_we_a;
        tb_addr_a = c_addr_a[12:0];
        tb_din_a  = c_din_a;
        
        tb_we_b   = c_we_b;
        tb_addr_b = c_addr_b[12:0];
        tb_din_b  = c_din_b;

        // Advance 1 Clock Cycle
        @(negedge clk); 

        // Read Outputs
        c_dout_a = tb_dout_a;
        c_dout_b = tb_dout_b;
    endtask

    // ---------------------------------------------------------
    // IMPORT FROM C++: The Main Test Sequencer
    // ---------------------------------------------------------
    import "DPI-C" context task run_cpp_test();

    initial begin
        
        // Hand complete control over to C++
        run_cpp_test();
        
        $finish;
    end

endmodule
