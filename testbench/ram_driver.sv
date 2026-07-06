class ram_driver;
  ram_transaction drv_tx;
  mailbox #(ram_transaction) mbx_gd;
  mailbox #(ram_transaction) mbx_dr;
  
  virtual ram_if.drv vif;
  
  covergroup drv_cg;
        WRITE: coverpoint drv_tx.write_enb { bins wrt[]={0,1}; }
        READ : coverpoint drv_tx.read_enb  { bins rd[]={0,1};  }
        DATA_IN: coverpoint drv_tx.data_in   { bins data={[0:255]}; }
        ADDRESS: coverpoint drv_tx.address   { bins address={[0:31]}; }
        WRXRD: cross WRITE, READ;
  endgroup
  
  function new(mailbox #(ram_transaction) mbx_gd, mailbox #(ram_transaction) mbx_dr, virtual ram_if.drv vif);
        this.mbx_gd=mbx_gd;
        this.mbx_dr=mbx_dr;
        this.vif=vif;
        drv_cg=new();
  endfunction
  
  task run();
    $display("[%0t] [DRV] Driver Started. Waiting for Reset...", $time);
    wait(vif.reset==1);
    $display("[%0t] [DRV] Reset finished! Driver active.", $time);
    
    forever begin
      mbx_gd.get(drv_tx);
      drv_cg.sample();
      mbx_dr.put(drv_tx);
      @(vif.drv_cb);
      vif.drv_cb.write_enb <= drv_tx.write_enb;
      vif.drv_cb.read_enb  <= drv_tx.read_enb;
      vif.drv_cb.address   <= drv_tx.address;
      if(drv_tx.write_enb) begin
        vif.drv_cb.data_in <= drv_tx.data_in;
      end 
      else begin
        vif.drv_cb.data_in<={`DATA_WIDTH{1'bz}}; 
      end
      $display("[%0t] [DRV] Driven | W=%0b R=%0b | Addr=%0d | DataIn=%0d", 
                     $time, drv_tx.write_enb, drv_tx.read_enb, drv_tx.address, drv_tx.data_in);
    end
  endtask
endclass
