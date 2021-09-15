    <div class="widget-box">
        <div class="widget-header header-color-green">
            <h5><%if Data=date() then%>HOJE<%else%><%=Data%><%end if%></h5>
            <div class="widget-toolbar hidden">
                <a data-action="collapse" href="#"><i class="1 far fa-chevron-up bigger-125"></i></a>
            </div>
            <div class="widget-toolbar no-border">
            </div>
        </div>
    </div>
    <div class="widget-body">
        <div class="widget-main">
            <div class="row">
              <div class="col-md-7">

              <%
			  AgendamentoID = ""
			  AtendimentoID = ""
				'set atend = db.execute("select agt.rdValorPlano, agt.ValorPlano, agt.Icone, agt.HoraInicio, agt.HoraFim, agt.id, p.NomeProfissional, proc.NomeProcedimento from agendamentoseatendimentos as agt left join profissionais as p on p.id=agt.ProfissionalID left join procedimentos as proc on proc.id=agt.ProcedimentoID where PacienteID="&PacienteID&" and Data="&mydatenull(Data)&" and Tipo='executado'")
				'set atend = db.execute("select ap.rdValorPlano, ap.ValorPlano, agt.HoraInicio, ap.Obs, agt.HoraFim, ap.id, p.NomeProfissional, proc.NomeProcedimento from atendimentosprocedimentos ap left join atendimentos agt on ap.AtendimentoID=agt.id left join sys_users u on u.id=agt.sysUser left join profissionais p on p.id=u.idInTable left join procedimentos proc on proc.id=ap.ProcedimentoID where agt.PacienteID="&PacienteID&" and agt.Data="&mydatenull(Data)&" limit 100")
				set atend = db.execute("select ap.rdValorPlano, ap.ValorPlano, agt.HoraInicio, ap.Obs, agt.HoraFim, ap.id, proc.NomeProcedimento, CASE WHEN u.`Table`='Profissionais' THEN (select NomeProfissional from profissionais where id=u.idInTable limit 1) WHEN u.`Table`='Funcionarios' THEN (select NomeFuncionario from funcionarios where id=u.idInTable limit 1) END as NomeProfissional from atendimentosprocedimentos ap left join atendimentos agt on ap.AtendimentoID=agt.id left join sys_users u on u.id=agt.sysUser left join procedimentos proc on proc.id=ap.ProcedimentoID where agt.PacienteID="&PacienteID&" and agt.Data="&mydatenull(Data)&" limit 100")
			  if not atend.eof then
			  	AtendimentoID = atend("id")
			  %>
              <h4 class="lighter blue no-margin header"><i class="far fa-star"></i> Procedimentos Realizados</h4>
                <table class="table table-condensed table-striped table-bordered table-hover">
                <thead>
                    <tr>
                    	<th width="5%"></th>
                        <th>Hora</th>
                        <th>Profissional</th>
                        <th>Procedimento</th>
                        <th>Valor</th>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                <%
                while not atend.eof
					ValorPlano = ""
					if atend("rdValorPlano")="V" then
						ValorPlano = formatnumber(atend("ValorPlano"), 2)
					else
						set conv = db.execute("select NomeConvenio from convenios where id = '"&atend("ValorPlano")&"'")
						if not conv.eof then
							ValorPlano = conv("NomeConvenio")
						end if
					end if
					Obs = atend("Obs")
					if not isnull(Obs) and Obs<>"" then
						temObs = 1
					else
						temObs = 0
					end if
                    %>
                    <tr>
                    	<td<% If temObs=1 Then %> rowspan="2"<% End If %>><img src="assets/img/executado.png" border="0"></td>
                        <td nowrap="nowrap"><%
						if not isnull(atend("HoraInicio")) then
							response.Write(formatdatetime(atend("HoraInicio"),4))
						end if
						if not isnull(atend("HoraFim")) then
							response.Write(" - "&formatdatetime(atend("HoraFim"),4))
						end if
						%></td>
                        <td><%=atend("NomeProfissional")%></td>
                        <td><%=atend("NomeProcedimento")%></td>
                        <td class="text-right"><%=ValorPlano%></td>
                        <td<%' If temObs=1 Then %> rowspan="2"<%' End If %>><label><input type="checkbox" class="ace" name="Lancto" value="<%=atend("id")%>|executado"><span class="lbl"></span></label></td>
                    </tr>
                    <%
					If temObs=1 and 1=2 Then
					%>
                    <tr>
                      <td colspan="4"><em><strong>Obs.: </strong><%=replace(Obs&" ", chr(10), "<br>")%></em></td>
                    </tr>
                    <%
					end if
					%>
                    <tr>
                      <td colspan="5"><%=quickfield("memo", atend("id"), "", 12, Obs, "obs", "", " rows='2' placeholder='Observa&ccedil;&otilde;es do atendimento...'")%></td>
                    </tr>
                    <%
                atend.movenext
                wend
                atend.close
                set atend=nothing
                %>
                </tbody>
                </table>

              <%
			  end if

				'set atend = db.execute("select agt.rdValorPlano, agt.ValorPlano, agt.Icone, agt.HoraInicio, agt.HoraFim, agt.id, p.NomeProfissional, proc.NomeProcedimento from agendamentoseatendimentos as agt left join profissionais as p on p.id=agt.ProfissionalID left join procedimentos as proc on proc.id=agt.ProcedimentoID where PacienteID="&PacienteID&" and Data="&mydatenull(Data)&" and Tipo='agendamento'")
				set atend = db.execute("select agt.rdValorPlano, agt.ValorPlano, agt.StaID Icone, agt.Hora HoraInicio, agt.HoraFinal HoraFim, agt.id, p.NomeProfissional, proc.NomeProcedimento from agendamentos as agt left join profissionais as p on p.id=agt.ProfissionalID left join procedimentos as proc on proc.id=agt.TipoCompromissoID where PacienteID="&PacienteID&" and Data="&mydatenull(Data)&" limit 20")
			  if not atend.eof then
			  	AgendamentoID = atend("id")
			  %>
              <h4 class="lighter blue no-margin header">Agendamentos</h4>
                <table class="table table-striped table-bordered table-hover">
                <thead>
                    <tr>
                    	<th width="5%"></th>
                        <th>Hora</th>
                        <th>Profissional</th>
                        <th>Procedimento</th>
                        <th>Valor</th>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                <%
                while not atend.eof
					ValorPlano = ""
					if atend("rdValorPlano")="V" then
						ValorPlano = formatnumber(atend("ValorPlano"), 2)
					else
						set conv = db.execute("select NomeConvenio from convenios where id = '"&atend("ValorPlano")&"'")
						if not conv.eof then
							ValorPlano = conv("NomeConvenio")
						end if
					end if
					if isdate(atend("HoraInicio")) then
						HoraInicio = formatdatetime(atend("HoraInicio"),4)
					else
						HoraInicio = ""
					end if
					if isdate(atend("HoraFim")) then
						HoraFim = formatdatetime(atend("HoraFim"),4)
					else
						HoraFim = ""
					end if
                    %>
                    <tr>
                    	<td><img src="assets/img/<%=atend("Icone")%>.png" border="0"></td>
                        <td nowrap="nowrap"><%=HoraInicio%> - <%=HoraFim%></td>
                        <td><%=atend("NomeProfissional")%></td>
                        <td><%=atend("NomeProcedimento")%></td>
                        <td class="text-right"><%=ValorPlano%></td>
                        <td><label><input type="checkbox" class="ace" name="Lancto" value="<%=atend("id")%>|agendamento"><span class="lbl"></span></label></td>
                    </tr>
                    <%
                atend.movenext
                wend
                atend.close
                set atend=nothing
                %>
                </tbody>
                </table>
              <%
			  end if
			  %>
              </div>
              <div class="col-xs-5">
              	<h4 class="lighter blue">Lan&ccedil;amentos Financeiros e Guias</h4>
				<!--#include file="ContaDetalheLanctos.asp"-->
                <div class="row"><div class="col-xs-12"><small>&raquo; Marque itens ao lado para lan&ccedil;ar</small></div></div>
                <div class="row">
	                <div class="col-md-6"><button name="TipoBotao" value="AReceber" class="btn btn-xs btn-primary btn-block">A Receber</button></div>
                    <div class="col-md-6"><%
					if ItensCredito=0 then
						%>
		                <button name="TipoBotao" value="Credito" disabled="disabled" type="button" class="btn btn-xs btn-primary btn-block">Usar Cr&eacute;dito - 0</button>
                        <%
					else
						%>
                        <div class="btn-group btn-block">
                            <button class="btn btn-xs btn-primary btn-block dropdown-toggle" data-toggle="dropdown">
                                Usar Cr&eacute;dito - <%=itensCredito%>
                                <span class="far fa-caret-down icon-on-right"></span>
                            </button>
                        	<ul class="dropdown-menu dropdown-info">
                            <%
							set cred = db.execute("select ii.id, p.NomeProcedimento, ii.ValorUnitario, i.`Value`, ii.Desconto, ii.Acrescimo, (select sum(ValorPago) from sys_financialmovement m where m.InvoiceID=i.id) as TotalPago from itensinvoice ii left join sys_financialinvoices i on i.id=ii.InvoiceID left join procedimentos p on p.id=ii.ItemID where i.AccountID="&PacienteID&" and i.AssociationAccountID=3 and ii.Executado='' and ii.Tipo='S'")
							while not cred.eof
								if not isnull(cred("TotalPago")) then
									TotalPago = ccur(cred("TotalPago"))
								else
									TotalPago = 0
								end if
								ValorInvoice = ccur(cred("Value"))
								if TotalPago<ValorInvoice and TotalPago>0 then
									NomeStatus = "Parcialmente pago"
									cor = "warning"
								elseif TotalPago=0 then
									NomeStatus = "N&atilde;o pago"
									cor = "danger"
								else
									NomeStatus = "Quitado"
									cor = "success"
								end if
								%>
                        		<li><a href="javascript:aplicarCredito(<%=cred("id")%>, '<%=AgendamentoID%>', '<%=AtendimentoID%>');"><%=cred("NomeProcedimento")%> - R$ <%=formatnumber(cred("ValorUnitario")-cred("Desconto")+cred("Acrescimo"),2)%> <span class="badge badge-<%=cor%>"><%=NomeStatus%></span></a></li>
                                <%
							cred.movenext
							wend
							cred.close
							set cred=nothing
							%>
                            </ul>
                        </div>
						<%
					end if
					%></div>
                </div>
                <hr class="no-margin" />
                
                <div class="row">
	                <div class="col-md-6"><button name="TipoBotao" value="GuiaConsulta" class="btn btn-xs btn-primary btn-block">Guia de Consulta</button></div>
	                <div class="col-md-6"><button name="TipoBotao" value="GuiaSADT" class="btn btn-xs btn-primary btn-block">Guia de SP/SADT</a></button></div>
                </div>
              </div>
            </div>
                
                
                
                
                
                
                
                
                
                
                
                
                
            <div class="widget-toolbox padding-8 clearfix hidden">
            </div>
        </div>
    </div>
<hr>
