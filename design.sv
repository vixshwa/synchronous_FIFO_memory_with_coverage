//design and verification of synchronous fifo memory(8 bit) with coverage
module sync_fifo #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH      = 16
) (
  input  logic                   clk,
  input  logic                   rst,
  input  logic                   wr_en,
  input  logic                   rd_en,
  input  logic [DATA_WIDTH-1:0]  data_in,
  output logic [DATA_WIDTH-1:0]  data_out,
  output logic                   full,
  output logic                   empty
);

  localparam PTR_WIDTH = $clog2(DEPTH);

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  logic [PTR_WIDTH:0]    wr_ptr, rd_ptr;

  logic wr_valid, rd_valid;

  assign wr_valid = wr_en && !full;
  assign rd_valid = rd_en && !empty;

  always_ff @(posedge clk) begin
    if (rst) begin
      wr_ptr <= '0;
    end else if (wr_valid) begin
      mem[wr_ptr[PTR_WIDTH-1:0]] <= data_in;
      wr_ptr <= wr_ptr + 1'b1;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      rd_ptr   <= '0;
      data_out <= '0;
    end else if (rd_valid) begin
      data_out <= mem[rd_ptr[PTR_WIDTH-1:0]];
      rd_ptr   <= rd_ptr + 1'b1;
    end
  end

  assign empty = (wr_ptr == rd_ptr);
  assign full  = (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]) &&
                 (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]);
  
  
  // full and empty can never both be true at once
  assert property (@(posedge clk) disable iff (rst) !(full && empty))
    else $error("ASSERTION FAILED: full and empty asserted simultaneously");

  // wr_ptr must not change on a cycle where a write is blocked (full, no read to free a slot)
  assert property (@(posedge clk) disable iff (rst)
    (wr_en && full && !rd_valid) |=> $stable(wr_ptr))
    else $error("ASSERTION FAILED: wr_ptr moved on a blocked write");

  // rd_ptr must not change on a cycle where a read is blocked (empty)
  assert property (@(posedge clk) disable iff (rst)
    (rd_en && empty) |=> $stable(rd_ptr))
    else $error("ASSERTION FAILED: rd_ptr moved on a blocked read");

endmodule
