<!--#include file="connect.asp"-->
<%
Item = ref("Item")
Valor = ref("Val")
spl = split(Item, "_")
Coluna = spl(0)
id = spl(1)

db.execute("update procedimentosrestricaofrase set "& coluna &"='"& Valor &"' where id="& id)
%>