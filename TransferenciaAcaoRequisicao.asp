<!--#include file="connect.asp"-->
<%
AcaoID= req("Acao")
TransferenciaFilaID= req("I")
NotificacaoID= req("NotificacaoID")

db.execute("UPDATE notificacoes SET StatusID=3 WHERE id="&NotificacaoID)
call updateUserNotifications(session("User"))
%>