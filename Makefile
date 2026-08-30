VERILATOR_HDL_FILES = \
	./src/gowin/clkdiv_5.v \
    ./src/gowin/clkgen_126.v \
	./src/hdmi/audio_clock_regeneration_packet.sv  \
    ./src/hdmi/audio_info_frame.sv  \
    ./src/hdmi/audio_sample_packet.sv  \
    ./src/hdmi/auxiliary_video_information_info_frame.sv  \
    ./src/hdmi/hdmi.sv  \
    ./src/hdmi/packet_assembler.sv  \
    ./src/hdmi/packet_picker.sv  \
    ./src/hdmi/serializer_gowin.sv  \
    ./src/hdmi/source_product_description_info_frame.sv  \
    ./src/hdmi/tmds_channel.sv  \
    ./src/clocks.sv \
    ./src/top.sv

SDL2_CFLAGS = $(shell pkg-config --cflags sdl2)
SDL2_LIBS   = $(shell pkg-config --libs sdl2)

.PHONY: help
help:
	@echo "sim"
	@echo "  Create a Veriloator simulation ./sim"
	@echo "configure-fpga"
	@echo "  Upload the bitstream to the fpga volatile storage"  
	@echo "clean"
	@echo "  Remove build artifacts"  
	
sim:
	@mkdir -p ./tmp/verilator
	@verilator \
		-y ./verilator/primitives \
		--public-params \
		--public-flat-rw \
		-Wno-fatal \
		--cc \
		-DVERILATOR=1 \
		--Mdir ./tmp/verilator \
		--exe verilator/sim_main.cpp \
		-top-module top \
		-o $(CURDIR)/sim \
		$(VERILATOR_HDL_FILES) \
		"$(SDL2_CFLAGS)" -LDFLAGS "$(SDL2_LIBS)"
	$(MAKE) -C ./tmp/verilator -f Vtop.mk

.PHONY: configure-fpga
configure-fpga:
	openFPGALoader -b tangnano9k impl/pnr/tn9k360p-development.fs

.PHONY: clean
clean:
	rm -rf tmp sim