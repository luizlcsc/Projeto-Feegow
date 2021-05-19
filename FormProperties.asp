<!--#include file="connect.asp"-->
<%
db_execute("update buiForms set TipoTitulo='"&req("TipoTitulo")&"' where id="&req("F"))
%>