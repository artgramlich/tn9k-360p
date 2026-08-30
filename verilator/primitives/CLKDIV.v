module CLKDIV #(
    parameter string DIV_MODE,
    parameter string GSREN = "false"
) (
    input  HCLKIN,
    input  RESETN,
    input  CALIB,
    output reg CLKOUT
);

    localparam int DIVISOR = (DIV_MODE == "2") ? 2 :
                             (DIV_MODE == "4") ? 4 :
                             (DIV_MODE == "5") ? 5 : 1;

    int counter;

    always @(posedge HCLKIN or negedge RESETN) begin
        if (!RESETN) begin
            counter <= 0;
            CLKOUT  <= 1'b0;
        end else begin
            if (counter >= (DIVISOR - 1)) begin
                counter <= 0;
                CLKOUT  <= !CLKOUT;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
