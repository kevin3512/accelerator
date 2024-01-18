module nonlinear#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,
    input[WIDTH-1:0]        in,
    input[2:0]              fun_id,        //选择非线性函数 , 3'b001 : ReLu
    output[WIDTH-1:0]       out
);

reg[WIDTH-1:0]      out;

always @ (*) begin
    case(fun_id)
        3'b001:    //ReLu
            begin
                out = in[WIDTH-1] > 0 ? 0 : in;
            end
    endcase
end

endmodule