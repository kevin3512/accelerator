// 排序和激活模块
module sort_relu(
    input           clk,
    input           rst,
    input[31:0]     in,
    input[31:0]     index,
    input           asce,   //升序排序信号，1表示升序（从小到大排列），0表示降序
    input           is_start     //是否可以开始
);
parameter K = 8;
reg[31:0] value_index[K-1:0];   //保存的当前最大/小值的下标
reg[31:0] value[K-1:0];         //保存的当前K个最大/小值
reg [31:0] temp1_value; 
reg [31:0] temp2_value;
reg [31:0] temp1_index; 
reg [31:0] temp2_index;


always @(in)begin:compare
    integer i;
    reg   flag; //标志位，0表示没找到位置，继续遍历找，1表示找到遍历位置，开始数据后移
    flag = 0;
    
    if(!rst)begin
        //复位信号
    end else begin
        if(is_start)begin
            for(i = 0; i < K; i = i + 1)begin
                if(flag == 0)begin
                    if(value[i] === 32'hxxxx_xxxx || (asce && in < value[i])  || (!asce && in > value[i]))begin
                        temp1_value = value[i];
                        value[i] = in;
                        temp1_index = value_index[i];
                        value_index[i] = index;
                        flag = 1;
                    end
                end else begin
                    temp2_value = value[i];
                    value[i] = temp1_value;
                    temp1_value = temp2_value;
                    temp2_index = value_index[i];
                    value_index[i] = temp1_index;
                    temp1_index = temp2_index;
                end
            end
        end
    end
    
end

endmodule