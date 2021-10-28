<!--#include file="connect.asp"-->
<%

AcaoID= req("Acao")
TransferenciaFilaID= req("I")
NotificacaoID= req("NotificacaoID")


set NotificacaoSQL = db.execute("SELECT StatusID, NotificacaoIDRelativo, TipoNotificacaoID FROM notificacoes WHERE id="&treatvalzero(NotificacaoID))


if not NotificacaoSQL.eof then
    StatusAtualID = NotificacaoSQL("StatusID")
    NotificacaoIDRelativo = NotificacaoSQL("NotificacaoIDRelativo")
    TipoNotificacaoID = NotificacaoSQL("TipoNotificacaoID")

    if StatusAtualID=3 or StatusAtualID=4 then
        response.write("Transação já aprovada")
        Response.End
    end if

    set NotificacaoResolvidaSQL = db.execute("SELECT id FROM notificacoes WHERE StatusID IN (3,4) AND TipoNotificacaoID="&TipoNotificacaoID&" AND NotificacaoIDRelativo="&NotificacaoIDRelativo)
    if not NotificacaoResolvidaSQL.eof then
        db.execute("UPDATE notificacoes SET StatusID=4 WHERE StatusID not in (3) AND TipoNotificacaoID="&TipoNotificacaoID&" AND NotificacaoIDRelativo="&NotificacaoIDRelativo)
        response.write("Outra notificação já foi aprovada.")
        Response.End
    end if

    if AcaoID="1" then
        sql  = "SELECT Descricao, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CaixaID, sysUser, UnidadeID, 'Transfer' FROM filatransferencia WHERE id='"&TransferenciaFilaID&"'"
        set fila  = db.execute(sql)
        if not fila.eof then
            ' ######################### BLOQUEIO FINANCEIRO ########################################
            UnidadeID = fila("UnidadeID")
            contabloqueadadebt = verificaBloqueioConta(2, 1, fila("AccountIDDebit"), UnidadeID,fila("Date"))
            contabloqueadacred = verificaBloqueioConta(2, 1, fila("AccountIDCredit"), UnidadeID,fila("Date"))
            if contabloqueadacred = "1" or contabloqueadadebt = "1" then
                response.write("Esta conta está BLOQUEADA e não pode ser alterada!")
                response.end
            end if
            ' #####################################################################################
        end if

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
end if
%>