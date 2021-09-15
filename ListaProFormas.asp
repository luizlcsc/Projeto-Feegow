<!--#include file="connect.asp"-->
<%
Filtro = req("Filtro")

if ref("X")<>"" then
	db_execute("delete from propostasformas where id="&ref("X"))
	Filtro=""
end if

if Filtro="" then
	set listaProFormas = db.execute("select id, NomeForma from propostasformas where sysActive=1 order by NomeForma")
else
	set listaProFormas = db.execute("select id, NomeForma from propostasformas where NomeForma like '%"&Filtro&"%' and sysActive=1 order by NomeForma")
end if
while not listaProFormas.EOF
	'TextoAtestado = listaProFormas("TextoAtestado")
    if 1=2 then
	%>
	<div class="profile-activity clearfix">
		<div>
			<span id="NomeAtestado<%=listaProFormas("id")%>"><%=listaProFormas("NomeForma")%></span>
			<span id="TituloAtestado<%=listaProFormas("id")%>" class="hidden"></span>
			<div class="time hidden">
				<i class="far fa-list bigger-110"></i>
				<span id="TextoAtestado<%=listaProFormas("id")%>"><%=TextoAtestado%></span>
			</div>
		</div>
	
		<div class="tools action-buttons">
		</div>
	</div>
    <%
    end if
    %>
                        <tr>
                          <td>
			                <a href="#" data-toggle="modal" class="blue" onClick="aplicarProFormas(<%=listaProFormas("id")%>, 'I')" title="" data-placement="top" data-rel="tooltip" data-original-title="Aplicar">
				                <i class="far fa-hand-o-left icon-hand-left bigger-125"></i>
			                </a>
                          </td>
                          <td><%=listaProFormas("NomeForma")%></td>
                          <td nowrap>
                          <%
                          IF aut("formapagamentopropostaA") = 1 THEN

                          %>
			              <a class="btn btn-xs btn-success tooltip-info" href="#modal-table" role="button" data-toggle="modal" data-original-title="Editar" data-rel="tooltip" data-placement="top" title="" onclick="modalProFormas('ProFormas', <%=listaProFormas("id")%>)">
				              <i class="far fa-edit icon-edit bigger-125"></i>
			              </a>
			              <%
			              end if

                          IF aut("formapagamentopropostaX") = 1 THEN
                          %>

                           <a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaProFormas('ProFormas', <%=listaProFormas("id")%>)" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
                               <i class="far fa-remove icon-remove bigger-125"></i>
                           </a>
                          <%
                          end if
                          %>

                          </td>
                        </tr>

    <%
listaProFormas.movenext
wend
listaProFormas.close
set listaProFormas = nothing

if ref("Aplicar")="ProFormas-Last" then
	set getLast = db.execute("select id, sysUser, sysActive from propostasformas where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")
	%>
	<script language="javascript">
		aplicarProFormas(<%=getLast("id")%>, 'I');
	</script>
	<%
end if
%>