<!--#include file="connect.asp"-->
<%
set pres = db.execute("select *, (select count(*) from PacientesPrescricoes where PacienteID="&req("PacienteID")&") as Total from PacientesPrescricoes where PacienteID="&req("PacienteID")&" order by Data desc")
if not pres.eof then
	Total = pres("Total")
else
	Total = 0
end if
%>
<div class="btn-group btn-block">
    <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
        <i class="far fa-history"></i> Hist&oacute;rico de Prescri&ccedil;&otilde;es - <%=Total%>
        <span class="far fa-caret-down icon-on-right"></span>
    </button>
    <ul class="dropdown-menu dropdown-warning">



<%
if ref("X")<>"" then
	db_execute("delete from PacientesPrescricoes where id="&ref("X"))
end if

if not pres.eof then
	while not pres.eof
		%>
        <li>
        	<a href="javascript:void(0)">
            	<span onclick="HistoricoPrescricoes(<%=pres("id")%>, '');"><i class="far fa-search-plus"></i> <%=left(pres("Data"),10)&" por "&nameInTable(pres("sysUser"))%></span>&nbsp;&nbsp;
            	<span class="red" onclick="if(confirm('Tem certeza de que deseja excluir esta prescrição?'))HistoricoPrescricoes('', <%=pres("id")%>)"><i class="far fa-trash"></i></span>
            </a> 
        	
        </li>
		<%
	pres.movenext
	wend
	pres.close
	set pres = nothing
	%>
    </ul>
</div>
    <%
end if

if ref("Aplicar")<>"" and 1=2 then
	set pres = db.execute("select * from PacientesPrescricoes where id="&ref("Aplicar"))
	if not pres.EOF then
	%>
    <div style="display:none" id="ReaplicarPrescricao"><%=pres("Prescricao")%></div>
	<script type="text/javascript">
		$("#receituario").val($("#ReaplicarPrescricao").html());
		<%
		if pres("ControleEspecial")="checked" then
			%>
			$("#ControleEspecial").attr('checked', 'checked');
			<%
		else
			%>
			$("#ControleEspecial").removeAttr('checked');
			<%
		end if
		%>
	</script>
	<%
	end if
end if
%>