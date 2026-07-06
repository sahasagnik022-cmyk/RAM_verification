`include "ram_defines.svh"
interface ram_if(input bit clk,input bit reset);
  logic [`DATA_WIDTH-1:0] data_in;
  logic [`DATA_WIDTH-1:0] data_out;
  logic write_enb,read_enb;
  logic [`ADDR_WIDTH-1:0] address;
  clocking drv_cb @(posedge clk);   
    output write_enb, read_enb, data_in, address;
  endclocking
  clocking mon_cb @(posedge clk);
    input write_enb, read_enb, data_in, address, data_out;
  endclocking
  
  modport drv(clocking drv_cb,input clk,reset);
  modport mon(clocking mon_cb,input clk,reset);
endinterface
