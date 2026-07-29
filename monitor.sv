class monitor;
  virtual intf vif;
  mailbox mon2scb;

  function new (virtual intf vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task main;
    forever begin
      transaction trans;
      trans = new();
      @(negedge vif.clk);
      trans.wr_en   <= vif.wr_en;
      trans.rd_en   <= vif.rd_en;
      trans.data_in <= vif.data_in;
      @(negedge vif.clk);
      trans.data_out <= vif.data_out;
      trans.full     <= vif.full;
      trans.empty    <= vif.empty;
      @(negedge vif.clk);
      mon2scb.put(trans);
      trans.display(" monitor ");
    end
  endtask
endclass
