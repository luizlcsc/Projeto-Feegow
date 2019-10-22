<!--#include file="connect.asp"-->
<%
    db_execute("update arquivos set Descricao='"&ref("Descricao")&"' where id="&req("IMG"))
%>