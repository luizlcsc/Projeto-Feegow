<!--#include file="connect.asp"-->
<%

if ref("X")<>"" then
	db_execute("delete from pacientesatestados where id="&ref("X"))
end if

set pres = db.execute("select * from pacientesatestados where PacienteID="&req("PacienteID")&" order by Data desc")
if not pres.eof then
	%>
	<span class="green middle bolder">Anteriores: </span>
	<%
	while not pres.eof
		%>
        <span class="label label arrowed-in arrowed-right"> 
        	<a class="white" href="javascript:HistoricoAtestados(<%=pres("id")%>, '')">
	            <i class="far fa-zoom-in"></i><%if len(pres("Titulo"))>1 then response.Write(pres("Titulo")&" - ")%> <%=left(pres("Data"),10)&" por "&nameInTable(pres("sysUser"))%>
            </a>
                
            <a class="red" href="javascript:HistoricoAtestados('', <%=pres("id")%>)">
                <i class="far fa-trash"></i>
            </a>
        </span>
		<%
	pres.movenext
	wend
	pres.close
	set pres = nothing
	%>
    <div class="hr dotted"></div>
    <%
end if

if ref("Aplicar")<>"" then
	set pres = db.execute("select * from pacientesatestados where id="&ref("Aplicar"))
	if not pres.EOF then
	%>
    <div style="display:none" id="ReaplicarAtestado"><%=pres("Atestado")%></div>
	<script language="javascript">
		$("#atestado").val($("#ReaplicarAtestado").html());
	</script>
	<%
	end if
end if
%>