import ram_pkg::*;
`include "ram_defines.svh"
module tb_top;
    bit clk = 0;
    bit reset;
    event trig_rst;
    initial begin
        forever #10 clk = ~clk;
    end
    ram_if pif(clk,reset);
    RAM dut (.clk(clk),.reset(reset),.address(pif.address),.write_enb(pif.write_enb),.read_enb(pif.read_enb),.data_in(pif.data_in),.data_out(pif.data_out));
    always@(pif.trig_rst) begin
        reset=0;
        #20;
        $display("Reset complete");
        reset=1;
    end
   // ram_test tb;
 //  ram_test_directed tb;
   ram_test_reset tb;
    initial begin
        reset=0;
        #20;
        reset=1;
        tb = new(pif);
        tb.run();
    end
endmodule
