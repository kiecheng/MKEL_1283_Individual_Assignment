#include "dpiheader.h"
#include "svdpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// ============================================================================
// File: Ccode.cpp
// Description: Methodology 3 - DPI-C Golden Model (Strict Rubric Compliance)
// ============================================================================

#include <iostream>
#include <iomanip>
#include <cstdlib>

using namespace std;

// ---------------------------------------------------------
// 1. The Golden Model (Static Array)
// ---------------------------------------------------------
uint8_t golden_mem[8192] = {0};

// ---------------------------------------------------------
// 2. Formatted Print Helper
// ---------------------------------------------------------
void check_and_print(string test_name, string port, uint16_t addr, uint8_t exp, uint8_t got) {
    if (exp == got) {
        cout << "   -> PASSED [" << test_name << "] " << port 
             << " | Addr: 0x" << hex << setfill('0') << setw(4) << addr 
             << " | Exp: 0x" << setw(2) << (int)exp 
             << " | Got: 0x" << setw(2) << (int)got << dec << endl;
    } else {
        cout << "   -> FAILED [" << test_name << "] " << port 
             << " | Addr: 0x" << hex << setfill('0') << setw(4) << addr 
             << " | Exp: 0x" << setw(2) << (int)exp 
             << " | Got: 0x" << setw(2) << (int)got << dec << endl;
    }
}

// ---------------------------------------------------------
// 3. Main Test Sequencer
// ---------------------------------------------------------
int run_cpp_test() {
    char dout_a, dout_b;
    uint16_t addr, addr_a, addr_b;
    uint8_t data, data_a, data_b;

    cout << "==================================================" << endl;
    cout << "   STARTING DPI-C GOLDEN MODEL SIMULATION" << endl;
    cout << "==================================================" << endl;

    // Initialize HW (Flush X's from the simulation)
    sv_tick(0, 0, 0, &dout_a, 0, 0, 0, &dout_b);

    // =====================================================
    // CRITERIA 1: Basic Read/Write
    // =====================================================
    cout << "\n[CRITERIA 1] Basic Read/Write..." << endl;
    
    // --- 1A: Verify Port A (Isolated) ---
    cout << "   --- Isolated Port A ---" << endl;
    for (int i = 0; i < 3; i++) {
        addr = rand() % 8192; data = rand() % 256;
        golden_mem[addr] = data;
        
        sv_tick(1, addr, data, &dout_a, 0, 0, 0, &dout_b); // Write A
        sv_tick(0, addr, data,    &dout_a, 0, 0, 0, &dout_b); // Read A
        
        check_and_print("Basic R/W", "Port A", addr, golden_mem[addr], (uint8_t)dout_a);
    }

    // --- 1B: Verify Port B (Isolated) ---
    cout << "   --- Isolated Port B ---" << endl;
    for (int i = 0; i < 3; i++) {
        addr = rand() % 8192; data = rand() % 256;
        golden_mem[addr] = data;
        
        sv_tick(0, 0, 0, &dout_a, 1, addr, data, &dout_b); // Write B
        sv_tick(0, 0, 0, &dout_a, 0, addr, data,    &dout_b); // Read B
        
        check_and_print("Basic R/W", "Port B", addr, golden_mem[addr], (uint8_t)dout_b);
    }

    // --- 1C: Verify Both Ports Simultaneously (Non-Colliding) ---
    cout << "   --- Simultaneous Non-Colliding ---" << endl;
    for (int i = 0; i < 3; i++) {
        // Split memory addresses to prevent accidental collisions here
        addr_a = rand() % 4000;
        addr_b = (rand() % 4000) + 4001; 
        data_a = rand() % 256;
        data_b = rand() % 256;

        golden_mem[addr_a] = data_a;
        golden_mem[addr_b] = data_b;
        
        // Write Both
        sv_tick(1, addr_a, data_a, &dout_a, 1, addr_b, data_b, &dout_b); 
        // Read Both
        sv_tick(0, addr_a, data_a, &dout_a, 0, addr_b, data_b, &dout_b); 
        
        check_and_print("Basic R/W", "Port A", addr_a, golden_mem[addr_a], (uint8_t)dout_a);
        check_and_print("Basic R/W", "Port B", addr_b, golden_mem[addr_b], (uint8_t)dout_b);
    }

    // =====================================================
    // CRITERIA 2: Cross-Port Verification
    // =====================================================
    cout << "\n[CRITERIA 2] Cross-Port Verification (Write A -> Read B)..." << endl;
    for (int i = 0; i < 3; i++) {
        addr = rand() % 8192; data = rand() % 256;
        golden_mem[addr] = data;
        
        sv_tick(1, addr, data, &dout_a, 0, addr, data, &dout_b); // Write A
        sv_tick(0, addr, data, &dout_a, 0, addr, data, &dout_b); // Read B
        
        check_and_print("Cross-Port", "Port B", addr, golden_mem[addr], (uint8_t)dout_b);
    }

    // =====================================================
    // CRITERIA 3: Concurrent Access (The Collision Cases)
    // =====================================================
    cout << "\n[CRITERIA 3] Concurrent Access Scenarios..." << endl;

    // --- 3A. Read-During-Write ---
    uint16_t rdw_addr = 0x0500;
    
    golden_mem[rdw_addr] = 0x22; // Preload data
    sv_tick(1, rdw_addr, 0x22, &dout_a, 0, 0, 0, &dout_b);
    sv_tick(0, rdw_addr, 0x22, &dout_a, 0, 0, 0, &dout_b); // Idle
    
    // The Collision Cycle
    uint8_t old_data = golden_mem[rdw_addr]; 
    golden_mem[rdw_addr] = 0xFF; // Update Golden Model

    sv_tick(1, rdw_addr, 0xFF, &dout_a, 0, rdw_addr, 0, &dout_b);  
    check_and_print("RD-WR Coll.", "Port B", rdw_addr, old_data, (uint8_t)dout_b);
    sv_tick(0, rdw_addr, 0xFF, &dout_a, 0, rdw_addr, 0, &dout_b);



    // --- 3B. Write-Write Collision ---
    uint16_t ww_addr = 0x0700;
    golden_mem[ww_addr] = 0xBB; // Port B wins the SV race condition

    // Both ports strike exactly the same address
    sv_tick(1, ww_addr, 0xAA, &dout_a, 1, ww_addr, 0xBB, &dout_b); 
    
    // Read back via Port A to see who won
    sv_tick(0, ww_addr, 0, &dout_a, 0, ww_addr, 0, &dout_b);
    check_and_print("WR-WR Coll.", "Port A", ww_addr, golden_mem[ww_addr], (uint8_t)dout_a);

    // =====================================================
    // CRITERIA 4: Full Range Sweep (Boundaries)
    // =====================================================
    cout << "\n[CRITERIA 4] Full Range Sweep (Boundaries 0x0000 and 0x1FFF)..." << endl;

    // ==========================================
    // CONCURRENT BOUNDARY CHECK (UVM STYLE)
    // ==========================================

    // --- 1. Write to boundaries (Port A = Min, Port B = Max) ---
    golden_mem[0x0000] = 0x11;
    golden_mem[0x1FFF] = 0x99;
    
    sv_tick(1, 0x0000, golden_mem[0x0000], &dout_a, 1, 0x1FFF, golden_mem[0x1FFF], &dout_b);


    // --- 2. Read from boundaries (Port A = Min, Port B = Max) ---
    sv_tick(0, 0x0000, golden_mem[0x0000], &dout_a, 0, 0x1FFF, golden_mem[0x1FFF], &dout_b);
    
    // Check both ports simultaneously
    check_and_print("Boundary Sweep 1", "Port A", 0x0000, golden_mem[0x0000], (uint8_t)dout_a);
    check_and_print("Boundary Sweep 1", "Port B", 0x1FFF, golden_mem[0x1FFF], (uint8_t)dout_b);


    // --- 3. Swap the boundaries: Write (Port A = Max, Port B = Min) ---
    // Using new data to ensure old values aren't just lingering
    golden_mem[0x1FFF] = 0x22;
    golden_mem[0x0000] = 0x88;
    
    sv_tick(1, 0x1FFF, golden_mem[0x1FFF], &dout_a, 1, 0x0000, golden_mem[0x0000] , &dout_b);


    // --- 4. Swap the boundaries: Read (Port A = Max, Port B = Min) ---
    sv_tick(0, 0x1FFF, golden_mem[0x1FFF], &dout_a, 0, 0x0000, golden_mem[0x0000] , &dout_b);
    
    // Check both ports simultaneously again
    check_and_print("Boundary Sweep 2", "Port A", 0x1FFF, golden_mem[0x1FFF], (uint8_t)dout_a);
    check_and_print("Boundary Sweep 2", "Port B", 0x0000, golden_mem[0x0000], (uint8_t)dout_b);
   
    cout << "\n==================================================" << endl;
    cout << "   DPI-C SIMULATION COMPLETE" << endl;
    cout << "==================================================" << endl;

    return 0; 
}
