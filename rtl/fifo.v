module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 128,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input clk,
    input rst,
    input enable,
    input wr_en,
    input rd_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output empty,
    output full,
    output [7:0] mem0_debug,
    output [7:0] mem1_debug
);

    // Memória do FIFO
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Ponteiros de leitura e escrita
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;
    reg [ADDR_WIDTH:0] count;  // qtd de elementos no FIFO

    // Flags
    assign empty = (count == 0);
    assign full  = (count == DEPTH);
    

    assign mem0_debug = mem[0];
    assign mem1_debug = mem[1];


    always @(posedge clk) begin
    if (wr_en && !full)
        $display("[%0t] WRITE ptr=%0d data=%h",
                 $time, wr_ptr, data_in);
end
always @(posedge clk) begin
    if (rd_en && !empty)
        $display("[%0t] READ ptr=%0d data=%h",
                 $time, rd_ptr, mem[rd_ptr]);
end

always @(posedge clk)
begin
    if (rd_en && !empty)
        $display("[%0t] READ ptr=%0d data=%02h",
                 $time,
                 rd_ptr,
                 mem[rd_ptr]);
end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            data_out <= 0;
        end else if (enable) begin
            // Escrita
            if (wr_en && !full) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
                wr_ptr <= wr_ptr + 1;
                count  <= count + 1;
            end

            // Leitura
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1;
                count  <= count - 1;
            end
        end
    end

endmodule