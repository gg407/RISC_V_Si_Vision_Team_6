class ins_driver extends uvm_driver#(ins_seq_item);
    `uvm_component_utils(ins_driver)
    virtual ins_if vif;
    ins_seq_item req,rsp;

    function new(string name="ins_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("INS Driver", "Building driver", UVM_MEDIUM)
        if(!(uvm_config_db#(virtual ins_if)::get(null, "", "vif", vif)))
            `uvm_fatal("NOVIF", "No virtual interface found");
        `uvm_info("INS Driver", "Finished building driver", UVM_MEDIUM)
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("INS Driver", "Running driver", UVM_MEDIUM)
        //reset();
        forever begin
            vif.instr_gnt_i = 1'b1;
            @(posedge vif.clk)
            vif.instr_rvalid_i = 1'b0;
            if(vif.instr_req_o) begin 
                seq_item_port.get_next_item(req);
                    capture(req);
                seq_item_port.item_done (req);
                seq_item_port.get_next_item(rsp);
                drive(rsp);
                vif.instr_rvalid_i = 1'b1;
                seq_item_port.item_done (rsp);
            end

        end
    endtask

    task reset();
        `uvm_info("Driver", "Resetting driver", UVM_MEDIUM)
        @(posedge vif.clk);
        vif.instr_rvalid_i = 1'b0;
        vif.instr_gnt_i = 1'b0;
        vif.instr_rdata_i = 0;
        `uvm_info("Driver", "Finished resetting driver", UVM_MEDIUM)
    endtask 

    task drive(ins_seq_item rsp);
        vif.instr_rdata_i =rsp.instr_rdata_i ;
    endtask

    task capture(ins_seq_item req);
        req.instr_addr_o =vif.instr_addr_o ;

    endtask
endclass
