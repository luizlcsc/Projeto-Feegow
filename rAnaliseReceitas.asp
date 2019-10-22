<!--#include file="connect.asp"-->

<%

DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")

%>
<h3 class="text-center">Análise de Receitas</h3>
<h4 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h4>

<%
splU = split(req("Unidades"), ", ")
for i=0 to ubound(splU)
		if splU(i)="0" then
			set un = db.execute("select NomeEmpresa Nome from empresa")
		else
			set un = db.execute("select UnitName Nome from sys_financialcompanyunits where id="&splU(i))
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
        	<th width="60%" class="text-center">CATEGORIA</th>
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
		
'		sql = "SELECT m.id, m.InvoiceID, m.Value, m.`Date`, m.CD, cat.Name, i.CompanyUnitID, ii.Tipo, ii.Quantidade, ii.CategoriaID FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i on i.id=m.InvoiceID LEFT JOIN itensinvoice ii on ii.InvoiceID=i.id LEFT JOIN sys_financialexpensetype cat on cat.id=ii.CategoriaID WHERE Type='Bill' AND m.CD='C' AND i.sysActive=1 AND m.Value>0 AND m.Date BETWEEN "&mydatenull(DataDe)&" AND "&mydatenull(DataAte)&" and i.CompanyUnitID="&splU(i)&" ORDER BY cat.Name"
		sql = "SELECT m.id, m.InvoiceID, m.Value, m.`Date`, m.CD, i.CompanyUnitID, ii.Tipo, ii.Quantidade, ii.CategoriaID, case ii.Tipo	when 'S' then proc.NomeProcedimento when 'O' then cat.Name else '' end Name FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i on i.id=m.InvoiceID LEFT JOIN itensinvoice ii on ii.InvoiceID=i.id LEFT JOIN sys_financialincometype cat on cat.id=ii.CategoriaID LEFT JOIN procedimentos proc on proc.id=ii.ItemID where Type='Bill' AND m.CD='C' AND i.sysActive=1 AND m.Value>0 AND m.Date BETWEEN "&mydatenull(DataDe)&" AND "&mydatenull(DataAte)&" and i.CompanyUnitID="&splU(i)&" order by Name"
		set G = db.execute(sql)
		while not G.eof

			Conta = Conta+1
			ValorTotal = ValorTotal+G("Value")



			if UltimaCategoria<>"" and UltimaCategoria<>G("Name") then
				strCatsValorDist = strCatsValorDist&"|^"&Valor
			end if
			
			if 1=2 then
			%>
			<tr class="danger">
				<td><%=g("Name")%></td>
				<td class="text-right">R$ <%=formatnumber(g("Value"), 2)%></td>
				<td class="text-right" id="cat<%=G("Name")%>"></td>
			</tr>
			<%
			end if
			
			if UltimaCategoria<>G("Name") then
				strCatsIDDist = strCatsIDDist&"|^"&g("Name")
				strCatsNomeDist = strCatsNomeDist&"|^"&g("Name")
			end if
			if UltimaCategoria="" or UltimaCategoria=G("Name") then
				Valor = Valor+g("Value")
			end if
			if UltimaCategoria<>"" and UltimaCategoria<>G("Name") then
				Valor = g("Value")
			end if

			
			UltimaCategoria = G("Name")
			response.Buffer
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
			%>
			<tr>
				<td><%=splNome(j)%></td>
				<td class="text-right">R$ <%=formatnumber(splValor(j), 2)%></td>
				<td class="text-right"><%=formatnumber(Percentual, 2)%>%</td>
			</tr>
			<%
			end if
		next
		%>
		<tr>
        	<th><%=cats%> categoria<%if cats>1 then response.Write("s") end if%></td>
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
