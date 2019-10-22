<table class="table table-bordered table-striped table-hover hidden")

<%
set hip = db.execute("select id, NomePaciente, Unidades from pacientes WHERE isnull(Unidades) ORDER BY NomePaciente LIMIT 200")
while not hip.eof
    set uni = db.execute("select group_concat(distinct '|', l.UnidadeID, '|') UnidadesAchadas from agendamentos a LEFT JOIN locais l on l.id=a.LocalID where a.PacienteID="& hip("id"))
    UnidadesAchadas = uni("UnidadesAchadas")

    db_execute("update pacientes set Unidades='"&UnidadesAchadas&"' where id="&hip("id"))
    %>
    <tr>
        <td><%=hip("NomePaciente")%></td>
        <td><%=hip("Unidades") %></td>
        <td><%=UnidadesAchadas %></td>
    </tr>
    <%
hip.movenext
wend
hip.close
set hip=nothing
%>
</table>