class generator;
  rand transaction trans;
  int repeat_count;

  mailbox gen2driv;

  event ended;

  function new(mailbox gen2driv);
    this.gen2driv = gen2driv;
  endfunction

  // Directed: force writes only, no reads, to drive the FIFO to full
  task fill_fifo(int depth);
    repeat (depth + 2) begin   // +2 extra writes to also test write-when-full
      trans = new();
      trans.wr_en   = 1;
      trans.rd_en   = 0;
      trans.data_in = $urandom_range(0, 255);
      trans.display("[generator-fill]");
      gen2driv.put(trans);
    end
  endtask

  // Directed: force reads only, no writes, to drive the FIFO to empty
  task drain_fifo(int depth);
    repeat (depth + 2) begin   // +2 extra reads to also test read-when-empty
      trans = new();
      trans.wr_en   = 0;
      trans.rd_en   = 1;
      trans.data_in = 0;
      trans.display("[generator-drain]");
      gen2driv.put(trans);
    end
  endtask

  // Directed: force simultaneous write+read every cycle
  task simultaneous_ops(int count);
    repeat (count) begin
      trans = new();
      trans.wr_en   = 1;
      trans.rd_en   = 1;
      trans.data_in = $urandom_range(0, 255);
      trans.display("[generator-simul]");
      gen2driv.put(trans);
    end
  endtask

  task main;
    repeat (repeat_count) begin
      trans = new();
      if (!(trans.randomize())) $fatal("gen::trans randomize failed");
      trans.display("[generator]");
      gen2driv.put(trans);
    end
    -> ended;
  endtask
endclass
