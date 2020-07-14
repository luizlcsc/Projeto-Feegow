<!--#include file="connect.asp"-->
<%
  sqlDeslogarUsuario = "SELECT * FROM "&Session("Banco")&".sys_users WHERE id = '"&Session("User")&"'"
  deslogarUser = true
  Session("Deslogar_user") = deslogarUser

  set trySysUser=db.execute(sqlDeslogarUsuario)
  if not trySysUser.EOF then
    notifiText = trySysUser("notiftarefas")

    If instr(notifiText, "|DISCONNECT|")=0 Then
    notiftarefas= notifiText&" |DISCONNECT|"
    elseif notifiText = "" then
      notiftarefas = "|DISCONNECT|"
    Else
      deslogarUser = false
    End if
	end if
 
  If deslogarUser Then
    db_execute("update sys_users set notifTarefas='"&notifTarefas&"' where id="&Session("User"))
  end if
%>
