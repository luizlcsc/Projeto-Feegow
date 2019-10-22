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
		if isnull(cons("ValorPlano")) then
			ValorPlano = ""
		else
			ValorPlano = "R$ "&formatnumber(cons("ValorPlano"), 2)
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
	<img class="carinha" src="assets/img/<%=cons("StaID")%>.png" />&nbsp; <%= left(NomePaciente, 21) %><%if len(NomePaciente)>21 then%>...<%end if%>
  </td>
  <td><%=Telefones%></td>
  <td><%= NomeProcedimento %></td>
  <td><%= NomeStatus %></td>
  <td><%=ValorPlano%></td>
</tr>
