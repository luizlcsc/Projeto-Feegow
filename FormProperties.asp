<!--#include file="connect.asp"-->
<%
db_execute("update buiForms set TipoTitulo='"&request.QueryString("TipoTitulo")&"' where id="&request.QueryString("F"))
%>