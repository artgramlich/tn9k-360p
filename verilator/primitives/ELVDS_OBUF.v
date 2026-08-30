module ELVDS_OBUF(
    input  I,
    output O,
    output OB
);

    assign O  = I;
    assign OB = ~I;

endmodule
