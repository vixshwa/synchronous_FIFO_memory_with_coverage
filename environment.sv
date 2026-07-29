`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "monitor.sv"
`include "coverage.sv"
class environment;
  generator gen;
  driver driv;
  monitor mon;
  scoreboard scb;
  coverage cov;

  mailbox gen2driv;
  mailbox mon2scb;

  virtual intf vif;

  function new(virtual intf vif);
    this.vif = vif;
    gen2driv = new();
    mon2scb  = new();
    gen  = new(gen2driv);
    driv = new(vif, gen2driv);
    mon  = new(vif, mon2scb);
    scb  = new(mon2scb);
    cov  = new(vif);
  endfunction

  task pre_test();
    driv.reset();
  endtask

  task test();
    fork
      driv.main();
      mon.main();
      scb.main();
      cov.main();
    join_none

    // Directed phase 1: force FIFO to full, including overflow attempt
    $display("=== DIRECTED: fill_fifo ===");
    gen.fill_fifo(16);

    // Directed phase 2: force FIFO to empty, including underflow attempt
    $display("=== DIRECTED: drain_fifo ===");
    gen.drain_fifo(16);

    // Directed phase 3: stress simultaneous read+write
    $display("=== DIRECTED: simultaneous_ops ===");
    gen.simultaneous_ops(20);

    // Random phase, as before
    $display("=== RANDOM phase ===");
    gen.repeat_count = 50;
    gen.main();
  endtask

  task post_test();
    wait (gen.ended.triggered);
    // 16 (fill) + 18 (drain, includes 2 underflow) ... totals vary by phase, so just drain queues
    wait (gen2driv.num() == 0);
    repeat (20) @(posedge vif.clk);   // let driver/monitor/scoreboard fully catch up
    $display("Functional coverage = %0.2f%%", cov.cg.get_coverage());
    scb.report();
  endtask

  task run;
    pre_test();
    test();
    post_test();
    $finish;
  endtask
endclass
