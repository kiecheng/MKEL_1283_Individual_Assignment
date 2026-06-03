`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2026 10:43:22 AM
// Design Name: 
// Module Name: tb_dual_port_ram
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
// Methodology 1: RTL Testbench
// Target DUT: 8KB Dual-Port RAM (8192 x 8)
// ============================================================================

module tb_dual_port_ram;
    // ---------------------------------------------------------
    // 1. Parameters & Signal Declarations
    // ---------------------------------------------------------
    parameter int NUM_ITERATIONS_A = 3; 
    parameter int NUM_ITERATIONS_B = 3; 

    logic        clk;
    
    // Port A
    logic [12:0] addr_a;
    logic [7:0]  din_a;
    logic        we_a;
    logic [7:0]  dout_a;

    // Port B
    logic [12:0] addr_b;
    logic [7:0]  din_b;
    logic        we_b;
    logic [7:0]  dout_b;

    // Stimulus Variables
    logic [7:0]  read_data;
    logic [7:0]  read_data_b; // Added for concurrent checking

    // ---------------------------------------------------------
    // 2. DUT Instantiation
    // ---------------------------------------------------------
    dual_port_ram dut (
        .clk(clk),
        .addr_a(addr_a), .din_a(din_a), .we_a(we_a), .dout_a(dout_a),
        .addr_b(addr_b), .din_b(din_b), .we_b(we_b), .dout_b(dout_b)
    );

    // ---------------------------------------------------------
    // 3. Clock Generation & EDA Playground Setup
    // ---------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time-unit period
    end

    // ---------------------------------------------------------
    // 4. Execution Tasks (Pass/Fail Assertions)
    // ---------------------------------------------------------
    
// ---------------------------------------------------------
    // 4. Execution Tasks (Pass/Fail Assertions) - CYCLE ALIGNED
    // ---------------------------------------------------------
    
    // Task 1: Isolated Port A Check
    task run_single_rw_check_A(input logic [12:0] target_addr, input logic [7:0] target_data);
        // Cycle 1: Drive Write, then wait for clock edge
        we_a = 1'b1; addr_a = target_addr; din_a = target_data; we_b = 1'b0;
        @(negedge clk); 
        
        // Cycle 2: Drive Read, then wait for clock edge
        we_a = 1'b0; addr_a = target_addr;   
        @(negedge clk);         
        
        // Data is now valid!
        read_data = dout_a;     
        
        assert (read_data == target_data) 
            $display("   -> PASSED [Port A]  : Addr %04h | Wrote: %02h | Read: %02h", target_addr, target_data, read_data);
        else 
            $error("   -> FAILED [Port A]  : Addr %04h | Exp: %02h | Got: %02h", target_addr, target_data, read_data);
    endtask

    // Task 2: Isolated Port B Check
    task run_single_rw_check_B(input logic [12:0] target_addr, input logic [7:0] target_data);
        // Cycle 1: Drive Write
        we_b = 1'b1; addr_b = target_addr; din_b = target_data; we_a = 1'b0;
        @(negedge clk); 
        
        // Cycle 2: Drive Read
        we_b = 1'b0; addr_b = target_addr;   
        @(negedge clk);         
        
        read_data = dout_b;     
        
        assert (read_data == target_data) 
            $display("   -> PASSED [Port B]  : Addr %04h | Wrote: %02h | Read: %02h", target_addr, target_data, read_data);
        else 
            $error("   -> FAILED [Port B]  : Addr %04h | Exp: %02h | Got: %02h", target_addr, target_data, read_data);
    endtask

    // Task 3: Concurrent Check 
    task run_concurrent_rw_check(input logic [12:0] t_addr_a, input logic [7:0] t_data_a, input logic [12:0] t_addr_b, input logic [7:0] t_data_b);
        // Cycle 1: Drive Writes
        we_a = 1'b1; addr_a = t_addr_a; din_a = t_data_a;
        we_b = 1'b1; addr_b = t_addr_b; din_b = t_data_b;
        @(negedge clk); 
        
        // Cycle 2: Drive Reads
        we_a = 1'b0; addr_a = t_addr_a;
        we_b = 1'b0; addr_b = t_addr_b;
        @(negedge clk);         
        
        read_data   = dout_a;
        read_data_b = dout_b;
        
        assert (read_data == t_data_a && read_data_b == t_data_b) 
            $display("   -> PASSED [Concurr] : [A] Addr %04h (Data %02h) | [B] Addr %04h (Data %02h)", t_addr_a, read_data, t_addr_b, read_data_b);
        else 
            $error("   -> FAILED [Concurr] : Match Failed! A_Got: %02h, B_Got: %02h", read_data, read_data_b);
    endtask

    // Task 4: Cross-Port Check 
    task run_cross_port_check(input logic [12:0] target_addr, input logic [7:0] target_data);
        // Cycle 1: Drive Write on Port A
        we_a = 1'b1; addr_a = target_addr; din_a = target_data; we_b = 1'b0;
        @(negedge clk); 
        
        // Cycle 2: Drive Read on Port B
        we_a = 1'b0; we_b = 1'b0; addr_b = target_addr;   
        @(negedge clk);         
        
        read_data = dout_b;     
        
        assert (read_data == target_data) 
            $display("   -> PASSED [Cross]   : Addr %04h | Wrote (A): %02h | Read (B): %02h", target_addr, target_data, read_data);
        else 
            $error("   -> FAILED [Cross]   : Addr %04h | Exp: %02h | Got: %02h", target_addr, target_data, read_data);
    endtask


    // ---------------------------------------------------------
    // 5. Main Test Sequencer 
    // ---------------------------------------------------------
    initial begin
        $display("==================================================");
        $display("   STARTING ULTIMATE RTL TESTBENCH SIMULATION");
        $display("==================================================");

        // --- System Initialization ---
        we_a = 0; addr_a = 0; din_a = 0;
        we_b = 0; addr_b = 0; din_b = 0;
        repeat(1) @(negedge clk); 

        // -----------------------------------------------------
        // PHASE 1: Isolated R/W
        // -----------------------------------------------------
        $display("\n[PHASE 1] Running %0d Isolated R/W on Port A...", NUM_ITERATIONS_A);
        repeat (NUM_ITERATIONS_A) begin
            run_single_rw_check_A($urandom_range(0, 8191), $urandom_range(0, 255));
        end

        $display("\n[PHASE 1] Running %0d Isolated R/W on Port B...", NUM_ITERATIONS_B);
        repeat (NUM_ITERATIONS_B) begin
            run_single_rw_check_B($urandom_range(0, 8191), $urandom_range(0, 255));
        end

        // -----------------------------------------------------
        // PHASE 2: Concurrent Stress Test (NEW)
        // -----------------------------------------------------
        $display("\n[PHASE 2] Running %0d Concurrent R/W on Both Ports...", NUM_ITERATIONS_B);
        repeat (NUM_ITERATIONS_B) begin
            // Split memory spaces to prevent accidental collisions during the random stress test
            run_concurrent_rw_check($urandom_range(0, 4000), $urandom_range(0, 255), 
                                    $urandom_range(4001, 8191), $urandom_range(0, 255));
        end

        // -----------------------------------------------------
        // PHASE 3: Cross-Port Verification
        // -----------------------------------------------------
        $display("\n[PHASE 3] Running %0d Random Cross-Port Checks...", NUM_ITERATIONS_A);
        repeat (NUM_ITERATIONS_A) begin
            run_cross_port_check($urandom_range(0, 8191), $urandom_range(0, 255));
        end

        // -----------------------------------------------------
        // PHASE 4: Directed Collision Scenarios
        // -----------------------------------------------------
        $display("\n[PHASE 4] Executing Collision Scenarios...");

        // --- 4A. Read-During-Write ---
        run_single_rw_check_A(13'h0500, 8'h22); // Pre-load known data
        
       // @(negedge clk); 
        we_a = 1'b1; addr_a = 13'h0500; din_a = 8'hFF; // Port A overwrites
        we_b = 1'b0; addr_b = 13'h0500;                // Port B reads simultaneously

        @(negedge clk);        
        we_a = 1'b0; // Drop write enable
        
        assert (dout_b == 8'h22) 
            $display("   -> PASSED [RD-WR]   : Addr %04h | A Wrote: FF | B Read: %02h (Old Data)", addr_a, dout_b);
        else 
            $warning("   -> FAILED [RD-WR]   : Addr %04h | Expected: 22 | Got: %02h", addr_a, dout_b);

        // --- 4B. Write-Write Collision ---
        @(negedge clk);
        we_a = 1'b1; addr_a = 13'h0700; din_a = 8'hAA; 
        we_b = 1'b1; addr_b = 13'h0700; din_b = 8'hBB; 

        @(negedge clk);
        we_a = 1'b0; we_b = 1'b0; addr_a = 13'h0700; // Setup read back on Port A

        @(negedge clk);
        read_data = dout_a; 
        
        // Log the collision winner based on our hardware discovery (Port B usually wins and outputs BB)
        $display("   -> INFO   [WR-WR]   : Addr %04h | A Wrote: AA | B Wrote: BB | Final State: %02h", addr_a, read_data);

        // -----------------------------------------------------
        // PHASE 5: Full Range Sweep (Directed Boundaries)
        // -----------------------------------------------------
        $display("\n[PHASE 5] Sweeping Fixed Boundaries (0x0000 and 0x1FFF)...");
        run_concurrent_rw_check(13'h0000, 8'h11, 13'h1FFF, 8'h99);
        run_concurrent_rw_check(13'h1FFF, 8'h22, 13'h0000, 8'h88);

        // -----------------------------------------------------
        // End of Simulation
        // -----------------------------------------------------
        $display("\n==================================================");
        $display("   SIMULATION COMPLETE");
        $display("==================================================\n");
        $finish;
    end

endmodule
