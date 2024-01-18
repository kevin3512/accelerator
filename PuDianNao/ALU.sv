module ALU #(parameter K = 20)(
    input               clk,
    input               rst,
    input[1:0]          select,                  //2'b01表示选择mlu输入, 2'b10表示选择outputbuffer输入
    input[31:0]         in,                      //单独一个数输入
    input[31:0]         in_mlu[15:0],            //来自alu的输入,包括数据和index
    input[31:0]         in_output[15:0],         //来自OutputBuffer的输入,包括数据和index
    input[31:0]         in_count,                   //输入第几波数据计数
    input[31:0]         out_count,                   //输出第几波数据计数
    input[3:0]          run_case,                //开始进行各种case的逻辑运算, 4'b0001 表示输出MLU到OutputBuf ,  4'b0010 表示排序MLU和OutputBuf的结果然后输出到OutputBuf , 
    input               is_asce_sort,            //较小的输出
    output reg[31:0]    out[15:0]

);
reg[31:0]       new_data[K-1:0];     //新输入数据，来自新一轮计算的MLU
reg[31:0]       new_index[K-1:0];
reg[31:0]       sorted_data[K-1:0];  //排序好的数据，来自OutputBuf
reg[31:0]       sorted_index[K-1:0];
reg[31:0]       new_sorted_data[K-1:0];
reg[31:0]       new_sorted_index[K-1:0];

reg [31:0]      debug_out_vector_collect[((2*K)/16+1)*16-1:0];
reg[31:0]       debug_out_ksort[2*K-1:0];
reg[31:0]       save_out[15:0];  //用与保存in的数据
integer         save_count = 0;    //保存的数据in的数量
reg             is_saved;      //in输入是否已经保存过

//解析输入数据  count + out_vector -->  sort[19:0]  + sort_index[19:0]
function void process_data(input reg[31:0] count, input reg [31:0] out_vector[15:0], output reg [31:0] out_vector_collect[((2*K)/16+1)*16-1:0], output reg [31:0] out_sort[K-1:0], output reg [31:0] out_sort_index[K-1:0]);
    int n = (2*K)/16;    //传输完成时的count值，比如K=20，则传40个数据，每次16位，需要传3次，故n=2(从0开始计数)
    for(integer w = 0; w < 16; w = w + 1) begin
        // TODO 就是这里，每次count==0的时候，总是利用In_mlu变化前的值进行赋值
        out_vector_collect[count*16+w] = out_vector[w];
        if(count == n)begin  //收集齐了，开始解析
            for (int i = 0; i < K; i++) begin
                out_sort[i] = out_vector_collect[i];
                out_sort_index[i] = out_vector_collect[K + i];
            end
        end 
    end
endfunction

//封装输出数据  sort[19:0]  + sort_index[19:0]  -->  out_vector[15:0] 
function void package_data(input reg[31:0] count, input reg [31:0] new_sorted_data[K-1:0], input reg [31:0] new_sorted_index[K-1:0], output reg [31:0] out_vector[15:0]);
    reg[31:0] out_ksort[2*K-1:0];
    for(integer i = 0 ; i < K; i = i + 1)begin
        out_ksort[i] = new_sorted_data[i];
        out_ksort[K+i] = new_sorted_index[i];
        //用与调试查看
        debug_out_ksort[i] = new_sorted_data[i];
        debug_out_ksort[K+i] = new_sorted_index[i];
    end
    //根据count值的不同，输出不同的部分
    out_vector = out_ksort[count*16 +: 16]; //表示选择从count*16开始的16位数据赋值给out_vector
endfunction

always @ (in) begin
    if(in !== 32'hxxxx_xxxx)begin
        is_saved = 0;
    end
end

always @ (posedge clk or negedge rst) begin
    if(!rst)begin

    end else begin
        if(select == 2'b01 && in_count >= 0)begin
            process_data(in_count, in_mlu, debug_out_vector_collect, new_data, new_index);
        end else if(select == 2'b10  && in_count >= 0)begin
            process_data(in_count, in_output, debug_out_vector_collect, sorted_data, sorted_data);
        end

        case(run_case)  // 开始运算输出
            4'b0001:   //直接输出来自MLU的结果到OutputBuf
                begin
                    new_sorted_data = new_data;
                    new_sorted_index = new_index;
                    //包装排序后的新数组输出
                    package_data(out_count, new_sorted_data, new_sorted_index, out);
                end

            4'b0010:   //重新排序MLU和来自OutputBuf的结果，然后输出到OutputBuf
                begin
                    // 对来自MLU的数组和来自OutputBuff的数组进行排序
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
                    //包装排序后的新数组输出
                    package_data(out_count, new_sorted_data, new_sorted_index, out);
                end
            4'b0011:  //4'b0011 表示将输入in进行存储，存够16个数后自动输出，或者给out_count>0的值，强制输出
                begin
                    if(!is_saved)begin
                        save_out[save_count] = in;
                        save_count = save_count + 1;
                        is_saved = 1;
                        if(save_count >= 16)begin  //攒到了16个数自动输出
                            out[15:0] = save_out[15:0];
                            save_count = 0;
                        end else if(out_count > 0)begin  //直接输出
                            for(integer i = 0; i < 16; i = i + 1)begin
                                if(i < save_count)begin
                                    out[i] = save_out[i];
                                end else begin
                                    out[i] = 32'hxxxx_xxxx;
                                end
                            end
                        end
                    end
                end
            4'b0100:  //清除之前的输出数据
                begin
                    save_count = 0;
                    for (integer i = 0; i < 16 ; i = i + 1) begin
                        out[i] = 32'hxxxx_xxxx;
                        save_out[i] = 32'hxxxx_xxxx;
                    end
                end
        endcase
        
                
    end
end

endmodule