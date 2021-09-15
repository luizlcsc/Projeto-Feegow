<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"
De = cdate(req("De"))
Ate = cdate(req("Ate"))
ProfissionalID = req("ProfissionalID")
%>
<div class="page-header">
    <h1 class="text-center">
        Laudos - Sintético
    </h1>
    <h4 class="text-center">
    	De <%=De%> até <%=Ate%>
    </h4>
</div>
<div>
<%
	set lau = db.execute("select l.*, f.Nome, p.NomePaciente from buiformspreenchidos l LEFT JOIN pacientes p on p.id=l.PacienteID LEFT JOIN buiforms f on f.id=l.ModeloID where l.LaudadoPor="&ProfissionalID&" and date(l.LaudadoEm) BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" and not isnull(p.NomePaciente)")
		%>
		<table class="table table-striped table-hover">
		  <thead>
			<tr class="warning">
				<th>Laudo</th>
                <th>Paciente</th>
                <th>Data</th>
                <th width="1%"></th>
			</tr>
		  </thead>
          <tbody>
          	<%
			while not lau.eof
				%>
				<tr>
                	<td><%= lau("Nome") %></td>
                	<td><%= lau("NomePaciente") %></td>
                	<td><%= lau("DataHora") %></td>
                	<td><a class="btn btn-xs btn-warning hidden-print" href="./?P=Pacientes&Pers=1&I=<%= lau("PacienteID") %>"><i class="far fa-view"></i> Visualizar</a></td>
                </tr>
				<%
			lau.movenext
			wend
			lau.close
			set lau=nothing
			%>
          </tbody>
		</table>
