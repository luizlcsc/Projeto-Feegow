<!--#include file="connect.asp"-->
<%
NotificacaoID = req("I")

set rsNotificacao = db.execute("SELECT * FROM notificacoes WHERE id= '" & NotificacaoID & "'")
if not rsNotificacao.eof then
    IdRelativo = rsNotificacao("NotificacaoIDRelativo")
    db.execute("UPDATE notificacoes SET StatusID = 3 WHERE id = '" & NotificacaoID & "'")
    select case rsNotificacao("TipoNotificacaoID")
        case 14
            response.redirect("./?P=solicitacoescompras&Pers=1#/solicitacoes/cotacao/" & IdRelativo)
        case 15
            response.redirect("./?P=solicitacoescompras&Pers=1#/aprovacoes")
        case 16
            response.redirect("./?P=solicitacoescompras&Pers=1#/ordens")
        case 17, 18, 20
            response.redirect("./?P=solicitacoescompras&Pers=1#/solicitacoes/edit/" & IdRelativo)
        case 19
            response.redirect("./?P=solicitacoescompras&Pers=1#/ordens/edit/" & IdRelativo)
    end select
    response.end
end if

response.redirect("./")
%>
