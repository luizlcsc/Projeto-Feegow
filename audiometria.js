
var tamano, ubicX, ubicY, filas, columnas;
var A_125, A_250, A_500, A_750, A_1000, A_1500, A_2000, A_3000, A_4000, A_6000, A_8000;
var A_E_125, A_E_250, A_E_500, A_E_750, A_E_1000, A_E_1500, A_E_2000, A_E_3000, A_E_4000, A_E_6000, A_E_8000;
var nom_ico = "";
var nom_ico_n = "";
var nom_ico_e = "";
var nom_ico_f = "";
var tipo = "";

//var jg = new jsGraphics("Canvas");    // Use the "Canvas" div for drawing 


//function cuadricula(tamano_t, ubicX_t, ubicY_t)

//function audio(tipo, A_125, A_250, A_500, A_750, A_1000, A_1500, A_2000, A_3000, A_4000, A_6000, A_8000)
function real(obj) {
	
	if (obj.search("-") == 1){  obj = obj.substring(1, 4); }
	if (obj.search("-") == 2){ obj = obj.substring(2, 4); }
	
	return obj;
}

function dibaudiod(aud)
{
		// Call jsGraphics() with no parameters if drawing within the entire document 
	
	//if (lado ==  "d") {objeto = "ODerecho";}
	//if (lado ==  "i") {objeto = "OIzquierdo";}	
		
	//	var jg = new jsGraphics(objeto);    // Use the "Canvas" div for drawing 
		
	//alert (aud)
	
		
		filas = 13;
		columnas = 10;
		tamano = 30;
		ubicX = 60;
		ubicY = 40;

//		filas = 12;
//		columnas = 10;
//		tamano = tamano_t;
//		ubicX = ubicX_t;
//		ubicY = ubicY_t;	

		jg.setFont("arial", "14px", Font.PLAIN);
		jg.setColor("blue");
	//	jg.drawString("Oido Derecho", ubicX, ubicY-40);
	//	jg.drawString("Oido Izquierdo", ubicX + (tamano*columnas + 30), ubicY-40);

//alert("BIEN...")		
		//jg.drawString("125  250 500 750 1000  1500  2000 3000 4000 6000 8000 ", ubicX, ubicY-20);
		// DIBUJA CUADRICULA
		jg.setFont("arial", "10px", Font.PLAIN);
		

		for (var i=0; i < 1; i++){
			
			ubicX = ubicX + (tamano*columnas + 40) * i
			
			// DIBUJA texto Hz
			jg.setColor("black");
			jg.drawString("125", ubicX-10 + (tamano*0), ubicY-20);
			jg.drawString("250", ubicX-10 + (tamano*1), ubicY-20);
			jg.drawString("500", ubicX-10 + (tamano*2), ubicY-20);
			jg.drawString("750", ubicX-10 + (tamano*3), ubicY-20);
			jg.drawString("1K", ubicX-10 + (tamano*4), ubicY-20);
			jg.drawString("1.5K", ubicX-10 + (tamano*5), ubicY-20);
			jg.drawString("2K", ubicX-10 + (tamano*6), ubicY-20);
			jg.drawString("3K", ubicX-10 + (tamano*7), ubicY-20);
			jg.drawString("4K", ubicX-10 + (tamano*8), ubicY-20);
			jg.drawString("6K", ubicX-10 + (tamano*9), ubicY-20);
			jg.drawString("8K", ubicX-10 + (tamano*10), ubicY-20);
			
			
			jg.setColor("5f5f5f");
			// DIBUJA COLUMNAS
			for (var j=0; j <= columnas; j++){
				jg.drawLine(tamano*j + ubicX, ubicY ,tamano*j + ubicX, ubicY + tamano*filas);
				//jg.drawRect(tamano*j + ubicX, ubicY,tamano,tamano*filas );
				
		     }
			
			// DIBUJA FILAS 		
				for (var j=0; j <= filas; j++){
				jg.drawLine(ubicX, tamano*j + ubicY, ubicX + tamano*columnas , tamano*j + ubicY );
				//jg.drawRect(ubicX, tamano*j + ubicY,tamano*columnas,tamano );
		     }		
		}
		
		// DIBUJA texto Db
			jg.setColor("black");
			
			jg.drawString("-10", ubicX -25 , ubicY -5 );
			for (var j=0; j < filas; j++){
				jg.drawString(10 * j ,ubicX -25 , ubicY -5  + (tamano*j) + tamano );
				}
			
			//jg.drawString("-10", ubicX  + (tamano*columnas + 15) , ubicY -5 );

			//for (var j=0; j < filas; j++){
			//	jg.drawString(10 * j ,ubicX  + (tamano*columnas + 15) , ubicY -5  + (tamano*j) + tamano );
			//	}
								
	//	ubicX = ubicX - (tamano*columnas + 40)



// AUDIOMETRIA AEREA - OIDO DERECHO

jg.setFont("arial", "14px", Font.BOLD);		
var cont = 7;
var cord = 5;

//if (taud == "a" ){cont = 7; cord = 5;}
//if (taud == "o" ){cont = 491; cord = 30;}

for (var i=0; i < 2; i++){		

			
	nom_ico = "";
	nom_ico_n = "";
	nom_ico_e = "";
	nom_ico_f = "";
	
	tipo = aud.substring(cont - 7, cont - 4);
	
	A_125 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_125 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_250 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_250 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_500 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_500 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_750 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_750 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_1000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_1000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_1500 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_1500 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_2000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_2000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_3000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_3000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_4000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_4000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_6000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_6000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_8000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_8000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	
	
	

   		  //VIA AREA DERECHA		
			if(tipo == "aad"){
				//ubicX = ubicX - (tamano*columnas + 40)
				jg.setStroke(1);
				jg.setColor("e51b1b");
				nom_ico_n = "vad.gif";
				nom_ico_e = "vade.gif";
				nom_ico_f = "vadf.gif";
			}

		  //VIA AREA IZQUIERDA
			if(tipo == "aai"){
				jg.setStroke(1);
				//ubicX = ubicX + (tamano*columnas + 40)
				jg.setColor("095aef");				
				nom_ico_n = "vai.gif";
				nom_ico_e = "vaie.gif";
				nom_ico_f = "vaif.gif";	
			
			}

		  //VIA OSEA DERECHA
			if(tipo == "aod"){
				//ubicX = ubicX - (tamano*columnas + 40)
				jg.setColor("e51b1b");
				jg.setStroke(Stroke.DOTTED);			
				nom_ico_n = "vod.gif";
				nom_ico_e = "vode.gif";
				nom_ico_f = "vodf.gif";
						
			}
		  
		  //VIA OSEA IZQUIERDA			
			if(tipo == "aoi"){
				jg.setStroke(Stroke.DOTTED);
				//ubicX = ubicX + (tamano*columnas + 40)
				jg.setColor("095aef");				
				nom_ico_n = "voi.gif";
				nom_ico_e = "voie.gif";
				nom_ico_f = "voif.gif";
			}

			
	 	// Umbral A_125 
			if(A_125 >= - 10 && A_125 <= 120){
				
				if (A_E_125 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_125*1, (ubicX-5) + tamano*0, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n; } // Simbolo Enmascarado
				

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 0, (A_125 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12); // Simbolo
				
				if(A_250 >= - 10 && A_250 <= 120){
					jg.drawLine(ubicX, (A_125 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano, (A_250 * tamano/10) + (ubicY + 10* tamano/10) );// Lineas
					}
				}
			if(A_125 >= - 120 && A_125 < -10){
				jg.drawImage(nom_ico_f, (ubicX - 5) + tamano * 0, (Math.abs(A_125) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20); // Simbolo no existe
				}


		// Umbral A_250
			
			if(A_250 >= - 10 && A_250 <= 120){
				if (A_E_250 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_250*1, (ubicX-5) + tamano*1, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 1, (A_250 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_500 >= - 10 && A_500 <= 120){
					jg.drawLine(ubicX + tamano * 1, (A_250 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 2, (A_500 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_250 >= - 120 && A_250 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 1,  (Math.abs(A_250) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}
				
		// Umbral A_500

			if(A_500 >= - 10 && A_500 <= 120){
				if (A_E_500 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_500*1, (ubicX-5) + tamano*2, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 2, (A_500 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_750 >= - 10 && A_750 <= 120){
					jg.drawLine(ubicX + tamano * 2, (A_500 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 3, (A_750 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_500 >= - 120 && A_500 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 2, (Math.abs(A_500) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}
				
		// Umbral A_750

			if(A_750 >= - 10 && A_750 <= 120){
				if (A_E_750 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_750*1, (ubicX-5) + tamano*3, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 3, (A_750 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_1000 >= - 10 && A_1000 <= 120){
					jg.drawLine(ubicX + tamano * 3, (A_750 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 4, (A_1000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_750 >= - 120 && A_750 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 3, (Math.abs(A_750) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_1000

			if(A_1000 >= - 10 && A_1000 <= 120){
				if (A_E_1000 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_1000*1, (ubicX-5) + tamano*4, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 4, (A_1000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_1500 >= - 10 && A_1500 <= 120){
					jg.drawLine(ubicX + tamano * 4, (A_1000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 5, (A_1500 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_1000 >= - 120 && A_1000 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 4, (Math.abs(A_1000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_1500

			if(A_1500 >= - 10 && A_1500 <= 120){
				if (A_E_1500 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_1500*1, (ubicX-5) + tamano*5, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 5, (A_1500 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_2000 >= - 10 && A_2000 <= 120){
					jg.drawLine(ubicX + tamano * 5, (A_1500 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 6, (A_2000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_1500 >= - 120 && A_1500 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 5, (Math.abs(A_1500) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_2000

			if(A_2000 >= - 10 && A_2000 <= 120){
				if (A_E_2000 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_2000*1, (ubicX-5) + tamano*6, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 6, (A_2000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_3000 >= - 10 && A_3000 <= 120){
					jg.drawLine(ubicX + tamano * 6, (A_2000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 7, (A_3000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_2000 >= - 120 && A_2000 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 6, (Math.abs(A_2000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_3000

			if(A_3000 >= - 10 && A_3000 <= 120){
				if (A_E_3000 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_3000*1, (ubicX-5) + tamano*7, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 7, (A_3000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_4000 >= - 10 && A_4000 <= 120){
					jg.drawLine(ubicX + tamano * 7, (A_3000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 8, (A_4000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_3000 >= - 120 && A_3000 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 7,  (Math.abs(A_3000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_4000

			if(A_4000 >= - 10 && A_4000 <= 120){
				if (A_E_4000 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_4000*1, (ubicX-5) + tamano*8, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 8, (A_4000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_6000 >= - 10 && A_6000 <= 120){
					jg.drawLine(ubicX + tamano * 8, (A_4000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 9, (A_6000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_4000 >= - 120 && A_4000 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 8,  (Math.abs(A_4000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_6000

			if(A_6000 >= - 10 && A_6000 <= 120){
				if (A_E_6000 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_6000*1, (ubicX-5) + tamano*9, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 9, (A_6000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_8000 >= - 10 && A_8000 <= 120){
					jg.drawLine(ubicX + tamano * 9, (A_6000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 10, (A_8000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_6000 >= - 120 && A_6000 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 9, (Math.abs(A_6000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_8000

			if(A_8000 >= - 10 && A_8000 <= 120){
				if (A_E_8000 >= -10){nom_ico = nom_ico_e; jg.drawString(A_E_8000*1, (ubicX-5) + tamano*10, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado
				jg.drawImage(nom_ico, (ubicX - 5) + tamano * 10, (A_8000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				}

			if(A_8000 >= - 120 && A_8000 < - 10){
				jg.drawImage(nom_ico_f, (ubicX -5) + tamano * 10,  (Math.abs(A_8000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

			
			

 	cont = 491; 
	cord = 30;
	
 }	
 	jg.setFont("arial", "14px", Font.PLAIN);		
	jg.drawString("<== E. A", (ubicX-5) + tamano*8.5, (ubicY + tamano*filas)+5);
	jg.drawString("<== E. O", (ubicX-5) + tamano*8.5, (ubicY + tamano*filas)+30);
	
	jg.setStroke(1);									
	jg.paint();	
}



function dibaudioi(aud)
{
		// Call jsGraphics() with no parameters if drawing within the entire document 
	
	//if (lado ==  "d") {objeto = "ODerecho";}
	//if (lado ==  "i") {objeto = "OIzquierdo";}	
		
	//	var jgi = new jsGraphics(objeto);    // Use the "Canvas" div for drawing 
		
	//alert (aud)
	
		
		filas = 13;
		columnas = 10;
		tamano = 30;
		ubicX = 60;
		ubicY = 40;

//		filas = 12;
//		columnas = 10;
//		tamano = tamano_t;
//		ubicX = ubicX_t;
//		ubicY = ubicY_t;	

		jgi.setFont("arial", "14px", Font.PLAIN);
		jgi.setColor("blue");
	//	jgi.drawString("Oido Derecho", ubicX, ubicY-40);
	//	jgi.drawString("Oido Izquierdo", ubicX + (tamano*columnas + 30), ubicY-40);

//alert("BIEN...")		
		//jgi.drawString("125  250 500 750 1000  1500  2000 3000 4000 6000 8000 ", ubicX, ubicY-20);
		// DIBUJA CUADRICULA
		jgi.setFont("arial", "10px", Font.PLAIN);
		

		for (var i=0; i < 1; i++){
			
			ubicX = ubicX + (tamano*columnas + 40) * i
			
			// DIBUJA texto Hz
			jgi.setColor("black");
			jgi.drawString("125", ubicX-10 + (tamano*0), ubicY-20);
			jgi.drawString("250", ubicX-10 + (tamano*1), ubicY-20);
			jgi.drawString("500", ubicX-10 + (tamano*2), ubicY-20);
			jgi.drawString("750", ubicX-10 + (tamano*3), ubicY-20);
			jgi.drawString("1K", ubicX-10 + (tamano*4), ubicY-20);
			jgi.drawString("1.5K", ubicX-10 + (tamano*5), ubicY-20);
			jgi.drawString("2K", ubicX-10 + (tamano*6), ubicY-20);
			jgi.drawString("3K", ubicX-10 + (tamano*7), ubicY-20);
			jgi.drawString("4K", ubicX-10 + (tamano*8), ubicY-20);
			jgi.drawString("6K", ubicX-10 + (tamano*9), ubicY-20);
			jgi.drawString("8K", ubicX-10 + (tamano*10), ubicY-20);
			
			
			jgi.setColor("5f5f5f");
			// DIBUJA COLUMNAS
			for (var j=0; j <= columnas; j++){
				jgi.drawLine(tamano*j + ubicX, ubicY ,tamano*j + ubicX, ubicY + tamano*filas);
				//jgi.drawRect(tamano*j + ubicX, ubicY,tamano,tamano*filas );
				
		     }
			
			// DIBUJA FILAS 		
				for (var j=0; j <= filas; j++){
				jgi.drawLine(ubicX, tamano*j + ubicY, ubicX + tamano*columnas , tamano*j + ubicY );
				//jgi.drawRect(ubicX, tamano*j + ubicY,tamano*columnas,tamano );
		     }		
		}
		
		// DIBUJA texto Db
			jgi.setColor("black");
			
			jgi.drawString("-10", ubicX -25 , ubicY -5 );
			for (var j=0; j < filas; j++){
				jgi.drawString(10 * j ,ubicX -25 , ubicY -5  + (tamano*j) + tamano );
				}
			
			//jgi.drawString("-10", ubicX  + (tamano*columnas + 15) , ubicY -5 );

			//for (var j=0; j < filas; j++){
			//	jgi.drawString(10 * j ,ubicX  + (tamano*columnas + 15) , ubicY -5  + (tamano*j) + tamano );
			//	}
								
	//	ubicX = ubicX - (tamano*columnas + 40)



// AUDIOMETRIA AEREA - OIDO DERECHO

jgi.setFont("arial", "14px", Font.BOLD);		
var cont = 249;
var cord = 5;

//if (taud == "a" ){cont = 7; cord = 5;}
//if (taud == "o" ){cont = 491; cord = 30;}

for (var i=0; i < 2; i++){		

			
	nom_ico = "";
	nom_ico_n = "";
	nom_ico_e = "";
	nom_ico_f = "";
	
	tipo = aud.substring(cont - 7, cont - 4);
	
	A_125 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_125 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_250 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_250 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_500 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_500 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_750 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_750 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_1000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_1000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_1500 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_1500 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_2000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_2000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_3000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_3000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_4000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_4000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_6000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_6000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_8000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	A_E_8000 = real(aud.substring(cont, cont + 4)) ;
	cont = cont  + 11 ;
	
	
	

   		  //VIA AREA DERECHA		
			if(tipo == "aad"){
				//ubicX = ubicX - (tamano*columnas + 40)
				jgi.setStroke(1);
				jgi.setColor("e51b1b");
				nom_ico_n = "vad.gif";
				nom_ico_e = "vade.gif";
				nom_ico_f = "vadf.gif";
			}

		  //VIA AREA IZQUIERDA
			if(tipo == "aai"){
				jgi.setStroke(1);
				//ubicX = ubicX + (tamano*columnas + 40)
				jgi.setColor("095aef");				
				nom_ico_n = "vai.gif";
				nom_ico_e = "vaie.gif";
				nom_ico_f = "vaif.gif";	
			
			}

		  //VIA OSEA DERECHA
			if(tipo == "aod"){
				//ubicX = ubicX - (tamano*columnas + 40)
				jgi.setColor("e51b1b");
				jgi.setStroke(Stroke.DOTTED);			
				nom_ico_n = "vod.gif";
				nom_ico_e = "vode.gif";
				nom_ico_f = "vodf.gif";
						
			}
		  
		  //VIA OSEA IZQUIERDA			
			if(tipo == "aoi"){
				jgi.setStroke(Stroke.DOTTED);
				//ubicX = ubicX + (tamano*columnas + 40)
				jgi.setColor("095aef");				
				nom_ico_n = "voi.gif";
				nom_ico_e = "voie.gif";
				nom_ico_f = "voif.gif";
			}

			
	 	// Umbral A_125
			if(A_125 >= - 10 && A_125 <= 120){
				
				if (A_E_125 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_125*1, (ubicX-5) + tamano*0, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n; } // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 0, (A_125 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12); // Simbolo
				
				if(A_250 >= - 10 && A_250 <= 120){
					jgi.drawLine(ubicX, (A_125 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano, (A_250 * tamano/10) + (ubicY + 10* tamano/10) );// Lineas
					}
				}
			if(A_125 >= - 120 && A_125 < -10){
				jgi.drawImage(nom_ico_f, (ubicX - 5) + tamano * 0, (Math.abs(A_125) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20); // Simbolo no existe
				}


		// Umbral A_250
			
			if(A_250 >= - 10 && A_250 <= 120){
				if (A_E_250 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_250*1, (ubicX-5) + tamano*1, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 1, (A_250 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_500 >= - 10 && A_500 <= 120){
					jgi.drawLine(ubicX + tamano * 1, (A_250 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 2, (A_500 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_250 >= - 120 && A_250 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 1,  (Math.abs(A_250) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}
				
		// Umbral A_500

			if(A_500 >= - 10 && A_500 <= 120){
				if (A_E_500 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_500*1, (ubicX-5) + tamano*2, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 2, (A_500 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_750 >= - 10 && A_750 <= 120){
					jgi.drawLine(ubicX + tamano * 2, (A_500 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 3, (A_750 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_500 >= - 120 && A_500 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 2, (Math.abs(A_500) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}
				
		// Umbral A_750

			if(A_750 >= - 10 && A_750 <= 120){
				if (A_E_750 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_750*1, (ubicX-5) + tamano*3, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 3, (A_750 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_1000 >= - 10 && A_1000 <= 120){
					jgi.drawLine(ubicX + tamano * 3, (A_750 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 4, (A_1000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_750 >= - 120 && A_750 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 3, (Math.abs(A_750) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_1000

			if(A_1000 >= - 10 && A_1000 <= 120){
				if (A_E_1000 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_1000*1, (ubicX-5) + tamano*4, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 4, (A_1000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_1500 >= - 10 && A_1500 <= 120){
					jgi.drawLine(ubicX + tamano * 4, (A_1000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 5, (A_1500 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_1000 >= - 120 && A_1000 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 4, (Math.abs(A_1000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_1500

			if(A_1500 >= - 10 && A_1500 <= 120){
				if (A_E_1500 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_1500*1, (ubicX-5) + tamano*5, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 5, (A_1500 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_2000 >= - 10 && A_2000 <= 120){
					jgi.drawLine(ubicX + tamano * 5, (A_1500 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 6, (A_2000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_1500 >= - 120 && A_1500 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 5, (Math.abs(A_1500) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_2000

			if(A_2000 >= - 10 && A_2000 <= 120){
				if (A_E_2000 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_2000*1, (ubicX-5) + tamano*6, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 6, (A_2000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_3000 >= - 10 && A_3000 <= 120){
					jgi.drawLine(ubicX + tamano * 6, (A_2000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 7, (A_3000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_2000 >= - 120 && A_2000 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 6, (Math.abs(A_2000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_3000

			if(A_3000 >= - 10 && A_3000 <= 120){
				if (A_E_3000 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_3000*1, (ubicX-5) + tamano*7, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 7, (A_3000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_4000 >= - 10 && A_4000 <= 120){
					jgi.drawLine(ubicX + tamano * 7, (A_3000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 8, (A_4000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_3000 >= - 120 && A_3000 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 7,  (Math.abs(A_3000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_4000

			if(A_4000 >= - 10 && A_4000 <= 120){
				if (A_E_4000 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_4000*1, (ubicX-5) + tamano*8, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 8, (A_4000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_6000 >= - 10 && A_6000 <= 120){
					jgi.drawLine(ubicX + tamano * 8, (A_4000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 9, (A_6000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_4000 >= - 120 && A_4000 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 8,  (Math.abs(A_4000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_6000

			if(A_6000 >= - 10 && A_6000 <= 120){
				if (A_E_6000 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_6000*1, (ubicX-5) + tamano*9, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado

				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 9, (A_6000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				if(A_8000 >= - 10 && A_8000 <= 120){
					jgi.drawLine(ubicX + tamano * 9, (A_6000 * tamano/10) + (ubicY + 10 * tamano/10) , ubicX + tamano * 10, (A_8000 * tamano/10) + (ubicY + 10* tamano/10) );
					}
				}
			if(A_6000 >= - 120 && A_6000 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 9, (Math.abs(A_6000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

		// Umbral A_8000

			if(A_8000 >= - 10 && A_8000 <= 120){
				if (A_E_8000 >= -10){nom_ico = nom_ico_e; jgi.drawString(A_E_8000*1, (ubicX-5) + tamano*10, (ubicY + tamano*filas)+cord);} else {nom_ico = nom_ico_n} // Simbolo Enmascarado
				jgi.drawImage(nom_ico, (ubicX - 5) + tamano * 10, (A_8000 * tamano/10) + (ubicY + 10 * tamano/10) -5 , 12, 12);
				}

			if(A_8000 >= - 120 && A_8000 < - 10){
				jgi.drawImage(nom_ico_f, (ubicX -5) + tamano * 10,  (Math.abs(A_8000) * tamano/10) + (ubicY + 10 * tamano/10) - 5 , 20, 20);
				}

			
			

 	cont = 733; 
	cord = 30;
	
 }	
 	jgi.setFont("arial", "14px", Font.PLAIN);	
	jgi.drawString("<== E. A", (ubicX-5) + tamano*8.5, (ubicY + tamano*filas)+5);
	jgi.drawString("<== E. O", (ubicX-5) + tamano*8.5, (ubicY + tamano*filas)+30);	
	
	jgi.setStroke(1);									
	jgi.paint();	
}