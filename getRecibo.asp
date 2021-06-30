<!--#include file="connect.asp"-->
<%
set rec = db.execute("select * from recibos where id="&req("ReciboID"))
if not rec.eof then
	%>
    <textarea class="hidden" id="txtProviRecibo"><%=rec("Texto")%></textarea>
    <script language="javascript">
	$("#EmitenteRecibo").val('<%=rec("Emitente")%>');
	$("#NomeRecibo").val('<%=rec("Nome")%>');
	$("#ValorRecibo").val('<%=formatnumber(rec("Valor"),2)%>');
	$("#DataRecibo").val('<%=rec("Data")%>');
	$("#ServicosRecibo").val('<%=rec("Servicos")%>');
	$("#TextoRecibo").val( $("#txtProviRecibo").val() );
	</script>
	<%
end if
%>