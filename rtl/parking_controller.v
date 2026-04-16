// Interpreta o resultado da NPU (classe de vaga) e acende LEDs correspondentes.

module parking_controller (
    input  wire [1:0] parking_class,
    output reg        led_green,
    output reg        led_yellow,
    output reg        led_red
);

    always @(*) begin
        // reset all outputs by default
        led_green  = 1'b0;
        led_yellow = 1'b0;
        led_red    = 1'b0;

        case (parking_class)
            2'b00: begin // vaga livre
                led_green = 1'b1;
            end
            2'b01: begin // vaga ocupada
                led_red = 1'b1;
            end
            2'b10: begin // vaga obstruída
                led_yellow = 1'b1;
            end
            default: begin // classe inválida
                led_green  = 1'b0;
                led_yellow = 1'b0;
                led_red    = 1'b0;
            end
        endcase
    end

endmodule
