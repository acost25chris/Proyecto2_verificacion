class scoreboard extends uvm_scoreboard;
    	`uvm_component_utils(scoreboard)

    	bit 		sign_X, sign_Y, sign_result;
    	logic [7:0] 	exp_X, exp_Y, exp_result;
    	logic [23:0] 	mantissa_X, mantissa_Y;
    	logic [47:0] 	mantissa_product; // Mantener 48 bits para el producto
    	logic [22:0] 	mantissa_final;
    	bit 		guard, round, sticky;
    	bit [31:0] 	expected_result;
	Item 		scoreboard_DB[$];
	Item		item_aux;
	int		csv_file; 

    	function new(string name="scoreboard", uvm_component parent=null);
        	super.new(name, parent);
    	endfunction

    	uvm_analysis_imp #(Item, scoreboard) m_analysis_imp;

    	virtual function void build_phase(uvm_phase phase);
        	super.build_phase(phase);
        	m_analysis_imp = new("m_analysis_imp", this);
    	endfunction

    	virtual function void write(Item item);
        	expected_mul(item);
        	`uvm_info("SCBD", $sformatf("in1=%0d in2=%0d DUT_out=%0d round mode=%0d", item.fp_X, item.fp_Y, item.fp_Z, item.r_mode), UVM_LOW)

        	if (item.fp_Z != expected_result) begin
            		`uvm_error("SCBD", $sformatf("ERROR: DUT=%0b expected=%0b", item.fp_Z, expected_result))
        	end else begin
            		`uvm_info("SCBD", $sformatf("PASS: DUT=%0d expected=%0d", item.fp_Z, expected_result), UVM_HIGH)
        	end
	
		scoreboard_DB.push_back(item);
    	endfunction

	virtual function void expected_mul(Item item);
		// Extraer el signo, el exponente y la mantisa de los operandos
		sign_X = item.fp_X[31];
		sign_Y = item.fp_Y[31];
		exp_X = item.fp_X[30:23]; 
		exp_Y = item.fp_Y[30:23];
		mantissa_X = {1'b1, item.fp_X[22:0]}; // Añadir bit implícito 1 en la mantisa
		mantissa_Y = {1'b1, item.fp_Y[22:0]};

		// Calcular el signo del resultado (XOR entre los signos)
		sign_result = sign_X ^ sign_Y;

		// Sumar los exponentes y ajustar el sesgo
		exp_result = (exp_X + exp_Y) - 127; 

		// Multiplicar las mantisas usando una multiplicación extendida de 24x24 bits
		mantissa_product = mantissa_X * mantissa_Y;
		//$display("Mantiza product %b",mantissa_product);

		// Normalización de la mantisa
		if(mantissa_product[47] == 1) begin
		    	mantissa_product = mantissa_product >> 1; // Desplazar a la derecha
		    	exp_result = exp_result + 1; // Ajustar el exponente
		end

		// Extraer los bits de redondeo (guard, round y sticky)
		round = mantissa_product[21];
		guard = mantissa_product[20];
		sticky = |mantissa_product[19:0]; // Sticky es 1 si cualquier bit en los bits bajos está activo

		// Aplicar el redondeo según el modo seleccionado
		case (item.r_mode)
			3'b000: begin // Redondeo al par más cercano (round to nearest, ties to even)
		        	if (round && guard && sticky) begin
		            		mantissa_final = mantissa_product[45:23] + 1;
		        	end else begin
		            		mantissa_final = mantissa_product[45:23];
		        	end
		    	end

		    	3'b001: begin // Redondeo hacia cero (round towards zero)
				mantissa_final = mantissa_product[45:23];
			end

		    	3'b010: begin // Redondeo hacia -infinito
				if (sign_result == 1) begin
				   	mantissa_final = mantissa_product[45:23] + 1;
				end else begin
					mantissa_final = mantissa_product[45:23];
				end
			end

		    	3'b011: begin // Redondeo hacia +infinito
		        	if (sign_result == 0) begin
		            		mantissa_final = mantissa_product[45:23] + 1;
		        	end else begin
		            		mantissa_final = mantissa_product[45:23];
		        	end
		    	end

		    	3'b100: begin // Redondeo a más cercano, fuera de cero 
				if (round == 1) begin
		            		mantissa_final = mantissa_product[45:23] + 1;
		        	end else begin
		            		mantissa_final = mantissa_product[45:23];
		        	end
		    	end

		    	default: begin // Si no se especifica, usar redondeo al par más cercano
		        	mantissa_final = mantissa_product[45:23];
		    	end
		endcase

		// Empaquetar el resultado final en IEEE-754
		if (item.ovrf == 1) begin // Overflow de exponente, resultado es infinito
		    	expected_result = {sign_result, 8'hFF, 23'h0};
			item.fp_esperado = expected_result;
		end else if (item.udrf == 1) begin // Underflow de exponente, resultado es cero
		    	expected_result = {sign_result, 8'h00, 23'h0};
			item.fp_esperado = expected_result;
		end else begin
			//$display("sign_result %b",mantissa_final);
		    	expected_result = {sign_result, exp_result[7:0], mantissa_final};
			item.fp_esperado = expected_result;
		end
	endfunction
	
	virtual function void documento_csv();
		$display("[%g] Generando reporte CSV", $time);
		csv_file = $fopen("Reporte_scoreboard.csv", "w"); //abre un archivo csv en modo escritura "w"
		$fwrite(csv_file, "Rounding mode, Dato X, Data Y, Resultado DUT, Resultado esperado, Ovrflow, Underflow\n"); //encabezado del documento
		foreach (scoreboard_DB[i]) begin
        		item_aux = scoreboard_DB[i];
			$fwrite(csv_file, "%b,%h,%h,%h,%h,%b,%b\n",
			item_aux.r_mode,
                	item_aux.fp_X,
			item_aux.fp_Y,  
                	item_aux.fp_Z,
			item_aux.fp_esperado, 
                	item_aux.ovrf, 
                	item_aux.udrf);
     		end
		$fclose(csv_file);
	endfunction
endclass

    

