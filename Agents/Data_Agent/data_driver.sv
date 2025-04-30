class data_driver extends uvm_driver#(data_seq_item);
    `uvm_component_utils(driver)
    virtual data_if vif;
    data_seq_item req,rsp;

    function new(string name="data_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("data Driver", "Building driver", UVM_MEDIUM)
        if(!(uvm_config_db#(virtual data_if)::get(null, "", "vif", vif)))
            `uvm_fatal("NOVIF", "No virtual interface found");
        `uvm_info("data Driver", "Finished building driver", UVM_MEDIUM)
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("data Driver", "Running driver", UVM_MEDIUM)
        //reset();
        forever begin
            @(posedge vif.clk)
            vif.valid_i = 1'b0;
            if(vif.data_req_o) begin 
                vif.grant_i = 1'b1;
                seq_item_port.get_next_item(req);
                    capture(req);
                seq_item_port.item_done (req);
                seq_item_port.get_next_item(rsp);
                    drive(rsp);
                vif.valid_i = 1'b1;
                seq_item_port.item_done (rsp);
            end

        end
    endtask

    task reset();
        `uvm_info("Driver", "Resetting driver", UVM_MEDIUM)
        @(posedge vif.clk);
        vif.valid_i = 1'b0;
        vif.grant_i = 1'b0;
        vif.data_rdata_i = 0;
        `uvm_info("Driver", "Finished resetting driver", UVM_MEDIUM)
    endtask 

    task drive(data_seq_item rsp);
        vif.data_rdata_i =rsp.data_rdata_i ;
    endtask

    task capture(data_seq_item req);
        req.data_addr_o =vif.data_addr_o ;
        req.data_we_o =vif.data_we_o ;
        req.data_be_o =vif.data_be_o ;
        req.data_wdata_o =vif.data_wdata_o ;

    endtask
endclass