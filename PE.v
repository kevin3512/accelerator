//PE基本处理单元
module PE(
    input           clk,
    input           rst,
    input[31:0]     In0, In1, In2, In3, In4, In5, In6, In7, In8, In9, In10, In11, In12, In13, In14, In15,
    input[31:0]     Par0, Par1, Par2, Par3, Par4, Par5, Par6, Par7, Par8, Par9, Par10, Par11, Par12, Par13, Par14, Par15,
    input[1:0]      Sel_cu,   //CU内部的控制信号
    input[1:0]      Sel_cu_go_back,  //CU 输出后是否回流的控制信号
    input[1:0]      Sel_adder,  //是否进入加法树的控制信号
    input           Is_save_cu_out,   //这个信号高电平时有两个功能，1，保存cu_out的输出到寄存器save_cu_out寄存器 ， 2，禁止cu计算结果保存到cu_out（因为会影响功能1，并且还有其他影响）
    input           Clear_reg,       //清除寄存器
    input           Is_shift_right,  //是否反量化，右移16位
    output[31:0]    Out_total,       //输出和
    output[31:0]    Out0, Out1, Out2, Out3, Out4, Out5, Out6, Out7, Out8, Out9, Out10, Out11, Out12, Out13, Out14, Out15  //对应每个CU计算的结果输出
    
);
//In输入信号中间变量
reg[31:0] In_data[15:0];
//Par输入信号中间变量
reg[31:0] Par_data[15:0];
//out输出信号中间变量
reg[31:0] Out_data[15:0];
//CU的输出
wire[31:0] cu_out[15:0];
//保存cu输出的寄存器
reg[31:0] save_cu_out[15:0];
//CU步骤完成的输出
reg[31:0] cu_complet_out[15:0];
//加法树的输入
reg[31:0] adder_in[15:0];
reg[1:0] reg_sel_cu;
reg[1:0] reg_sel_cu_go_back;
reg[1:0] reg_sel_adder;

//Out输出
assign Out0 = Out_data[0];
assign Out1 = Out_data[1];
assign Out2 = Out_data[2];
assign Out3 = Out_data[3];
assign Out4 = Out_data[4];
assign Out5 = Out_data[5];
assign Out6 = Out_data[6];
assign Out7 = Out_data[7];
assign Out8 = Out_data[8];
assign Out9 = Out_data[9];
assign Out10 = Out_data[10];
assign Out11 = Out_data[11];
assign Out12 = Out_data[12];
assign Out13 = Out_data[13];
assign Out14 = Out_data[14];
assign Out15 = Out_data[15];

always @ (posedge clk or negedge rst)begin: clear_pe_reg
    if(!rst)begin

    end else begin
        if(Clear_reg)begin
            for(integer i = 0 ; i < 16; i = i + 1)begin
                In_data[i] = 32'h0;
                Par_data[i] = 32'h0;
                save_cu_out[i] = 32'h0;
                cu_complet_out[i] = 32'h0;
                adder_in[i] = 32'h0;
            end
        end
    end
end

//-------------开始描述PE电路结构-----------------------
//描述CU电路结构
generate
  genvar j;
  for (j = 0; j < 16; j = j + 1) begin
    computer_unit cu_inst (
      .clk(clk),
      .rst(rst),
      .Input_data(In_data[j]),
      .Input_par(Par_data[j]),
      .Sel(Sel_cu),
      .Is_output(!Is_save_cu_out),
      .Is_shift_right(Is_shift_right),
      .Out(cu_out[j])
    );
  end
endgenerate

//描述加法树电路结构
adder_tree_8 at_8(adder_in[0], adder_in[1], adder_in[2], adder_in[3], adder_in[4], adder_in[5], adder_in[6], adder_in[7], adder_in[8], adder_in[9], adder_in[10], adder_in[11], adder_in[12], adder_in[13], adder_in[14], adder_in[15], Out_total);

//处理输入数据In
always @(In0 or In1 or In2 or In3 or In4 or In5 or In6 or In7 or In8 or In9 or In10 or In11 or In12 or In13 or In14 or In15)begin : load_in
    //In_data数据来自输入In
    In_data[0] = In0;
    In_data[1] = In1;
    In_data[2] = In2;
    In_data[3] = In3;
    In_data[4] = In4;
    In_data[5] = In5;
    In_data[6] = In6;
    In_data[7] = In7;
    In_data[8] = In8;
    In_data[9] = In9;
    In_data[10] = In10;
    In_data[11] = In11;
    In_data[12] = In12;
    In_data[13] = In13;
    In_data[14] = In14;
    In_data[15] = In15;
end

//处理输入数据Par
always @(Par0 or Par1 or Par2 or Par3 or Par4 or Par5 or Par6 or Par7 or Par8 or Par9 or Par10 or Par11 or Par12 or Par13 or Par14 or Par15)begin : load_par
    //Par_data数据来自输入Par
    Par_data[0] = Par0;
    Par_data[1] = Par1;
    Par_data[2] = Par2;
    Par_data[3] = Par3;
    Par_data[4] = Par4;
    Par_data[5] = Par5;
    Par_data[6] = Par6;
    Par_data[7] = Par7;
    Par_data[8] = Par8;
    Par_data[9] = Par9;
    Par_data[10] = Par10;
    Par_data[11] = Par11;
    Par_data[12] = Par12;
    Par_data[13] = Par13;
    Par_data[14] = Par14;
    Par_data[15] = Par15;
end

//处理Par_data和In_data的赋值情况
always @(posedge clk or negedge rst)begin : reset_par_or_in
    integer i;
    if(!rst)begin
        //todo
    end
    else begin
        //cu输出值暂时保存
        for (i = 0; i < 16; i = i + 1) begin
            save_cu_out[i] = cu_out[i];
        end
        if(Is_save_cu_out == 1'b1)begin
            case(Sel_cu_go_back)
                2'b01:
                    begin
                        //Par_data数据来自已经计算完成的CU结果
                        for (i = 0; i < 16; i = i + 1) begin
                            if(save_cu_out[i] !== 32'hxxxx_xxxx)begin
                                Par_data[i] = save_cu_out[i];
                            end
                            
                        end
                    end

                2'b11:
                    begin
                        //In_data数据来自已经计算完成的CU结果
                        for (i = 0; i < 16; i = i + 1) begin
                            if(save_cu_out[i] !== 32'hxxxx_xxxx)begin
                                In_data[i] = save_cu_out[i];
                            end
                        end
                    end
            endcase
        end 
    end
end



//处理cu_complet_out的赋值情况
always @(posedge clk or negedge rst) begin : handle_cu_out
    integer i;
    if(!rst)begin

    end else begin
        if(Sel_cu_go_back == 2'b10)begin
            for (i = 0; i < 16; i = i + 1) begin
                cu_complet_out[i] = cu_out[i];
            end
        end
    end
end

//处理Sel_adder信号不同的数据流
always @(posedge clk or negedge rst) begin : handle_sel_adder
    integer i;
    if(!rst)begin
        //do nothing
    end else begin
        case(Sel_adder) 
            2'b01:
            begin
                //每个CU的结果单独输出
                for (i = 0; i < 16; i = i + 1) begin
                    Out_data[i] = cu_complet_out[i];
                end
            end
            2'b10:
            begin
                //所有CU的结果进入加法器树，输出总和
                for (i = 0; i < 16; i = i + 1) begin
                    adder_in[i] = cu_complet_out[i];
                end
            end
        endcase
    end

end

endmodule