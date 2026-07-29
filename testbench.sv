`include "interface.sv"
`include "test.sv"
module top;
  bit clk, rst;

  always #5 clk = ~clk;

  initial begin
    rst = 1;
    repeat (2) @(negedge clk);
    rst = 0;
  end

  // Mid-test reset: pulse rst once partway through, to confirm recovery
  initial begin
    #1600;
    $display("=== MID-TEST RESET PULSE ===");
    rst = 1;
    repeat (2) @(negedge clk);
    rst = 0;
  end

  intf i_intf(clk, rst);
  test t1(i_intf);

  sync_fifo dut (.clk(i_intf.clk),
                 .rst(i_intf.rst),
                 .wr_en(i_intf.wr_en),
                 .rd_en(i_intf.rd_en),
                 .data_in(i_intf.data_in),
                 .data_out(i_intf.data_out),
                 .full(i_intf.full),
                 .empty(i_intf.empty));

  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars;
  end
endmodule
