# 27 MHz oscillator 
create_clock -name clk_27 -period 37.037 -waveform {0 18.518} [get_ports {clk_27}]
# 126 MHz clock from rPLL for HDMI
create_generated_clock -name clk_126 -source [get_pins {clk_27_ibuf/I}] -master_clock clk_27 -divide_by 3 -multiply_by 14 [get_pins {u_clocks/u_clkgen_126/rpll_inst/CLKOUT}]
# 25.2 MHz pixel clock from CLKDIV of 126 MHz pixel clock
create_generated_clock -name clk_pixel -source [get_pins {u_clocks/u_clkgen_126/rpll_inst/CLKOUT}] -master_clock clk_126 -divide_by 5 [get_pins {u_clocks/clkdiv_pixel/clkdiv_inst/CLKOUT}]
# 48 kHz Audio clock generated from the pixel clock register
create_clock -name clk_audio -period 20833.333 [get_pins {u_clocks/clk_audio_s0/Q}]
set_false_path -from [get_clocks {clk_pixel}] -to [get_clocks {clk_audio}]
set_false_path -from [get_clocks {clk_audio}] -to [get_clocks {clk_pixel}]
