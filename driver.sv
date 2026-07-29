class driver;
  int no_transactions;

  virtual intf vif;

  mailbox gen2driv;

  function new (virtual intf vif, mailbox gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
  endfunction

  task reset;
    wait (vif.rst);
    $display("[driver]------------reset started-----------");
    vif.wr_en   <= 0;
    vif.rd_en   <= 0;
    vif.data_in <= 0;
    wait (!vif.rst);
    $display("[driver]-------------reset ended------------");
  endtask

  task main;
    transaction trans;
    forever begin

      gen2driv.get(trans);
      @(posedge vif.clk);
      vif.wr_en   <= trans.wr_en;
      vif.rd_en   <= trans.rd_en;
      vif.data_in <= trans.data_in;

      @(posedge vif.clk);
      vif.wr_en <= 0;      // deassert — exactly one FIFO op per transaction
      vif.rd_en <= 0;
      trans.data_out <= vif.data_out;
      trans.full     <= vif.full;
      trans.empty    <= vif.empty;

      @(posedge vif.clk);
      trans.display("driver");
      no_transactions++;
    end
  endtask
endclass
