<%

Class Devolucao

    function gerarDevolucao(InvoiceID, iteninvoice, accountId, TipoOperacao, MotivoDevolucao, DebitarCaixa, Observacao, contaID)

 ' se tiver CaixaID = 7
 ' Se não for o id da sys_financialcurrentaccounts gravar 1

  'SELECT * FROM sys_financialcurrentaccounts WHERE AccountType = 1 
 ' se tiver CaixaID = 7
 ' Se não for o id da sys_financialcurrentaccounts gravar 1
        accounts = Split(accountId, "_")

        name = accountName(accounts(0), accounts(1))&""

        if DebitarCaixa = "" then DebitarCaixa = "null" end if
        set totalItens = db.execute("select SUM((ValorUnitario - Desconto + Acrescimo) * Quantidade) as total from itensinvoice ii where ii.id in ( " & iteninvoice & " ) ")
        set allProcedimentos = db.execute("select GROUP_CONCAT(NomeProcedimento) as Procs from itensinvoice ii INNER join Procedimentos p ON ii.ItemID = p.id WHERE ii.id in ( " & iteninvoice & " ) ")
        
        Total = 0
        if not totalItens.eof then 
            Total = totalItens("total")
        end if

        NomeProcedimentosDevolvidos = ""
        if not allProcedimentos.eof then 
            NomeProcedimentosDevolvidos = allProcedimentos("Procs")
        end if

        itens = Split(iteninvoice, ",")
        for j = 0 to ubound(itens)
            iitem = itens(j)
            set RepasseSQL = db.execute("SELECT id,ItemContaAPagar FROM rateiorateios WHERE ItemInvoiceID = ("&iitem&") order by IFNULL(ItemContaAPagar,0) DESC")
            if not RepasseSQL.eof then
                if not isnull(RepasseSQL("ItemContaAPagar")) then
                %>
                    <script>
                    showMessageDialog('Existem contas a pagar gerado para o repasse. Exclua a conta antes de marcar o item como cancelado.');
                    </script>
                <%
                    'Response.End
                else
                    db.execute("DELETE FROM rateiorateios WHERE  ItemInvoiceID = ("&iitem&")")
                    %>
                    <script>
                    showMessageDialog('Repasses removidos.', 'warning');
                    </script>
                    <%
                end if
            end if
        next

        set devolucoes = db.execute("select * from devolucoes d where d.invoiceID = " & InvoiceID & " AND sysActive = 1")
        if not devolucoes.eof then 
            'update
            sqlDevolucao = "update devolucoes set motivoDevolucaoID = "&MotivoDevolucao&", tipoOperacao = "&TipoOperacao&", observacao = '"&Observacao&"', debitarCaixa = "&DebitarCaixa&", sysUser = "&session("User")&", totalDevolucao = "&treatvalzero(Total)&", AccountID="&treatvalnull(contaID)&" where invoiceID = "&InvoiceID&"  AND sysActive = 1 "
        else
            'insert
            sqlDevolucao = "insert into devolucoes(invoiceID, motivoDevolucaoID, tipoOperacao, observacao, debitarCaixa, sysUser, totalDevolucao, AccountID) values("&InvoiceID&", "&MotivoDevolucao&", "&TipoOperacao&", '"&Observacao&"', "&DebitarCaixa&", "&session("User")&", "&treatvalzero(Total)&", "&treatvalnull(contaID)&")"
        end if
        db.execute(sqlDevolucao)

        db.execute("update itensinvoice Set Executado = 'C', Associacao = null, ProfissionalID = 0, HoraExecucao = null, HoraFim = null  where id in ( " & iteninvoice & " ) ")

        set newdevolucoes = db.execute("select * from devolucoes d where d.invoiceID = " & InvoiceID & " AND sysActive = 1")
        db.execute("delete from devolucoes_itens where devolucoesID = " & newdevolucoes("id"))


        itens = Split(iteninvoice, ",")
        for i = 0 to ubound(itens)
            iitem = itens(i)
            db.execute("insert into devolucoes_itens(devolucoesID, itensInvoiceID) values( " & newdevolucoes("id") & ", " & iitem & ")")
            'i = i + 1
        next

        set planoDeContas = db.execute("select id from sys_financialexpensetype where Name = 'Devoluções' LIMIT 1")
        if planoDeContas.eof then 
            db.execute("insert into sys_financialexpensetype(Name, sysActive, sysUser) values('Devoluções', 1, "&session("User")&")")
            set planoDeContas = db.execute("select id from sys_financialexpensetype where Name = 'Devoluções' LIMIT 1")
        end if

        'Operação para DEVOLVER o dinheiro para o paciente
        if TipoOperacao = 1 then 
            
            'Não é necessário mais (pelo menos por enquanto) ao cancelar uma conta gerar uma CONTA A PAGAR para o PACINET

            ContasAPagarCancelamento = getConfig("ContasAPagarCancelamento")

            if ContasAPagarCancelamento then
                if newdevolucoes("invoiceAPagarID")&"" = "" then 
                    sqlInvoice = "insert into sys_financialinvoices(Name, AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, CD, sysActive, sysUser, sysDate, Description, Recurrence, RecurrenceType) values('Devolução', "&accounts(1)&", "&accounts(0)&", "&treatvalzero(Total)&", 1, 'BRL', "&session("UnidadeID")&", 'D', 1, "&session("User")&", curdate(), 'Gerado a partir de Devolução', 1, 'm')"
                    db.execute(sqlInvoice)

                    set invoice = db.execute("select id from sys_financialinvoices where AccountID = "&accounts(1)&" AND AssociationAccountID = "&accounts(0)&" order by id desc LIMIT 1")
                    idNewInvoice = invoice("id")
                    db.execute("update devolucoes set invoiceAPagarID = "&idNewInvoice&" where id = " & newdevolucoes("id"))
                    
                    DescricaoInvoice = "Devolução referente a ["&NomeProcedimentosDevolvidos&"] do dia " & Date

                    sqlItensInvoice = "insert into itensinvoice(InvoiceID, Quantidade, ItemID, ValorUnitario, Descricao, Executado, CategoriaID, Tipo, sysUser) values("&idNewInvoice&", 1, 0, "&treatvalzero(Total)&", '"&DescricaoInvoice&"', '',"&planoDeContas("id")&", 'O', "&session("User")&")"
                    db.execute(sqlItensInvoice)

                    sqlMovementBill = "insert into sys_financialmovement(Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, ValorPago, CaixaID, UnidadeID) " &_ 
                    " values('Devolução "& name &"', "&accounts(0)&", "&accounts(1)&", 0,0, 1, "&treatvalzero(Total)&", now(), 'D','Bill', 'BRL', -1, "&idNewInvoice&", 1, "&session("User")&",0, "&treatvalnull(session("CaixaID"))&","&session("UnidadeID")&" )"
                    db.execute(sqlMovementBill)

                    set newdevolucoes = db.execute("select * from devolucoes d where d.invoiceID = " & InvoiceID)

                else
                    sqlInvoice = "update sys_financialinvoices set AccountID = "&accounts(1)&", AssociationAccountID = "&accounts(0)&", Value = "&treatvalzero(Total)&", CompanyUnitID = "&session("UnidadeID")&", CD = 'D', sysUser = "&session("User")&" WHERE id = " & newdevolucoes("invoiceAPagarID")
                    db.execute(sqlInvoice)

                    sqlItensInvoice = "update itensinvoice set ValorUnitario = "&treatvalzero(Total)&" WHERE InvoiceID = " & newdevolucoes("invoiceAPagarID")
                    db.execute(sqlItensInvoice)

                    idNewInvoice = newdevolucoes("invoiceAPagarID")

                    'update
                    sqlMovementBill = "update sys_financialmovement set AccountAssociationIDCredit = "&accounts(0)&", AccountIDCredit = "&accounts(1)&", Value = "&treatvalzero(Total)&", ValorPago = "&treatvalzero(Total)&", CaixaID =  "&treatvalnull(session("CaixaID"))&" , UnidadeID = "&session("UnidadeID")&" where InvoiceID = " & idNewInvoice  &_ 
                        " AND AccountIDCredit = "&accounts(1)& " AND Type = 'Bill' "
                    db.execute(sqlMovementBill)
                end if

            else

                ' Temos que gerar um credito para o paciente
                'Executado = credCan(iteninvoice, "C")
                set dadosInv = db.execute("select i.AccountID, i.AssociationAccountID, sum(ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorItem from sys_financialinvoices i LEFT JOIN itensinvoice ii ON i.id=ii.InvoiceID WHERE ii.id in ("& iteninvoice&")")
                if not dadosInv.eof then
                    if ccur(dadosInv("ValorItem"))>0 then
                        idPagador = 0
                        idAccountCredit = session("CaixaID")
                        if Session("CaixaID")&"" <> "" then
                            idPagador = 7
                        else
                            idAccountCredit = contaID
                            idPagador = 1
                        end if
                        db.execute("insert into sys_financialmovement set Name='Devolução ("& iteninvoice &")', AccountAssociationIDCredit="&idPagador&", AccountIDCredit="& treatvalnull(idAccountCredit) &", AccountAssociationIDDebit="& dadosInv("AssociationAccountID") &", AccountIDDebit="& dadosInv("AccountID") &", PaymentMethodID=1, Value="& treatvalzero(dadosInv("ValorItem")) &", Date=curdate(), CD='T', Type='Transfer', Obs='{C"& ItemID &"}', Currency='', Rate=1, sysUser="&session("User")&", CaixaID="& treatvalnull(session("CaixaID")) &", UnidadeID="& treatvalzero(session("UnidadeID")) &"")
                    end if
                end if
                db.execute("insert into sys_financialmovement set Name='Cancelamento de serviço ("& iteninvoice &")', AccountAssociationIDCredit="& dadosInv("AssociationAccountID") &", AccountIDCredit="& dadosInv("AccountID") &", AccountAssociationIDDebit=0, AccountIDDebit=0, PaymentMethodID=1, Value="& treatvalzero(dadosInv("ValorItem")) &", Date=curdate(), CD='T', Type='Transfer', Obs='{C"& ItemID &"}', Currency='', Rate=1, sysUser="&session("User")&", CaixaID=null, UnidadeID="& treatvalzero(session("UnidadeID")) &"")
            end if
        elseif TipoOperacao = 0 then
            'if IsNumeric(iteninvoice) then
                Executado = credCan(iteninvoice, "C")
            'else
            '    itens = Split(iteninvoice, ",")
            '    for i = 0 to ubound(itens)
            '        iitem = itens(i)
            '        Executado = credCan(iitem, "C")
                    'i = i + 1
            '    next
            'end if
        end if
        cancelarReciboDevolucao(InvoiceID)
        gerarDevolucao = true
    end function

    function cancelarReciboDevolucao(InvoiceID)
        sqlExecute = "update recibos set Nome = CONCAT(Nome, ' [ CANCELADO ]'), sysActive = -1 where InvoiceID = " & InvoiceID
        db.execute(sqlExecute)
    end function

    function credCan(ItemID, SC)
        if SC<>"C" then
            sqlExecute = "delete from sys_financialmovement where Obs='{C"& ItemID &"}'"
            db.execute(sqlExecute)

            credCan=SC
        else
            'set vcaMovCanc = db.execute("select * from sys_financialmovement m where Obs='{C"& ItemID &"}'")
            'if vcaMovCanc.eof then
                set dadosInv = db.execute("select i.AccountID, i.AssociationAccountID, sum(ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorItem from sys_financialinvoices i LEFT JOIN itensinvoice ii ON i.id=ii.InvoiceID WHERE ii.id in ("& ItemID&")")
                if not dadosInv.eof then
                    if ccur(dadosInv("ValorItem"))>0 then
                        db.execute("insert into sys_financialmovement set Name='Crédito de cancelamento ("& ItemID &")', AccountAssociationIDCredit="& dadosInv("AssociationAccountID") &", AccountIDCredit="& dadosInv("AccountID") &", AccountAssociationIDDebit=0, AccountIDDebit=0, PaymentMethodID=1, Value="& treatvalzero(dadosInv("ValorItem")) &", Date=curdate(), CD='', Type='Transfer', Obs='{C"& ItemID &"}', Currency='', Rate=1, sysUser="&session("User")&", CaixaID="& treatvalnull(session("CaixaID")) &", UnidadeID="& treatvalzero(session("UnidadeID")) &"")
                    end if
                end if
            'end if
            credCan=SC
        end if
    end function

    function validarRegrasExcluirPagamento(pInvoiceID,ByRef MsgValidacao)

        validarRegrasExcluirPagamento = true
        'Validar se esta invoice ja teve devolução em dinheiro de algum valor
        sqlDevolucao = "select count(id) total from devolucoes where invoiceID = " & pInvoiceID & " and sysActive = 1 and tipoOperacao = 1"
        set rsDevolucao = db.execute(sqlDevolucao)
        if not rsDevolucao.eof then 
            if ccur(rsDevolucao("total")) > 0 then 
                validarRegrasExcluirPagamento = false
                MsgValidacao = "Já existe devoluções para esta conta."
            end if
        end if

         set sqlValidacao = db.execute("SELECT COUNT(*) > 0 existem FROM nfe_notasemitidas WHERE InvoiceID = "&pInvoiceID&" AND situacao = 1;")

         if not sqlValidacao.eof then
            if sqlValidacao("existem") then
                validarRegrasExcluirPagamento = false
                MsgValidacao = "Existe nota emitida para esta conta."
            end if
         end if

         set sqlValidacao = db.execute("SELECT count(*) > 0 existem FROM rateiorateios JOIN itensinvoice ON itensinvoice.id = rateiorateios.ItemInvoiceID WHERE itensinvoice.InvoiceID = "&pInvoiceID&";")
         if not sqlValidacao.eof then
             if sqlValidacao("existem") then
                 MsgValidacao = "Existe repasse para esta conta."
             end if
          end if


        if validarRegrasExcluirPagamento then 
            sqlDevlucao = "select totalDevolucao from devolucoes where invoiceID = " & pInvoiceID & " and sysActive = 1"
            set rsDevolucao = db.execute(sqlDevolucao)
            if not rsDevolucao.eof then 

            end if

        end if
    end function

    function replaceTagsDevolucao(textoModeloDevolucao, InvoiceID) 

        'Retorna os dados da devolucao 
        sqlDadosdaInvoice = "SELECT mov.date," &_
	                        " d.id as iddevolucao, " &_
                            " invoice.id as invoiceID, " &_
                            "    totalDevolucao, " &_
                            "    u.Nome AS usuario, " &_
                            "    clin.id AS unidadeID," &_
                            "    clin.nome AS unidade," &_
                            "    d.sysDate, " &_
                            "    d.sysUser, " &_
                            " concat('R$ ',FORMAT((SELECt SUM(ii.Quantidade * (ii.ValorUnitario + ii.Acrescimo - ii.Desconto)) FROM itensinvoice as ii WHERE ii.invoiceid = d.invoiceID), 2, 'pt_BR')) AS valor, " &_
                            " IF(tipoOperacao = 1,'Devolver (Dinheiro)', 'Deixar de Crédito') op ," &_
                            " invoice.AccountID,  " &_  
                            " invoice.AssociationAccountID,  " &_
                            " nfe.numeronfse, " &_
                            " nfe.numero " &_                    
                            " FROM  devolucoes d " &_
                            " INNER JOIN motivo_devolucao md ON (md.id = d.motivoDevolucaoID) " &_ 
                            " INNER JOIN sys_financialmovement AS mov ON (mov.InvoiceID = d.InvoiceID)" &_
                            " INNER JOIN cliniccentral.licencasusuarios AS u ON (u.id = d.sysUser )" &_
                            " INNER JOIN sys_financialdiscountpayments  AS disc ON (disc.InstallmentID= mov.id)" &_
                            " INNER JOIN sys_financialmovement AS mov2 ON (mov2.id=disc.MovementID)" &_
                            " INNER JOIN sys_financialinvoices AS invoice ON (invoice.id = d.InvoiceID)" &_
                            " LEFT JOIN nfe_notasemitidas  AS nfe ON (nfe.InvoiceID = invoice.id) " &_
                            " INNER JOIN (SELECT id  *-1 AS id, unitname AS nome from sys_financialcompanyunits" &_
                            "             UNION" &_
                            "             SELECT 0 AS id, nomeempresa AS nome FROM empresa" &_
                            "             UNION" &_
                            "             SELECT id AS id, NomeProfissional FROM profissionais) AS clin ON (clin.id  = invoice.CompanyUnitID)" &_
                            " WHERE d.invoiceID =  " & InvoiceID & "  " &_
                            " ORDER BY mov2.Date DESC LIMIT 1"
        set rsDevolucao = db.execute(sqlDadosdaInvoice)
        
        'replaceTags(valor, PacienteID, UserID, UnidadeID)
        impresso = replaceTags(textoModeloDevolucao, rsDevolucao("AssociationAccountID")&"_"&rsDevolucao("AccountID") ,rsDevolucao("sysUser"), rsDevolucao("unidadeID"))

        impresso = replace(impresso,"[Devolucoes.unidade]",rsDevolucao("unidade"))

        if rsDevolucao("invoiceID") <> "" then
            impresso = replace(impresso,"[Devolucoes.guianro]",rsDevolucao("invoiceID"))
        else 
            impresso = replace(impresso,"[Devolucoes.guianro]","Não Informado")
        end if 

        if rsDevolucao("numero") <> "" then
            impresso = replace(impresso,"[Devolucoes.rpa]",rsDevolucao("numero"))
        else
            impresso = replace(impresso,"[Devolucoes.rpa]","Não Informado")
        end if 

        if rsDevolucao("numeronfse") <> "" then
            impresso = replace(impresso,"[Devolucoes.nfe]",rsDevolucao("numeronfse"))
        else 
            impresso = replace(impresso,"[Devolucoes.nfe]","Não Informado")
        end if

        impresso = replace(impresso,"[Devolucoes.Valor]",rsDevolucao("valor"))
        impresso = replace(impresso,"[Devolucoes.data]",rsDevolucao("date"))     
        replaceTagsDevolucao = impresso

    end function

End Class
%>