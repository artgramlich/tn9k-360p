`timescale 1ns / 1ps

module top(
    // External signals
    input  logic        clk_27,        // Onboard 27 MHz oscillator
    input  logic        rst_n,         // Active-low system reset    
    // HDMI Connector
    output logic hdmi_clk_p,           // HDMI TMDS Clock P
    output logic hdmi_clk_n,           // HDMI TMDS Clock N
    output logic [2:0] hdmi_data_p,    // HDMI TMDS Data P
    output logic [2:0] hdmi_data_n     // HDMI TMDS Data N
);

    // ============================================================
    // Interconnects
    // ============================================================
    logic clk_126;
    logic clk_pixel;
    logic clk_audio;
    logic clocks_locked;
    logic [23:0] rgb_data;
    logic signed [15:0] audio_data_left; 
    logic signed [15:0] audio_data_right;
    logic [9:0]  x;              
    logic [9:0]  y;              


    
    // ============================================================
    // Clocks
    // ============================================================
    
    clocks u_clocks(
        .clk_27(clk_27), 
        .rst_n(rst_n),
        .clk_126(clk_126),
        .clk_pixel(clk_pixel),
        .clk_audio(clk_audio),
        .clocks_locked(clocks_locked)
    );

    // ============================================================
    // HDMI
    // ============================================================
    logic [2:0] tmds_serialized;
    logic       tmds_clock;

    localparam CUSTOM_FRAME_WIDTH       = 1000;
    localparam CUSTOM_FRAME_HEIGHT      = 420;
    localparam CUSTOM_SCREEN_WIDTH      = 640;
    localparam CUSTOM_SCREEN_HEIGHT     = 360;
    localparam CUSTOM_HSYNC_PULSE_START = 40;
    localparam CUSTOM_HSYNC_PULSE_SIZE  = 120;
    localparam CUSTOM_VSYNC_PULSE_START = 10;
    localparam CUSTOM_VSYNC_PULSE_SIZE  = 5;
    localparam CUSTOM_INVERT            = 0;
    localparam CUSTOM_VIDEO_RATE        = 25200000; 


    hdmi #(
        .DVI_OUTPUT(1'b0),                 
        .VIDEO_ID_CODE(0),                 
        .VIDEO_REFRESH_RATE(60),           
        .AUDIO_RATE(48000),
        .AUDIO_BIT_WIDTH(16),            
        .CUSTOM_FRAME_WIDTH(CUSTOM_FRAME_WIDTH),          
        .CUSTOM_FRAME_HEIGHT(CUSTOM_FRAME_HEIGHT),         
        .CUSTOM_SCREEN_WIDTH(CUSTOM_SCREEN_WIDTH),
        .CUSTOM_SCREEN_HEIGHT(CUSTOM_SCREEN_HEIGHT),
        .CUSTOM_HSYNC_PULSE_START(CUSTOM_HSYNC_PULSE_START),     
        .CUSTOM_HSYNC_PULSE_SIZE(CUSTOM_HSYNC_PULSE_SIZE),
        .CUSTOM_VSYNC_PULSE_START(CUSTOM_VSYNC_PULSE_START),     
        .CUSTOM_VSYNC_PULSE_SIZE(CUSTOM_VSYNC_PULSE_SIZE),
        .CUSTOM_INVERT(CUSTOM_INVERT),               
        .CUSTOM_VIDEO_RATE(CUSTOM_VIDEO_RATE),   
        .CUSTOM_BIT_WIDTH(10),
        .CUSTOM_BIT_HEIGHT(10)             
    ) hdmi_inst (
        .clk_pixel_x5(clk_126),
        .clk_pixel(clk_pixel),
        .clk_audio(clk_audio),
        .reset(!clocks_locked),
        .rgb(rgb_data),
        //.audio_sample_word('{16'sd0, 16'sd0}),
        .audio_sample_word('{audio_data_left, audio_data_right}),
        .tmds(tmds_serialized),
        .tmds_clock(tmds_clock),
        .cx(x),
        .cy(y),
        .frame_width(),
        .frame_height(),
        .screen_width(),
        .screen_height()
    );
    
    ELVDS_OBUF obuf_data0 (.I(tmds_serialized[0]), .O(hdmi_data_p[0]), .OB(hdmi_data_n[0]));
    ELVDS_OBUF obuf_data1 (.I(tmds_serialized[1]), .O(hdmi_data_p[1]), .OB(hdmi_data_n[1]));
    ELVDS_OBUF obuf_data2 (.I(tmds_serialized[2]), .O(hdmi_data_p[2]), .OB(hdmi_data_n[2]));
    ELVDS_OBUF obuf_clock (.I(tmds_clock),         .O(hdmi_clk_p),     .OB(hdmi_clk_n));


    // ============================================================
    // TEST
    // ============================================================
    logic [7:0]  audio_sweep = 8'd0;
    logic [15:0] audio_phase = 16'd0;
    logic [7:0]  frame_color_offset = 8'd0;
    always_ff @(posedge clk_pixel) begin
        if (!clocks_locked) begin
            rgb_data    <= 24'h000000;
            audio_sweep <= 8'd0;
            audio_phase <= 16'd0;
            frame_color_offset <= 8'd0;
        end else begin
            rgb_data <= { (x[7:0] + frame_color_offset), y[7:0], 8'hFF }; 
            if (x == 0 && y == 0) begin
                audio_sweep <= audio_sweep + 1'b1;
                frame_color_offset <= frame_color_offset + 1'b1;
            end
            audio_phase <= audio_phase + audio_sweep;
        end
    end
    assign audio_data_left  = audio_phase[15] ? 16'sd4000 : -16'sd4000;
    assign audio_data_right = audio_phase[15] ? -16'sd4000 : 16'sd4000; // Inverted for stereo separation


endmodule
