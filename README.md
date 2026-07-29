# Design Verification of a Synchronous FIFO Memory

A complete functional verification project for a parameterized synchronous FIFO, built in **SystemVerilog** using a lightweight, class-based testbench — the same layered principles UVM formalizes (generator, driver, monitor, scoreboard, coverage), without the factory/phasing overhead. Verified on **EDA Playground** using **Synopsys VCS**.

The FIFO itself is a 16-deep, 8-bit-wide circular-buffer design using the classic "extra pointer bit" technique to distinguish `full` from `empty`. The testbench drives it through directed corner-case tests (fill-to-full, drain-to-empty, simultaneous read+write, a live mid-test reset) followed by constrained-random stimulus, and checks every result against an independent reference-model scoreboard while tracking functional coverage.

This project was built and debugged iteratively — three real bugs were found and root-caused along the way (a reset race condition, a scoreboard/monitor timing misalignment, and a driver pulse-width bug that briefly caused a silent false-pass). Each is documented below, since finding and fixing them is the actual point of doing verification, not just writing a testbench that runs.

## Highlights

- ✅ Directed tests for `full`, `empty`, overflow/underflow protection, and simultaneous ops
- ✅ Constrained-random stimulus with weighted `wr_en`/`rd_en` distribution
- ✅ Independent scoreboard with a queue-based reference model
- ✅ Functional coverage (signal coverpoints + cross coverage + data-range bins)
- ✅ Mid-simulation reset test to confirm live recovery
- ✅ SVA assertions for `full`/`empty` mutual exclusion and pointer stability
- ✅ 100% functional coverage, 0 outstanding data mismatches

## Repository Structure

```
├── design.sv           # sync_fifo RTL — parameterized DATA_WIDTH / DEPTH
├── interface.sv         # DUT signal bundle (intf)
├── transaction.sv        # Randomizable stimulus item
├── generator.sv         # Directed + randomized stimulus generation
├── driver.sv             # Drives transactions onto the DUT
├── monitor.sv            # Passively samples DUT pins
├── scoreboard.sv         # Reference-model based checker
├── coverage.sv           # Functional coverage (covergroups)
├── environment.sv        # Wires all components together
├── test.sv                # Top-level test program
└── testbench.sv           # Clock/reset generation, DUT instantiation
```

## FIFO Parameters

| Parameter    | Value | Notes                                  |
|--------------|-------|-----------------------------------------|
| `DATA_WIDTH` | 8     | Bits per entry                          |
| `DEPTH`      | 16    | Number of entries                       |
| Pointer width| 5     | `$clog2(DEPTH) + 1` (extra wrap bit)    |

## Running the Project

1. Open a new project on [EDA Playground](https://www.edaplayground.com).
2. Add all `.sv` files from this repo to the Testbench pane (`design.sv` goes in the separate Design pane).
3. Select **Synopsys VCS** as the simulator, enable **Open EPWave after run**.
4. Click **Run**.

## Bugs Found During Verification

| # | Bug | Root Cause | Fix |
|---|-----|-----------|-----|
| 1 | Reset race condition | `rst` deasserted on the same instant as the first `posedge clk` | Hold reset across 2 clock periods, release on `negedge clk` |
| 2 | Scoreboard/monitor timing misalignment | Scoreboard checked `data_out` against the wrong transaction | Check `data_out` within the same transaction the monitor captured |
| 3 | Driver pulse-width bug → silent false-pass | `wr_en`/`rd_en` held 3 cycles instead of 1; fix then exposed a monitor sampling race | Deassert after 1 cycle; sample monitor on `negedge clk` |

## Verification Results

- **Functional coverage:** 100%
- **Full/empty assertion:** confirmed at exactly 16 writes / 0 items via waveform inspection
- **Data ordering:** confirmed correct across fill, drain, and random phases
- **Mid-test reset:** DUT recovers cleanly — pointers and `empty` reset correctly mid-operation

## Author

Vishwathma HP — B.E. Electronics & Communication Engineering, BNM Institute of Technology (VTU)

## License

For academic use.
