<!--#include file="FuncoesAntigas.asp"-->
<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Minhas Faturas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("boletos disponíveis para impressão");
    $(".crumb-icon a span").attr("class", "far fa-barcode");
    $("#rbtns").html('<a href="./?P=ClExtratoSMS&Pers=1" class="btn btn-primary btn-sm pull-right"><i class="far fa-envelope"></i> EXTRATO DE SMS</a>');
</script>

<hr>

<div class="panel">
<div class="panel-body">

<table class="table table-striped table-bordered ">
  <thead>
    <tr class="danger">
        <th>IDENTIFICA&Ccedil;&Atilde;O</th>
        <th>VENCIMENTO</th>
        <th>VALOR</th>
        <th>PAGAMENTO</th>
    </tr>
  </thead>
<%
set baf = dbc.execute("select l.Cliente from cliniccentral.licencas l where l.id="&replace(session("Banco"), "clinic", ""))
if not baf.EOF then
	idBafim = baf("Cliente")

    set ClienteSQL = dbc.execute("SELECT NomePaciente,Endereco,Cidade,Estado,Cep FROM clinic5459.pacientes WHERE id="&idBafim)
	if not ClienteSQL.eof then
        BNome=ClienteSQL("NomePaciente")
        BEndereco=ClienteSQL("Endereco")
        BCidade=ClienteSQL("Cidade")
        BEstado=ClienteSQL("Estado")
        BCep=ClienteSQL("Cep")
	end if
	
	
	set pReceitas=dbc.execute("select * from clinic5459.sys_financialinvoices where CD ='C' AND AccountID = '"&idBafim&"' AND AssociationAccountID=3 order by sysDate desc")
	while not pReceitas.eof
		exibe="N"
		CId = pReceitas("id")
		%>
		<!--#include file="minhasFaturasCalculo.asp"-->
		<%
		VencimentoOriginal=pReceitas("sysDate")
		if cdate(Vencimento)<dateadd("d",4,date()) then
			exibe="S"
		end if
		if msg="QUITADA" or cdate(Vencimento) < cdate("2019-01-01") then
			exibe="N"
		end if
		if exibe="S" then
		    boletoURL = "#"
		    set boleto = dbc.execute("select * from clinic5459.iugu_invoices WHERE BillID ="& MovID&" ORDER BY DataHora DESC Limit 1")
		    if not boleto.eof then
		        boletoURL = boleto("FaturaURL")
		    end if

		    IF boletoURL = "#" THEN
		        'response.write("select * from clinic5459.boletos_emitidos WHERE MovementID ="& MovID&" ORDER BY DataHora DESC Limit 1")
		        set boleto2 = dbc.execute("select * from clinic5459.boletos_emitidos WHERE MovementID ="& MovID&" ORDER BY DataHora DESC Limit 1")
                if not boleto2.eof then
                    boletoURL = boleto2("InvoiceURL")
                end if
		    END IF
		%>
		<tr>
		  <td height="22" style="border-bottom:1px dotted #667"><%=pReceitas("Name")%></td>
			<td align="right" style="border-bottom:1px dotted #667"><%=VencimentoOriginal%></td>
		  <td align="right" style="border-bottom:1px dotted #667"><strong>R$ <%=fn(pReceitas("Value"))%></strong><br />
	<span class="label arrowed arrowed-in arrowed-right-in label-sm label-<%= classe %>"><%=msg%></span>
	</td>
		  <td align="center"><strong>
		  <%
			if cdate(VencimentoOriginal)<date() then
				Vencto=dateAdd("d",1,date())
				Vencto= cdate(day(Vencto)&"/"&month(Vencto)&"/"&year(Vencto))
				VenctoOriginal="Vencimento original em "&VencimentoOriginal&"."
			else
				Vencto=sepDat(VencimentoOriginal)
				VenctoOriginal=""
			end if
		  %>
		  <a class="btn btn-default btn-sm" href="<%=boletoURL%>" target="_blank">
		  <i class="far fa-barcode"></i> IMPRIMIR BOLETO
		  </a>
		  </strong></td>
		</tr>
	<%
		end if
	pReceitas.moveNext
	wend
	pReceitas.close
	set pReceitas=nothing
end if
%>
</table>
</div>
</div>
