<%
function validaNotificacao(notificacaoId)

end function

function clearNotificacoes(idNotificacao, idRelativo, statusNovo)
    db.execute("UPDATE notificacoes SET StatusID="&statusNovo&" WHERE NotificacaoIDRelativo="&treatvalzero(idRelativo)&" AND TipoNotificacaoID="&treatvalzero(idNotificacao))
end function
%>