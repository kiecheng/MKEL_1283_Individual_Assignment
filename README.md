# Functional Verification of an 8KB Dual-Port RAM Using Classical SV, UVM, and DPI-C

## Overview

This project presents a comparative study of three hardware verification methodologies applied to a synchronous 8 KB Dual-Port RAM:

* Classical SystemVerilog (SV) Testbenching
* Universal Verification Methodology (UVM)
* DPI-C Hardware–Software Co-Simulation with C++

The objective is to evaluate each methodology in terms of verification capability, implementation complexity, scalability, and simulation performance under identical verification scenarios.

---

## Project Objectives

* Verify the functional correctness of a synchronous Dual-Port RAM.
* Implement equivalent verification environments using SV, UVM, and DPI-C.
* Compare execution performance and architectural trade-offs.
* Evaluate the effectiveness of each methodology in handling concurrent memory operations.

---

## Design Under Test (DUT)

### Synchronous 8 KB Dual-Port RAM

| Parameter       | Specification            |
| --------------- | ------------------------ |
| Memory Capacity | 8 KB (8192 × 8-bit)      |
| Address Width   | 13-bit                   |
| Data Width      | 8-bit                    |
| Ports           | 2 Independent Ports      |
| Clocking        | Single Synchronous Clock |

### Key Features

* Independent Port A and Port B access
* Simultaneous read/write capability
* Shared memory array
* Collision and concurrent access support

---

## Verification Methodologies

### 1. Classical SystemVerilog

Directed verification using procedural testbench tasks.

**Characteristics**

* Manual stimulus generation
* Immediate assertion-based checking
* Fast execution
* Simple implementation

**Measured Runtime**

* 0.076 s

---

### 2. Universal Verification Methodology (UVM)

Object-oriented verification framework utilizing reusable verification components.

**Components**

* Sequence
* Sequencer
* Driver
* Monitor
* Scoreboard
* Coverage Subscriber

**Features**

* Constrained-random stimulus generation
* Functional coverage collection
* Automated edge-case detection

**Measured Runtime**

* 0.214 s

---

### 3. DPI-C Co-Simulation

Hybrid verification environment integrating SystemVerilog with a C++ Golden Reference Model.

**Features**

* Cross-language verification
* Cycle-accurate hardware execution
* Algorithmic reference checking
* Software-based golden model

**Measured Runtime**

* 0.207 s

---

## Verification Scenarios

The following test scenarios were executed across all methodologies:

### Basic Read/Write Verification

* Write data to memory
* Read back data
* Verify data integrity

### Cross-Port Verification

* Write using Port A
* Read using Port B
* Confirm shared memory consistency

### Concurrent Access Verification

#### Read-During-Write (RDW)

* Simultaneous read and write to the same address

#### Write-Write Collision

* Simultaneous writes from both ports to the same address

### Full Address Range Verification

* Minimum address (0x0000)
* Maximum address (0x1FFF)

---

## Performance Comparison

| Metric                    | Classical SV | UVM                | DPI-C             |
| ------------------------- | ------------ | ------------------ | ----------------- |
| Stimulus Generation       | Procedural   | Constrained-Random | Algorithmic (C++) |
| Runtime                   | 0.076 s      | 0.214 s            | 0.207 s           |
| Approx. Testbench LOC     | 150          | 450                | 200               |
| Implementation Complexity | Low          | High               | Medium            |
| Scalability               | Low          | High               | Medium-High       |

---

## Tools Used

* Vivado Simulator 2025.2
* SystemVerilog
* UVM
* DPI-C
* C++
* GitHub

All simulations were executed in batch mode to eliminate GUI rendering overhead and ensure accurate runtime profiling.

---

## Key Findings

* Classical SV achieved the fastest execution time but required significant manual effort.
* UVM provided the most scalable and reusable verification architecture through constrained-random verification and functional coverage.
* DPI-C successfully integrated a C++ Golden Model, enabling efficient algorithmic checking while maintaining performance comparable to UVM.
* All methodologies successfully verified read/write functionality, cross-port access, and collision behavior.

---
