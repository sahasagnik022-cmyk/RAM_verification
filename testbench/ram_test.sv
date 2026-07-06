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

class ram_test_negative extends ram_test;
    function new(virtual ram_if vif);
        super.new(vif); 
    endfunction
    task run();
        $display("[%0t] [TST] ILLEGAL Negative Test Started.", $time);
        env = new(vif);
        env.build();
        env.gen.blueprint = new();
        env.gen.blueprint.wr_rd.constraint_mode(0);
        env.gen.blueprint.randomize() with { write_enb == 1; read_enb == 1; };
        env.run();
    endtask
    
endclass
