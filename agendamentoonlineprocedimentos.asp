<!--#include file="connect.asp"-->
<%
if req("Retirar")<>"" then
	db.execute("update procedimentos set ExibirAgendamentoOnline=0 where id="& req("Retirar"))
end if
if req("Inserir")<>"" then
	db.execute("update procedimentos set ExibirAgendamentoOnline=1 where id="& req("Inserir"))
end if

if ref("retProc")<>"" then
	db.execute("update procedimentos set ExibirAgendamentoOnline=0 where id IN("& ref("retProc") &")")
end if

if req("AtExiVal")<>"" then
	Profissionais = ref("ProfissionaisExiVal"& req("AtExiVal"))
	I = req("AtExiVal")
	if Profissionais="" then
		db.execute("delete from aoexival where ProcedimentoID="& I)
	else
		set vca = db.execute("select id from aoexival where ProcedimentoID="& I)
		if vca.eof then
			db.execute("insert into aoexival set ProcedimentoID="& I &", Profissionais='"& Profissionais &"', sysUser="& session("User"))
		else
			db.execute("update aoexival set Profissionais='"& Profissionais &"', sysUser="& session("User") &" where ProcedimentoID="& I)
		end if
	end if
	response.end
end if
%>

<div class="row">
	<%= quickfield("simpleSelect", "InserirPAO", "Habilitar novo procedimento", 6, "", "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' and (ExibirAgendamentoOnline=0 OR ISNULL(ExibirAgendamentoOnline)) ORDER BY NomeProcedimento LIMIT 400", "NomeProcedimento", "") %>
	<div class="col-md-6 pt25 text-right">
		<button class="btn btn-danger" onclick="retiraMassa()" type="button">RETIRAR</button>
	</div>
</div>

<table class="table">
	<thead>
		<tr>
			<th width="1%"><input type="checkbox" onclick="$('.retProc').prop('checked', $(this).prop('checked'))"  ></th>
			<th>Procedimentos habilitados no agendamento online</th>
			<th>Tipo</th>
			<th>Grupo</th>
			<th nowrap>Exibição de valores</th>
			<th width="1%"></th>
		</tr>
	</thead>
	<tbody>
		<%
		set proc = db.execute("select p.id, p.NomeProcedimento, ifnull(p.ProcedimentoTelemedicina, '') ProcedimentoTelemedicina, t.TipoProcedimento, g.NomeGrupo, axv.Profissionais ProfissionaisExiVal FROM procedimentos p LEFT JOIN aoexival axv ON axv.ProcedimentoID=p.id LEFT JOIN tiposprocedimentos t ON t.id=p.TipoProcedimentoID LEFT JOIN procedimentosgrupos g ON g.id=p.GrupoID WHERE p.sysActive=1 AND p.Ativo='on' AND p.ExibirAgendamentoOnline=1 ORDER BY p.NomeProcedimento LIMIT 300")
		if proc.eof then
			%>
			<tr>
				<td><em>Nenhum procedimento ativo habilitado para o agendamento online.</em></td>
			</tr>
			<%
		end if
		while not proc.eof
			ProfissionaisExiVal = proc("ProfissionaisExiVal")
			%>
			<tr>
				<td><input type="checkbox" class="retProc" name="retProc" value="<%= proc("id") %>">
				<td>
					<a href="./?P=procedimentos&Pers=1&I=<%= proc("id")%>" target="_blank"><%= proc("NomeProcedimento") %></a>
					<%
					if proc("ProcedimentoTelemedicina")="S" then
						%>
						<i class="far fa-video-camera"></i>
						<%
					end if
					%>

				</td>
				<td><%= proc("TipoProcedimento") %></td>
				<td><%= proc("NomeGrupo") %></td>
				<td>
					<%= quickfield("multiple", "ProfissionaisExiVal"& proc("id"), "", 12, ProfissionaisExiVal, "select 'ALL' id, '     TODOS OS PROFISSIONAIS' NomeProfissional UNION select id, NomeProfissional from profissionais where sysActive=1 and ativo='on' order by NomeProfissional", "NomeProfissional", " data-ProcID='"& proc("id") &"' ") %>
				</td>
				<td><button onclick="ajxContent('agendamentoonlineprocedimentos&Retirar=<%= proc("id") %>', '', 1, 'procedimentos');" type="button" class="btn btn-xs btn-danger">Retirar</button>
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
$("#InserirPAO").change(function(){
	ajxContent('agendamentoonlineprocedimentos&Inserir='+$(this).val(), '', 1, 'procedimentos');
});

$("select[name^='ProfissionaisExiVal']").change(function(){
	$.post("agendamentoonlineProcedimentos.asp?AtExiVal="+ $(this).attr("data-ProcID"), $(this).serialize(), function(data){
		eval(data);
	});
});

function retiraMassa(){
	$.post("agendamentoonlineprocedimentos.asp", $(".retProc").serialize(), function(data){
		$("#procedimentos").html(data);
	});
}

<!--#include file="JQueryFunctions.asp"-->
</script>