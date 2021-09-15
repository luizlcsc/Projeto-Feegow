<!--#include file="connect.asp"-->
<%
if ref("X")<>"" then
	db_execute("delete from pacientespedidos where id="&ref("X"))
end if

set pres = db.execute("select * from pacientespedidos where PacienteID="&req("PacienteID")&" order by Data desc")
if not pres.eof then
	%>
	<span class="green middle bolder">Pedidos anteriores: </span>
	<%
	while not pres.eof
		%>
        <span class="label label arrowed-in arrowed-right"> 
        	<a class="white" href="javascript:HistoricoPedidos(<%=pres("id")%>, '')">
	            <i class="far fa-zoom-in"></i> <%=left(pres("Data"),10)&" por "&nameInTable(pres("sysUser"))%>
            </a>
                
            <a class="red" href="javascript:HistoricoPedidos('', <%=pres("id")%>)">
                <i class="far fa-remove"></i>
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
	set pres = db.execute("select * from pacientespedidos where id="&ref("Aplicar"))
	if not pres.EOF then
	%>
    <div style="display:none" id="ReaplicarPedido"><%=pres("PedidoExame")%></div>
	<script language="javascript">
		$("#pedidoexame").val($("#ReaplicarPedido").html());
	</script>
	<%
	end if
end if
%>