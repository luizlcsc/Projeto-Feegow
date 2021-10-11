<%

function LoadSessionCaixa()

    set plast = db.execute(" SELECT caixa.*,subcaixa.id as subcaixa FROM caixa                      "&chr(13)&_
                           " LEFT JOIN subcaixa ON subcaixa.caixaID = caixa.id                      "&chr(13)&_
                           "                   AND isnull(subcaixa.dtFechamento)                    "&chr(13)&_
                           " WHERE TRUE                                                             "&chr(13)&_
                           "  AND   "&session("User")&" in (caixa.sysUser,subcaixa.sysUser)         "&chr(13)&_
                           "  AND  isnull(caixa.dtFechamento);                                      ")

    session("CaixaID") = ""
    session("SubCaixaID") = ""

    IF NOT plast.EOF THEN
        session("CaixaID")    = plast("id")
        session("SubCaixaID") = plast("subcaixa")&""
    END IF

end function

FUNCTION CaixaTemporario(invoiceID)

        IF session("SubCaixaID") = "" THEN
            CaixaTemporario = "1"
            EXIT FUNCTION
        END IF


        sql = " SELECT count(*) = 0 or                                                                             "&chr(13)&_
              "        SUM(bill.SubCaixaID is not null AND coalesce(notificacoes.StatusID = 3,false) > 0) as valido"&chr(13)&_
              " FROM sys_financialinvoices                                                                         "&chr(13)&_
              " LEFT JOIN sys_financialmovement as bill ON bill.InvoiceID  = sys_financialinvoices.id              "&chr(13)&_
              " LEFT JOIN sys_financialdiscountpayments ON sys_financialdiscountpayments.InstallmentID = bill.id   "&chr(13)&_
              " LEFT JOIN sys_financialmovement as pay  ON pay.id = sys_financialdiscountpayments.MovementID       "&chr(13)&_
              " LEFT JOIN subcaixa                      ON subcaixa.caixaID = pay.SubCaixaID                       "&chr(13)&_
              "                                        AND subcaixa.dtFechamento IS NULL                           "&chr(13)&_
              " LEFT JOIN notificacoes                  ON notificacoes.NotificacaoIDRelativo = pay.id             "&chr(13)&_
              "                                        AND notificacoes.TipoNotificacaoID     = 5                  "&chr(13)&_
              " WHERE sys_financialinvoices.id = "&invoiceID&"                                                     "&chr(13)&_
              " AND  COALESCE(NULLIF(bill.SubCaixaID = '"&session("SubCaixaID")&"',''),FALSE);                       "

        set validado = db.execute(sql)


        CaixaTemporario = validado("valido") = "1"
END FUNCTION


function MsgSubCaixaByMov(id)
    sqlSubcaixa = " INSERT INTO notificacoes(TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, CriadoPorID, Prioridade, StatusID, Metadata)      "&chr(13)&_
                  " SELECT 5,caixa.sysUser,sys_financialmovement.id,subcaixa.sysUser,1,1                                                            "&chr(13)&_
                  "      ,CONCAT('                                                                                                                  "&chr(13)&_
                  " <div><b>Subcaixa:</b> [USUARIO_CRIADOR.NOME]</div>                                                                              "&chr(13)&_
                  " <div><b>Forma de Pagamento:</b>',sys_financialpaymentmethod.PaymentMethod,' </div>                                              "&chr(13)&_
                  " <div><b>Valor Total:</b> R$ ',FORMAT(sys_financialmovement.Value, 2,'de_DE'),'</div>                                            "&chr(13)&_
                  " <div><b>Valor Recebido:</b> R$ ',coalesce(FORMAT(sys_financialmovement.ValorRecebido, 2,'de_DE'),0),'</div>                     "&chr(13)&_
                  " <div><b>Troco:</b> R$ ',coalesce(FORMAT(sys_financialmovement.ValorRecebido - sys_financialmovement.Value, 2,'de_DE'),0),'</div>"&chr(13)&_
                  " ')                                                                                                                              "&chr(13)&_
                  "     FROM sys_financialmovement                                                                                                  "&chr(13)&_
                  "     JOIN sys_financialpaymentmethod ON sys_financialpaymentmethod.id = sys_financialmovement.PaymentMethodID                    "&chr(13)&_
                  "     JOIN subcaixa ON subcaixa.id = sys_financialmovement.SubCaixaID                                                             "&chr(13)&_
                  "     JOIN caixa    ON caixa.id = sys_financialmovement.CaixaID                                                                "&chr(13)&_
                  "    WHERE sys_financialmovement.id = "&id&";                                                                                       "
    set plast = db.execute(sqlSubcaixa)
end function

function notificarSangria()

        IF getConfig("ValordaSangria") = "" THEN
            Exit Function
        END IF

        SaldoFinalCaixa= 0
        set caixa = db.execute("SELECT * FROM caixa where sysUser="&session("User")&" and isnull(dtFechamento)")

        IF caixa.eof THEN
            Exit Function
        END IF

        set mov = db.execute("select m.PaymentMethodID,"&_
        "-777 as Recebimentos, "&_
        "-777 as Pagamentos, "&_
        " pm.PaymentMethod "&_
        " from sys_financialmovement m "&_
        " left join sys_financialpaymentmethod pm on pm.id=m.PaymentMethodID "&_
        " where m.Type<>'Bill' and (AccountAssociationIDDebit=7 and AccountIDDebit="&caixa("id")&" or AccountAssociationIDCredit=7 and AccountIDCredit="&caixa("id")&" ) group by m.PaymentMethodID "&_
        " UNION ALL "&_
        "select mOutros.PaymentMethodID, ifnull(sum(mOutros.Value),0), 0, pmOutros.PaymentMethod from sys_financialmovement mOutros "&_
        " left join sys_financialpaymentmethod pmOutros on pmOutros.id=mOutros.PaymentMethodID "&_
        "where mOutros.PaymentMethodID not in(1, 2) and mOutros.CaixaID="&caixa("id")&_
        " group by mOutros.PaymentMethodID")
        SaldoFinalFinal = 0
        while not mov.eof
            Recebimentos = mov("Recebimentos")
            Pagamentos = ccur(mov("Pagamentos"))
            if Recebimentos=-777 then
                set pRec = db.execute("select ifnull(sum(Value), 0) Recebimentos from sys_financialmovement where (Type='Pay' or Type='Transfer') and AccountAssociationIDDebit=7 and AccountIDDebit="&caixa("id")&" and PaymentMethodID="& mov("PaymentMethodID"))
                Recebimentos = pRec("Recebimentos")
            end if
            if Pagamentos=-777 then
                set pPag = db.execute("select ifnull(sum(Value), 0) Pagamentos from sys_financialmovement where (Type='Pay' or Type='Transfer') and AccountAssociationIDCredit=7 and AccountIDCredit="&caixa("id")&" and PaymentMethodID="& mov("PaymentMethodID"))
                Pagamentos = pPag("Pagamentos")
            end if

            SaldoFinal = Recebimentos-Pagamentos
            SaldoFinalFinal = SaldoFinalFinal+SaldoFinal

            if mov("PaymentMethodID")=1 then
                SaldoFinalCaixa= SaldoFinalCaixa+SaldoFinal
            end if
        mov.movenext
        wend
        mov.close
        set mov=nothing

        IF ccur(getConfig("ValordaSangria")) <= ccur(SaldoFinalCaixa) THEN
            db.execute("UPDATE notificacoes SET StatusID = 3 WHERE UsuarioID = "&session("User")&" and TipoNotificacaoID = 11;")
            db.execute("INSERT INTO notificacoes(TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, CriadoPorID, Prioridade, StatusID, Metadata)VALUES(11,"&session("User")&","&session("User")&","&session("User")&",1,1,'')")
        END IF

end function

%>