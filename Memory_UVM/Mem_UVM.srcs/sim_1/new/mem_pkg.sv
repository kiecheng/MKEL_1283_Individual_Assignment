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

// ============================================================================
// Methodology 2: UVM Testbench (Aligned with Lecture Slides Pg 13-23)
// Target DUT: 8KB Dual-Port RAM (8192 x 8)
// ============================================================================

// ============================================================================
// File: mem_pkg.sv
// Description: UVM Software Components
// ============================================================================

`include "uvm_macros.svh"

package mem_pkg;
    import uvm_pkg::*;

    // ---------------------------------------------------------
    // 1. TRANSACTION ITEM 
    // ---------------------------------------------------------
    class mem_item extends uvm_sequence_item;
        rand logic [12:0] addr_a, addr_b;
        rand logic [7:0]  din_a, din_b;
        rand logic        we_a, we_b;
        logic [7:0]       dout_a, dout_b; 

        `uvm_object_utils_begin(mem_item)
            `uvm_field_int(addr_a, UVM_ALL_ON)
            `uvm_field_int(din_a,  UVM_ALL_ON)
            `uvm_field_int(we_a,   UVM_ALL_ON)
            `uvm_field_int(dout_a, UVM_ALL_ON)
            `uvm_field_int(addr_b, UVM_ALL_ON)
            `uvm_field_int(din_b,  UVM_ALL_ON)
            `uvm_field_int(we_b,   UVM_ALL_ON)
            `uvm_field_int(dout_b, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "mem_item");
            super.new(name);
        endfunction
    endclass

    // ---------------------------------------------------------
    // 2. THE SCENES (Child Sequences)
    // ---------------------------------------------------------
    

    // --- SCENE 1 & 2: The Sequential Stress Test ---
    class scene_1_2_seq extends uvm_sequence #(mem_item);
        `uvm_object_utils(scene_1_2_seq)

        function new(string name = "scene_1_2_seq");
            super.new(name);
        endfunction

        task body();
            mem_item req;
            logic [12:0] saved_addr;
            logic [12:0] saved_addr_a, saved_addr_b;

            `uvm_info("SEQ", "=== EXECUTING SCENE 1 & 2 (SEQUENTIAL ISOLATION & CROSS) ===", UVM_LOW)
            
            // -----------------------------------------------------
            // CLASSICAL SPEC 1A: Port A Isolation (8 Iterations)
            // -----------------------------------------------------
            `uvm_info("SEQ", "Running 3 Random R/W on Port A...", UVM_LOW)
            repeat(3) begin 
                // Write Port A (Port B is forced idle: we_b=0)
                req = mem_item::type_id::create("req"); start_item(req);
                if (!req.randomize() with { we_a == 1; we_b == 0; }) `uvm_error("SEQ", "Rand failed")
                saved_addr = req.addr_a;
                finish_item(req);

                // Read Port A
                req = mem_item::type_id::create("req"); start_item(req);
                if (!req.randomize() with { we_a == 0; we_b == 0; addr_a == saved_addr; }) `uvm_error("SEQ", "Rand failed")
                finish_item(req);
            end

            // -----------------------------------------------------
            // CLASSICAL SPEC 1B: Port B Isolation (5 Iterations)
            // -----------------------------------------------------
            `uvm_info("SEQ", "Running 3 Random R/W on Port B...", UVM_LOW)
            repeat(3) begin 
                // Write Port B (Port A is forced idle: we_a=0)
                req = mem_item::type_id::create("req"); start_item(req);
                if (!req.randomize() with { we_a == 0; we_b == 1; }) `uvm_error("SEQ", "Rand failed")
                saved_addr = req.addr_b;
                finish_item(req);

                // Read Port B
                req = mem_item::type_id::create("req"); start_item(req);
                if (!req.randomize() with { we_a == 0; we_b == 0; addr_b == saved_addr; }) `uvm_error("SEQ", "Rand failed")
                finish_item(req);
            end
            
            `uvm_info("SEQ", "=== EXECUTING SCENE 1 & 2 (WRITE-THEN-READ STRESS) ===", UVM_LOW)
    
            repeat(3) begin 
                // Write Operation
                req = mem_item::type_id::create("req"); start_item(req);
                if (!req.randomize() with { 
                    we_a == 1; 
                    we_b == 1; 
                    addr_a inside {[13'h0000:13'h0FA0]}; // 0 to 4000 (Decimal)
                    addr_b inside {[13'h0FA1:13'h1FFF]}; // 4001 to 8191 (Decimal)
                }) `uvm_error("SEQ", "Rand failed")
                saved_addr_a = req.addr_a;
                saved_addr_b = req.addr_b;
                finish_item(req);

                // Read Operation
                req = mem_item::type_id::create("req"); start_item(req);
                if (!req.randomize() with { 
                    we_a == 0; 
                    we_b == 0; 
                    addr_a == saved_addr_a; 
                    addr_b == saved_addr_b; 
                }) `uvm_error("SEQ", "Rand failed")
                finish_item(req);
            end 
            
            // -----------------------------------------------------
            // CLASSICAL SPEC 2: Cross-Port Verification (8 Iterations)
            // -----------------------------------------------------
            `uvm_info("SEQ", "Running 3 Cross-Port Checks (Write A -> Read B)...", UVM_LOW)
            repeat(3) begin 
                // Write on Port A
                req = mem_item::type_id::create("req"); start_item(req);
                if (!req.randomize() with { we_a == 1; we_b == 0; addr_b == req.addr_a;}) `uvm_error("SEQ", "Rand failed")
                saved_addr = req.addr_a;
                finish_item(req);

                // Read exactly that address on Port B
                req = mem_item::type_id::create("req"); start_item(req);
                if (!req.randomize() with { we_a == 0; we_b == 0; addr_b == saved_addr;}) `uvm_error("SEQ", "Rand failed")
                finish_item(req);
            end

        endtask
    endclass

    // --- SCENE 3: Collisions ---
    class scene_3_seq extends uvm_sequence #(mem_item);
        `uvm_object_utils(scene_3_seq)

        function new(string name = "scene_3_seq");
            super.new(name);
        endfunction

        task body();
            mem_item req;
            `uvm_info("SEQ", "=== EXECUTING SCENE 3 (COLLISIONS) ===", UVM_LOW)

            // Setup
            req = mem_item::type_id::create("req"); start_item(req);
            req.randomize() with { addr_a == 13'h0500; we_a == 1; we_b == 0; din_a == 8'h22; };
            finish_item(req);
            
            // Read-During-Write Collision
            req = mem_item::type_id::create("req"); start_item(req);
            req.randomize() with {addr_a == 13'h0500; we_a == 0; we_b == 0; din_a == 8'h22; };
            finish_item(req);

            // Read-During-Write Collision
            req = mem_item::type_id::create("req"); start_item(req);
            req.randomize() with { addr_a == 13'h0500; addr_b == 13'h0500; we_a == 1; we_b == 0; din_a == 8'hFF; };
            finish_item(req);
            
            // Read-During-Write Collision
            req = mem_item::type_id::create("req"); start_item(req);
            req.randomize() with {addr_a == 13'h0500; addr_b == 13'h0500; we_a == 0; we_b == 0; din_a == 8'hFF; };
            finish_item(req);

            // Write-Write Collision
            req = mem_item::type_id::create("req"); start_item(req);
            req.randomize() with { addr_a == 13'h0700; addr_b == 13'h0700; we_a == 1; we_b == 1; din_a == 8'hAA; din_b == 8'hBB; };
            finish_item(req);
            
            // Read back the collision result (Matches Classical Phase 4B)
            req = mem_item::type_id::create("req"); start_item(req);
            req.randomize() with {addr_a == 13'h0700; addr_b == 13'h0700; we_a == 0; we_b == 0; din_a == 8'hAA; din_b == 8'hBB; };
            finish_item(req);

        endtask
    endclass

    // --- SCENE 4: Boundaries ---
    class scene_4_seq extends uvm_sequence #(mem_item);
        `uvm_object_utils(scene_4_seq)

        function new(string name = "scene_4_seq");
            super.new(name);
        endfunction

        task body();
            mem_item req;
            `uvm_info("SEQ", "=== EXECUTING SCENE 4 (BOUNDARY SWEEP) ===", UVM_LOW)

            // Write to boundaries
            req = mem_item::type_id::create("req"); start_item(req);
            req.randomize() with { addr_a == 13'h0000; addr_b == 13'h1FFF; we_a == 1; we_b == 1; };
            finish_item(req);
            
            // Read from boundaries
            req = mem_item::type_id::create("req"); start_item(req);
            req.randomize() with { addr_a == 13'h0000; addr_b == 13'h1FFF; we_a == 0; we_b == 0; };
            finish_item(req);

	        req = mem_item::type_id::create("req"); start_item(req);
	        req.randomize() with { addr_a == 13'h1FFF; addr_b == 13'h0000; we_a == 1; we_b == 1; };
	        finish_item(req);

            // Swap the boundaries: Read
	        req = mem_item::type_id::create("req"); start_item(req);
	        req.randomize() with { addr_a == 13'h1FFF; addr_b == 13'h0000; we_a == 0; we_b == 0; };
	        finish_item(req);
        endtask
    endclass

    // ---------------------------------------------------------
    // 3. MASTER SEQUENCE (The Conductor)
    // ---------------------------------------------------------
    class mem_master_sequence extends uvm_sequence #(mem_item);
        `uvm_object_utils(mem_master_sequence)

        function new(string name = "mem_master_sequence");
            super.new(name);
        endfunction

        task body();
            scene_1_2_seq seq_1_2;
            scene_3_seq   seq_3;
            scene_4_seq   seq_4;

            `uvm_info("MASTER_SEQ", "=== STARTING MASTER SEQUENCE ===", UVM_LOW)

            seq_1_2 = scene_1_2_seq::type_id::create("seq_1_2");
            seq_3   = scene_3_seq::type_id::create("seq_3");
            seq_4   = scene_4_seq::type_id::create("seq_4");

            // Execute all three scenes in strict order
            seq_1_2.start(m_sequencer); 
            seq_3.start(m_sequencer);   
            seq_4.start(m_sequencer);

            `uvm_info("MASTER_SEQ", "=== MASTER SEQUENCE COMPLETE ===", UVM_LOW)
        endtask
    endclass

    // ---------------------------------------------------------
    // 4. LOW-LEVEL COMPONENTS ( & Monitor)
    // ---------------------------------------------------------
    class mem_driver extends uvm_driver #(mem_item);
        `uvm_component_utils(mem_driver)
        virtual mem_if vif;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif))
                `uvm_fatal("DRV", "Could not get vif")
        endfunction

      task run_phase(uvm_phase phase);
        // 1. Initialize variables
        vif.we_a <= 0; vif.addr_a <= 0; vif.din_a <= 0;
        vif.we_b <= 0; vif.addr_b <= 0; vif.din_b <= 0;
    
        // 2. Sync to the clock ONCE before the loop begins
        @(negedge vif.clk);
    
            forever begin
                // Fetch the item immediately
                seq_item_port.get_next_item(req);
        
                // 3. Drive signals immediately (non-blocking update for the upcoming posedge)
                vif.we_a   <= req.we_a;
                vif.addr_a <= req.addr_a;
                vif.din_a  <= req.din_a;
                vif.we_b   <= req.we_b;
                vif.addr_b <= req.addr_b;
                vif.din_b  <= req.din_b;
        
                // 4. Hold the stimulus for exactly ONE clock cycle
                @(negedge vif.clk);
        
                // 5. Instantly tell the sequencer we are done so it fetches the next item for the very next clock cycle
                seq_item_port.item_done();
            end
        endtask 
    endclass

    class mem_monitor extends uvm_monitor;
        `uvm_component_utils(mem_monitor)
        virtual mem_if vif;
        uvm_analysis_port #(mem_item) mon_ap;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            mon_ap = new("mon_ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif))
                `uvm_fatal("MON", "Could not get vif")
        endfunction

        task run_phase(uvm_phase phase);
            mem_item item;
            @(negedge vif.clk); 
            
            forever begin
                item = mem_item::type_id::create("item");
                
                // 1. Sample inputs exactly half a cycle after the driver applies them
                @(posedge vif.clk); 
                item.we_a   = vif.we_a;
                item.addr_a = vif.addr_a;
                item.din_a  = vif.din_a;
                item.we_b   = vif.we_b;
                item.addr_b = vif.addr_b;
                item.din_b  = vif.din_b;
                
                // 2. Sample outputs after the RTL has evaluated them
                @(negedge vif.clk); 
                item.dout_a = vif.dout_a;
                item.dout_b = vif.dout_b;
                
                // 3. Broadcast to the scoreboard
                mon_ap.write(item);
                
                // DO NOT add another wait state here! 
                // The loop immediately returns to wait for the next posedge, staying perfectly in sync with the driver.
            end
        endtask
    endclass

    // ---------------------------------------------------------
    // 5. ANALYSIS COMPONENTS (Scoreboard & Coverage)
    // ---------------------------------------------------------
    class mem_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(mem_scoreboard)
        uvm_analysis_imp #(mem_item, mem_scoreboard) sb_export;
        logic [7:0] ref_mem [0:8191];

        function new(string name = "mem_scoreboard", uvm_component parent = null);
            super.new(name, parent);
            sb_export = new("sb_export", this);
            foreach(ref_mem[i]) ref_mem[i] = 8'hxx; 
        endfunction

        function void write(mem_item item);
            // Capture expected data BEFORE any new writes update the ref_mem
            logic [7:0] exp_a = ref_mem[item.addr_a];
            logic [7:0] exp_b = ref_mem[item.addr_b];
            
            // 1. Update the reference memory & Log Collisions
            if (item.we_a && item.we_b && (item.addr_a == item.addr_b)) begin
                ref_mem[item.addr_a] = item.din_b; // Port B wins write-write collision
                
                // --> NEW: Explicitly log the Write-Write Collision details <--
                `uvm_info("SB COLLISION", $sformatf("WR-WR at Addr: %04h | Port A Wrote: %02h | Port B Wrote (WINNER): %02h", item.addr_a, item.din_a, item.din_b), UVM_LOW)
                
            end else begin
                // Normal sequential logic
                if (item.we_a) ref_mem[item.addr_a] = item.din_a;
                if (item.we_b) ref_mem[item.addr_b] = item.din_b;
            end

            // 2. Check Port A
            if (!item.we_a) begin 
                if (exp_a !== 8'hxx) begin
                    if (item.dout_a === exp_a) begin
                        `uvm_info("SB PASS", $sformatf("MATCH [A] Addr: %04h | Wrote: %02h | Read: %02h", item.addr_a, exp_a, item.dout_a), UVM_LOW)
                    end else begin
                        `uvm_error("SB FAIL", $sformatf("MISMATCH [A] Addr: %04h | Exp: %02h, Got: %02h", item.addr_a, exp_a, item.dout_a))
                    end
                end
            end

            // 3. Check Port B
            if (!item.we_b) begin
                if (exp_b !== 8'hxx) begin
                    if (item.dout_b === exp_b) begin
                        `uvm_info("SB PASS", $sformatf("MATCH [B] Addr: %04h | Wrote: %02h | Read: %02h", item.addr_b, exp_b, item.dout_b), UVM_LOW)
                    end else begin
                        `uvm_error("SB FAIL", $sformatf("MISMATCH [B] Addr: %04h | Exp: %02h, Got: %02h", item.addr_b, exp_b, item.dout_b))
                    end
                end
            end
        endfunction 
    endclass

    class mem_coverage extends uvm_subscriber #(mem_item);
        `uvm_component_utils(mem_coverage)
        mem_item item;

        covergroup mem_cg;
            cp_we_a: coverpoint item.we_a;
            cp_we_b: coverpoint item.we_b;
            cp_addr_a: coverpoint item.addr_a {
                bins min_addr = {13'h0000};
                bins max_addr = {13'h1FFF};
                bins others   = {[13'h0001:13'h1FFE]};
            }
            cross_we: cross cp_we_a, cp_we_b;
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            mem_cg = new();
        endfunction

        function void write(mem_item t);
            item = t;
            mem_cg.sample();
        endfunction
    endclass

    // ---------------------------------------------------------
    // 6. HIGHER-LEVEL CONTAINERS (Agent & Env)
    // ---------------------------------------------------------
    class mem_agent extends uvm_agent;
        `uvm_component_utils(mem_agent)
        mem_driver    driver;
        uvm_sequencer #(mem_item) sequencer;
        mem_monitor   monitor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            driver    = mem_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer#(mem_item)::type_id::create("sequencer", this);
            monitor   = mem_monitor::type_id::create("monitor", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction
    endclass

    class mem_env extends uvm_env;
        `uvm_component_utils(mem_env)
        mem_agent      agent;
        mem_scoreboard sb;
        mem_coverage   cov;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = mem_agent::type_id::create("agent", this);
            sb    = mem_scoreboard::type_id::create("sb", this);
            cov   = mem_coverage::type_id::create("cov", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            agent.monitor.mon_ap.connect(sb.sb_export);
            agent.monitor.mon_ap.connect(cov.analysis_export);
        endfunction
    endclass

    // ---------------------------------------------------------
    // 7. TOP-LEVEL TEST (The Clean Manager)
    // ---------------------------------------------------------
    class mem_test extends uvm_test;
        `uvm_component_utils(mem_test)
        mem_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = mem_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            mem_master_sequence master_seq;
            
            phase.raise_objection(this);
            master_seq = mem_master_sequence::type_id::create("master_seq");

            `uvm_info("TEST", "Handing control to Master Sequence...", UVM_LOW)
            master_seq.start(env.agent.sequencer);
            
            phase.drop_objection(this);
        endtask
    endclass

endpackage 
