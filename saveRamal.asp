<!--#include file="connect.asp"-->
<%
Ramal     = req("Ramal")
pabxCod   = req("pabxCod")
usuarioID = req("U")

if Ramal<>"" then
  qColuna       = "Ramal"
  qColunaValor  = Ramal
elseif pabxCod<>"" then
  qColuna = "pabx_cod"
  qColunaValor  = pabxCod
end if

db.execute("update sys_users set "&qColuna&"='' WHERE "&qColuna&"='"&qColunaValor&"';")
db.execute("update sys_users set "&qColuna&"="&qColunaValor&" WHERE id= "&usuarioID&";")
%>