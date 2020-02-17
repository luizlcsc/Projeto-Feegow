<!--#include file="connect.asp"-->
<%
Acao = ref("A")
I = ref("I")
Tipo = ref("T")
if Acao="Add" then
	db_execute("insert into obrigacampos (Tipo, Recurso, Obrigar, Exibir) values ('"&Tipo&"', '"&Tipo&"', '', '')")
end if
if Acao="Remove" then
	db_execute("delete from obrigacampos where id="&I)
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
		set perm = db.execute("select * from obrigacampos")
		if perm.eof then
			%>
			<tr>
            	<td colspan="8">
                	Não há regras definidas para obrigatoriedade de campos.
                </td>
            </tr>
			<%
		end if
		while not perm.eof
		  %>
          <tr>
            <td>
                <%=perm("Tipo") %>
            </td>
            <td><%
                if perm("Tipo")="Paciente" then
                    call quickfield("multiple", "Obrigar"&perm("id"), "Campos obrigatórios", 12, perm("Obrigar"), "select ColumnName id from cliniccentral.sys_resourcesfields where ResourceID=1 UNION ALL select 'Convenio' UNION ALL select 'Retornos' UNION ALL select 'Relativos' order by id", "id", "")
                elseif perm("Tipo")="Agendamento" then
                    camposPacienteAgenda="'Nascimento', 'CPF', 'Documento', 'IndicadoPor', 'Profissao', 'Origem', 'Sexo', 'NomeSocial', 'Pendencias', 'Matricula1'"
                    camposPacienteAgendaObrigar="'Nascimento', 'CPF', 'Documento', 'IndicadoPor', 'Profissao', 'Origem', 'Email1', 'Cel1', 'Sexo', 'NomeSocial', 'Pendencias', 'Matricula1'"

                    call quickfield("multiple", "Obrigar"&perm("id"), "Campos obrigatórios", 12, perm("Obrigar"), "select ColumnName id from cliniccentral.sys_resourcesfields where resourceId=1 AND columnName IN ("&camposPacienteAgendaObrigar&") union all select 'IndicadoPorSelecao' id ", "id", "")
                    call quickfield("multiple", "Exibir"&perm("id"), "Exibir campos adicionais", 12, perm("Exibir"), "select ColumnName id from cliniccentral.sys_resourcesfields where resourceId=1 AND columnName IN ("&camposPacienteAgenda&") union all select 'IndicadoPorSelecao' id", "id", "")
                end if
                %></td>
            <td><button onClick="xPerm(<%=perm("id")%>)" type="button" class="btn btn-xs btn-danger"><i class="fa fa-remove"></i></button></td>
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