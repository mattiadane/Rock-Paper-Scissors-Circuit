module MorraCinese_tb;
    // Dichiarazione dei segnali
    reg clk ;
    reg [1:0] primo;
    reg [1:0] secondo;
    reg inizia;
    wire [1:0] manche;
    wire [1:0] partita;

    // Istanziazione del modulo
    MorraCinese mc (
        .clk(clk), 
        .primo(primo), 
        .secondo(secondo), 
      	.inizia(inizia),
        .manche(manche), 
        .partita(partita)
    );
  integer i,j,file1,file2;

    // Generazione del clock
    always begin
        #5 clk = ~clk;
    end

    // Testbench
    initial begin
      	$dumpfile("dump.vcd");
    	 $dumpvars(1);
        // Inizializzazione dei segnali
        clk = 0;
        primo = 2'b00;
        secondo = 2'b00;
        inizia = 1'b0;
      
        #10;  // Aspetta un ciclo di clock
		file1 = $fopen("testbench.script", "w");
      	file2 = $fopen("output_verilog.txt", "w");
      $fdisplay(file1, "read_blif FSMD.blif");
    	
        // Inizia la partita
        inizia = 1'b1;
        primo = 2'b10;  
        secondo = 2'b10;
      $fdisplay(file1, "simulate %b %b %b %b %b", primo[1], primo[0],secondo[1],secondo[0],inizia);
      	
        #10;
      $fdisplay(file2, "Outputs: %b %b %b %b", manche[1], manche[0],partita[1],partita[0]);
      
      	$display("Manche: %d - Partita: %d", manche, partita);

        // Continua la partita
      for (i = 0; i < 4 ; i = i + 1) begin 
        for (j = 0; j < 4 ; j = j + 1) begin
          	inizia = 0;
        	primo = i;  
        	secondo = j; 
          $fdisplay(file1, "simulate %b %b %b %b %b", primo[1], primo[0],secondo[1],secondo[0],inizia);
      	
        	#10;
          $display("Mosse giocate %d-%d // Manche: %d - Partita: %d", primo, secondo, manche, partita);
          $fdisplay(file2, "Outputs: %b %b %b %b", manche[1], manche[0],partita[1],partita[0]);
      
      end 
      end
      for (i = 3; i >= 0 ; i = i - 1) begin 
        for (j = 3; j >= 0 ; j = j - 1) begin
          	inizia = 0;
        	primo = i;  
        	secondo = j; 
          $fdisplay(file1, "simulate %b %b %b %b %b", primo[1],primo[0],secondo[1],secondo[0],inizia);
      	
        	#10;
          $display("Mosse giocate %d-%d // Manche: %d - Partita: %d", primo, secondo, manche, partita);
          $fdisplay(file2, "Outputs: %b %b %b %b", manche[1], manche[0],partita[1],partita[0]);
      
      end 
      end
      
      $fdisplay(file1, "quit");
      $fclose(file1);
      $fclose(file2);
      $finish;
    end
endmodule