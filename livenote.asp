<!--#include file="connect.asp"-->

<h1>Data de Fechamento: <%=date()%></h1>
<%
response.Charset="utf-8"
'calcular licenças
'calcular sms
TotalGeral = 0
set lics = db.execute("select lm.Licencas from cliniccentral.licencasusuariosmulti lm where lm.Email='epaco@livenote.com.br'")
Licencas = lics("Licencas")
Licencas = replace(Licencas, "|", "")
c = 0
%>
<table border="1" width="100%">
<thead>
	<tr>
    	<th>Empresa</th>
    	<th>Profissionais</th>
    	<th>Início</th>
    	<th>Quantidade</th>
    	<th>Dias</th>
    	<th>Valor Unit.</th>
    	<th>Total</th>
    </tr>
</thead>
<tbody>
<%
set lic = db.execute("select l.id, l.NomeContato, l.DataHora from cliniccentral.licencas l where l.id in("&Licencas&") and id!=105")
while not lic.eof 
	c=c+1
	%>
    <tr>
		<td><%=lic("NomeContato")%></td>
        <td><%
		set profs = db.execute("select NomeProfissional from clinic"&lic("id")&".profissionais where sysActive=1 and Ativo='on'")
		p = 0
		data = formatdatetime(lic("DataHora"), 2)
		Dias = datediff("d", data, date())
		while not profs.eof
			p=p+1
			%>
			<%=profs("NomeProfissional")%><br>
			<%
		profs.movenext
		wend
		profs.close
		set profs=nothing
		
		Unitario = 25
		
		ValorTotal = p*Dias*(Unitario/30)
		TotalGeral = TotalGeral+ValorTotal
		%></td>
        <td><%=Data%></td>
        <td><%=p%></td>
        <td><%=Dias%></td>
        <td>25</td>
        <td><%=formatnumber(ValorTotal,2)%></td>
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
    	<td colspan="6"></td>
        <td><%=formatnumber(TotalGeral, 2)%></td>
    </tr>
</tfoot>
</table><br>
