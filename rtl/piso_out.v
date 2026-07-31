// Parallel-in serial-out register for the two 16-bit ReLU results.
module piso_out (
    input  wire        CLKEXT,
    input  wire        RST_GLO,
    input  wire        EN_PISO_OUT,
    input  wire        CLR_PISO_OUT,
    input  wire        SHIFT_OUT,
    input  wire [15:0] mac0_out,
    input  wire [15:0] mac1_out,
    output wire [7:0]  D_OUT
  );

  reg [31:0] shift_reg;

  // Expose the current MSB before the active clock edge shifts it.
  // This lets the FIFO store the correct byte on every SHIFT_OUT cycle.
  assign D_OUT = shift_reg[31:24];

  always @(posedge CLKEXT or posedge RST_GLO)
  begin
    if (RST_GLO)
      shift_reg <= 32'd0;
    else if (CLR_PISO_OUT)
      shift_reg <= 32'd0;
    else if (EN_PISO_OUT)
    begin
      if (!SHIFT_OUT)
        shift_reg <= {mac0_out, mac1_out};
      else
        shift_reg <= {shift_reg[23:0], 8'b0};
    end
  end

endmodule
