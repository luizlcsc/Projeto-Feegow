<!--#include file="connect.asp"-->
<%
response.Charset = "utf-8"

%>

<table border="1" width="100%">
<thead>
	<tr>
    	<th>Pacientes em Novembro/2015</th>
    	<th>Pacientes em Junho/2016</th>
    </tr>
</thead>
<tbody>
<%
set pac = db.execute("select dbold.id idold, dbold.NomePaciente pacvelho, dbnew.NomePaciente pacnovo from clinic522_20nov.pacientes dbold LEFT JOIN clinic522.pacientes dbnew on dbold.id=dbnew.id order by dbold.NomePaciente")
while not pac.eof
	if isnull(pac("pacvelho")) or isnull(pac("pacnovo")) then
%>
	<tr>
    	<td><%=pac("idold") &" - "& pac("pacvelho")%></td>
    	<td><%=pac("pacnovo")%></td>
        <td>
        <%
		set atend = db.execute("select id from clinic522.atendimentos where PacienteID="&pac("idold"))
		while not atend.eof
			%>
			<%=atend("id")%><br>
			<%
		atend.movenext
		wend
		atend.close
		set atend=nothing
		%>
        </td>
    </tr>
<%
	end if
pac.movenext
wend
pac.close
set pac=nothing
%>
</tbody>
</table>