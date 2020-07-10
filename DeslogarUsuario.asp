<!--#include file="connect.asp"-->
<%
  sqlDeslogarUsuario = "SELECT * FROM "&Session("Banco")&".sys_users WHERE id = '"&Session("User")&"'"
  deslogarUser = true

  set trySysUser=db.execute(sqlDeslogarUsuario)
  if not trySysUser.EOF then
    If trySysUser("notiftarefas") = "" Then
      notiftarefas = "|DISCONNECT|"
    Else
      notiftarefas=replace(trim(notiftarefas&" "), "|DISCONNECT|", "")
    End if
	end if
  
  If deslogarUser Then
    db_execute("update sys_users set notifTarefas='"&notifTarefas&"' where id="&Session("User"))
    Response.Write "Deslogado"
  end if
%>