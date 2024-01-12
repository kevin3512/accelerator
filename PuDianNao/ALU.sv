module ALU #(parameter K = 20)(
    input               clk,
    input               rst,
    input[1:0]          select,                  //2'b01表示选择alu输入, 2'b10表示选择outputbuffer输入
    input[31:0]         in_mlu[15:0],            //来自alu的输入,包括数据和index
    input[31:0]         in_output[15:0],         //来自OutputBuffer的输入,包括数据和index
    input[31:0]         count,                   //输入第几波数据技术
    input               is_start,                //开始进行逻辑运算
    input               is_asce_sort,            //较小的输出
    output[31:0]        out[15:0]

);
reg[31:0]       new_data[K-1:0];     //新输入数据，来自新一轮计算的MLU
reg[31:0]       new_index[K-1:0];
reg[31:0]       sorted_data[K-1:0];  //排序好的数据，来自OutputBuf
reg[31:0]       sorted_index[K-1:0];
reg[31:0]       new_sorted_data[K-1:0];
reg[31:0]       new_sorted_index[K-1:0];

//解析输入数据
function void process_data(input reg [31:0] out_vector[15:0], output reg [31:0] out_sort[K-1:0], output reg [31:0] out_sort_index[K-1:0]);
    int n = (2*K)/16;    //传输完成时的count值，比如K=20，则传40个数据，每次16位，需要传3次，故n=2(从0开始计数)
    reg [31:0] out_vector_collect[((2*K)/16+1)*16-1:0];

    for(integer w = 0; w < 16; w = w + 1) begin
        out_vector_collect[count*16+w] = out_vector[w];
        if(count == n)begin  //收集齐了，开始解析
            for (int i = 0; i < K; i++) begin
                out_sort[i] = out_vector_collect[i];
                out_sort_index[i] = out_vector_collect[K + i];
            end
        end 
        
    end
endfunction

always @ (in_mlu or in_output or count) begin
    if(select == 2'b01)begin
        process_data(in_mlu, new_data, new_index);
    end else if(select == 2'b10)begin
        process_data(in_output, sorted_data, sorted_data);
    end

    if(is_start)begin  //开始运算输出
        for (integer i = 0, j = 0, k = 0; k < K; k = k + 1) begin  // 遍历长度为 20 的数组
            if (i == K) begin  // 如果数组new_data已经全部添加到sorted_array中
                new_sorted_data[k] = sorted_data[j];  // 则将数组sorted_data中剩余元素依次添加到sorted_array中
                new_sorted_index[k] = sorted_index[j];
                j = j + 1;  // 更新数组sorted_data的索引
            end else if (j == K) begin  // 如果数组sorted_data已经全部添加到sorted_array中
                new_sorted_data[k] = new_data[i];  // 则将数组1中剩余元素依次添加到sorted_array中
                new_sorted_index[k] = new_index[i];
                i = i + 1;  // 更新数组new_data的索引
            end else if (new_data[i] < sorted_data[j]) begin  // 如果数组new_data当前元素小于数组sorted_data当前元素
                new_sorted_data[k] = new_data[i];  // 则将数组1当前元素添加到sorted_array中
                new_sorted_index[k] = new_index[i];
                i = i + 1;  // 更新数组new_data的索引
            end else begin  // 如果数组sorted_data当前元素小于等于数组1当前元素
                new_sorted_data[k] = sorted_data[j];  // 则将数组sorted_data当前元素添加到sorted_array中
                new_sorted_index[k] = sorted_index[j];
                j = j + 1;  // 更新数组sorted_data的索引
            end
        end
    end
end

endmodule