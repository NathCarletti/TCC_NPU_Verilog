// Testbench para demonstrar integração do sistema de classificação de vaga com NPU.

`timescale 1ns/1ps
module tb_parking_npu;

    reg clk;
    reg resetn;

    // Inputs para o top-level
    reg [7:0] sensor_distance;
    reg [7:0] sensor_delta;
    reg [7:0] sensor_time;
    reg [7:0] sensor_lux;
    reg       start;

    // Saídas
    wire [1:0] parking_class;
    wire       npu_busy;
    wire       npu_done;
    wire       fifo_full;
    wire       fifo_empty;
    wire       led_green;
    wire       led_yellow;
    wire       led_red;

    // FIFO read debug
    wire       fifo_read;
    wire [31:0] debug_fifo_read_count;

    // Debug outputs
    wire [31:0] debug_cycle_count;
    wire [1:0]  debug_npu_state;
    wire [31:0] debug_npu_input;
    wire [7:0]  debug_npu_output;

    // Instancia do DUT
    parking_npu_top dut (
        .clk(clk),
        .resetn(resetn),
        .sensor_distance(sensor_distance),
        .sensor_delta(sensor_delta),
        .sensor_time(sensor_time),
        .sensor_lux(sensor_lux),
        .start(start),
        .parking_class(parking_class),
        .npu_busy(npu_busy),
        .npu_done(npu_done),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty),
        .led_green(led_green),
        .led_yellow(led_yellow),
        .led_red(led_red),
        .fifo_read(fifo_read),
        .debug_fifo_read_count(debug_fifo_read_count),
        .debug_cycle_count(debug_cycle_count),
        .debug_npu_state(debug_npu_state),
        .debug_npu_input(debug_npu_input),
        .debug_npu_output(debug_npu_output)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    initial begin
        // Reset
        resetn = 0;
        start = 0;
        sensor_distance = 8'd0;
        sensor_delta = 8'd0;
        sensor_time = 8'd0;
        sensor_lux = 8'd0;
        #20;

        resetn = 1;
        #20;

        $display("[TB] Iniciando cenarios de classificacao de estacionamento");

        // 1) vaga livre (distância alta, delta baixo, tempo alto, luz alta)
        sensor_distance = 8'd200;
        sensor_delta = 8'd2; 
        sensor_time = 8'd30; //tempo em que a condição detectada se manteve estável 
        sensor_lux = 8'd120; 
        pulse_start();
        wait_done_and_report(8'd0); // vaga livre

        // 2) vaga ocupada (distância baixa, tempo baixo, delta baixo)
        sensor_distance = 8'd30;
        sensor_delta = 8'd1;
        sensor_time = 8'd20;
        sensor_lux = 8'd80; //luz boa, não suficiente para indicar vaga livre sozinha, mas sensor mais confiavel
        pulse_start();
        wait_done_and_report(8'd1); // vaga ocupada

        // 3) vaga obstruída (valores inconsistentes)
        sensor_distance = 8'd110; //não é nem muito perto nem muito longe
        sensor_delta = 8'd50; //pessoa andando, possivelmente
        sensor_time = 8'd15; //pouco tempo, mas não zero
        sensor_lux = 8'd20; //pouca luz (faz com que sensor fique inconsistente)
        pulse_start();
        wait_done_and_report(8'd2); // vaga obstruída

        $display("[TB] Simulacao completa");
        #50;
        $stop;
    end

    task pulse_start;
        begin
            start = 1;
            #40;   // manter start ativo por vários ciclos
            start = 0;
        end
    endtask

    task wait_done_and_report;
        input [7:0] scenario;
        integer i;
        begin
            // aguarda DONE (timeout para evitar travar eternamente)
            for (i = 0; i < 2000; i = i + 1) begin
                #10;
                if (npu_done) begin
                    $display("[TB] cenario=%0d | dist=%0d delta=%0d tempo=%0d lux=%0d | class=%0d | green=%b yellow=%b 
                                red=%b | busy=%b done=%b | fifo_read=%b fifo_read_count=%0d | cycle=%0d | npu_state=%0d | 
                                npu_in=0x%08h | npu_out=0x%02h",
                             scenario,
                             sensor_distance,
                             sensor_delta,
                             sensor_time,
                             sensor_lux,
                             parking_class,
                             led_green,
                             led_yellow,
                             led_red,
                             npu_busy,
                             npu_done,
                             fifo_read,
                             debug_fifo_read_count,
                             debug_cycle_count,
                             debug_npu_state,
                             debug_npu_input,
                             debug_npu_output);                    
                    disable wait_done_and_report;
                end
            end
            $display("[TB] ATENÇÃO: timeout aguardando npu_done no cenario %0d", scenario);
        end
    endtask

endmodule
