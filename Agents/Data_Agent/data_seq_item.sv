class data_seq_item extends uvm_sequence_item;
  
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  bit we ;
  bit[3:0] be;
  bit [31:0] addr ;
  int wdata ;
  rand int rdata ;
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(data_seq_item)
  	`uvm_field_int(we,UVM_ALL_ON)
  	`uvm_field_int(be,UVM_ALL_ON)
  	`uvm_field_int(addr,UVM_ALL_ON)
  	`uvm_field_int(wdata,UVM_ALL_ON)
  	`uvm_field_int(rdata,UVM_ALL_ON)	
  `uvm_object_utils_end
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "data_seq_item");
    super.new(name);
  endfunction
  //---------------------------------------
  // printing
  //---------------------------------------
   
  function string convert2string();
    return($sformatf("we : %0d , be : %0d , addr : %0d , wdata : %0d , rdata : %0d  ",we,be,addr,wdata,rdata));
  endfunction
  //---------------------------------------
  //Constrains
  //---------------------------------------
  constraint data {
    rdata dist{ –2147483648 := 25 ,  2147483647 := 25 , 0 :=25 , [-2147483647 : -1 ] :/ 12.5 , [1 : 2147483646] :/ 12.5 }; 
  				  }
endclass
  
