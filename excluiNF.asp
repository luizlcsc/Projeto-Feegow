<!--#include file="connect.asp"-->
<%

id = ref("id")
db.execute("UPDATE nfe_notasemitidas SET situacao=-1 WHERE id="&id)
%>