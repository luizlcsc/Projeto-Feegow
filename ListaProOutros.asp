<!--#include file="connect.asp"-->
<%
Filtro = req("Filtro")

if ref("X")<>"" then
	db_execute("delete from propostasoutros where id="&ref("X"))
	Filtro=""
end if

if Filtro="" then
	set listaProOutros = db.execute("select id, NomeDespesa from propostasoutros where sysActive=1 order by NomeDespesa")
else
	set listaProOutros = db.execute("select id, NomeDespesa from propostasoutros where NomeDespesa like '%"&Filtro&"%' and sysActive=1 order by NomeDespesa")
end if
while not listaProOutros.EOF
	'TextoAtestado = listaProOutros("TextoAtestado")
%>
                        <tr>
                          <td>
			                <span class="tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Aplicar">
			                <a href="#" data-toggle="modal" class="blue" onClick="aplicarProOutros(<%=listaProOutros("id")%>, 'I')">
				                <i class="far fa-hand-o-left icon-hand-left bigger-125"></i>
			                </a>
			                </span>
                          </td>
                          <td><%=listaProOutros("NomeDespesa")%></td>
                          <td nowrap>
			                <a class="btn btn-xs btn-success" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar modelos de atestados e textos para futuras emiss&otilde;es" data-rel="tooltip" data-placement="top" title="" onclick="modalProOutros('ProOutros', <%=listaProOutros("id")%>)">
				                <i class="far fa-edit icon-edit bigger-125"></i>
			                </a>
			                <a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaProOutros('ProOutros', <%=listaProOutros("id")%>)" class="btn btn-xs btn-danger" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
				                <i class="far fa-remove icon-remove bigger-125"></i>
			                </a>

                          </td>
                        </tr>

    <%
listaProOutros.movenext
wend
listaProOutros.close
set listaProOutros = nothing

if ref("Aplicar")="ProOutros-Last" then
	set getLast = db.execute("select id, sysUser, sysActive from propostasoutros where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")
	%>
	<script language="javascript">
		aplicarProOutros(<%=getLast("id")%>, 'I');
	</script>
	<%
end if
%>