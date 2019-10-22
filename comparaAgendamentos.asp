<!--#include file="connect.asp"-->
<%
Data = req("Data")

response.buffer
%>
<div class="panel">
	<div class="panel-body">
		<table class="table table-striped table-condensed table-bordered table-hover">
			<thead>
				<tr>
					<th>Conta</th>
					<th>Data</th>
					<th>Paciente / Unidade Agenda</th>
					<th>Procedimento</th>
					<th>Valor Age</th>
					<th>Val Fat</th>
					<th>Uni Age</th>
					<th>Uni Fat</th>
					<th>Usu�rio</th>
					<th>Usu�rio II</th>
					<th>Rep Cons</th>
				</tr>
			</thead>
			<tbody>
				<%
				set age = db.execute("select a.Data, a.PacienteID, a.TipoCompromissoID, a.ProfissionalID, pac.NomePaciente, proc.NomeProcedimento, a.ValorPlano, l.UnidadeID, u.NomeFantasia FROM agendamentos a LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN profissionais prof ON prof.id=a.ProfissionalID LEFT JOIN pacientes pac ON pac.id=a.PacienteID LEFT JOIN locais l ON l.id=a.LocalID LEFT JOIN sys_financialcompanyunits u ON u.id=l.UnidadeID WHERE a.Data>="& mydatenull(Data) &" and a.Data<=curdate() AND a.rdValorPlano='V' AND a.StaID IN (1, 2, 3, 4, 5)")
				if not age.eof then
                    while not age.eof
                        response.flush()
                        set inv = db.execute("select ii.InvoiceID, ii.DataExecucao, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) Valor, i.CompanyUnitID, i.sysUser, ii.sysUser sysUserII, (select ifnull(ItemContaAPagar,0) from rateiorateios where ItemInvoiceID=ii.id and ContaCredito LIKE '5_%' LIMIT 1) RepCons from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID where ii.DataExecucao>="& mydatenull(age("Data")) &" AND ii.ProfissionalID="& age("ProfissionalID") &" AND ii.ItemID="& age("TipoCompromissoID") &" AND ii.Tipo='S' AND i.AccountID="& age("PacienteID") &" AND i.CD='C'")
                        if not inv.eof then
                            ValorInvoice = inv("Valor")
                            UnidadeInvoice = inv("CompanyUnitID")
                            InvoiceID = inv("InvoiceID")
                            btnInv = "<a href='./?P=Invoice&Pers=1&CD=C&I="& InvoiceID &"' class='btn btn-xs' target='_blank'>"& inv("InvoiceID") &"</a>"
                            sysUser = inv("sysUser")
                            sysUserII = inv("sysUserII")
                            RepCons = inv("RepCons")
                            APagar = ""
                            btnPag = ""
                            if not isnull(RepCons) then
                                set papag = db.execute("select InvoiceID from itensinvoice where id="& RepCons)
                                if not papag.eof then
                                    APagar = papag("InvoiceID")
                                    btnPag = "<a href='./?P=Invoice&Pers=1&CD=D&I="& APagar &"' class='btn btn-xs' target='_blank'>"& APagar &"</a>"
                                end if
                            end if
                        else
                            ValorInvoice = ""
                            UnidadeInvoice = ""
                            InvoiceID = ""
                            btnInv = ""
                            sysUser = ""
                            sysUserII = ""
                            RepCons = ""
                        end if

                        if UnidadeInvoice<>"" then
                            if age("UnidadeID")=UnidadeInvoice then
                                classe = ""
                            else
                                classe = "danger"
                            %>
                            <tr class="<%= classe %>">
                                <td><%= btnInv %></td>
                                <td><%= age("Data") %></td>
                                <td><%= age("NomePaciente") &"<br>"& age("NomeFantasia") %></td>
                                <td><%= age("NomeProcedimento") %></td>
                                <td class="text-right"><%= fn(age("ValorPlano")) %></td>
                                <td class="text-right"><%= fn( ValorInvoice ) %></td>
                                <td><%= age("UnidadeID") %></td>
                                <td><%= UnidadeInvoice %></td>
                                <td><%= inv("sysUser") %></td>
                                <td><%= inv("sysUserII") %></td>
                                <td><%= btnPag %></td>
                            </tr>
                            <%
                            end if
                        end if
                    age.movenext
                    wend
                    age.close
                    set age = nothing
                else
                    %>
                    <tr><td colspan="11">Nenhum agendamento encontrado</td></tr>
                    <%
                end if
				%>
			</tbody>
		</table>
	</div>
</div>