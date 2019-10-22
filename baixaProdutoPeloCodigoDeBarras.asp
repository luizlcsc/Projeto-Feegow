<!--#include file="connect.asp"-->
<%
cbi = req("cbi")

set PosicaoSQL = db.execute("SELECT id, ProdutoID FROM estoqueposicao WHERE CBID='"&cbi&"'")

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