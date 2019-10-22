    	<h4><%=units("UnitName")%></h4>
        <table class="table table-bordered table-condensed">
        	<thead>
            	<tr class="success">
                	<th class="text-center" width="70%">Vendas - Particular</th>
                    <th class="text-center" width="30%">Valor</th>
                </tr>
            </thead>
            <tbody>
            <%
			totalTotal = 0
			set inv = db.execute("select sum(ap.ValorFinal) Total from atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID WHERE `Data`>="&mydatenull(De)&" and `Data`<="&mydatenull(Ate)&" AND ap.rdValorPlano='V' AND UnidadeID="&UnidadeID)

'			set inv = db.execute("select i.*, met.PaymentMethod, (select sum(Value) from sys_financialinvoices where CD='C' and sysActive=1 and FormaID=i.FormaID and CompanyUnitID="&UnidadeID&" and sysDate>="&mydatenull(De)&" and sysDate<="&mydatenull(Ate)&") Total from sys_financialinvoices i left join sys_formasrecto f on f.id=i.FormaID left join sys_financialpaymentmethod met on met.id=f.MetodoID where i.sysDate>="&mydatenull(De)&" and i.sysDate<="&mydatenull(Ate)&" and sysActive=1 and i.CD='C' and i.CompanyUnitID="&UnidadeID&"  group by i.FormaID")
			while not inv.eof
				NomeMetodo = "Particular"'inv("PaymentMethod")
				'if isnull(NomeMetodo) then
				'	NomeMetodo = "Diversos"
				'end if
				Total = inv("Total")
				if isnull(Total) then
					Total = 0
				end if
			%>
            	<tr>
                	<td><%=NomeMetodo%></td>
                    <td class="text-right"><%= formatnumber(Total,2) %></td>
                </tr>
            <%
			inv.movenext
			wend
			inv.close
			set inv=nothing
			TotalGeral = TotalGeral+total
			%>
            </tbody>
            <tfoot>
            	<tr>
                	<td><strong>Total</strong></td>
                    <td class="text-right"><strong><%= formatnumber(total,2) %></strong></td>
                </tr>
            </tfoot>
        </table>
        <table class="table table-bordered table-condensed">
        	<thead>
            	<tr class="warning">
                	<th class="text-center" width="70%">Conv&ecirc;nio</th>
                    <th class="text-center" width="30%">Valor</th>
                </tr>
            </thead>
            <tbody>
            <%
			total = 0
			
			set conv = db.execute("select distinct ap.ValorPlano, conv.NomeConvenio from atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID LEFT JOIN convenios conv on conv.id=ap.ValorPlano WHERE at.`Data`>="&mydatenull(De)&" and at.`Data`<="&mydatenull(Ate)&" AND ap.rdValorPlano='P' AND at.UnidadeID="&UnidadeID&" and not isnull(NomeConvenio) order by conv.NomeConvenio")
			
'			set conv = db.execute("select conv.NomeConvenio, "&_ 
'			"(select sum(ValorProcedimento) from tissguiaconsulta where DataAtendimento>="&mydatenull(De)&" and DataAtendimento<="&mydatenull(Ate)&" and ConvenioID=conv.id and UnidadeID="&UnidadeID&") TotalConsulta "&_ 
'			" from tissguiaconsulta gc left join convenios conv on conv.id=gc.ConvenioID where gc.DataAtendimento>="&mydatenull(De)&" and gc.DataAtendimento<="&mydatenull(Ate)&" and gc.sysActive=1 and UnidadeID="&UnidadeID&" group by gc.ConvenioID order by conv.NomeConvenio") 
			while not conv.eof
				set val = db.execute("select sum(ap.ValorFinal) Total from atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID WHERE at.`Data`>="&mydatenull(De)&" and at.`Data`<="&mydatenull(Ate)&" AND ap.rdValorPlano='P' AND at.UnidadeID="&UnidadeID&" and ValorPlano="&conv("ValorPlano")&" and rdValorPlano='P'")
				total = total+val("Total")
			%>
            	<tr>
                	<td><%=conv("NomeConvenio")%></td>
                    <td class="text-right"><%= formatnumber(val("Total"),2) %></td>
                </tr>
            <%
			conv.movenext
			wend
			conv.close
			set conv=nothing
			TotalGeral = TotalGeral+total
			%>
            </tbody>
            <tfoot>
            	<tr>
                	<td><strong>Total</strong></td>
                    <td class="text-right"><strong><%= formatnumber(Total,2) %></strong></td>
                </tr>
            </tfoot>
        </table>


