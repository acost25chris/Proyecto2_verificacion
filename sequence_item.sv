class Item extends uvm_sequence_item;
	rand bit [2:0] 		r_mode;
  	randc bit [31:0] 	fp_X, fp_Y;
	rand int		delay;
  	bit [31:0] 		fp_Z;
	bit [31:0] 		fp_esperado;
	bit 			ovrf, udrf;

	`uvm_object_utils_begin(Item)
		`uvm_field_int(r_mode,UVM_DEFAULT)
		`uvm_field_int(fp_X,UVM_DEFAULT)
		`uvm_field_int(fp_Y,UVM_DEFAULT)
		`uvm_field_int(fp_Z,UVM_DEFAULT)
		`uvm_field_int(fp_esperado,UVM_DEFAULT)
		`uvm_field_int(ovrf,UVM_DEFAULT)
		`uvm_field_int(udrf,UVM_DEFAULT)
	`uvm_object_utils_end

	constraint const_r_mode {r_mode >= 3'b00; r_mode < 3'b101;}
	constraint const_delay{soft delay inside {[1:10]};}

	constraint const_fp_XY {
    		// Normalizados
    		(fp_X[30:23] inside {[8'h01:8'hFE]}) || // Exponentes entre 1 y 254 (normalizado)
    		(fp_Y[30:23] inside {[8'h01:8'hFE]}) ||

	    	// Subnormales
	    	(fp_X[30:23] == 8'h00 && fp_X[22:0] != 0) || // Exponente 0, mantisa no cero
	    	(fp_Y[30:23] == 8'h00 && fp_Y[22:0] != 0) ||

	    	// Overflow (Infinity)
	    	(fp_X[30:23] == 8'hFF && fp_X[22:0] == 0) || // Exponente 255, mantisa cero
	    	(fp_Y[30:23] == 8'hFF && fp_Y[22:0] == 0) ||

	    	// NaN
	    	(fp_X[30:23] == 8'hFF && fp_X[22:0] != 0) || // Exponente 255, mantisa no cero
	    	(fp_Y[30:23] == 8'hFF && fp_Y[22:0] != 0);
  	}

  	function new(string name = "Item");
    		super.new(name);
  	endfunction

	virtual function string convert2str();
    		return $sformatf("in1=%0d, in2=%0d, out=%0d",fp_X, fp_Y, fp_Z);
  	endfunction
endclass

