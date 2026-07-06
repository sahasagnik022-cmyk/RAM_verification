class ram_scoreboard;
    ram_transaction exp_tx; 
    ram_transaction act_tx; 
    mailbox #(ram_transaction) mbx_ref;
    mailbox #(ram_transaction) mbx_mon;
    int total_reads = 0;
    int passes      = 0;
    int fails       = 0;
    function new(mailbox #(ram_transaction) mbx_ref, mailbox #(ram_transaction) mbx_mon);
        this.mbx_ref = mbx_ref;
        this.mbx_mon = mbx_mon;
    endfunction
    task run();
        $display("[%0t] [SCB] Scoreboard Started.", $time);
        
        forever begin
            mbx_ref.get(exp_tx);
            mbx_mon.get(act_tx);
            total_reads++;
            if (exp_tx.address !== act_tx.address) begin
                $fatal(1, "[SCB] FATAL SYNC ERROR! Ref Addr=%0d, Mon Addr=%0d", exp_tx.address, act_tx.address);
            end
            if (exp_tx.data_out === act_tx.data_out) begin
                $display("[%0t] [SCB] PASS! Addr=%0d | Expected=%0d, Actual=%0d", 
                         $time, act_tx.address, exp_tx.data_out, act_tx.data_out);
                passes++;
            end else begin
                $error("[%0t] [SCB] FAIL! Addr=%0d | Expected=%0d, Actual=%0d", 
                       $time, act_tx.address, exp_tx.data_out, act_tx.data_out);
                fails++;
            end
        end
    endtask

    function void report();
        $display("========================================");
        $display("          SCOREBOARD SUMMARY            ");
        $display("========================================");
        $display(" Total Reads Checked : %0d", total_reads);
        $display(" Total Passes        : %0d", passes);
        $display(" Total Fails         : %0d", fails);
        $display("========================================");
    endfunction

endclass
