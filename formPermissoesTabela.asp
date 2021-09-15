<!--#include file="connect.asp"-->
<%
Acao = ref("A")
I = ref("I")
Tipo = ref("T")
FormID = req("F")
if Acao="Add" then
	db_execute("insert into buipermissoes (Tipo, FormID, Grupo, Permissoes) values ('"&Tipo&"', "&FormID&", '', '')")
end if
if Acao="Remove" then
	db_execute("delete from buipermissoes where id="&I)
end if
%>
      <table class="table table-striped table-bordered table-condensed table-hover">
      	<thead>
          <tr>
            <th>Regra</th>
            <th width="1%"><small>Inserir</small></th>
            <th nowrap="nowrap" width="1%"><small>Visualizar<br /> de outros</small></th>
            <th nowrap="nowrap" width="1%"><small>Alterar <br />próprios</small></th>
            <th nowrap="nowrap" width="1%"><small>Alterar <br />de outros</small></th>
            <th nowrap="nowrap" width="1%"><small>Inativar <br />próprios</small></th>
            <!--<th nowrap="nowrap" width="1%"><small>Inativar <br />de outros</small></th>-->
            <th width="1%"></th>
          </tr>
        </thead>
        <tbody>
        <%
		set perm = db.execute("select * from buipermissoes where FormID="&req("F"))
		if perm.eof then
			%>
			<tr>
            	<td colspan="8">
                	Não há regras de permissionamento de grupos/pessoas específicas para este formulário. Neste caso, serão utilizadas as regras padrão definidas no permissionamento geral.
                </td>
            </tr>
			<%
		end if
		while not perm.eof
		  %>
          <tr>
          	<td><%
			if perm("Tipo")="F" then
				call quickfield("multiple", "Grupo"&perm("id"), "Funcionários", 12, perm("Grupo"), "select id, NomeFuncionario, '2' Tipo from funcionarios where sysActive=1 and Ativo='on' UNION ALL select 0, 'Todos', '1' order by Tipo, NomeFuncionario", "NomeFuncionario", "")
			elseif perm("Tipo")="P" then
				call quickfield("multiple", "Grupo"&perm("id"), "Profissionais", 12, perm("Grupo"), "select id, NomeProfissional, '2' Tipo  from profissionais where sysActive=1 and Ativo='on' UNION ALL select 0, 'Todos', '1' order by Tipo, NomeProfissional", "NomeProfissional", "")
			elseif perm("Tipo")="E" then
				call quickfield("multiple", "Grupo"&perm("id"), "Profissionais das seguintes especialidades", 12, perm("Grupo"), "select id, especialidade, '2' Tipo from especialidades where sysActive=1 UNION ALL select 0, 'Todas', '1' order by Tipo, especialidade", "especialidade", "")
			end if
			%></td>
            <td><label><input class="ace" name="Permissoes<%=perm("id")%>"<% If instr(perm("Permissoes"), "IN")>0 Then %> checked="checked"<% End If %> value="IN" type="checkbox" /><span class="lbl"></span></label></td>
            <td><label><input class="ace" name="Permissoes<%=perm("id")%>"<% If instr(perm("Permissoes"), "VO")>0 Then %> checked="checked"<% End If %> value="VO" type="checkbox" /><span class="lbl"></span></label></td>
            <td><label><input class="ace" name="Permissoes<%=perm("id")%>"<% If instr(perm("Permissoes"), "AP")>0 Then %> checked="checked"<% End If %> value="AP" type="checkbox" /><span class="lbl"></span></label></td>
            <td><label><input class="ace" name="Permissoes<%=perm("id")%>"<% If instr(perm("Permissoes"), "AO")>0 Then %> checked="checked"<% End If %> value="AO" type="checkbox" /><span class="lbl"></span></label></td>
            <td><label><input class="ace" name="Permissoes<%=perm("id")%>"<% If instr(perm("Permissoes"), "XP")>0 Then %> checked="checked"<% End If %> value="XP" type="checkbox" /><span class="lbl"></span></label></td>
            <!--<td><label><input class="ace" name="Permissoes" checked="checked" value="XO" type="checkbox" /><span class="lbl"></span></label></td>-->
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