class ram_reference_model;
    ram_transaction ref_tx;
    mailbox #(ram_transaction) mbx_dr;
    mailbox #(ram_transaction) mbx_rs;
    logic [`DATA_WIDTH-1:0] ref_mem [0:`DEPTH-1]; 
    function new(mailbox #(ram_transaction) mbx_dr, mailbox #(ram_transaction) mbx_rs);
        this.mbx_dr = mbx_dr;
        this.mbx_rs = mbx_rs;
        foreach(ref_mem[i]) begin
            ref_mem[i] = {`DATA_WIDTH{1'bx}}; 
        end
    endfunction
    task run();
        $display("[%0t] [REF] Reference Model Started.", $time);
        forever begin
            mbx_dr.get(ref_tx);
            if (ref_tx.write_enb && !ref_tx.read_enb) begin
                ref_mem[ref_tx.address] = ref_tx.data_in;
                
                $display("[%0t] [REF] WRITE | Recorded Addr=%0d, DataIn=%0d", 
                         $time, ref_tx.address, ref_tx.data_in);
            end
            else if (!ref_tx.write_enb && ref_tx.read_enb) begin
                ram_transaction exp_tx = ref_tx.copy(); 
                exp_tx.data_out = ref_mem[ref_tx.address]; 
                mbx_rs.put(exp_tx); 
                $display("[%0t] [REF] READ  | Predicted Addr=%0d, ExpectedOut=%0d", 
                         $time, exp_tx.address, exp_tx.data_out);
            end
            else begin
                $display("[%0t] [REF] HOLD  | Ignoring Addr=%0d", $time, ref_tx.address);
            end
            
        end
    endtask
    
endclass
