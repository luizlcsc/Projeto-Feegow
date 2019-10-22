<!--#include file="connect.asp"-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
	<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
	<LINK REL="stylesheet" TYPE="text/css" HREF="estilo1.css">

	<title>Audiometria Online</title>
	
<script type="text/javascript" src="assets/js/jquery.min.js"></script>
<script type="text/javascript" src="wz_jsgraphics.js"></script>
<script type="text/javascript" src="audiometria.js"> </script>

<style>
input {
	width:29px;
}
.grade{
	background-color:#000!important;
}
</style>

<style media="print">
input {
	width:29px;
}
.grade{
	background-color:#000!important;
	border:1px solid #000!important;
}
</style>

<style>
@media print{
	.al{border:1px solid #000 !important;
	min-height:1px !important;}
	.bg{    background:url(audiometria/base.jpg) 60px 40px no-repeat !important;
    -webkit-print-color-adjust: exact;}
		.bg2{    background:url(audiometria/base.jpg) 60px 40px no-repeat !important;
    -webkit-print-color-adjust: exact;}
	
	}
</style>

	
</head>

<body>
<%
campo = request.QueryString("field")
ModeloID = request.QueryString("ModeloID")
PacienteID = request.QueryString("PacienteID")
set modelo = db.execute("select * from buiforms where id="&ModeloID)
if not modelo.EOF then
	if modelo("Tipo")=4 or modelo("Tipo")=3 then
		FTipo = "L"
	else
		FTipo = "AE"
	end if
end if
FormID = session("FP"&FTipo)'request.QueryString("FormID")

tipo_audio = ref("tipo_audio")
if tipo_audio="" or tipo_audio="a" then
	tipo_audio="a"
else
	tipo_audio="o"
end if

viazeradaA = "aad0125-999ead0125-999aad0250-999ead0250-999aad0500-999ead0500-999aad0750-999ead0750-999aad1000-999ead1000-999aad1500-999ead1500-999aad2000-999ead2000-999aad3000-999ead3000-999aad4000-999ead4000-999aad6000-999ead6000-999aad8000-999ead8000-999aai0125-999eai0125-999aai0250-999eai0250-999aai0500-999eai0500-999aai0750-999eai0750-999aai1000-999eai1000-999aai1500-999eai1500-999aai2000-999eai2000-999aai3000-999eai3000-999aai4000-999eai4000-999aai6000-999eai6000-999aai8000-999eai8000-999"
viazeradaO = "aod0125-999eod0125-999aod0250-999eod0250-999aod0500-999eod0500-999aod0750-999eod0750-999aod1000-999eod1000-999aod1500-999eod1500-999aod2000-999eod2000-999aod3000-999eod3000-999aod4000-999eod4000-999aod6000-999eod6000-999aod8000-999eod8000-999aoi0125-999eoi0125-999aoi0250-999eoi0250-999aoi0500-999eoi0500-999aoi0750-999eoi0750-999aoi1000-999eoi1000-999aoi1500-999eoi1500-999aoi2000-999eoi2000-999aoi3000-999eoi3000-999aoi4000-999eoi4000-999aoi6000-999eoi6000-999aoi8000-999eoi8000-999"

if FormID="N" or FormID="" then
	valor = viazeradaA&viazeradaO
else
'	response.Write("select * from `_"&ModeloID&"` where id="&FormID)
	set pValor = db.execute("select * from `_"&ModeloID&"` where id="&FormID)
	if not pValor.EOF then
'		if tipo_audio = "a" then
'			valor = left(pValor(""&campo&""), 484)&viazeradaO
'		else
'			valor = viazeradaA&right(pValor(""&campo&""), 484)
'		end if
		valor = pValor(""&campo&"")
	end if
end if

'response.Write(tipo_audio&": "&valor)
function converteVal(campo)
	if tipo_audio = "a" then
		valores = left(valor, 484)
	else
		valores = right(valor, 484)
	end if
	converteVal = mid(valores, campo*11-3, 4)
	if isnumeric(converteVal) then
		if converteVal = "-999" then
			converteVal = ""
		else
			converteVal = cint(converteVal)
		end if
	else
		if instr(converteVal, "-") then
			spl = split(converteVal, "-")
			converteVal = "-"&spl(1)
			if isnumeric(converteVal) then
				converteVal = cint(converteVal)
			else
				converteVal = ""
			end if
		else
			converteVal = ""
		end if
	end if
end function
%>
<FORM CLASS="borde" ACTION="" NAME="form" id="audiometria" METHOD="POST">

 
<input type="hidden" name="c_audio" value="<%=valor%>">
<input type="hidden" name="tipo_audioT" value="<%=tipo_audio%>">


<!--
 
<button name="tipo_audioxs" type="submit" value="aad"> OD Aereo  <img src="vad.gif"></button>
<button name="tipo_audioxi" type="submit" value="aod"> OD Oseo  <img src="vod.gif"></button>
<button name="tipo_audiox" type="submit" value="aai"> OI Aereo  <img src="vai.gif"></button>
<button name="tipo_audioxz" type="submit" value="aoi"> OI Oseo  <img src="voi.gif"></button>

-->


<TABLE BORDER=0>
<TR>
	<TD>
		<div style="text-align:right">Selecione a via: </div>  
	</TD>

	<TD>
	</TD>
		
	<TD>
		<!-- Tipo de Audiometria -->
		
		<P>
		
		<SELECT NAME="tipo_audio" onChange="this.form.submit()">
            <OPTION VALUE = "a"<%if tipo_audio="a" then%> selected<%end if%>>Via a&eacute;rea</OPTION> 
            <OPTION VALUE = "o"<%if tipo_audio="o" then%> selected<%end if%>>Via &oacute;ssea</OPTION> 
		</SELECT>
		</P>	

 	</TD>
</TR>


<TR>
	<TH>Ouvido Direito</TH>
	<TH></TH>
	<TH>Ouvido Esquerdo</TH>
</TR>
   
<TR>

  <TH>
  <TABLE BORDER=0>

   <TR>

	<TH>125</TH>
	<TH>250</TH>
	<TH>500</TH>
	<TH>750</TH>
	<TH>1K</TH>
	<TH>1.5K</TH>
	<TH>2K</TH>
	<TH>3K</TH>
	<TH>4K</TH>
	<TH>6K</TH>
	<TH>8K</TH>

   </TR>


  <TR>
 
 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_0125" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"   
			VALUE='<%=converteVal(1)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_0250" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);" 
			VALUE='<%=converteVal(3)%>'>
		
		</INPUT>
    </TD>
 
  	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_0500" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(5)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_0750" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(7)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_1000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(9)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_1500" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(11)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_2000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(13)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_3000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(15)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_4000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(17)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_6000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(19)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ad_8000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(21)%>'>
		
		</INPUT>
    </TD>
    
 </TR>    

 <TR>
	
 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_0125" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"   
			VALUE='<%=converteVal(2)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_0250" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);" 
			VALUE='<%=converteVal(4)%>'>
		
		</INPUT>
    </TD>
 
  	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_0500" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(6)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_0750" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(8)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_1000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(10)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_1500" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(12)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_2000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(14)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_3000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(16)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_4000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(18)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_6000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(20)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ed_8000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(22)%>'>
		
		</INPUT>
    </TD>
  
  </TR>    
  
  </TABLE>

  </TH>


  <TH> - </TH>


  <TH>
  <TABLE BORDER=0>

   <TR>

	<TH>125</TH>
	<TH>250</TH>
	<TH>500</TH>
	<TH>750</TH>
	<TH>1K</TH>
	<TH>1.5K</TH>
	<TH>2K</TH>
	<TH>3K</TH>
	<TH>4K</TH>
	<TH>6K</TH>
	<TH>8K</TH>

   </TR>


  <TR>
 
 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_0125" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"   
			VALUE='<%=converteVal(23)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_0250" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);" 
			VALUE='<%=converteVal(25)%>'>
		
		</INPUT>
    </TD>
 
  	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_0500" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(27)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_0750" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(29)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_1000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(31)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_1500" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(33)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_2000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(35)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_3000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(37)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_4000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(39)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_6000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(41)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ai_8000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(43)%>'>
		
		</INPUT>
    </TD>
    
 </TR>    

 <TR>
	
 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_0125" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"   
			VALUE='<%=converteVal(24)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_0250" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);" 
			VALUE='<%=converteVal(26)%>'>
		
		</INPUT>
    </TD>
 
  	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_0500" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(28)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_0750" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(30)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_1000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(32)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_1500" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(34)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_2000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(36)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_3000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(38)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_4000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(40)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_6000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(42)%>'>
		
		</INPUT>
    </TD>

 	<TD>
		<!-- Codigo -->
		<INPUT TYPE="TEXT" NAME="ei_8000" SIZE="1" MAXLENGTH="4" onkeyUp="return ValNumero(this);"
			VALUE='<%=converteVal(44)%>'>
		
		</INPUT>
    </TD>
  
  </TR>    
  
  </TABLE>

 </TH>
</TR>

	  
<TR>
	<TD class="bg">
		<div id="ODerecho" style="position:relative;height:450px;width:100px;">
	
			<script type="text/javascript">
			<!--
		
		
				var jg = new jsGraphics("ODerecho");    
				var x_audio ="";
				var celda_act = "";
				var valor_act = "";
				var taud = 'a';
				
				
			  	x_audio = '<%=valor%>';
			  	this.dibaudiod(x_audio);
			  	
			//-->
			</script>
	
		</div>
		  	
	</TD>

	<TD>
	
	</TD>
	
	<TD class="bg2">
		<div id="OIzquierdo" style="position:relative;height:450px;width:100px;">
	
			<script type="text/javascript">
			<!--
		
		
				var jgi = new jsGraphics("OIzquierdo");    
			  	this.dibaudioi(x_audio);
		  		
			  	
			  	
			//-->
			</script>
	
		</div>	
	</TD>

</TR>

</TABLE>


 

 

 
</FORM>


	<script type="text/javascript">
	<!--



	    //*** Este Codigo permite Validar que sea un campo Numerico
	    function Solo_Numerico(variable){
	    	//alert (variable.length)
			if (variable.substring(0,1) == "" ) {act_audio();}	
			Numer=parseInt(variable);
  			
	  		if (isNaN(Numer)){
	  				
	  				if (variable.substring(0,1) == "-" && variable.value.length == 1){
	  						return "-";
	  				}
	  				else {
	  					
	            		return "";
	            	}
      		}
      		
      		else if (Numer >= -120 && Numer <= 120){
      			valor_act = Numer;
      			act_audio();
      			return Numer;
			  		
      		}else
      			alert("Valor fora do intervalo permitido.")
      			return "";
      		
	        
	    }
	    
		function ValNumero(Control){
			celda_act = Control.name;
			Control.value=Solo_Numerico(Control.value);
			
	    }
	    //*** Fin del Codigo para Validar que sea un campo Numerico

		function completa(obj) {
			if (obj.length == 0){ obj = '-999';}
			if (obj.length == 1){ obj = '000' + obj;}
			if (obj.length == 2){ obj = '00' + obj;}
			if (obj.length == 3){ obj = '0' + obj;}
			if (obj.length == 4){ obj = obj;}
			return obj;
		}				

		
		
		function act_audio(){
			var cad = "";
			var rem = "";
			var cont = 0;
			var posi = 0;
			
			taud = '<%=tipo_audio%>';
	
			cad = celda_act.substring(0, 1) + taud + celda_act.substring(1, 2) + celda_act.substring(3, 7);
			posi = x_audio.indexOf(cad);
			
			cad = x_audio.substring(posi, posi + 11);
			rem = cad.substring(0, 7) + completa(valor_act.toString());
			x_audio = x_audio.replace(cad, rem);
			
			valor_act = -999;
		  	
	  	    jg.clear();
		  	this.dibaudiod(x_audio);

	  	    jgi.clear();
		  	this.dibaudioi(x_audio);
			  			  	
		 		
		}
		

	//-->
	$("input").change(function(){
		$.ajax({
			type:"POST",
			url:"saveAudiometria.asp?campo=<%=campo%>&ModeloID=<%=ModeloID%>&FormID=<%=FormID%>&PacienteID=<%=PacienteID%>",
			data:$("#audiometria").serialize(),
			success:function(data){
				eval(data);
			}
		});
	});
	</script>



 
</body>
</html>