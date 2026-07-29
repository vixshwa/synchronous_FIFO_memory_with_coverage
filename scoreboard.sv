class scoreboard;
  mailbox mon2scb;

  int no_transactions;
  int full_checks, empty_checks;

  bit [7:0] ref_queue[$];

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task main;
    transaction trans;
    bit [7:0] expected_data;
    forever begin
      mon2scb.get(trans);

      if (trans.rd_en && ref_queue.size() > 0) begin
        expected_data = ref_queue.pop_front();
        if (trans.data_out == expected_data)
          $display(" Result is expected ");
        else
          $error("wrong Result\n\t, expected %0h actual %0h", expected_data, trans.data_out);
      end

      if (trans.wr_en && ref_queue.size() < 16)
        ref_queue.push_back(trans.data_in);

      // Flag checks
      if (trans.full !== (ref_queue.size() == 16)) begin
        $error("full flag mismatch: DUT=%0b expected=%0b (queue size=%0d)",
                trans.full, (ref_queue.size() == 16), ref_queue.size());
      end else full_checks++;

      if (trans.empty !== (ref_queue.size() == 0)) begin
        $error("empty flag mismatch: DUT=%0b expected=%0b (queue size=%0d)",
                trans.empty, (ref_queue.size() == 0), ref_queue.size());
      end else empty_checks++;

      no_transactions++;
      trans.display("scoreboard");
    end
  endtask

  function void report();
    $display("Scoreboard: %0d transactions, %0d full-checks passed, %0d empty-checks passed",
               no_transactions, full_checks, empty_checks);
  endfunction
endclass
