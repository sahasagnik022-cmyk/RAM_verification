class ram_environment;
    virtual ram_if vif;
    mailbox #(ram_transaction) mbx_gen2drv; 
    mailbox #(ram_transaction) mbx_drv2ref; 
    mailbox #(ram_transaction) mbx_ref2scb; 
    mailbox #(ram_transaction) mbx_mon2scb; 
    ram_generator       gen;
    ram_driver          drv;
    ram_monitor         mon;
    ram_reference_model ref_model;
    ram_scoreboard      scb;
    function new(virtual ram_if vif);
        this.vif = vif;
    endfunction
    task build();
        $display("[%0t] [ENV] Build Phase Started",$time);
        mbx_gen2drv=new(1);
        mbx_drv2ref=new();
        mbx_ref2scb=new();
        mbx_mon2scb=new();
        gen=new(mbx_gen2drv);
        drv=new(mbx_gen2drv, mbx_drv2ref, vif); 
        mon=new(vif, mbx_mon2scb);
        ref_model=new(mbx_drv2ref, mbx_ref2scb); 
        scb=new(mbx_ref2scb, mbx_mon2scb);
    endtask
    task run();
        $display("[%0t] [ENV] Run Phase Started",$time);
        fork
            gen.run();
            drv.run();
            mon.run();
            ref_model.run();
            scb.run();
        join_any 
        #50; 
        scb.report();
        $finish;
    endtask

endclass
