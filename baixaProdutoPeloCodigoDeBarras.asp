<!--#include file="connect.asp"-->
<%
cbi = req("cbi")

set PosicaoSQL = db.execute("SELECT ep.id, ep.ProdutoID FROM estoqueposicao ep LEFT JOIN produtos p ON p.id=ep.ProdutoID WHERE (ep.CBID LIKE '%"&cbi&"' OR p.Codigo='"&cbi&"') AND ep.Quantidade>0 AND p.sysActive=1 LIMIT 1")

if not PosicaoSQL.eof then
%>
location.href = "?P=produtos&I=<%=PosicaoSQL("ProdutoID")%>&Pers=1&BaixarPosicao=<%=PosicaoSQL("id")%>"
<%
else
%>
alert("Código de barras não encontrado.");
<%
end if
%>