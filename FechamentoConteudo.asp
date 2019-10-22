<h3><%=units("UnitName")%></h3>

<table class="table table-bordered table-condensed">
	<thead>
    	<tr>
        	<th width="80%">FORMA</th>
            <th>VALOR</th>
        </tr>
    </thead>
	<tbody>
    <%
	SubtotalGeral = 0
	sql = "select distinct m.PaymentMethodID MetodoID, mp.PaymentMethod NomeMetodo, (select sum(value) from sys_financialmovement where Date BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND CD='D' AND Type='Pay' AND UnidadeID="&UnidadeID&" and PaymentMethodID=m.PaymentMethodID) Total from sys_financialmovement m LEFT JOIN sys_financialpaymentmethod mp on mp.id=m.PaymentMethodID WHERE m.Date BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND m.CD='D' AND m.Type='Pay' AND m.UnidadeID="&UnidadeID
'	response.Write(sql)
	set f = db.execute(sql)
	while not f.eof
		MetodoID = f("MetodoID")
		NomeMetodo = f("NomeMetodo")
		Total = f("Total")
		SubtotalGeral = SubtotalGeral+Total
		%>
		<tr>
        	<td><strong><%=NomeMetodo%></strong></td>
            <td class="text-right"><strong>R$ <%=formatnumber(Total,2)%></strong></td>
        </tr>
		<%
		if MetodoID=8 then'cartao de credito
			set cc=db.execute("select distinct tr.Parcelas from sys_financialcreditcardtransaction tr LEFT JOIN sys_financialmovement m on m.id=tr.MovementID WHERE m.Date BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND m.CD='D' AND m.Type='Pay' AND m.UnidadeID="&UnidadeID&" AND m.PaymentMethodID=8")
			while not cc.eof
				Parcelas = cc("Parcelas")
				set stt = db.execute("select sum(m.value) Subtotal from sys_financialmovement m LEFT JOIN sys_financialcreditcardtransaction tr on tr.MovementID=m.id WHERE m.Date BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND m.CD='D' AND m.Type='Pay' AND m.UnidadeID="&UnidadeID&" AND m.PaymentMethodID=8 and tr.Parcelas="&Parcelas)
				Subtotal = stt("Subtotal")
				%>
                <tr>
                    <td>&nbsp; <%=Parcelas%> parcela<%if Parcelas>1 then response.Write("s") end if%></td>
                    <td class="text-right">R$ <%=formatnumber(Subtotal,2)%></td>
                </tr>
				<%
			cc.movenext
			wend
			cc.close
			set cc=nothing
		elseif MetodoID=2 then
			Subtotal = 0
'			set cq = db.execute("select (select count(*) from chequesinvoice where InvoiceID=ci.InvoiceID) parcelas from chequesinvoice ci WHERE DataPagto BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" group by parcelas order by parcelas")
			set cq = db.execute("select *, (select count(*) from chequesinvoice where InvoiceID=ci.InvoiceID) Parcelas from chequesinvoice ci WHERE ci.DataPagto BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND ci.UnidadeID="&UnidadeID&" order by Parcelas")
			while not cq.eof
				if Parcelas<>ccur(cq("Parcelas")) then
					Aparece = 1
				else
					Aparece = 0
				end if
				Parcelas = ccur(cq("Parcelas"))
				Valor = cq("Valor")
				Subtotal = Subtotal + Valor
			cq.movenext
			if cq.eof then
				acabou = 1
			else
				if Parcelas<>ccur(cq("Parcelas")) then
					acabou = 1
				else
					acabou = 0
				end if
			end if
			if acabou=1 then
				%>
                <tr>
                    <td>&nbsp; <%=Parcelas%> parcela<%if Parcelas>1 then response.Write("s") end if%> <%'="Ap: "&Aparece%></td>
                    <td class="text-right"><%'=Valor%> R$ <%=formatnumber(Subtotal,2)%> <%'=acabou%></td>
                </tr>
				<%
			end if
				if acabou=1 then
					Subtotal = 0
				end if
			wend
			cq.close
			set cq=nothing
		end if
	f.movenext
	wend
	f.close
	set f=nothing

	TotalGeral = TotalGeral+Subtotalgeral
	%>
    </tbody>
    <tfoot>
    	<tr>
        	<th>SUBTOTAL</th>
        	<th class="text-right">R$ <%=formatnumber(SubtotalGeral,2)%>
        </tr>
    </tfoot>
</table>