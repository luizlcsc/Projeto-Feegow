<!--#include file="connect.asp"-->
<%
De = session("User")
Para = ref("chatID")
db_execute("insert into chatmensagens (De, Para, Mensagem) values ("&De&", "&Para&", '"&ref("mensagem")&"')")
set pPara = db.execute("select * from sys_users where id="&Para)
'response.Write(pPara("novasmsgs"))
if instr(pPara("novasmsgs"), "|"&De&"|")=0 or isnull(pPara("novasmsgs")) then
	db_execute("update sys_users set novasmsgs='"&pPara("novasmsgs")&"|"&De&"|' where id="&Para)
end if
%>
callTalk(<%=session("User")%>, <%=ref("chatID")%>, '', 'body_<%=ref("chatID")%>');