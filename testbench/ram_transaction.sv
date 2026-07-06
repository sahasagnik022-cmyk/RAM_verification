class ram_transaction;
  rand bit [`DATA_WIDTH-1:0] data_in;
  rand bit write_enb,read_enb;
  rand bit[`ADDR_WIDTH-1:0] address;
  bit [`DATA_WIDTH-1:0] data_out;
  
  constraint wr_rd{
    {write_enb,read_enb}!=2'b11;
  }
  virtual function ram_transaction copy();
        ram_transaction cp=new();
        cp.data_in=this.data_in;
        cp.write_enb=this.write_enb;
        cp.read_enb=this.read_enb;
        cp.address=this.address;
        cp.data_out=this.data_out;
        return cp;
    endfunction
    
endclass
