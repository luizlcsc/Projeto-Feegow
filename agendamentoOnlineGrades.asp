<!--#include file="connect.asp"-->
<%
if req("Retirar")<>"" then
	db.execute("update assfixalocalxprofissional set Compartilhada='' where id="& req("Retirar"))
end if
if req("Inserir")<>"" then
	db.execute("update assfixalocalxprofissional set Compartilhada='S' where id="& req("Inserir"))
end if
%>

<div class="row">
	<%
	sql = "select a.id, concat( prof.NomeProfissional, ' - ', "&_
	" CASE WHEN a.DiaSemana=1 THEN 'Domingo' WHEN a.DiaSemana=2 THEN 'Segunda' WHEN a.DiaSemana=3 THEN 'Terça' WHEN a.DiaSemana=4 THEN 'Quarta' WHEN a.DiaSemana=5 THEN 'Quinta' WHEN a.DiaSemana=6 THEN 'Sexta' WHEN a.DiaSemana=7 THEN 'Sábado' ELSE 'Outros' END "&_
	" , ' - ', HoraDe, ' a ', HoraA , ' - Vigência de ', IFNULL(InicioVigencia, 'sempre'), ' até ', IFNULL(FimVigencia, 'sempre') ) Descricao from assfixalocalxprofissional a LEFT JOIN profissionais prof ON prof.id=a.ProfissionalID WHERE a.Compartilhada='' AND IFNULL(FimVigencia, '2050-01-01')>=CURDATE()"

	'response.write( sql )
	
	call quickfield("simpleSelect", "InserirPAO", "Compartilhar grade", 6, "", sql, "Descricao", "") %>
</div>

<table class="table">
	<thead>
		<tr>
			<th width="1%"></th>
			<th>Profissional</th>
			<th>Dia da semana</th>
			<th>Horários</th>
			<th nowrap>Vigência</th>
			<th nowrap>Procedimentos Habilitados</th>
			<th nowrap>Convênios Habilitados</th>
		</tr>
	</thead>
	<tbody>
		<%
		set proc = db.execute("select prof.NomeProfissional, a.id, a.ProfissionalID, a.HoraDe, a.HoraA, a.InicioVigencia, a.FimVigencia, a.DiaSemana, a.Procedimentos, a.Convenios from assfixalocalxprofissional a LEFT JOIN profissionais prof ON prof.id=a.ProfissionalID where a.Compartilhada='S' AND IFNULL(FimVigencia, '2050-01-01')>=CURDATE()")
		if proc.eof then
			%>
			<tr>
				<td><em>Nenhuma grade habilitada para o agendamento online.</em></td>
			</tr>
			<%
		end if
		while not proc.eof
			if isnull(proc("InicioVigencia")) and isnull(proc("FimVigencia")) then
				Vigencia = "Sempre"
			elseif not isnull(proc("InicioVigencia")) and isnull(proc("FimVigencia")) then
				Vigencia = "A partir de "& proc("InicioVigencia")
			elseif isnull(proc("InicioVigencia")) and not isnull(proc("FimVigencia")) then
				Vigencia = "Até "& proc("FimVigencia")
			else
				Vigencia = "De "& proc("InicioVigencia") &" a "& proc("FimVigencia")
			end if

			Procedimentos = proc("Procedimentos")&""
			if Procedimentos="" then
				descProcedimentos = "<em>Padrão das configurações.</em>"
			else
				sql = "select group_concat(NomeProcedimento) Procedimentos from procedimentos where sysActive=1 AND ativo='on' AND id IN("& replace(Procedimentos, "|", "") &")"
				'response.write( sql &"<BR>")
				set procs = db.execute( sql )
				descProcedimentos = procs("Procedimentos")
			end if

			Convenios = proc("Convenios")&""
			if Convenios="" then
				descConvenios = "<em>Padrão das configurações.</em>"
			elseif Convenios="|P|" then
				descConvenios = "<em>Somente particular</em>"
			else
				sql = "select group_concat(NomeConvenio) Convenios from convenios where sysActive=1 AND id IN("& replace(replace(Convenios, "|", ""), "P", "0") &")"
				'response.write( sql &"<BR>")
				set convs = db.execute( sql )
				descConvenios = convs("Convenios")
			end if

			%>
			<tr>
				<td><button onclick="ajxContent('agendamentoonlineGrades&Retirar=<%= proc("id") %>', '', 1, 'grades');" type="button" class="btn btn-xs btn-danger">Retirar</button>
				<td nowrap>
					<a href="./?P=profissionais&Pers=1&I=<%= proc("ProfissionalID")%>&Aba=Horarios" target="_blank"><%= proc("NomeProfissional") %></a>
				</td>
				<td nowrap><%= weekdayname(proc("DiaSemana")) %></td>
				<td nowrap><%= ft(proc("HoraDe")) &" a "& ft(proc("HoraA")) %></td>
				<td nowrap><%= Vigencia %></td>
				<td><%= descProcedimentos %></td>
				<td><%= descConvenios %></td>
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
	ajxContent('agendamentoonlineGrades&Inserir='+$(this).val(), '', 1, 'grades');
});

<!--#include file="JQueryFunctions.asp"-->
</script>