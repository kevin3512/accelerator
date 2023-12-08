
//Testbench of PE
`timescale 1ns/1ns
module PE_tb;
    reg           clk;
    reg           rst;
    reg[31:0]     in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15;
    reg[31:0]     par0, par1, par2, par3, par4, par5, par6, par7, par8, par9, par10, par11, par12, par13, par14, par15;
    reg[1:0]      sel_cu;   //CU内部的控制信号
    reg[1:0]      sel_cu_go_back;  //CU 输出后是否回流的控制信号
    reg[1:0]      sel_adder;  //是否进入加法树的控制信号
    reg           is_save_cu_out;  //是否保存cu_out的值
    wire[31:0]    out_total;       //输出和
    wire[31:0]    out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15;  //对应每个CU计算的结果输出
    //用于临时保存cu_out数据
    reg[31:0] cu_save[15:0];
        
    PE PE(.clk(clk), .rst(rst), .In0(in0), .In1(in1), .In2(in2), .In3(in3), .In4(in4), .In5(in5), .In6(in6), .In7(in7), .In8(in8), .In9(in9), .In10(in10), .In11(in11), .In12(in12), .In13(in13), .In14(in14), .In15(in15),
         .Par0(par0), .Par1(par1), .Par2(par2), .Par3(par3), .Par4(par4), .Par5(par5), .Par6(par6), .Par7(par7), .Par8(par8), .Par9(par9), .Par10(par10), .Par11(par11), .Par12(par12), .Par13(par13), .Par14(par14), .Par15(par15),
         .Sel_cu(sel_cu),.Sel_cu_go_back(sel_cu_go_back),.Sel_adder(sel_adder),.Is_save_cu_out(is_save_cu_out),.Out_total(out_total),
         .Out0(out0), .Out1(out1), .Out2(out2), .Out3(out3), .Out4(out4), .Out5(out5), .Out6(out6), .Out7(out7), .Out8(out8), .Out9(out9), .Out10(out10), .Out11(out11), .Out12(out12), .Out13(out13), .Out14(out14), .Out15(out15));

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA();
        clk = 0;
        rst = 1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        //-----------------测试两个矩阵数据相乘再经过加法树加和的情况--------------------
        //Y = a1 * b1 + a2 * b2 + … + an * bn   点积操作：LR，SVM, DNN
        // in = {32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01};
        in0 = 32'h01;
        in1 = 32'h01;
        in2 = 32'h01;
        in3 = 32'h01;
        in4 = 32'h01;
        in5 = 32'h01;
        in6 = 32'h01;
        in7 = 32'h01;
        in8 = 32'h01;
        in9 = 32'h01;
        in10 = 32'h01;
        in11 = 32'h01;
        in12 = 32'h01;
        in13 = 32'h01;
        in14 = 32'h01;
        in15 = 32'h01;
        // par = {32'h01, 32'h02, 32'h03, 32'h04, 32'h05, 32'h06, 32'h07, 32'h08, 32'h09, 32'h0a, 32'h0b, 32'h0c, 32'h0d, 32'h0e, 32'h0f, 32'h10};  
        par0 = 32'h01;
        par1 = 32'h02;
        par2 = 32'h03;
        par3 = 32'h04;
        par4 = 32'h05;
        par5 = 32'h06;
        par6 = 32'h07;
        par7 = 32'h08;
        par8 = 32'h09;
        par9 = 32'h0a;
        par10 = 32'h0b;
        par11 = 32'h0c;
        par12 = 32'h0d;
        par13 = 32'h0e;
        par14 = 32'h0f;
        par15 = 32'h10;
    #20    
        sel_cu<=2'b11;  //执行乘法操作
    #20 
        sel_cu_go_back<=2'b10; //数据进入下一步
    #20
        sel_adder<=2'b10;  //进行加法树操作

    #20
        //控制信号归零，方便后面调试查看
        sel_cu<=2'b00; sel_cu_go_back<=2'b00; sel_adder<=2'b00;

    #100    
        //--------------------测试两个矩阵相乘分别输出部分和的情况 --------------
        // in = {32'h01, 32'h02, 32'h03, 32'h04, 32'h05, 32'h06, 32'h07, 32'h08, 32'h09, 32'h0a, 32'h0b, 32'h0c, 32'h0d, 32'h0e, 32'h0f, 32'h10};
        in0 = 32'h01;
        in1 = 32'h02;
        in2 = 32'h03;
        in3 = 32'h04;
        in4 = 32'h05;
        in5 = 32'h06;
        in6 = 32'h07;
        in7 = 32'h08;
        in8 = 32'h09;
        in9 = 32'h0a;
        in10 = 32'h0b;
        in11 = 32'h0c;
        in12 = 32'h0d;
        in13 = 32'h0e;
        in14 = 32'h0f;
        in15 = 32'h10;
        // par = {32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02, 32'h02};  
        par0 = 32'h02;
        par1 = 32'h02;
        par2 = 32'h02;
        par3 = 32'h02;
        par4 = 32'h02;
        par5 = 32'h02;
        par6 = 32'h02;
        par7 = 32'h02;
        par8 = 32'h02;
        par9 = 32'h02;
        par10 = 32'h02;
        par11 = 32'h02;
        par12 = 32'h02;
        par13 = 32'h02;
        par14 = 32'h02;
        par15 = 32'h02;
    #20    
        sel_cu<=2'b11; //执行乘法操作
    #20 
        sel_cu_go_back<=2'b10;   //数据进入下一步
    #20
        sel_adder<=2'b01; //跳过加法树进入下一步
    #20
        //控制信号归零，方便后面调试查看
        sel_cu<=2'b00; sel_cu_go_back<=2'b00; sel_adder<=2'b00;

    #100
        //----------------------测试求两个点的距离的情况，先加后乘   距离计算：k-NN， k-Means------------------------------------
        // Y = (x1-x2)² + (y1-y2)²          //先加后乘电路
        // step1:
	    //   Z1 = a1 + b1 , Z2 = a2 + b2;   //加法电路
        // step2:
        //   W2 = Z1 * Z1 + Z2 * Z2;        //乘加电路
        // in = {32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01, 32'h01};
        in0 = 32'h01;
        in1 = 32'h01;
        in2 = 32'h01;
        in3 = 32'h01;
        in4 = 32'h01;
        in5 = 32'h01;
        in6 = 32'h01;
        in7 = 32'h01;
        in8 = 32'h01;
        in9 = 32'h01;
        in10 = 32'h01;
        in11 = 32'h01;
        in12 = 32'h01;
        in13 = 32'h01;
        in14 = 32'h01;
        in15 = 32'h01;
        // par = {32'h01, 32'h02, 32'h03, 32'h04, 32'h05, 32'h06, 32'h07, 32'h08, 32'h09, 32'h0a, 32'h0b, 32'h0c, 32'h0d, 32'h0e, 32'h0f, 32'h10};  
        par0 = 32'h01;
        par1 = 32'h02;
        par2 = 32'h03;
        par3 = 32'h04;
        par4 = 32'h05;
        par5 = 32'h06;
        par6 = 32'h07;
        par7 = 32'h08;
        par8 = 32'h09;
        par9 = 32'h0a;
        par10 = 32'h0b;
        par11 = 32'h0c;
        par12 = 32'h0d;
        par13 = 32'h0e;
        par14 = 32'h0f;
        par15 = 32'h10;
    #20    
        sel_cu<=2'b10;  //计算加法操作
    #20 
        //这里由于把cu_out赋值给Par以后，就会算出一个新的cu_out，因此需要先保存一下，再复制
        is_save_cu_out<=1'b1;
    #20
        sel_cu_go_back<=2'b01;  //把结果赋值给Par
    #20 
        sel_cu_go_back<=2'b11;  //把结果赋值给In
    #20    
        sel_cu<=2'b11;         //计算乘法操作
    #20 
        sel_cu_go_back<=2'b10; //进入下一步
    #20
        sel_adder<=2'b10;     //进入加法树计算
    #150
        sel_cu<=2'b00; sel_cu_go_back<=2'b00; sel_adder<=2'b00;
    $finish;
    end
endmodule