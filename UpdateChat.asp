<!--#include file="connect.asp"-->
<%
chatID=request.QueryString("ChatID")
De=request.QueryString("ChatID")
Para=session("User")

'libera sinalização de mensagem na tabela do usuario
set buscaMsg = db.execute("select novasmsgs from sys_users where id="&Para)
if instr(buscaMsg("novasmsgs"), de)>0 then
    db_execute("update sys_users set novasmsgs='"&replace(buscaMsg("novasmsgs"), "|"&De&"|", "")&"' where id="&Para)
end if

%>
<!--#include file="calltalk.asp"-->