<!--#include file="connect.asp"-->

<%

DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")

%>
<h3 class="text-center">Débitos Pendentes</h3>
<h4 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h4>

<%
totalGeral = 0

splU = split(req("Unidades"), ", ")
for i=0 to ubound(splU)
		if splU(i)="0" then
			set un = db.execute("select NomeFantasia Nome from empresa")
		else
			set un = db.execute("select NomeFantasia Nome from sys_financialcompanyunits where id="&splU(i))
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
        	<th width="60%" class="text-center">CREDOR</th>
            <th width="20%" class="text-center">VALOR</th>
            <th width="20%" class="text-center">PERCENTUAL</th>
        </tr>
	</thead>
    <tbody>
        <%
		Conta=0
		UltimaCategoria = ""
		strCatsNomeDist = ""
		strCatsIDDist = ""
		strCatsValorDist = ""
		Valor = 0
		ValorTotal = 0
		
		sql = "select m.AccountAssociationIDCredit, m.AccountIDCredit, m.Value, m.ValorPago from sys_financialmovement m LEFT JOIN sys_financialinvoices i on i.id=m.InvoiceID where m.Type='Bill' and m.ValorPago<m.Value and m.Value>0 and m.CD='D' AND m.Date BETWEEN "&mydatenull(DataDe)&" AND "&mydatenull(DataAte)&" and i.CompanyUnitID="&splU(i)&" order by m.AccountAssociationIDCredit, m.AccountIDCredit"
		set G = db.execute(sql)
		while not G.eof

			Conta = Conta+1
			ContaID = G("AccountAssociationIDCredit")&"_"&G("AccountIDCredit")


			if UltimaCategoria<>"" and UltimaCategoria<>ContaID then
				strCatsValorDist = strCatsValorDist&"|^"&Valor
			end if
			
			if 1=2 then
			%>
			<tr class="danger">
				<td><%=ContaID%></td>
				<td class="text-right">R$ <%=g("Value")&" - "&g("ValorPago")%></td>
				<td class="text-right"></td>
			</tr>
			<%
			end if
			
			if UltimaCategoria<>ContaID then
				strCatsIDDist = strCatsIDDist&"|^"&ContaID
				strCatsNomeDist = strCatsNomeDist&"|^"&ContaID
			end if
			if UltimaCategoria="" or UltimaCategoria=ContaID then
				Valor = Valor + (g("Value")-g("ValorPago"))
			end if
			if UltimaCategoria<>"" and UltimaCategoria<>ContaID then
				Valor = g("Value")-g("ValorPago")
			end if

			
			UltimaCategoria = ContaID
			ValorTotal = ValorTotal + Valor
		G.movenext
		wend
		G.close
		set G=nothing
		strCatsValorDist = strCatsValorDist&"|^"&Valor


		splID = split(strCatsIDDist, "|^")
		splNome = split(strCatsNomeDist, "|^")
		splValor = split(strCatsValorDist, "|^")
		
		if ValorTotal>0 then
			coef = 100/ValorTotal
		end if
		
		cats = 0
		for j=0 to ubound(splID)
			if splValor(j)<>"" and isnumeric(splValor(j)) then
				Percentual = coef*ccur(splValor(j))
				cats = cats+1
				splConta = split(splNome(j), "_")
				Nome = accountName(splConta(0), splConta(1))
				if Nome="" then
					Nome = "---"
				end if
			%>
			<tr>
				<td><%=Nome%></td>
				<td class="text-right">R$ <%=formatnumber(splValor(j), 2)%></td>
				<td class="text-right"><%=formatnumber(Percentual, 2)%>%</td>
			</tr>
			<%
			end if
		next
		
		totalGeral = totalGeral+ValorTotal
		%>
		<tr>
        	<th><%=cats%> credor<%if cats>1 then response.Write("es") end if%></td>
        	<th class="text-right">R$ <%=formatnumber(ValorTotal, 2)%></th>
            <th class="text-right">100,00%</th>
        </tr>
    </tbody>
</table>

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
<h4 class="text-right">Total geral: R$ <%=formatnumber(totalGeral, 2)%></h4>
