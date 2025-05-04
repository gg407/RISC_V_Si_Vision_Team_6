class data_seqr extends uvm_sequencer#(data_seq_item);

  `uvm_component_utils(data_seqr) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name = "data_seqr", uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
