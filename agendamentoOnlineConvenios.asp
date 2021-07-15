<!--#include file="connect.asp"-->
<%
if req("Retirar")<>"" then
	db.execute("update convenios set ExigirAgendamentoOnline=0 where id="& req("Retirar"))
end if
if req("Inserir")<>"" then
	db.execute("update convenios set ExigirAgendamentoOnline=1 where id="& req("Inserir"))
end if
%>

<div class="row">
	<%= quickfield("simpleSelect", "InserirCAO", "Habilitar novo convênio", 6, "", "select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' and ExigirAgendamentoOnline=0 ORDER BY NomeConvenio", "NomeConvenio", "") %>
</div>

<table class="table mt20">
	<thead>
		<tr class="info">
			<th>Convênios habilitados no agendamento online</th>
			<th>Profissionais</th>
			<th width="1%"></th>
		</tr>
	</thead>
	<tbody>
		<%
		set proc = db.execute("select id, NomeConvenio FROM convenios WHERE sysActive=1 AND Ativo='on' AND ExigirAgendamentoOnline=1 ORDER BY NomeConvenio")
		if proc.eof then

			%>
			<tr>
				<td><em>Nenhum convênio habilitado para o agendamento online.</em></td>
			</tr>
			<%
		end if
		while not proc.eof
			Profissionais = ""
			ConvenioID = proc("id")
			set profs = db.execute("select id, NomeProfissional from profissionais where sysActive=1 AND Ativo='on' AND NOT SomenteConvenios LIKE '%|NONE|%' AND (ISNULL(SomenteConvenios) OR SomenteConvenios='' OR SomenteConvenios LIKE '%|"& ConvenioID &"|%') ORDER BY NomeProfissional")
			while not profs.eof
				
				Profissionais = Profissionais & "<a target='_blank' class='btn btn-xs' href='./?P=Profissionais&Pers=1&I="& profs("id") &"'>"& profs("NomeProfissional") &"</a>"
				
			profs.movenext
			wend
			profs.close
			set profs = nothing
			%>
			<tr>
				<td><a href="./?P=convenios&Pers=1&I=<%= proc("id")%>" target="_blank"><%= proc("NomeConvenio") %></td>
				<td><%= Profissionais %></td>
				<td><button onclick="ajxContent('agendamentoonlineconvenios&Retirar=<%= proc("id") %>', '', 1, 'convenios');" type="button" class="btn btn-xs btn-danger">Retirar</button>
			</tr>
			<%
		proc.movenext
		wend
		proc.close
		set proc = nothing
		%>
	</tbody>
</table>

<script type="text/javascript">
$("#InserirCAO").change(function(){
	ajxContent('agendamentoonlineconvenios&Inserir='+$(this).val(), '', 1, 'convenios');
});
</script>