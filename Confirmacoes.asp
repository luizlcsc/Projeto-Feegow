<!--#include file="connect.asp"-->

<script type="text/javascript">
    $(".crumb-active a").html("Confirmações de Agendamentos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("via e-mail e SMS");
    $(".crumb-icon a span").attr("class", "far fa-envelope");
</script>

<br />
<div class="panel">
    <div class="panel-body">
		<%
		if lcase(session("Table"))="profissionais" then
			filtraProf = " where a.ProfissionalID="&session("idInTable")
		end if
		set conf = db.execute("select ar.*, pro.NomeProfissional, a.id as AgendaID,  a.Data, a.Hora, a.StaID, p.NomePaciente,p.id as PacienteID from agendamentosrespostas ar LEFT JOIN agendamentos a on a.id=ar.AgendamentoID LEFT JOIN pacientes p on p.id=a.PacienteID  LEFT JOIN profissionais pro on pro.id=a.ProfissionalID  "&filtraProf&" order by ar.DataHora desc limit 1000")
		if conf.eof then
			%>
            Nenhuma confirmação recente.
            <%
		else
			%>
            <table class="table table-striped table-condensed table-hover">
                <thead>
                    <tr class="alert">
                        <th width="1%"></th>
                        <th>Agendamento</th>
                        <th nowrap>Resposta em</th>
                        <th>Profissional</th>
                        <th>Paciente</th>
                        <th>Resposta</th>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                <%
				while not conf.eof
					if not isnull(conf("AgendaID")) then
                    %>
                    <tr>
                        <td width="1%"><img src="assets/img/<%=conf("StaID")%>.png" /></td>
						<td><%if not isnull(conf("Data")) then%><%=formatdatetime(conf("Data"),2)%><%end if%>&nbsp;<%if not isnull(conf("Hora")) then%><%=formatdatetime(conf("Hora"),4)%><%end if%></td>
						<td><%=left(conf("DataHora"),16)%></td>
                        <td><%=conf("NomeProfissional")%></td>
                        <%if not isnull(conf("PacienteID")) then%>
                            <td><a href="?P=Pacientes&Pers=1&I=<%=conf("PacienteID")%>"><%=conf("NomePaciente")%></a></td>
                        <%else%>
                            <td><i>Paciante Excluído</i></td>
                        <%end if%>
                        <td><em><%=conf("Resposta")%></em></td>
                        <td width="1%"><a href="./?P=Agenda<%if versaoAgenda()=1 then%>-1<%end if%>&Pers=1&Conf=<%=conf("id")%>" class="btn btn-xs btn-white"><i class="far fa-search-plus"></i></a></td>
                    </tr>
                    <%
                    end if
				conf.movenext
				wend
				conf.close
				set conf=nothing
				%>
                </tbody>
            </table>
            <%
		end if
		%>
    </div>
</div>