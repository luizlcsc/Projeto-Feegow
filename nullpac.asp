<!--#include file="connect.asp"-->
<%
db_execute("update sys_users set UltPac=NULL where id="&session("User"))
%>
