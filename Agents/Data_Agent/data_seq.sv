class data_seq extends uvm_sequence #(data_seq_item);
    `uvm_object_utils(data_seq)    
    data_seq_item req,rsp;
    data_seq_item q [$:2];
    [7:0] data_mem [int];
    cfg data_agent_cfg;
    //[31:0] data_mem [32];

    
    int num_items;

    function new(string name="data_seq");
        super.new(name);
    endfunction

    virtual task pre_body();
        `uvm_info("Seq", "Starting pre body ", UVM_MEDIUM)
        cfg=data_agent_cfg::type_id::create("cfg");

        if(!uvm_config_db#(data_agent_cfg)::get(get_sequencer(), "", "cfg", cfg))
            `uvm_fatal("NOCFG", "No configuration object found");
        
        num_items = cfg.num_items;
        `uvm_info("Seq", "Finished pre body ", UVM_MEDIUM)

    endtask

    virtual task body();

        `uvm_info("Seq", "Starting sequence", UVM_MEDIUM)
    
        rsp = data_seq_item::type_id::create("rsp");
        // Load the memory with some important values
        {data_mem[0],data_mem[1],data_mem[2],data_mem[3]} = 32'b0;               // zero
        {data_mem[4],data_mem[5],data_mem[6],data_mem[7]} = {1'b0,31{1'b1}};     // max positive
        {data_mem[8],data_mem[8],data_mem[10],data_mem[11]} = {1'b1,31{1'b0}};   // max positive
        for(int i=12;i<inst_num; i=i+4) begin
            assert(rsp.randomize);
            {data_mem[i],data_mem[i+1],data_mem[i+2],data_memi[i+3]}= rsp.data;
        end

        forever begin

            start_item(req);
            finish_item(req);
            
            
            start_item(rsp);
                rsp.copy(req);
                rsp.data_rdata_i = 0;

                if(req.data_we_o) begin
                    foreach(req.data_be_o[i]) begin
                        if(req.data_be_o[i]) begin
                            data_mem[req.data_addr_o+i] = req.data_wdata_o>>(i*8);
                        end
                    end

                end
                else begin

                    foreach(req.data_be_o[i]) begin
                        if(req.data_be_o[i]) begin
                            rsp.data_rdata_i |= data_mem[req.data_addr_o+i]<<(i*8);
                        end
                    end
                end
            finish_item(rsp);
            


        end
        

        `uvm_info("Seq", "Finishing sequence", UVM_MEDIUM)
        
    endtask
endclass
//capture the reqeset 
//put it in a queue
//choose whether to respond now or later
//if the randomized signals the rvalid is high
//the response will be sent to the driver based on the request that should be poped from the queue
