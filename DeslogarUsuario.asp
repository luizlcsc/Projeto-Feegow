<!--#include file="connect.asp"-->
<%
  sqlDeslogarUsuario = "SELECT * FROM sys_users WHERE id = '"&Session("User")&"'"
  
  notiftarefas='"&replace(trim(notiftarefas&" "), "|DISCONNECT|", "")&"'
  db_execute("update sys_users set notifTarefas='"&notifTarefas&"' where id="&Session("User"))
%>