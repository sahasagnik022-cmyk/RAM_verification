class ram_generator;
  ram_transaction blueprint;
  mailbox #(ram_transaction) mbx;
  int num_transactions=`NO_OF_TRANS;
  function new(mailbox #(ram_transaction) mbx);
    this.mbx=mbx;
    blueprint=new();
  endfunction
  task run();
    $display("[%0t] [GEN] Generator Started.", $time);
    for(int i=0;i<num_transactions;i++) begin
      ram_transaction drv_tx;
      drv_tx=blueprint.copy();
      if(!drv_tx.randomize()) begin
        $display("FATAL:Randomization failed");
        $finish;
      end
      mbx.put(drv_tx);
      $display("[%0t] [GEN] Created Tx %0d | W=%0b R=%0b | Addr=%0d | DataIn=%0d", 
                     $time,i,drv_tx.write_enb,drv_tx.read_enb,drv_tx.address,drv_tx.data_in);
    end
    $display("[%0t] [GEN] Generator Finished. Created %0d transactions.", $time, num_transactions);
  endtask
endclass
