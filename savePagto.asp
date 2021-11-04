<!--#include file="connect.asp"-->
<!--#include file="Classes/ApiClient.asp"-->
<!--#include file="sqls/sqlUtils.asp"-->

<%
T = req("T")
if ref("ValorPagto")>0 then
    ValorPagto = ccur(ref("ValorPagto"))
else
    ValorPagto = ccur(0)
end if
MetodoID = ref("MetodoID")
AccountID=ref("AccountID")
'verifica se acc id eh array
if instr(AccountID, ",") then
    AccountIDSplt = split(AccountID,",")
    AccountID=AccountIDSplt(0)
end if

if ref("DataPagto")&""="" then
    DataPagto = date()
else
    DataPagto = cdate(ref("DataPagto"))
end if

splAccountID = split(AccountID, "_")
AccountIDInvoice = splAccountID(1)
AssociationAccountIDInvoice = splAccountID(0)

if (MetodoID="1" or MetodoID="2") and session("CaixaID")<>"" then
    Destino = "7_"&session("CaixaID")
else
    if ref("ContaID")<>"" then
        Destino = "1_"&ref("ContaID")
    else
        if lcase(session("Table"))="profissionais" then
            Destino = "5_"&session("idInTable")
        else
            Destino = "4_"&session("idInTable")
        end if
    end if
end if
if MetodoID="3" then
    Destino = ref("ContaRectoID_3")
end if
splDestino = split(Destino, "_")
DestinoAssID = splDestino(0)
DestinoID = splDestino(1)


if T="C" then
	AccountAssociationIDCredit = AssociationAccountIDInvoice
	AccountIDCredit = AccountIDInvoice
	AccountAssociationIDDebit = DestinoAssID
	AccountIDDebit = DestinoID
	reverse = "D"
else
	AccountAssociationIDCredit = DestinoAssID
	AccountIDCredit = DestinoID
	AccountAssociationIDDebit = AssociationAccountIDInvoice
	AccountIDDebit = AccountIDInvoice
	reverse = "C"
end if

MetodoID = ccur(ref("MetodoID"))
sufixo = "_"&MetodoID

' ######################### BLOQUEIO FINANCEIRO ########################################
UnidadeID = treatvalzero(ref("UnidadeIDPagto"))
contabloqueadacred = verificaBloqueioConta(2, 1, AccountIDCredit, UnidadeID,DataPagto)
contabloqueadadebt = verificaBloqueioConta(2, 1, AccountIDDebit, UnidadeID,DataPagto)
if contabloqueadacred = "1" or contabloqueadadebt = "1" then
    retorno  = " alert('Esta conta está BLOQUEADA e não pode ser alterada!'); " &_
               " $('.parcela').prop('checked', false); $('#pagar').fadeOut(); " &_
               " geraParcelas('N'); "
    response.write(retorno)
    response.end
end if
' #####################################################################################


insMov = "insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Obs, Currency, Rate, CaixaID, UnidadeID, sysUser) values ('Pagamento', '"&AccountAssociationIDCredit&"', '"&AccountIDCredit&"', '"&AccountAssociationIDDebit&"', '"&AccountIDDebit&"', "&ref("MetodoID")&", '"&treatVal(ValorPagto)&"', "&myDatenull(DataPagto)&", '"&reverse&"', 'Pay', '"&ref("Obs")&"', '"&ref("PaymentCurrency")&"', 1, "&treatvalnull(session("CaixaID"))&", "&treatvalzero(ref("UnidadeIDPagto"))&", "&session("User")&")"
'response.Write(insMov)

db.execute(insMov)
LastMovementIDQ = db.execute("SELECT LAST_INSERT_ID() as Last")
LastMovementID = LastMovementIDQ("last") 
call gravaLog(insMov, "AUTO")

webhookJson = "{ ""forma_pagamento_id"": """&ref("MetodoID")&""", ""valor"": """&treatVal(ValorPagto)&""", ""data_recebimento"": """&now()&""", ""id"": "&LastMovementID&", ""unidade_id"": """&ref("UnidadeIDPagto")&""" }"

Set api = new ApiClient

call api.addWebhookToQueue(112, webhookJson)


if T="C" then
	select case MetodoID
	case 2'check
		if ref("Cashed"&sufixo)="" then
			Cashed=0
			StatusID = 1
			'vai ter que ter uma verifica��o de pra qual conta foi o cheque pra colocar depositado, transferido, em caixa
			'...
		else
			Cashed=1
			StatusID = 4
		end if
        sqlCheque = "insert into sys_financialReceivedChecks (BankID, CheckNumber, Holder, Document, CheckDate, Cashed, AccountAssociationID, AccountID, MovementID, StatusID, sysUser, Valor, Branch, Account) values ('"&ref("BankID"&sufixo)&"', '"&ref("CheckNumber"&sufixo)&"', '"&ref("Holder"&sufixo)&"', '"&ref("Document"&sufixo)&"', '"&myDate(ref("CheckDate"&sufixo))&"', "&Cashed&", "&DestinoAssID&", "&DestinoID&", "&LastMovementID&", "&StatusID&", "&session("User")&", "&treatvalzero(ValorPagto)&", '"&ref("Branch"&sufixo)&"', '"&ref("Account"&sufixo)&"')"
  '      response.Write( sqlCheque )
		db.execute(sqlCheque)
		'grava o primeiro status do cheque recebido
		set getChequeID = db.execute("select id from sys_financialreceivedchecks where sysUser="&session("User")&" order by id desc LIMIT 1")
		ChequeID = getChequeID("id")
		db.execute("update sys_financialmovement set ChequeID="&ChequeID&" where id="&LastMovementID)
        sqlCheque = "insert into chequemovimentacao (ChequeID, MovimentacaoID, Data, StatusID, sysUser) values ("&ChequeID&", "&LastMovementID&", '"&myDate(DataPagto)&"', "&StatusID&", "&session("User")&")"
		db.execute(sqlCheque)
        call gravaLog(sqlCheque, "AUTO")

	case 4'bank bill
		if ref("BankFee"&sufixo)<>"" then
			if ccur(ref("BankFee"&sufixo))>0 then
				db.execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, MovementAssociatedID, Currency, Rate, sysUser) values ('Taxa boleto', '"&AccountAssociationIDDebit&"', '"&AccountIDDebit&"', 0, 0, 0, '"&treatVal(ref("BankFee"&sufixo))&"', '"&myDate(DataPagto)&"', 'C', 'Fee', "&LastMovementID&", '"&ref("PaymentCurrency")&"', 1, "&session("User")&")")
			end if
		end if

	case 8, 9'credit card
	    sqlCart= "insert into sys_financialCreditCardTransaction (TransactionNumber, AuthorizationNumber, BandeiraCartaoID, MovementID, Parcelas) values ('"&ref("TransactionNumber"&sufixo)&"', '"&ref("AuthorizationNumber"&sufixo)&"', "&treatvalzero(ref("BandeiraCartaoID"&sufixo))&", "&LastMovementID&","&ref("NumberOfInstallments"&sufixo)&")"
		db.execute(sqlCart)
        call gravaLog(sqlCart, "AUTO")
		set getTransactionID = db.execute("select * from sys_financialCreditCardTransaction order by id desc LIMIT 1")
		TransactionID = getTransactionID("id")         

		'credit card account informations
		set getAssociation = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&AccountAssociationIDDebit)
		if not getAssociation.eof then
			set getAccountData = db.execute("select * from "&getAssociation("table")&" where id="&AccountIDDebit)

            requestBandeiraCartaoSelecionado = ref("BandeiraCartaoID"&sufixo)
            requestNumeroParcelas = ref("NumberOfInstallments"&sufixo)

            queryTaxa = getTaxaAtual(DestinoID,LastMovementID,requestNumeroParcelas)
            set RetornoTaxaAtual2 = db.execute(queryTaxa)
            taxaAtual= ""
            taxaAtual = RetornoTaxaAtual2("taxaAtual")

			if not getAccountData.EOF then
                if AccountAssociationIDDebit = 1 then
                    PercentageDeducted = taxaAtual
                else
                    PercentageDeducted = 0
                end if             

				DaysForCredit = getAccountData("DaysForCredit")
				NumberOfInstallments = ccur(ref("NumberOfInstallments"&sufixo))
				c=0
				cardInstallmentValue = ccur(ValorPagto)/NumberOfInstallments
				DateToReceive = DataPagto

				while c<NumberOfInstallments
					c=c+1
					if isnull(DaysForCredit) or DaysForCredit="" or not isnumeric(DaysForCredit) then
					    DaysForCredit = 30
					end if

					if not isnull(DateToReceive) and DateToReceive<>"" and isdate(DateToReceive) then
						DateToReceive = dateAdd("d", DaysForCredit, DateToReceive)
						if weekday(DateToReceive)=1 then
							thisDateToReceive=dateAdd("d", 1, DateToReceive)
						elseif weekday(DateToReceive)=7 then
							thisDateToReceive=dateAdd("d", 2, DateToReceive)
						else
							thisDateToReceive=DateToReceive
						end if
					end if
					db.execute("insert into sys_financialCreditCardReceiptInstallments (DateToReceive, Fee, Value, TransactionID, InvoiceReceiptID, Parcela) values ("&myDatenull(thisDateToReceive)&", "&PercentageDeducted&", "&treatValnull(cardInstallmentValue)&", "&TransactionID&", 0, "&c&")")
				wend
			end if
		end if
	end select
else
	select case ccur(ref("MetodoID"))
	case 2'check
		if ref("Cashed"&sufixo)="" then
			Cashed=0
		else
			Cashed=1
		end if

   'ex. do C:     sqlCheque = "insert into sys_financialReceivedChecks (BankID, CheckNumber, Holder, Document, CheckDate, Cashed, AccountAssociationID, AccountID, MovementID, StatusID, sysUser, Valor) values ('"&ref("BankID"&sufixo)&"', '"&ref("CheckNumber"&sufixo)&"', '"&ref("Holder"&sufixo)&"', '"&ref("Document"&sufixo)&"', '"&myDate(ref("CheckDate"&sufixo))&"', "&Cashed&", "&DestinoAssID&", "&DestinoID&", "&LastMovementID&", "&StatusID&", "&session("User")&", "&treatvalzero(ValorPagto)&")"
        sqlCheque = "insert into sys_financialIssuedChecks (CheckNumber, CheckDate, Cashed, AccountAssociationID, AccountID, MovementID) values ('"&ref("CheckNumber"&sufixo)&"', '"&myDate(ref("CheckDate"&sufixo))&"', "&Cashed&", "&DestinoAssID&", "&DestinoID&", "&LastMovementID&")"
		db.execute(sqlCheque)
		call gravaLog(sqlCheque, "AUTO")
        set getChequeID = db.execute("select id from sys_financialissuedchecks order by id desc limit 1")
		ChequeID = getChequeID("id")
		db.execute("update sys_financialmovement set ChequeID="&ChequeID&" where id="&LastMovementID)
	case 5, 6, 7
		if ref("BankFee"&sufixo)<>"" then
			if ccur(ref("BankFee"&sufixo))>0 then
				db.execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, MovementAssociatedID, Currency, Rate, sysUser) values ('Taxa de transfer&ecirc;ncia', '"&AccountAssociationIDCredit&"', '"&AccountIDCredit&"', 0, 0, 0, '"&treatVal(ref("BankFee"&sufixo))&"', '"&myDate(DataPagto)&"', 'C', 'Fee', "&LastMovementID&", '"&ref("PaymentCurrency")&"', 1, "&session("User")&")")
			end if
		end if
	case 10
		db.execute("insert into sys_financialCreditCardTransaction (TransactionNumber, AuthorizationNumber, BandeiraCartaoID, MovementID, Parcelas) values ('"&ref("TransactionNumber"&sufixo)&"', '"&ref("AuthorizationNumber"&sufixo)&"',"&treatvalzero(ref("BandeiraCartaoID"&sufixo))&", "&LastMovementID&", "&ref("NumberOfInstallments"&sufixo)&")")
		set getTransactionID = db.execute("select * from sys_financialCreditCardTransaction order by id desc LIMIT 1")
		TransactionID = getTransactionID("id")

		'credit card account informations
		set getAssociation = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&DestinoAssID)

        if 0 then

            'aqui faz a adicao de um item na fatura do cartao de credito
            set ContaCorrenteSQL = db.execute("SELECT * FROM sys_financialcurrentaccounts WHERE id = "&AccountIDCredit)

            if not ContaCorrenteSQL.eof then

                MelhorDia = ContaCorrenteSQL("BestDay")
                Vencimento = ContaCorrenteSQL("DueDay")

                if isnumeric(MelhorDia) and not isnull(MelhorDia) then
                    MelhorDia = ccur(MelhorDia)
                else
                    MelhorDia = 1
                end if

                if isnumeric(Vencimento) and not isnull(Vencimento) then
                    Vencimento = ccur(Vencimento)
                else
                    Vencimento = 1
                end if


                DataFechamentoFatura = MelhorDia&"/"&month(DataPagto)&"/"&year(DataPagto)
                DataVencimento = Vencimento&"/"&month(DataPagto)&"/"&year(DataPagto)

                while not isdate(DataFechamentoFatura)
                    DataFechamentoFatura = (MelhorDia -1)&"/"&month(DataPagto)&"/"&year(DataPagto)
                wend
                while not isdate(DataVencimento)
                    DataVencimento = (Vencimento -1)&"/"&month(DataPagto)&"/"&year(DataPagto)
                wend
                DataFechamentoFatura = cdate(DataFechamentoFatura)
                DataVencimento = cdate(DataVencimento)

                if DataFechamentoFatura <= DataPagto then
                   DataFechamentoFatura = dateadd("m", 1, DataFechamentoFatura)
                   DataVencimento = dateadd("m", 1, DataVencimento)
                end if

            end if

            if not getAssociation.eof then
                set getAccountData = db.execute("select * from "&getAssociation("table")&" where id="&DestinoID)
                if not getAccountData.EOF then
                    DueDay = getAccountData("DueDay")
                    NumberOfInstallments = ccur(ref("NumberOfInstallments"&sufixo))
                    c=0
                    cardInstallmentValue = ccur(ValorPagto)/NumberOfInstallments

                    DateToPayFixed = DataVencimento
                    while c<NumberOfInstallments
                        c=c+1
                        DateToPay = DateToPayFixed


                        if weekday(DateToPay)=1 then
                            DateToPay=dateAdd("d", 1, DateToPay)
                        elseif weekday(DateToPay)=7 then
                            DateToPay=dateAdd("d", 2, DateToPay)
                        end if


                        'FATURA DO CARTAO

                        set FaturaExisteSQL = db.execute("SELECT * FROM sys_financialcreditcardpaymentinstallments fcpi LEFT JOIN sys_financialcreditcardtransaction fct ON fct.id = fcpi.TransactionID LEFT JOIN sys_financialmovement fm ON fm.id = fct.MovementID WHERE fm.PaymentMethodID =10 AND fm.AccountIDCredit = "&AccountIDCredit&" AND fm.AccountAssociationIDCredit = 1 AND fcpi.ItemInvoiceID IS NOT NULL AND MONTH(fcpi.DateToPay) = "&month(DateToPay)&" AND YEAR(fcpi.DateToPay) = "&year(DateToPay))
                        ValorFatura = treatvalzero(ref("ValorParcela"))

                        if not FaturaExisteSQL.eof then
                            'Fatura ja existe, atualizar valor da fatura
                            ItemFaturaID = FaturaExisteSQL("ItemInvoiceID")
                            set InvoiceSQL = db.execute("SELECT InvoiceID FROM itensinvoice WHERE id="&ItemFaturaID)
                            InvoiceID = InvoiceSQL("InvoiceID")

                            db.execute("update itensinvoice SET ValorUnitario = ValorUnitario + "&ValorFatura & " WHERE id ="&ItemFaturaID)
                            db.execute("update sys_financialmovement SET Value=Value +"&ValorFatura&" WHERE InvoiceID="&InvoiceID)
                            db.execute("update sys_financialinvoices SET Value = Value + "& ValorFatura & " where id="&InvoiceID)
                        else
                            'Fatura nao existe, criar
                            NomeFatura = "Fatura do cartão ("&monthname(month(DateToPay)) &"/"& year(DateToPay)&")"
                            sqlfatura = "insert INTO sys_financialinvoices (Name, AccountID, AssociationAccountID, Value, Tax,currency,CompanyUnitID, recurrence,recurrencetype, CD, sysActive, sysUser, CaixaID,sysDate) VALUES ('"&NomeFatura&"', "&AccountIDCredit&",1, "&ValorFatura&",1,'BRL' ,"&treatvalzero(ref("UnidadeIDPagto"))&", 1,'m', 'D',1,"&session("User")&","&treatvalnull(session("CaixaID"))&", "&mydatenull(DateToPay)&")"

                            db.execute(sqlfatura)
                            call gravaLog(sqlCheque, "AUTO")
                            
                            set InvoiceSQL = db.execute("SELECT id FROM sys_financialinvoices ORDER BY id DESC LIMIT 1")
                            InvoiceID = InvoiceSQL("id")
                            ' item
                            sqlIntem = "insert itensinvoice SET InvoiceID="&InvoiceID&", Tipo='O', Quantidade=1,CategoriaID=0, ItemID=0, ValorUnitario="&ValorFatura&", Descricao='"&NomeFatura&"',sysUser="&session("User")&", sysDate=now(), Associacao=0"
                            db.execute(sqlIntem)

                            call gravaLog(sqlIntem, "AUTO")
                            set ItemInvoiceSQL = db.execute("SELECT id FROM itensinvoice ORDER BY id DESC LIMIT 1")
                            ItemFaturaID = ItemInvoiceSQL("id")

                            db.execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, CaixaID, UnidadeID) values (0, 0, 1, "& AccountIDCredit &", "& ValorFatura&", "&mydatenull(DateToPay)&", 'D', 'Bill', 'BRL', 1, "& InvoiceID &", 1, "& session("User") &", "& treatvalnull(session("CaixaID")) &", "& treatvalzero(ref("UnidadeIDPagto")) &")")

                        end if

                        db.execute("insert into sys_financialCreditCardPaymentInstallments (DateToPay, Value, TransactionID, ItemInvoiceID,Parcela) values ('"&myDate(DateToPay)&"', '"&treatVal(cardInstallmentValue)&"', "&TransactionID&", "&ItemFaturaID&","&c&")")
                        DateToPayFixed = dateAdd("m", 1, DateToPayFixed)
                    wend
                end if
			end if
		end if
	end select
end if


splItens = split(ref("ItemPagarID"), ", ")
for i=0 to ubound(splItens)
    ItemID = splItens(i)
    Valor = ref("Descontar_"&ItemID)
    if Valor<>"" and isnumeric(Valor) then
        Valor = ccur(Valor)
        if Valor>0 then

            sqlItensDescontadosFind = "select id from itensdescontados where  ItemID = "&ItemID&" AND PagamentoID = "&LastMovementID&" AND Valor = "&treatvalzero(Valor)&"  LIMIT 1"
            set DiscountPay = db.execute(sqlItensDescontadosFind)

            if DiscountPay.eof then 
                sqlInsertIntens = "insert into itensdescontados (ItemID, PagamentoID, Valor) values ("&ItemID&", "&LastMovementID&", "&treatvalzero(Valor)&")"
                db.execute(sqlInsertIntens)
            end if

            'rotina para atualizar o status de agenda ->
            if T="C" then
                sqlat = "select i.AccountID PacienteID, i.AssociationAccountID Associacao, ii.ItemID ProcedimentoID, (ii.Quantidade * (ii.ValorUnitario + ii.Acrescimo - ii.Desconto)) ValorTotal, ii.ProfissionalID, ii.DataExecucao from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID where ii.id="&ItemID
                'response.Write( sqlat )
                set iinv = db.execute(sqlat)
                if not iinv.eof then
                    if not isnull(iinv("DataExecucao")) and iinv("Associacao")=3 then
                        Data = iinv("DataExecucao")
                        call statusPagto("", iinv("PacienteID"), Data, "V", iinv("ValorTotal"), 0, iinv("ProcedimentoID"), iinv("ProfissionalID"))
                    end if
                end if
            end if
            '<- rotina para atualizar o status de agenda


        end if
    end if
next

set invs = db.execute("select sum(valor) PagoInvoice, ii.InvoiceID from itensdescontados id left join itensinvoice ii on ii.id=id.ItemID where id.PagamentoID="&LastMovementID&" group by invoiceid")
    while not invs.eof
        InvoiceID = invs("InvoiceID")
        PagoInvoice = invs("PagoInvoice")
        set movs = db.execute("select id, ifnull(ValorPago,0) ValorPago, `Value` from sys_financialmovement where Type='Bill' AND InvoiceID="&invs("InvoiceID"))
        while not movs.eof
            if instr(ref("Parcela"), "|"&movs("id")&"|") then
                ValorMov = ccur(movs("Value"))
                ValorPago = ccur(movs("ValorPago"))

                ValorPendente = ValorMov-ValorPago
                if PagoInvoice>=ValorPendente then
                    ValorPagoMov = ValorPendente
                else
                    ValorPagoMov = PagoInvoice
                end if

                db.execute("insert into sys_financialdiscountpayments (InstallmentID, MovementID, DiscountedValue) values ("&movs("id")&", "&LastMovementID&", "&treatvalzero(ValorPagoMov)&")")
                sqlMov = "update sys_financialmovement set ValorPago="&treatvalzero( ValorPago+ValorPagoMov )&" where id="&movs("id")
                db.execute(sqlMov)
                call gravaLog(sqlMov, "AUTO")
                PagoInvoice = PagoInvoice - ValorPagoMov
            end if
        movs.movenext
        wend
        movs.close
        set movs=nothing
    invs.movenext
    wend
    invs.close
    set invs = nothing

if T="C" and InvoiceID&"" <>"" then

    'Validar se o pagamento é completo e se a configuração esta ativa
    
    '09/09/2019
    'verificar configuração de exebição de listagem de recibos
    exibeListagem = getConfig("ExibeListagem")

    abrirReciboAutomatico = getConfig("ReciboAutomaticoFinanceiro")
    if abrirReciboAutomatico = 1 then
        set iInvoices = db.execute("SELECT IFNULL(Value, 0) Value, CD FROM sys_financialinvoices WHERE id=" & InvoiceID)
        set iPagoInvoices = db.execute("SELECT IFNULL(SUM(ValorPago),0) ValorTotal FROM sys_financialmovement WHERE InvoiceID =" & InvoiceID)
        
        CD = iInvoices("Value")
        if iInvoices("Value") = iPagoInvoices("ValorTotal")  then
        %>
        $.get("relatorio.asp?TipoRel=ifrReciboIntegrado&I=<%=InvoiceID%>",  function(data){  
            printWindow = window.open('');
            printWindow.document.write(data);
            
            setTimeout(function(){
                printWindow.top.close();
            }, 500);
        });
            <% if exibeListagem = 1 then %>
            setTimeout(function(){
                listaRecibos("<%=InvoiceID%>");
            }, 500);
            <% end if %>
        <%
        end if
    end if

    if InvoiceID<>"" then
        call reconsolidar("invoice", InvoiceID)
    end if

    set ConfigSQL = db.execute("SELECT SplitNF FROM sys_config WHERE id=1")
    if not ConfigSQL.eof then
        if ConfigSQL("SplitNF")=1 then
            if exibeListagem = 1 then
                %>
                setTimeout(function(){
                    listaRecibos('<%=InvoiceID%>');
                }, 3500);
                <%
            end if
        end if
    end if
end if


action = "recebimento"
category = "conta_a_receber"

if CD="D" then
    action = "pagamento"
    category = "conta_a_pagar"
end if
%>

gtag('event', '<%=action%>', {
    'event_category': '<%=category%>',
    'event_label': "Botão 'Pagar' clicado.",
});

var MovementPayID = '<%=LastMovementID%>';

if( $.isNumeric($("#PacienteID").val()) )
{
    ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
    if($('#Checkin').val()=='1'){
        $.get("callAgendamentoProcedimentos.asp?Checkin=1&ConsultaID="+ $("#ConsultaID").val() +"&PacienteID="+ $("#PacienteID").val() +"&ProfissionalID="+ $("#ProfissionalID").val() +"&ProcedimentoID="+ $("#ProcedimentoID").val(), function(data){ $("#divAgendamentoCheckin").html(data) });
    }
}else{
    $('.parcela').prop('checked', false); $('#pagar').fadeOut();
    geraParcelas('N');
}
