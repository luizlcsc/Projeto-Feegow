<!--#include file="connect.asp"-->
<%
Filtro = ref("Filtro")
PacienteID=req("p")
if Filtro="" then
	%>Digite o c&oacute;digo ou parte da descri&ccedil;&atilde;o da CID para buscar.
   <%
else
	set listaCID = db.execute("select * from cliniccentral.cid10 where Codigo like '%"&Filtro&"%' or Descricao like '%"&Filtro&"%' limit 200")
	if listaCID.eof then
		%>
		Nenhuma doen&ccedil;a encontrada com o termo '<em><%=Filtro%></em>'.
		<%
	end if
	while not listaCID.EOF
		Diag = listaCID("Codigo")&": "&listaCID("Descricao")
		%>
		<tr id="Codigo<%=listaCID("id")%>">
            <td width="1%"><a style="cursor:pointer;" onClick="ajxContent('ListaDiagnosticos&PacienteID=<%=PacienteID%>&CID=<%=listaCID("id")%>', '', '1', 'ListaDiagnosticos');">
                <i class="fa fa-hand-o-left"></i>
                </a>
            </td>

            <td > <span style="float: left;"><%=Diag%></span></td>

        </tr>
	<%
	listaCID.movenext
	wend
	listaCID.close
	set listaCID = nothing
end if
%>