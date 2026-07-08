class ram_test;
    virtual ram_if vif;
    ram_environment env;
    function new(virtual ram_if vif);
        this.vif=vif;
    endfunction
    task run();
        $display("[%0t] [TST] Test Started.", $time);
        env=new(vif);
        env.build();
        env.run();
    endtask
endclass

class ram_test_directed extends ram_test;

    function new(virtual ram_if vif);
        super.new(vif);
    endfunction

    task run();
        $display("--- Starting Directed Sequence Test ---");
        env = new(vif);
        env.build();
        fork
            env.drv.run();
            env.mon.run();
            env.ref_model.run();
            env.scb.run();
        join_none
        wait(vif.reset == 1);
        repeat(1)@(posedge vif.clk)
        env.gen.write_sequence(5);
        repeat(5)@(posedge vif.clk)
        env.gen.hold_sequence(2);
        repeat(2)@(posedge vif.clk)
        env.gen.read_sequence(5);
        repeat(5)@(posedge vif.clk)
        $finish;
    endtask
endclass


class ram_test_reset extends ram_test;

    function new(virtual ram_if vif);
        super.new(vif);
    endfunction

    task run();
        ram_transaction tx;

        env = new(vif);
        env.build();

        fork
            env.drv.run();
            env.mon.run();
            env.ref_model.run();
            env.scb.run();
        join_none

        wait(vif.reset == 1);
        @(posedge vif.clk);

        tx = new();
        tx.write_enb = 1;
        tx.read_enb  = 0;
        tx.address   = 5;
        tx.data_in   = 42;
        env.gen.mbx.put(tx);

        repeat(2) @(posedge vif.clk);

        tx = new();
        tx.write_enb = 1;
        tx.read_enb  = 0;
        tx.address   = 10;
        tx.data_in   = 99;
        env.gen.mbx.put(tx);

        @(posedge vif.clk);
        -> vif.trig_rst;

        wait(vif.reset == 0);
        wait(vif.reset == 1);
        repeat(2) @(posedge vif.clk);

        tx = new();
        tx.write_enb = 0;
        tx.read_enb  = 1;
        tx.address   = 10;
        env.gen.mbx.put(tx);

        repeat(2) @(posedge vif.clk);

        tx = new();
        tx.write_enb = 0;
        tx.read_enb  = 1;
        tx.address   = 5;
        env.gen.mbx.put(tx);

        repeat(5) @(posedge vif.clk);

        $finish;
    endtask

endclass
