class transaction;
  rand bit wr_en;
  rand bit rd_en;
  rand bit [7:0] data_in;
       bit [7:0] data_out;
       bit full;
       bit empty;

  constraint c_ops {
    wr_en dist {1 :/ 60, 0 :/ 40};
    rd_en dist {1 :/ 60, 0 :/ 40};
  }

  function void display(string name);
    $display("------------------------------------");
    $display("%s", name);
    $display("------------------------------------");
    $display("wr_en: %0d || rd_en: %0d || data_in: %0h", wr_en, rd_en, data_in);
    $display("data_out: %0h | full: %0d | empty: %0d", data_out, full, empty);
    $display("------------------------------------");
  endfunction
endclass
