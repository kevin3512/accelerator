module sel_2#(parameter WIDTH = 16)(
    input[WIDTH-1:0]    in1,
    input[WIDTH-1:0]    in2,
    input               sel,
    output[WIDTH-1:0]   out
);

assign out = sel ? in1 : in2;

endmodule