<!--#include file="connect.asp"-->
<%
Filtro = ref("Filtro")
PacienteID=req("p")
if Filtro="" then
	%>Digite o c&oacute;digo ou parte da descri&ccedil;&atilde;o da CID para buscar.
   <%
else
	urlbmj = getConfig("urlbmj")
	IF urlbmj <> "" THEN 
		sqlBmj = " (SELECT GROUP_CONCAT(DISTINCT CONCAT('<BR><strong>BMJ:</strong> <a href=""[linkbmj]/',bmj.codbmj,'"" class=""badge badge-primary"">',if(bmj.PortugueseTopicTitle='0',bmj.TopicTitle,bmj.PortugueseTopicTitle),'</a>') SEPARATOR ' ') " &_ 
				" FROM cliniccentral.cid10_bmj bmj" &_
				" WHERE bmj.cid10ID = cliniccentral.cid10.id) "
	ELSE
		sqlBmj = " '' "
	END IF
	set listaCID = db.execute("SELECT *, "&sqlBmj&" FROM cliniccentral.cid10 WHERE Codigo LIKE '%"&Filtro&"%' or Descricao like '%"&Filtro&"%' order by id limit 200")
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
                <i class="far fa-hand-o-left"></i>
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
