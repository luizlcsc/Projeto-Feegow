<!--#include file="connect.asp"-->

<%

DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")

%>
<h3 class="text-center">Créditos Pendentes</h3>
<h4 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h4>

<%
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
<table class="table table-bordered table-hover" width="100%" id="tabela-relatorio">
	<thead>
        <tr>
        	<th width="60%" class="text-center">DEVEDOR</th>
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
		strCatsDataDist = ""
		strCatsValorDist = ""
		Valor = 0
		ValorTotal = 0
		
'		sql = "SELECT m.id, m.InvoiceID, m.Value, i.sysDate as 'Date', m.CD, cat.Name, i.CompanyUnitID, ii.Tipo, ii.Quantidade, ii.CategoriaID FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i on i.id=m.InvoiceID LEFT JOIN itensinvoice ii on ii.InvoiceID=i.id LEFT JOIN sys_financialexpensetype cat on cat.id=ii.CategoriaID WHERE Type='Bill' AND m.CD='C' AND i.sysActive=1 AND m.Value>0 AND m.Date BETWEEN "&mydatenull(DataDe)&" AND "&mydatenull(DataAte)&" and i.CompanyUnitID="&splU(i)&" ORDER BY cat.Name"
		sql = "select m.AccountAssociationIDDebit, m.AccountIDDebit, m.Value, m.ValorPago, m.`Date` from sys_financialmovement m LEFT JOIN sys_financialinvoices i on i.id=m.InvoiceID where m.Type='Bill' and (m.ValorPago<m.Value OR isnull(m.ValorPago)) and m.Value>0 and m.CD='C' AND m.Date BETWEEN "&mydatenull(DataDe)&" AND "&mydatenull(DataAte)&" and i.CompanyUnitID="&splU(i)&" order by m.AccountAssociationIDDebit, m.AccountIDDebit"
		set G = db.execute(sql)
		while not G.eof
			Conta = Conta+1
			ContaID = G("AccountAssociationIDDebit")&"_"&G("AccountIDDebit")
			Data = G("Date")
			ValorPago = g("ValorPago")
			if isnull(ValorPago) then
				ValorPago = 0
			end if

			if UltimaCategoria<>"" and UltimaCategoria<>ContaID then
				strCatsValorDist = strCatsValorDist&"|^"&Valor
			end if
			
			if 1=2 then
			%>
			<tr class="danger">
				<td><%=ContaID%></td>
				<td class="text-right">R$ <%=g("Value")&" - "&ValorPago%></td>
				<td class="text-right"></td>
			</tr>
			<%
			end if
			
			if UltimaCategoria<>ContaID then
				strCatsIDDist = strCatsIDDist&"|^"&ContaID
				strCatsDataDist = strCatsDataDist&"|^"&Data
				strCatsNomeDist = strCatsNomeDist&"|^"&ContaID
			end if
			if UltimaCategoria="" or UltimaCategoria=ContaID then
				Valor = Valor + (g("Value")-ValorPago)
			end if
			if UltimaCategoria<>"" and UltimaCategoria<>ContaID then
				Valor = g("Value")-ValorPago
			end if

			
			UltimaCategoria = ContaID
		G.movenext
		wend
		G.close
		set G=nothing
		strCatsValorDist = strCatsValorDist&"|^"&Valor


		splID = split(strCatsIDDist, "|^")
		splNome = split(strCatsNomeDist, "|^")
		splData = split(strCatsDataDist, "|^")
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
                if ccur(splValor(j))>0.03 then
			        %>
			        <tr>
				        <td><a target="_blank" href="./?P=Pacientes&Pers=1&I=<%=replace(splConta(1), "3_", "")%>&Ct=1"><%=Nome%></a></td>
				        <td class="text-right"><%=formatnumber(splValor(j), 2)%></td>
				        <td class="text-right" id="<%=splU(i) &"_"& splID(j)%>"><%=formatnumber(Percentual, 2)%>%</td>
			        </tr>
			        <%
                end if
			end if
		next
		%>
    </tbody>
    <tfoot>
		<tr>
        	<th><%=cats%> devedor<%if cats>1 then response.Write("es") end if%></th>
        	<th class="text-right">R$ <%=formatnumber(ValorTotal, 2)%></th>
            <th class="text-right">100,00%</th>
        </tr>
    </tfoot>
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
<script >
setTimeout(function() {
    jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "date-uk-pre": function ( a ) {
        var ukDatea = a.split('/');
        return (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
    },

    "date-uk-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },

    "date-uk-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
    } );

  $("#tabela-relatorio").dataTable( {
      aoColumns: [ null, null,null ],
      ordering: true,
      bPaginate: false,
      bLengthChange: false,
      bFilter: false,
      bInfo: false,
      bAutoWidth: false
  } );
},100);

</script>
