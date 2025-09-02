`timescale 1ns/1ps
module fsm_fpga_tb;

    reg clk, rst, Rb;
    wire win, lose;

    // DUT instantiation
    fsm_fpga dut (.clk(clk),.rst(rst),.Rb(Rb),.win(win),.lose(lose));

    always #5 clk = ~clk;

    initial begin
        
        clk = 0; rst = 1; Rb  = 0;

        // Reset pulse
        #12 rst = 0;

        // First roll
        #10 Rb = 1;  
        #10 Rb = 0;

        // Keep rolling several times
        repeat (10) begin
            #20 Rb = 1;  
            #10 Rb = 0;
        end

        // Reset in between
        rst = 1; #10; rst = 0;

        repeat (5) begin
            #20 Rb = 1;  
            #10 Rb = 0;
        end

        #100 $finish;
    end

    always @(posedge clk) begin
        $display("t=%0t | rst=%b | ps=%b | ns=%b | Rb=%b | dice=(%0d,%0d) | sum=%0d | point=%0d | win=%b lose=%b", 
                 $time, rst, dut.ps, dut.ns, Rb, dut.a, dut.b, dut.sum, dut.store_pt, win, lose);         
   
    end

endmodule
