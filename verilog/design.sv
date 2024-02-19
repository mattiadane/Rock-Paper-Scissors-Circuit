module MorraCinese (
    input clk,               // segnale di clock
    input reg[1:0] primo,    // input della scelta del primo giocatore
    input reg[1:0] secondo,  // input della scelta del secondo giocatore
    input inizia,            // bit che mi funziona da reset
    output reg[1:0] manche,      // output che mi dice come è andata la manche
  output reg[1:0] partita     // output che mi dice come è andata la partita
);
  	reg[1:0] stato;
  	reg[4:0] n_manche;       // registro adibito a tenere il numero massimo di manche
  	reg[4:0] count_manche;   // registro adibito per tenere il conto delle manche giocate
    reg[4:0] count1;         // registro che conta il punteggio del primo giocatore
    reg[4:0] count2;         // registro che conta il punteggio del secondo giocatore
  	reg[1:0] stato_prossimo; // registro per salvare lo stato prossimo in base agli input
    reg[1:0] vincitore_prec; // registro per salvare vincitore precedente
    reg[1:0] mossa_prec;     // registro per salvare la mossa del vincitore precedente
  
  	// bit provenienti dal Datapth
    bit vantaggio_mag_1_2; 
  	bit vantaggio_mag_2_2;
    bit forza_fine;         // bit utilizzato per forzare la fine di una partita
    bit mosse_valide;       
  	bit terminabile;

    always @(posedge clk) begin : UPDATE
        if(inizia) begin
            stato = 3'b000;                       // setto come stato iniziale INIZIA
            n_manche = {primo, secondo} + 3'b100; // setto il numero di manche massime da giocare
            count1 = 5'b00000;                    // setto il punteggio del primo giocatore a 0
            count2 = 5'b00000;                    // setto il punteggio del secondo giocatore a 0
            count_manche = 5'b00000;              // setto il contatore delle manche giocate a 0
          	forza_fine = 1'b0;                    // resetto la fine forzata
		        vincitore_prec = 2'b00;               // resetto il vincitore
		        mossa_prec = 2'b00;                   // resetto la mossa precedente vincente
          	mosse_valide = 1'b0;                  // resetto le mosse valide
          	terminabile = 1'b0;                   // resetto la partita terminabile
          	vantaggio_mag_1_2 = 1'b0;             // resetto il vantaggio del giocatore 1
          	vantaggio_mag_2_2 = 1'b0;             // resetto il vantaggio del giocatore 2
        end else begin
            stato = stato_prossimo;               // metto come stato il valore del prossimo stato
        end
    end


  always @(primo, secondo) begin : DATAPATH
          
    if(count_manche > 3) begin
      	terminabile = 1'b1; 
   	end
  
    if(count1 >= (count2 + 1)) begin
   		vantaggio_mag_1_2 = 1'b1;
    end else begin
      	vantaggio_mag_1_2 = 1'b0;
    end
    
    if(count2 >= (count1 + 1)) begin
      	vantaggio_mag_2_2 = 1'b1;
    end else begin
        vantaggio_mag_2_2 = 1'b0;
    end   
    
    case(vincitore_prec)
          2'b01:
                if(primo == mossa_prec) begin
                    mosse_valide = 1'b0;
                end else begin
                    mosse_valide = 1'b1;
                end
            
            2'b10:
                if(secondo == mossa_prec) begin
                    mosse_valide = 1'b0;
                end else begin
                    mosse_valide = 1'b1;
                end
          	default:
              mosse_valide = 1'b1;
        endcase
    
    end
  
    

  always @(stato, primo, secondo, inizia, mosse_valide, terminabile, forza_fine, vantaggio_mag_1_2, vantaggio_mag_2_2) begin : FSM
    
        case (stato)
            2'b00:  // stato di reset/pareggio
              if(inizia) begin // per resettare la partita
                manche = 2'b00;
                partita = 2'b00;
                stato_prossimo = stato;
              end else begin
                if(mosse_valide) begin // nel caso in cui le mosse sono valide
                  if(forza_fine) begin
                    // situazione in cui siamo in pareggio ed è l'ultima manche giocabile
                    if(primo == 2'b01 && secondo == 2'b11 || 
                   		primo == 2'b10 && secondo == 2'b01 || 
                   		primo == 2'b11 && secondo == 2'b10) begin
                      	manche = 2'b01;
                      	partita = 2'b01;
                      	stato_prossimo = 2'b11;
                    end else if(secondo == 2'b01 && primo == 2'b11 || 
                        		secondo == 2'b10 && primo == 2'b01 || 
                        		secondo == 2'b11 && primo == 2'b10) begin
                      	manche = 2'b10;
                      	partita = 2'b10;
                      	stato_prossimo = 2'b11;
                    end else if(primo == 2'b00 || secondo == 2'b00) begin
                      	manche = 2'b00;
                      	partita = 2'b00;
                      	stato_prossimo = stato;
                    end else begin
                        manche = 2'b11;
                      	partita = 2'b11;
                      	stato_prossimo = 2'b11;
                    end
                  end else begin
                    // situazione in cui non sono all'ultima manche
                    if(primo == 2'b01 && secondo == 2'b11 || 
                   		primo == 2'b10 && secondo == 2'b01 || 
                   		primo == 2'b11 && secondo == 2'b10) begin
                      	manche = 2'b01;
                      	partita = 2'b00;
                      	stato_prossimo = 2'b01;
                    end else if(secondo == 2'b01 && primo == 2'b11 || 
                        		secondo == 2'b10 && primo == 2'b01 || 
                        		secondo == 2'b11 && primo == 2'b10) begin
                      	manche = 2'b10;
                      	partita = 2'b00;
                      	stato_prossimo = 2'b10;
                    end else if(primo == 2'b00 || secondo == 2'b00) begin
                        manche = 2'b00;
                      	partita = 2'b00;
                      	stato_prossimo = stato;
                    end else begin
                        manche = 2'b11;
                      	partita = 2'b00;
                      	stato_prossimo = 2'b00;
                    end
                  end
                end else begin
                  manche = 2'b00;
                  partita = 2'b00;
                  stato_prossimo = stato;
                end
              end
                
            2'b01: // stato di vantaggio del giocatore 1
              if(inizia) begin
                manche = 2'b00;
                partita = 2'b00;
                stato_prossimo = 2'b00;
              end else if(terminabile && vantaggio_mag_1_2) begin
                manche = vincitore_prec;
                partita = 2'b01;
                stato_prossimo = 2'b11;
              end else begin
                if(mosse_valide) begin
                  if(forza_fine) begin
                    // situazione in cui siamo nell'ultima manche giocabile
                    if(primo == 2'b01 && secondo == 2'b11 || 
                   		primo == 2'b10 && secondo == 2'b01 || 
                   		primo == 2'b11 && secondo == 2'b10) begin
                      manche = 2'b01;
                      partita = 2'b01;
                      stato_prossimo = 2'b11;
                    end else if(secondo == 2'b01 && primo == 2'b11 || 
                        		secondo == 2'b10 && primo == 2'b01 || 
                        		secondo == 2'b11 && primo == 2'b10) begin
                      manche = 2'b10;
                      if(terminabile && vantaggio_mag_1_2) begin
                        partita = 2'b01;
                        stato_prossimo = 2'b11;
                      end else begin
                        partita = 2'b11;
                        stato_prossimo = 2'b11;
                      end 
                      
                    end else if(primo == 2'b00 || secondo == 2'b00) begin
                        manche = 2'b00;
                      	partita = 2'b00;
                      	stato_prossimo = stato;
                    end else begin
                        manche = 2'b11;
                      	partita = 2'b01;
                      	stato_prossimo = 2'b11;
                    end
                  end else begin
                    // situazione non siamo all'ultima manche giocabile
                    if(primo == 2'b01 && secondo == 2'b11 || 
                   		primo == 2'b10 && secondo == 2'b01 || 
                   		primo == 2'b11 && secondo == 2'b10) begin
                      manche = 2'b01;
                      if(vantaggio_mag_1_2) begin // POSSIBILE MODIFICA CON VANTAGGIO_MAG
                        if(terminabile) begin
                         	partita = 2'b01;
                        	stato_prossimo = 2'b11;
                        end else begin 
                          	partita = 2'b00;
                          	stato_prossimo = stato;
                        end
                      end else begin
                        partita = 2'b00;
                        stato_prossimo = stato;
                      end 
                    end else if(secondo == 2'b01 && primo == 2'b11 || 
                        		secondo == 2'b10 && primo == 2'b01 || 
                        		secondo == 2'b11 && primo == 2'b10) begin
                      manche = 2'b10;
                      if(vantaggio_mag_1_2) begin
                        if(terminabile) begin
                          partita = 2'b01;
                          stato_prossimo = 2'b11;
                        end else begin
                          partita = 2'b00;
                          stato_prossimo = stato;
                        end
                      end else begin
                        partita = 2'b00;
                        stato_prossimo = 2'b00;
                      end
                    end else if(primo == 2'b00 || secondo == 2'b00) begin
                      manche = 2'b00;
                      partita = 2'b00;
                      stato_prossimo = stato;
                    end else begin
                      manche = 2'b11;
                      partita = 2'b00;
                      stato_prossimo = stato;
                    end
                  end

                end else begin
                  manche = 2'b00;
                  partita = 2'b00;
                  stato_prossimo = 2'b01;
                end
              end


            2'b10: // stato di vantaggio del giocatore 2
			if(inizia) begin
                manche = 2'b00;
                partita = 2'b00;
                stato_prossimo = 2'b00; // stato di reset/pareggio
              end else if(terminabile && vantaggio_mag_2_2) begin
                manche = vincitore_prec;
                partita = 2'b10;
                stato_prossimo = 2'b11;
              end else begin
                if(mosse_valide) begin
                  if(forza_fine) begin
                    // situazione in cui siamo all'ultima manche giocabile
                    if(primo == 2'b01 && secondo == 2'b11 || 
                   		primo == 2'b10 && secondo == 2'b01 || 
                   		primo == 2'b11 && secondo == 2'b10) begin
                      	manche = 2'b01;
                      if(vantaggio_mag_2_2 && terminabile) begin
                        partita = 2'b10;
                        stato_prossimo = 2'b11;
                      end else begin
                        partita = 2'b11;
                        stato_prossimo = 2'b11;
                      end
                    end else if(secondo == 2'b01 && primo == 2'b11 || 
                        		secondo == 2'b10 && primo == 2'b01 || 
                        		secondo == 2'b11 && primo == 2'b10) begin
						manche = 2'b10;
                      	partita = 2'b10;
                      	stato_prossimo = 2'b11;
                    end else if(primo == 2'b00 || secondo == 2'b00) begin
                      manche = 2'b00;
                      partita = 2'b00;
                      stato_prossimo = stato;
                    end else begin
                      manche = 2'b11;
                      partita = 2'b10;
                      stato_prossimo = 2'b11;
                    end
                  end else begin
                    // situazione di gioco normale
                    if(primo == 2'b01 && secondo == 2'b11 || 
                   		primo == 2'b10 && secondo == 2'b01 || 
                   		primo == 2'b11 && secondo == 2'b10) begin
                      manche = 2'b01;
                      if(vantaggio_mag_2_2) begin
                        if(terminabile) begin
                          partita = 2'b10;
                          stato_prossimo = 2'b11;                          
                        end else begin
                          partita = 2'b00;
                          stato_prossimo = stato;
                        end
                      end else begin 
                        partita = 2'b00;
                        stato_prossimo = 2'b00;
                      end
                    end else if(secondo == 2'b01 && primo == 2'b11 || 
                        		secondo == 2'b10 && primo == 2'b01 || 
                        		secondo == 2'b11 && primo == 2'b10) begin
                      manche = 2'b10;
                      if(vantaggio_mag_2_2) begin
                        if(terminabile) begin
                        	partita = 2'b10;
                        	stato_prossimo = 2'b11;
                        end else begin
                          partita = 2'b00;
                          stato_prossimo = stato;
                        end
                      end else begin
                        partita = 2'b00;
                        stato_prossimo = stato;
                      end
                    end else if(primo == 2'b00 || secondo == 2'b00) begin
                      manche = 2'b00;
                      partita = 2'b00;
                      stato_prossimo = stato;
                    end else begin
                      manche = 2'b11;
                      partita = 2'b00;
                      stato_prossimo = stato;
                    end
                  end
                  
                end else begin
                  manche = 2'b00;
                  partita = 2'b00;
                  stato_prossimo = 2'b10;
                end
              end
               
            2'b11: // stato di fine
              if(inizia) begin
                manche = 2'b00;
                partita = 2'b00;
                stato_prossimo = 2'b00;
              end else begin
                manche = 2'b00; 
                partita = 2'b00;
                stato_prossimo = stato;
              end
        endcase
    end
  	
  always @(posedge clk) begin : DATAPATH_USCITE
    if(mosse_valide == 1'b0) begin
      vincitore_prec = vincitore_prec;
    end else begin
      case(manche)
        2'b00: vincitore_prec = vincitore_prec;
        2'b01: vincitore_prec = 2'b01;
        2'b10: vincitore_prec = 2'b10;
        2'b11: vincitore_prec = 2'b11;
      endcase
    end
    
    	// valorizzo la mossa precedente
        case (manche)
          	2'b00:
                mossa_prec = mossa_prec;
            2'b01:
          		mossa_prec = primo;
            2'b10:
          		mossa_prec = secondo;
         	2'b11:
              mossa_prec = 2'b00;
        endcase
      
      	// case per aumentare i contatori
        case(manche)
          2'b01:
            count1 = count1 + 1;
          2'b10:
            count2 = count2 + 1;
        endcase
    
    	// incremento il valore di count manche
    	case(manche)
      		2'b01, 2'b10, 2'b11:
        	count_manche = count_manche + 1;
    	endcase
    end
  
  always @(posedge clk, count_manche) begin
      if(count_manche == n_manche) begin
        forza_fine = 1'b1; // bit per forzare la fine del gioco
    end
  end

endmodule