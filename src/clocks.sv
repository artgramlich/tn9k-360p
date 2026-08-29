module clocks (
    input  logic clk_27, 
    input  logic rst_n,
    output logic clk_126,
    output logic clk_pixel,
    output logic clk_audio,
    output logic clocks_locked

);

    assign clocks_locked = clk_126_locked; 

    // rPLL to generate 126 MHz 5x pixel clock
    logic clk_126_locked;
    clkgen_126 u_clkgen_126(
        .clkin(clk_27),
        .reset(!rst_n),
        .clkout(clk_126),
        .lock(clk_126_locked)
    );

    // 25.2 MHz pixel clock from the 5x clock
    clkdiv_5 clkdiv_pixel(
        .hclkin(clk_126),
        .resetn(clk_126_locked),
        .clkout(clk_pixel)
    );

    // 48 KHz audio strobe (1 cycle pulse every 525 pixel clock cycles)
    // 25,200,000 / 48,000 = 525 total states (0 to 524)
    logic [9:0] audio_counter = 10'd0;
    always_ff @(posedge clk_pixel) begin
        if (!clk_126_locked) begin
            audio_counter <= 10'd0;
            clk_audio     <= 1'b0;
        end else if (audio_counter == 10'd524) begin
            audio_counter <= 10'd0;
            clk_audio     <= 1'b1;
        end else begin
            audio_counter <= audio_counter + 1'b1;
            clk_audio     <= 1'b0;
        end
    end

endmodule