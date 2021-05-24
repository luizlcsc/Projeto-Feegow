<!--#include file="connect.asp"-->
<%
Tipo = req("Tipo")
Destino = req("Destino")

if Tipo="DescricaoTabela" then
	set q = db.execute("select * from tissprocedimentostabela where Codigo like '"&ref("Codigo")&"' and TabelaID like '"&ref("TabelaID")&"'")
	if not q.eof then
		%>
		$("#<%=Destino%>").val("<%=q("Descricao")%>");
		<%
	end if
end if
%>