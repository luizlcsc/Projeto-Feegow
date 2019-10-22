<!--#include file="connect.asp"-->
<%
valPar = req("valPar")
spl = split(valPar, "_")
ValorID = spl(1)
Coluna = spl(2)

valor = ref("valor")

db_execute("update buitabelasvalores set c"&Coluna&"='"&valor&"' where id="&ValorID)
%>