<!--#include file="connect.asp"-->

<%

DataDe = req("DataDe")
DataAte = req("DataAte")

%>
<h3 class="text-center">Serviços a Executar</h3>
<h4 class="text-center">Vendido entre <%=DataDe%> e <%=DataAte%></h4>

<%
splU = split(req("UnidadeID"), ", ")
for i=0 to ubound(splU)
    UnidadeID = replace(splU(i), "|", "")
		if UnidadeID="0" then
			set un = db.execute("select NomeFantasia Nome from empresa")
		else
			set un = db.execute("select NomeFantasia Nome from sys_financialcompanyunits where id="& UnidadeID)
		end if
		if un.EOF then
			NomeUnidade = ""
		else
			NomeUnidade = un("Nome")
		end if
	  %>
<h4><%= NomeUnidade %></h4>
<table class="table table-bordered table-hover" width="100%">
	<thead>
        <tr>
            <th width="1%"></th>
        	<th width="40%" class="text-center">PACIENTE</th>
            <th width="40%" class="text-center">PROCEDIMENTO</th>
            <th width="10%" class="text-center">VALOR TOTAL</th>
        </tr>
	</thead>
    <tbody>
        <%
		Conta = 0
        Subtotal = 0
		sql = "SELECT ii.InvoiceID, p.id PacienteID, p.NomePaciente, proc.NomeProcedimento, (ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo)) Valor FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN pacientes p ON p.id=i.AccountID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE i.sysDate BETWEEN "& mydatenull(DataDe) &" AND "& mydatenull(DataAte) &" AND i.CD='C' AND i.CompanyUnitID="& UnidadeID &" AND ii.Tipo='S' AND ii.Executado LIKE ''"
		set G = db.execute(sql)
		while not G.eof
			Conta = Conta+1
			Subtotal = Subtotal+ g("Valor")
			%>
            <tr>
                <td width="1%"><a href="./?P=Invoice&Pers=1&I=<%= G("InvoiceID") %>" target="_blank" class="btn btn-xs btn-primary hidden-print"><i class="far fa-external-link"></i></a> </td>
                <td><a href="./?P=Pacientes&Pers=1&I=<%= G("PacienteID") %>" target="_blank"><%= G("NomePaciente") %></a></td>
                <td><%= G("NomeProcedimento") %></td>
                <td class="text-right"><%= fn(G("Valor")) %></td>
            </tr>
            <%
		G.movenext
		wend
		G.close
		set G=nothing
		strCatsValorDist = strCatsValorDist&"|^"&Valor


		splID = split(strCatsIDDist, "|^")
		splNome = split(strCatsNomeDist, "|^")
		splValor = split(strCatsValorDist, "|^")
		
		cats = 0
		for j=0 to ubound(splID)
			if splValor(j)<>"" and isnumeric(splValor(j)) then
				ValorTotal = ValorTotal + ccur(splValor(j))
				if ValorTotal>0 then
					coef = 100/ValorTotal
				end if
				
				Percentual = coef*ccur(splValor(j))
				cats = cats+1
				splConta = split(splNome(j), "_")
				Nome = accountName(splConta(0), splConta(1))
				if Nome="" then
					Nome = "---"
				end if
			%>
			<tr>
				<td><a target="_blank" href="./?P=Conta&Pers=1&I=<%=replace(splConta(1), "3_", "")%>"><%=Nome%></a></td>
				<td class="text-right">R$ <%=formatnumber(splValor(j), 2)%></td>
				<td class="text-right" id="<%=splU(i) &"_"& splID(j)%>"><%=formatnumber(Percentual, 2)%>%</td>
			</tr>
			<%
			end if
		next
		%>
		<tr>
        	<th colspan="2"><%=conta%> registro<%if conta>1 then response.Write("s") end if%></td>
        	<th class="text-right">R$ <%=fn(Subtotal)%></th>
        </tr>
    </tbody>
</table>
<script>
<%
	splPerc = split(strCatsIDDist, "|^")
	if ValorTotal>0 then
		fator = 100/valorTotal
	else
		fator = 0
	end if
	for k=0 to ubound(splPerc)
		valPerc = splValor(k)
		if valPerc="" then
			ValPerc = 0
		else
			valPerc = ccur(valPerc)
		end if
		valPerc = valPerc*fator
		%>
		$('#<%=splU(i)&"_"&splPerc(k)%>').html('<%=formatnumber(valPerc, 2)%>');
		<%
	next
%>
</script>
<hr style="page-break-after:always; margin:0;padding:0">
<%
	
'	response.Write(strCatsID&"<br>")
'	response.Write(strCatsNome&"<br>")
'	response.Write(strCatsValor&"<br><br>")
	
'	response.Write(strCatsIDDist&"<br>")
'	response.Write(strCatsNomeDist&"<br>")
'	response.Write(strCatsValorDist&"<br><br>")
	
next
%>
