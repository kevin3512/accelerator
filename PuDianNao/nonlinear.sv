module nonlinear#(parameter WIDTH = 32)(
    input[WIDTH-1:0]        in,
    input[2:0]              fun_id,        //选择非线性函数 , 3'b001 : ReLu
    output[WIDTH-1:0]       out
);

reg[WIDTH-1:0]      out;

always @ (*) begin
    case(fun_id)
        3'b001:    //ReLu
            begin
                out = in > 0 ? in : 0;
            end
    endcase
end

endmodule