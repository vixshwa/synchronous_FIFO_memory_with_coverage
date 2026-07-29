class coverage;
  virtual intf vif;
  mailbox mon2cov;

  int no_transactions;

  covergroup cg;                      //functional coverage coverage handler
    option.per_instance = 1;

    cp_wr_en : coverpoint vif.wr_en;   //data-oriented coverage 
    cp_rd_en : coverpoint vif.rd_en;
    cp_full  : coverpoint vif.full;
    cp_empty : coverpoint vif.empty;

    cp_simultaneous : cross cp_wr_en, cp_rd_en;

    cp_data_in : coverpoint vif.data_in {
      bins low  = {[0:63]};
      bins mid  = {[64:191]};
      bins high = {[192:255]};
    }
  endgroup

  function new(virtual intf vif);
    this.vif = vif;
    cg = new();
  endfunction

  task main;
    forever begin
      @(posedge vif.clk);
      cg.sample();
      no_transactions++;
    end
  endtask
endclass
