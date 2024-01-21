//PE中的基本计算单元CU
module computer_unit(
    input               clk,
    input               rst,
    input[31:0]         Input_data,  //输入数据
    input[31:0]         Input_par,   //输入参数，如：权重
    input[1:0]          Sel,         //控制信号
    input               Is_output,    //是否输出
    input               Is_shift_right,  //反量化操作，右移16位
    output reg[31:0]    Out          //输出信号
);

    reg[31:0]           cal_out;

    always @(posedge clk or negedge rst)
        if(!rst)begin
            //do nothing
        end else begin
            if(Is_output)begin
                case(Sel)
                    2'b00:                   //减法操作
                        Out = Input_data - Input_par ; 
                    2'b01:                   //比较器
                        Out = Input_data > Input_par ? 1 : 0 ;
                    2'b10:                   //加法器
                        Out = Input_data + Input_par ;
                    2'b11:                   //乘法器
                        begin
                            cal_out = Input_data * Input_par;
                            if(Is_shift_right)begin
                                if(cal_out[31] == 1)begin
                                    Out = {{16{cal_out[31]}}, cal_out[31:16]}; // 使用符号扩展
                                end else begin
                                    Out = cal_out >> 16; // 正数直接进行位移操作
                                end
                            end else begin
                                Out = cal_out;
                            end
                        end
                endcase
            end
        end

endmodule