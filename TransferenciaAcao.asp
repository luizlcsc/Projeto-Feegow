<!--#include file="connect.asp"-->
<%

AcaoID= req("Acao")
TransferenciaFilaID= req("I")
NotificacaoID= req("NotificacaoID")


if AcaoID="1" then
    db.execute("INSERT INTO sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CaixaID, sysUser, UnidadeID, Type) "&_
    " (SELECT Descricao, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CaixaID, sysUser, UnidadeID, 'Transfer' FROM filatransferencia WHERE id="&TransferenciaFilaID&")" )

    set MovementSQL = db.execute("SELECT id FROM sys_financialmovement ORDER BY id DESC LIMIT 1")

    MovementID=MovementSQL("id")

    AcaoID=3
end if

db.execute("UPDATE filatransferencia SET MovementID="&treatvalnull(MovementID)&", Aprovado="&AcaoID&", DataResposta=NOW() WHERE id="&TransferenciaFilaID)
db.execute("UPDATE notificacoes SET StatusID=3 WHERE id="&NotificacaoID)

set NotificacaoSQL = db.execute("SELECT * FROM notificacoes WHERE id="&NotificacaoID)
if not NotificacaoSQL.eof then
    TipoNotificacaoID= NotificacaoSQL("TipoNotificacaoID")
    NotificacaoIDRelativo= NotificacaoSQL("NotificacaoIDRelativo")
    CriadoPorID= NotificacaoSQL("CriadoPorID")

    db.execute("UPDATE notificacoes SET StatusID=4 WHERE TipoNotificacaoID="&treatvalzero(TipoNotificacaoID)&" AND NotificacaoIDRelativo="&treatvalzero(NotificacaoIDRelativo)&" AND CriadoPorID="&treatvalzero(CriadoPorID)&" AND StatusID=1")

end if

call updateUserNotifications(session("User"))
%>