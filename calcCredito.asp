<!--#include file="connect.asp"-->
<%
Credito = ref("Credito")
splCredito = split(Credito, ", ")
valCredito = 0
for i=0 to ubound(splCredito)
	spl2 = split(splCredito(i), "_")
	valCredito = valCredito + ccur( spl2(1) )
next



if Credito="" then
	response.Write( "H&aacute; cr&eacute;ditos dispon&iacute;veis para o pagamento desta conta. Marque acima caso deseje utilizar." )
else
	%>
<div class="row">
    <%=quickField("currency", "valCredito", "Valor a Utilizar", 4, formatnumber(valCredito,2) , "", "", " onkeyup=""apaDistCred();""")%>
    <div class="col-md-4">
    	<label>&nbsp;</label><br />
    	<button type="button" onclick="applyCredit();" class="btn btn-sm btn-success"><i class="far fa-download"></i> Utilizar Cr&eacute;dito</button>
    </div>
</div>
<script>

function apaDistCred(){
	var ValorPagto = $("#valCredito").val().replace(/\./g,'');
	ValorPagto = ValorPagto.replace(',', '.');
	var TotalItens = <%=treatval(req("TotalItens"))%>;
	if(ValorPagto<TotalItens){
		$("#divDist").slideDown();
	}else{
		$("#divDist").slideUp();
	}
		
	Disponivel = parseFloat(ValorPagto);
	$(".descontar").each(function(index, element) {
		Pendente = parseFloat( treatval( $(this).attr('data-descontar') ) );
		if(Disponivel>=Pendente){
			Descontar=Pendente;
			Disponivel = Disponivel-Descontar;
		}else{
			Descontar = Disponivel;
			Disponivel = 0;
		}

		$(this).val( Descontar.toFixed(2).toString().replace('.', ',') );
	});
}

apaDistCred();

<!--#include file="jQueryFunctions.asp"-->
</script>
    <%
end if
%>