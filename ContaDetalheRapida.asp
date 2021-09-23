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
				'set atend = db.execute("select agt.rdValorPlano, agt.ValorPlano, agt.Icone, agt.HoraInicio, agt.HoraFim, agt.id, p.NomeProfissional, proc.NomeProcedimento from agendamentoseatendimentos as agt left join profissionais as p on p.id=agt.ProfissionalID left join procedimentos as proc on proc.id=agt.ProcedimentoID where PacienteID="&PacienteID&" and Data="&mydatenull(Data)&" and Tipo='executado'")
				set atend = db.execute("select ap.rdValorPlano, ap.ValorPlano, agt.HoraInicio, agt.HoraFim, ap.id, p.NomeProfissional, proc.NomeProcedimento from atendimentosprocedimentos ap left join atendimentos agt on ap.AtendimentoID=agt.id left join sys_users u on u.id=agt.sysUser left join profissionais p on p.id=u.idInTable left join procedimentos proc on proc.id=ap.ProcedimentoID where agt.PacienteID="&PacienteID&" and agt.Data="&mydatenull(Data))
			  if not atend.eof then
			  %>
              <h4 class="lighter blue no-margin header"><i class="far fa-star"></i> Procedimentos Realizados pelo Profissional</h4>
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
                    %>
                    <tr>
                    	<td><img src="assets/img/executado.png" border="0"></td>
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
                        <td><label><input type="checkbox" class="ace" name="Lancto" value="<%=atend("id")%>|executado"><span class="lbl"></span></label></td>
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


              <%
				'set atend = db.execute("select agt.rdValorPlano, agt.ValorPlano, agt.Icone, agt.HoraInicio, agt.HoraFim, agt.id, p.NomeProfissional, proc.NomeProcedimento from agendamentoseatendimentos as agt left join profissionais as p on p.id=agt.ProfissionalID left join procedimentos as proc on proc.id=agt.ProcedimentoID where PacienteID="&PacienteID&" and Data="&mydatenull(Data)&" and Tipo='agendamento'")
				set atend = db.execute("select agt.rdValorPlano, agt.ValorPlano, agt.StaID Icone, agt.Hora HoraInicio, agt.HoraFinal HoraFim, agt.id, p.NomeProfissional, proc.NomeProcedimento from agendamentos as agt left join profissionais as p on p.id=agt.ProfissionalID left join procedimentos as proc on proc.id=agt.TipoCompromissoID where PacienteID="&PacienteID&" and Data="&mydatenull(Data))
			  if not atend.eof then
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
						HoraInicio = formatdatetime(HoraInicio,4)
					else
						HoraInicio = ""
					end if
					if isdate(atend("HoraFim")) then
						HoraFim = formatdatetime(HoraFim,4)
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
	                <div class="col-md-6"><button name="TipoBotao" value="Credito" disabled="disabled" type="button" class="btn btn-xs btn-primary btn-block">Usar Cr&eacute;dito</button></div>
                </div>
                <hr class="no-margin" />
                
                <div class="row">
	                <div class="col-md-6"><button name="TipoBotao" value="GuiaConsulta" class="btn btn-xs btn-primary btn-block">Guia de Consulta</button></div>
	                <div class="col-md-6"><button name="TipoBotao" value="GuiaSADT" class="btn btn-xs btn-primary btn-block">Guia de SP/SADT</a></div>
                </div>
              </div>
            </div>
                
                
                
                
                
                
                
                
                
                
                
                
                
            <div class="widget-toolbox padding-8 clearfix hidden">
            </div>
        </div>
    </div>
<hr>
