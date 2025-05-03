
class instruction_sequencer extends uvm_sequencer#(ins_seq_item);
  `uvm_component_utils(instruction_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass

