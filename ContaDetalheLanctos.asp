				<%
				cLanc = 0
'                set itensinvoice = db.execute("select ii.*, pf.NomeProfissional, pc.NomeProcedimento, (select sum(Value) from sys_financialmovement where Type='Bill' and InvoiceID=i.id) as TotalInvoice, (select sum(ValorPago) from sys_financialmovement where Type='Bill' and InvoiceID=i.id) as TotalPago from itensinvoice as ii left join sys_financialinvoices as i on i.id=ii.InvoiceID left join profissionais as pf on pf.id=ii.ProfissionalID left join procedimentos as pc on pc.id=ii.ItemID where ii.DataExecucao="&mydatenull(Data)&" and i.AssociationAccountID=3 and i.AccountID="&PacienteID)
                set itensinvoice = db.execute("select ii.*, pf.NomeProfissional, pc.NomeProcedimento, (select sum(Value-ValorPago) from sys_financialmovement where Type='Bill' and InvoiceID=i.id) as Pendente from itensinvoice as ii left join sys_financialinvoices as i on i.id=ii.InvoiceID left join profissionais as pf on pf.id=ii.ProfissionalID left join procedimentos as pc on pc.id=ii.ItemID where ii.DataExecucao="&mydatenull(Data)&" and i.AssociationAccountID=3 and i.AccountID="&PacienteID)
				set gc = db.execute("select g.*, pf.NomeProfissional, pc.NomeProcedimento, c.NomeConvenio from tissguiaconsulta as g left join profissionais as pf on pf.id=g.ProfissionalID left join procedimentos as pc on pc.id=g.ProcedimentoID left join convenios as c on c.id=g.ConvenioID where PacienteID="&PacienteID&" and g.DataAtendimento="&mydateNull(Data)&" and g.sysActive=1")
				set gs = db.execute("select ig.*, pf.NomeProfissional, pc.NomeProcedimento, c.NomeConvenio from tissprocedimentossadt as ig left join profissionais as pf on pf.id=ig.ProfissionalID left join procedimentos as pc on pc.id=ig.ProcedimentoID left join tissguiasadt as g on g.id=ig.GuiaID left join convenios as c on c.id=g.ConvenioID where ig.Data="&mydatenull(Data)&" and g.sysActive=1 and g.PacienteID="&PacienteID)
                if not itensinvoice.eof or not gc.eof or not gs.eof then
                    %>
                    <table class="table table-condensed table-striped table-hover">
                    <thead>
                    	<tr>
                        	<th>Forma</th>
                            <th>Profissional</th>
                            <th>Procedimento</th>
                            <th>Valor</th>
                            <th></th>
                        </tr>
                    </thead>
                    <%
                    while not itensinvoice.eof
						cLanc = cLanc+1
                        %>
                        <tr>
                        	<td>Particular</td>
                        	<td><%=itensinvoice("NomeProfissional")%></td>
                            <td><%=itensinvoice("NomeProcedimento")%></td>
                            <%
							if itensinvoice("Pendente")=0 then
								classePend = "green"
								iconePend = "check"
							else
								classePend = "red"
								iconePend = "exclamation-circle"
							end if
							%>
                            	<td class="<%=classePend%>"> <i class="far fa-<%=iconePend&" "&classePend%>"></i> <strong><%=formatnumber( itensinvoice("ValorUnitario")-itensinvoice("Desconto")+itensinvoice("Acrescimo") , 2 )%></strong></td>
                            <td><a href="./?P=invoice&Pers=1&T=C&I=<%=itensinvoice("InvoiceID")%>" class="btn btn-info btn-xs"><i class="far fa-edit"></i></a></td>
                        </tr>
                        <%
                    itensinvoice.movenext
                    wend
                    itensinvoice.close
                    set itensinvoice=nothing
					
					while not gc.eof
						cLanc = cLanc+1
						%>
                        <tr>
                        	<td><%=gc("NomeConvenio")%></td>
                        	<td><%=gc("NomeProfissional")%></td>
                            <td><%=gc("NomeProcedimento")%></td>
                            <td class="text-right"><%=formatnumber(gc("ValorProcedimento"),2)%></td>
                            <td><a href="./?P=tissguiaconsulta&Pers=1&I=<%=gc("id")%>" class="btn btn-info btn-xs"><i class="far fa-edit"></i></a></td>
                        </tr>
						<%
					gc.movenext
					wend
					gc.close
					set gc=nothing
					
					while not gs.eof
						cLanc = cLanc+1
						%>
                        <tr>
                        	<td><%=gs("NomeConvenio")%></td>
                        	<td><%=gs("NomeProfissional")%></td>
                            <td><%=gs("NomeProcedimento")%></td>
                            <td><%=gs("ValorUnitario")%></td>
                            <td><a href="./?P=tissguiasadt&Pers=1&I=<%=gs("GuiaID")%>" class="btn btn-info btn-xs"><i class="far fa-edit"></i></a></td>
                        </tr>
						<%
					gs.movenext
					wend
					gs.close
					set gs=nothing
                    %>
                    </table>
                    <%
                end if
				
				'Depois de gcons, gsadt e ii...
				if cLanc=0 then
					%>
					<div class="row"><div class="col-xs-12"><span class="label block label-warning arrowed-in arrowed-in-right label-lg">NADA COBRADO</span></div></div>
					<%
				end if
                %>
                <hr>
