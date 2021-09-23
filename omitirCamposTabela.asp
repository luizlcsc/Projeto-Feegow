<!--#include file="connect.asp"-->
<%
Acao = ref("A")
I = ref("I")
Tipo = ref("T")
if Acao="Add" then
	db_execute("insert into omissaocampos (Tipo, Recurso, Omitir) values ('"&Tipo&"', 'Pacientes', '')")
end if
if Acao="Remove" then
	db_execute("delete from omissaocampos where id="&I)
end if
%>
      <table class="table table-striped table-bordered table-condensed table-hover">
      	<thead>
          <tr>
            <th width="20%">Grupo</th>
            <th width="80%"></th>
          </tr>
        </thead>
        <tbody>
        <%
		set perm = db.execute("select * from omissaocampos")
		if perm.eof then
			%>
			<tr>
            	<td colspan="8">
                	Não há regras definidas para omissão de dados específicos dos pacientes.
                </td>
            </tr>
			<%
		end if
		while not perm.eof
		  %>
          <tr>
          	<td><%
			if perm("Tipo")="F" then
				call quickfield("multiple", "Grupo"&perm("id"), "Funcionários", 12, perm("Grupo"), "select id, NomeFuncionario, '2' Tipo from funcionarios where sysActive=1 UNION ALL select 0, 'Todos', '1' order by Tipo, NomeFuncionario", "NomeFuncionario", "")
			elseif perm("Tipo")="P" then
				call quickfield("multiple", "Grupo"&perm("id"), "Profissionais", 12, perm("Grupo"), "select id, NomeProfissional, '2' Tipo  from profissionais where sysActive=1 AND Ativo = 'on' UNION ALL select 0, 'Todos', '1' order by Tipo, NomeProfissional", "NomeProfissional", "")
			elseif perm("Tipo")="E" then
				call quickfield("multiple", "Grupo"&perm("id"), "Profissionais das seguintes especialidades", 12, perm("Grupo"), "select id, especialidade, '2' Tipo from especialidades where sysActive=1 UNION ALL select 0, 'Todas', '1' order by Tipo, especialidade", "especialidade", "")
            elseif perm("Tipo")="C" then
                  response.write("Campos a omitir na tela de checkin:")
			end if
			%></td>
            <td><%=quickfield("multiple", "Omitir"&perm("id"), "Campos a omitir", 12, perm("Omitir"), "select ColumnName id, label from cliniccentral.sys_resourcesfields where ResourceID=1 UNION ALL select 'Convenio' id, 'Convenio' label UNION ALL select 'Programação de Agendamentos (Retornos)' label,'Retornos' id UNION ALL select 'Pessoas Relacionadas e Parentes' label, 'Relativos' order by id", "id", "")%></td>
            <td><button onClick="xPerm(<%=perm("id")%>)" type="button" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button></td>
          </tr>
          <%
		perm.movenext
		wend
		perm.close
		set perm=nothing
		%>
        </tbody>
      </table>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>