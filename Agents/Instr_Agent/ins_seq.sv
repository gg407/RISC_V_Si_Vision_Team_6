class inst_seq extends uvm_sequence #(inst_seq_item);
    `uvm_object_utils(inst_seq)    
    ins_seq_item req,rsp;
    ins_seq_item q [$:2];
    [31:0] inst_mem [int];
   // [31:0] inst_mem [32];

    
    //inst_mem [0:inst_mem_size-1] = { 
    int num_items;
    ins_cfg cfg;

    function new(string name="inst_seq");
        super.new(name);
    endfunction

    virtual task pre_body();
        `uvm_info("Seq", "Starting pre body ", UVM_MEDIUM)
        cfg=ins_cfg::type_id::create("cfg");

        if(!uvm_config_db#(ins_cfg)::get(m_sequencer, "", "cfg", cfg))
            `uvm_fatal("NOCFG", "No configuration object found");
        
        num_items = cfg.num_items;
        `uvm_info("Seq", "Finished pre body ", UVM_MEDIUM)

    endtask

    virtual task body();
        `uvm_info("Seq", "Starting sequence", UVM_MEDIUM)
        req = seq_item::type_id::create("req");
        rsp = seq_item::type_id::create("rsp");
        for(int i=0;i<inst_num; i=i+4) begin
            assert(rsp.randomize);
            inst_mem[i] = rsp.instruction;
        end
        rsp = seq_item::type_id::create("rsp");
        for(int i=0 ;i<inst_num; i=i+4) begin
            start_item(req);
            finish_item(req);
            
            start_item(rsp);
            rsp.copy(req);
            if (inst_mem.exists(req.instr_addr_o)) begin
                rsp.instr_rdata_i = inst_mem[req.instr_addr_o];
            end else begin
                rsp.instr_rdata_i = 32'h00000013; // NOP: ADDI x0, x0, 0
                `uvm_warning("Driver SEQ", $sformatf("Sent NOP for missing addr 0x%08x", req.instr_addr_o));
            end
             
            finish_item(rsp);

            // Non ideal case
            // if(rsp.grant) begin
            //     q.push_front(req);
            // end
            
            

            // if(q.size() > 0) begin
            //     if(rsp.rvalid) begin
            //         inst_mem[req.addr] = rsp.instruction;
            //         rsp.instr_i = inst_mem[req.addr];
            //     end
            // end
            // start_item(rsp);
            // finish_item(rsp);
            
        end
        

        `uvm_info("Seq", "Finishing sequence", UVM_MEDIUM)
        
    endtask
endclass
//capture the reqeset 
//put it in a queue
//choose whether to respond now or later
//if the randomized signals the rvalid is high
//the response will be sent to the driver based on the request that should be poped from the queue
