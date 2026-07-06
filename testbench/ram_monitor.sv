class ram_monitor;
    ram_transaction mon_tx;
    mailbox #(ram_transaction) mbx_ms; 
    virtual ram_if.mon vif;            
    logic prev_read = 0;
    logic [`ADDR_WIDTH-1:0] prev_addr;

    covergroup mon_cg;
        DATA_OUT: coverpoint mon_tx.data_out { bins dout={[0:255]}; }
    endgroup

  function new(virtual ram_if.mon vif, mailbox #(ram_transaction) mbx_ms);
        this.vif = vif;
        this.mbx_ms = mbx_ms;
        mon_cg = new();
    endfunction

    task run();
        wait(vif.reset == 1);

        forever begin
            @(vif.mon_cb); 
            if (prev_read) begin
                mon_tx = new();
                mon_tx.write_enb=0;
                mon_tx.read_enb=1;
                mon_tx.address=prev_addr;     
                mon_tx.data_out=vif.mon_cb.data_out; 
                mon_cg.sample(); 
                mbx_ms.put(mon_tx);
                $display("[%0t] [MON] Captured READ  | Addr=%0d | DataOut=%0d", 
                         $time, mon_tx.address, mon_tx.data_out);
            end
            prev_read = (!vif.mon_cb.write_enb && vif.mon_cb.read_enb);
            prev_addr = vif.mon_cb.address; 
            if (vif.mon_cb.write_enb && !vif.mon_cb.read_enb) begin
                $display("[%0t] [MON] Captured WRITE | Addr=%0d | DataIn=%0d", 
                         $time, vif.mon_cb.address, vif.mon_cb.data_in);
            end
        end
    endtask
endclass
