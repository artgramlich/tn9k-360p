module rPLL #(
    parameter string FCLKIN,
    parameter string DYN_IDIV_SEL,
    parameter int    IDIV_SEL,
    parameter string DYN_FBDIV_SEL,
    parameter int    FBDIV_SEL,
    parameter string DYN_ODIV_SEL,
    parameter int    ODIV_SEL,
    parameter string PSDA_SEL,
    parameter string DYN_DA_EN,
    parameter string DUTYDA_SEL,
    parameter bit    CLKOUT_FT_DIR,
    parameter bit    CLKOUTP_FT_DIR,
    parameter int    CLKOUT_DLY_STEP,
    parameter int    CLKOUTP_DLY_STEP,
    parameter string CLKFB_SEL,
    parameter string CLKOUT_BYPASS,
    parameter string CLKOUTP_BYPASS,
    parameter string CLKOUTD_BYPASS,
    parameter int    DYN_SDIV_SEL,
    parameter string CLKOUTD_SRC,
    parameter string CLKOUTD3_SRC,
    parameter string DEVICE
) (
    input  CLKIN,          
    input  RESET,          
    input  RESET_P,        
    input  PWRDN,          
    input  CLKSEL,         
    input  FBDSEL,         
    input  IDSEL,          
    input  ODSEL,          
    input  PSDA,           
    input  DUTYDA,         
    input  FDLY,           
    input  CLKFB,          
    
    output logic CLKOUT,         
    output logic CLKOUTD,        
    output logic CLKOUTP,        
    output logic CLKOUTD3,       
    output logic LOCK      
);

    always_comb begin
        LOCK      = !RESET;
        CLKOUT    = CLKIN;
        CLKOUTD   = CLKIN;
        CLKOUTP   = CLKIN;
        CLKOUTD3  = CLKIN;
    end

endmodule
