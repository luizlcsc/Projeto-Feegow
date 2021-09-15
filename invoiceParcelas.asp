<!--#include file="connect.asp"-->
<%
InvoiceID = req("I")
CD = req("T")
Parcela = ref("Parcela")
%>
<table width="100%" class="table table-striped table-condensed">
	<thead>
    	<tr class="info">
            <th width="1%"><button type="button" class="btn btn-xs" style="visibility:hidden"><i class="far fa-chevron-down"></i></button></th>
        	<th width="18%">Vencimento</th>
        	<th width="18%">Obs.</th>
        	<th width="18%">Valor</th>
            <th width="18%">Valor Pago</th>
        	<th width="10%">Pend&ecirc;ncias</th>
        </tr>
    </thead>
    <tbody>
	<%

	StatusEmissaoBoleto = recursoAdicional(8)

	if (ref("NumeroParcelas")="" or req("Recalc")="N") and req("PlanoPagto")="" then
        TotalPago = 0
		set parcelas=db.execute("select * from sys_financialmovement where Type='Bill' AND InvoiceID="&InvoiceID&" order by Date")

		set NumeroParcelasSQL = db.execute("select count(id)NumeroParcelas from sys_financialmovement where Type='Bill' AND InvoiceID="&InvoiceID)
		NumeroParcelas = NumeroParcelasSQL("NumeroParcelas")

		while not parcelas.eof
			conta = conta+1
			ValorPago = parcelas("ValorPago")
			ParcelaID = parcelas("id")
			ParcelaValor = parcelas("Value")
			ParcelaData = parcelas("Date")
			Name = parcelas("Name")
            PacelaCD = parcelas("CD")
            ParcelaCaixaID = parcelas("CaixaID")
            TotalPago = TotalPago + ValorPago

			If IsNull(ParcelaValor) Then
				ParcelaValor = 0
			End if
			%>
			<!--#include file="invoiceLinhaParcela.asp"-->
			<%
		parcelas.movenext
		wend
		parcelas.close
		set parcelas=nothing
    elseif req("PlanoPagto")<>"" then
        ParcelaData = date()
        set pp = db.execute("select * from planopagtoparcelas where PlanoPagtoID="&req("PlanoPagto")&" order by Parcela")
        c = 0
        while not pp.eof
            c = c-1
            ValorInvoice = replace(pp("Formula"), "Total", ccur(ref("Valor")))
            ValorInvoice = eval(ValorInvoice)
			conta = conta+1
			ValorPago = 0
			ParcelaID = c
			ParcelaValor = ValorInvoice'!
			ParcelaData = dateadd(pp("TipoIntervalo"), pp("Intervalo"), ParcelaData)
			Name = pp("Name")
            PacelaCD = "C"
            ParcelaCaixaID = ""
            TotalPago = 0
			%>
			<!--#include file="invoiceLinhaParcela.asp"-->
			<%
        pp.movenext
        wend
        pp.close
        set pp=nothing
        %>
        <script type="text/javascript">
            $("#NumeroParcelas").val("<%=c*(-1)%>");
        </script>
        <%
	else
		tagPagto = "<button class=""btn btn-block btn-xs btn-danger"" type=""button"" onclick=""pagamento(0);""><i class=""far fa-check""></i> Lan&ccedil;ar Pagamento</button>"
		NumeroParcelas = ref("NumeroParcelas")
		if not isnumeric(NumeroParcelas) then
			NumeroParcelas=1
		else
			NumeroParcelas=ccur(NumeroParcelas)
		end if
		c = 0
		Recurrence = ref("Recurrence")
		RecurrenceType = ref("RecurrenceType")
		if Recurrence="" then
			Recurrence=1
		end if
		if RecurrenceType="" then
			RecurrenceType="m"
		end if

		ParcelaData = date()
		while c<NumeroParcelas
			c=c+1
			ParcelaID = c*(-1)
			ParcelaValor = 0
			%>
			<!--#include file="invoiceLinhaParcela.asp"-->
			<%
			ParcelaData = dateAdd(RecurrenceType, Recurrence, ParcelaData)
		wend
		%>
		<script>
<%
if req("recalc")<>"N" then
%>
$(document).ready(function(e) {
		recalc();
});
<%
end if
%>
		</script>
		<%
	end if
	%>
    </tbody>
</table>



<script>


$(".parcela").click(function() {
    if( $(this).val().indexOf("-")>0 ){
        $("#PendPagar").val( $(this).val() );
        $("#btnSave").click();
    }else{
        pagar();
    }
});

$(document).ready(function(e) {
<%

if Parcela<>"" then
	set newID = db.execute("select group_concat(id) refPagto from sys_financialmovement where InvoiceID="&InvoiceID&" and Rate in("&replace(Parcela, "|", "")&")")
	refPagto = newID("refPagto")
	if isnull(refPagto) then
		refPagto = Parcela
	end if
	splRefPagto = split(refPagto, ",")
	for i=0 to ubound(splRefPagto)
		%>
    	$('#Parcela<%=splRefPagto(i) %>').click();
        pagar();
		<%
	next
	%>
	<%
end if
%>

    <%if TotalPago>0 then %>
    disable(true);
    <%else %>
    disable(false);

    <%end if %>
});


$(".liPar").on("mouseover", function(){
    $("#propParc"+ $(this).attr("data-par") ).removeClass("hidden");
});
$(".liPar").on("mouseout", function(){
    $("#propParc"+ $(this).attr("data-par") ).addClass("hidden");
});

function propParc(ParcelaID){
    $.post("propParc.asp?ParcelaID="+ParcelaID, $("#formItens").serialize(), function(data){ eval(data) });
}

<!--#include file="jQueryFunctions.asp"-->
</script>

<!--#include file="disconnect.asp"-->