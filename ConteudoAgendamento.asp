<%
NomePaciente = ""
Telefones = ""
NomeProcedimento = ""
ValorPlano = ""
NomeStatus = ""
ConsultaID = pTemp("ConsultaID")
set cons = db.execute("select * from agendamentos where id="&ConsultaID)
if not cons.EOF then
	set pac = db.execute("select id, NomePaciente, Tel1, Tel2, Cel1, Cel2, Foto from pacientes where id="&cons("PacienteID"))
	if not pac.eof then
		PacienteID = pac("id")
		NomePaciente = pac("NomePaciente")
		if len(pac("Tel1"))>5 then Telefones = Telefones&" / "&pac("Tel1") end if
		if len(pac("Tel2"))>5 then Telefones = Telefones&" / "&pac("Tel2") end if
		if len(pac("Cel1"))>5 then Telefones = Telefones&" / "&pac("Cel1") end if
		if len(pac("Cel2"))>5 then Telefones = Telefones&" / "&pac("Cel2") end if
		if len(Telefones)>2 then
			Telefones = right(Telefones, (len(Telefones)-2) )
		end if
		if len(pac("Foto"))>1 then
			Foto = "<img src=""uploads/"&pac("Foto")&""" width=""70"" />"
		else
			Foto = ""
		end if
	end if
	set proc = db.execute("select id, NomeProcedimento from procedimentos where id="&cons("TipoCompromissoID"))
	if not proc.eof then
		NomeProcedimento = proc("NomeProcedimento")
	end if
	if cons("rdValorPlano")="P" then
		set conv = db.execute("select id, NomeConvenio from convenios where id="&cons("ValorPlano"))
		if not conv.EOF then
			ValorPlano = conv("NomeConvenio")
		end if
	else
		if not isnull(cons("ValorPlano")) then
			ValorPlano = "R$ "&formatnumber(cons("ValorPlano"), 2)
		else
			ValorPlano = ""
		end if
	end if
	set sta = db.execute("select * from staConsulta where id="&cons("StaID"))
	if not sta.EOF then
		NomeStatus = sta("StaConsulta")
	end if
end if
%>
<tr id="<%=replace(formatDateTime(pTemp("Hora"),4), ":", "")%>" class="<%if minute(hora)>0 then%> fc-minor<%end if%>">
  <th class="fc-agenda-axis fc-widget-header"><%=formatDateTime(pTemp("Hora"),4)%></th>
  <td class="fc-col0 fc-thu fc-widget-content fc-state-highlight fc-today" title="<%=NomePaciente%>  <%=Telefones%>" alt="<%=NomePaciente%>  <%=Telefones%>">
  	
<span onclick="abreAgenda('<%= replace(formatDateTime(pTemp("Hora"),4), ":", "") %>', <%=ConsultaID%>, $('#Data').val(), $('#Data').val(), '<%=pTemp("LocalID")%>')">

                        <div style="text-align:left" class="label label-grey arrowed-right col-xs-4 text-left nomePaciente">
                                        <img class="carinha" src="assets/img/<%=cons("StaID")%>.png" /><span class="spanNomePaciente"><%= left(NomePaciente, 21) %><%if len(NomePaciente)>21 then%>...<%end if%> &nbsp;&nbsp; <%=Telefones%></span>

					<%
					if Foto<>"" then
					%>
                            <div class="popover" style="margin-top:-40px; z-index:100000">
                                <div class="arrow"></div>
                                    <%=Foto%>
                            </div>
                    <%
					end if
					%>
                        </div>




    <span class="label label-grey arrowed-right item-agenda-1 hidden"><%= NomePaciente %> <span class="badge badge-light"><%=Telefones%></span></span>
    <span class="label label-default arrowed-in arrowed-right col-xs-3 hidden-480"><%= NomeProcedimento %></span>
    <span class="label label-light arrowed-in arrowed-right col-xs-3 hidden-480"><%= NomeStatus %></span>
</span>
	<%=ValorPlano%>
    <div class="btn-toolbar btn-block hidden">
    <div class="btn-group pull-right">
        <button class="btn btn-xs btn-danger btn-block dropdown-toggle" data-toggle="dropdown">
        <i class="far fa-dollar"> <%=ValorPlano%></i>
        <span class="far fa-caret-down icon-on-right"></span>
        </button>
        <ul class="dropdown-menu dropdown-success">
        <li class="red btn-xs text-center"><i class="far fa-info-sign"></i> Receita n&atilde;o lan&ccedil;ada</li>
        <li class="divider"></li>
        <li>
        <a href="./?P=sys_financialinvoices&I=N&A=<%=cons("id")%>&T=C&Pers=1">Lan&ccedil;ar A Receber</a>
        </li>
        <li>
        <a href="#">Lan&ccedil;ar Guia de Consulta</a>
        </li>
        <li>
        <a href="#">Lan&ccedil;ar Guia de SP/SADT</a>
        </li>
        </ul>
    </div>
    </div>
  </td>
  
  <td>
  
  <%if ccur(contaagendamentos)<ccur(MaximoAgendamentos) then%><button type="button" onclick="abreAgenda('<%=replace(left(cdate( hour(cons("Hora"))&":"&minute(cons("Hora")) ),5), ":", "")%>', 0, '<%=cons("Data")%>', '<%=cons("LocalID")%>')" class="btn btn-success btn-xs"><i class="far fa-plus"></i></button><%end if%>
  </td>
  
</tr>
