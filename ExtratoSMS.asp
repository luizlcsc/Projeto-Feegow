<!--#include file="connectCentral.asp"-->
<!--#include file="connect.asp"-->
<form method="get" action="">
    <input type="hidden" name="P" value="<%=req("P")%>">
    <input type="hidden" name="Pers" value="<%=req("Pers")%>">
    <div class="clearfix form-actions">
        <%=quickField("datepicker", "De", "De", 2, req("De"), "", "", "")%>
        <%=quickField("datepicker", "Ate", "Ate", 2, req("Ate"), "", "", "")%>
		<%=quickField("text", "Cupom", "Cupom", 2, req("Cupom"), "", "", "")%>
		<%=quickField("text", "ValorSMS", "Valor SMS", 2, fn(req("ValorSMS")), " input-mask-brl text-right", "", "")%>
        <div class="col-md-2">
        	<label>&nbsp;</label><br>
        	<button class="btn btn-primary btn-sm"><i class="far fa-search"></i> Buscar</button>
        </div>
    </div>

<table class="table table-striped table-bordered">
<thead>
	<tr>
    	<th>Licenca</th>
    	<th>Parceiro</th>
    	<th>Cliente</th>
     	<th>Quantidade</th>
    	<th>Valor</th>
   </tr>
</thead>
<tbody>
<%
if req("De")<>"" and req("Ate")<>"" then
'livenote

	set multi = dbc.execute("select Email, Licencas from licencasusuariosmulti where Email='epaco@livenote.com.br'")
	mlics = multi("Licencas")

	cl=0
	tot = 0
	query = "select distinct sms.LicencaID, lic.Cupom, lic.NomeContato from smshistorico sms LEFT JOIN licencas lic ON lic.id = sms.LicencaID WHERE date(sms.DataHora)>="&mydatenull(req("De"))&" AND date(sms.DataHora)<="&mydatenull(req("Ate"))
	If req("Cupom") <> "" Then
		query = query & " and lic.Cupom = '" &req("Cupom")&"'"
	End if
	
	set lic = dbc.execute(query)
    ValorSMS = 0.12


	if req("ValorSMS")&""<>"" AND req("ValorSMS")<>"0,00" then
		ValorSMS  = req("ValorSMS")
	end if

	while not lic.eof
		NomeCliente = ""
		sql = "select count(id) as total from smshistorico WHERE LicencaID="&lic("LicencaID")&" AND date(DataHora)>="&mydatenull(req("De"))&" AND date(DataHora)<="&mydatenull(req("Ate"))

		set conta = dbc.execute(sql) 
		cl = cl+1
		total = ccur(conta("total"))
		tot = total+tot
		valor = eval(total * ValorSMS)

		%>
		<tr>
			<td><%=lic("LicencaID")%></td>
			<td><%=lic("Cupom")%></td>
			<td><%=lic("NomeContato")%></td>
			<td class="text-right"><%=total%></td>
			<td class="text-right"><%=formatnumber(valor,2)%></td>
		</tr>
		<%
	lic.movenext
	wend
	lic.close
	set lic=nothing
	%>
    </tbody>
    <tfoot>
    	<tr>
        	<td colspan="3"><%=cl%> clientes enviaram SMS no período.</td>
            <td class="text-right"><%=tot%></td>
            <td class="text-right"><%=formatnumber(eval(tot * ValorSMS), 2)%></td>
    </tfoot>
	<%

end if
%>
</table>