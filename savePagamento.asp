<!--#include file="connect.asp"-->
<%
InvoiceID = req("I")
set inv = db.execute("select i.*, fr.MetodoID from sys_financialinvoices i left join sys_formasrecto fr on fr.id=i.FormaID where i.id="&InvoiceID)
AccountIDInvoice = inv("AccountID")
AssociationAccountIDInvoice = inv("AssociationAccountID")

splAccountID = split(ref("ContaRectoID"), "_")
AccountID = splAccountID(1)
AssociationAccountID = splAccountID(0)
DataPagto = cdate(ref("DataPagto"))
ValorPagto = ccur(ref("ValorPagto"))

T = ref("T")
if T="C" then
	AccountAssociationIDCredit = AssociationAccountIDInvoice
	AccountIDCredit = AccountIDInvoice
	AccountAssociationIDDebit = AssociationAccountID
	AccountIDDebit = AccountID
	reverse = "D"
else
	AccountAssociationIDCredit = AssociationAccountID
	AccountIDCredit = AccountID
	AccountAssociationIDDebit = AssociationAccountIDInvoice
	AccountIDDebit = AccountIDInvoice
	reverse = "C"
end if
' ######################### BLOQUEIO FINANCEIRO ########################################
UnidadeID = treatvalzero(ref("UnidadeIDPagto"))
contabloqueadacred = verificaBloqueioConta(2, 1, AccountIDCredit, UnidadeID,DataPagto)
contabloqueadadebt = verificaBloqueioConta(2, 1, AccountIDDebit, UnidadeID,DataPagto)
if contabloqueadacred = "1" or contabloqueadadebt = "1" then
	retorno  = " alert('Esta conta está BLOQUEADA e não pode ser alterada!'); " &_
               " $('.parcela').prop('checked', false); " &_
			   " $('#modal-table').modal('hide');"&_
               " geraParcelas('N'); "
    response.write(retorno)
	if ref("Lancto")="Dir" then>
		response.write(" window.opener.ajxContent('Conta', "&AccountIDInvoice&", '1', 'divHistorico');")
	end if
    response.end
end if
' #####################################################################################

db_execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Obs, Currency, Rate, CaixaID, UnidadeID, sysUser) values ('Pagamento', '"&AccountAssociationIDCredit&"', '"&AccountIDCredit&"', '"&AccountAssociationIDDebit&"', '"&AccountIDDebit&"', "&ref("MetodoID")&", '"&treatVal(ValorPagto)&"', '"&myDate(DataPagto)&"', '"&reverse&"', 'Pay', '"&ref("Obs")&"', '"&ref("PaymentCurrency")&"', 1, "&treatvalnull(ref("CaixaID"))&", "&treatvalzero(session("UnidadeID"))&", "&session("User")&")")
set getLastMovementID = db.execute("select id from sys_financialMovement order by id desc LIMIT 1")
LastMovementID = getLastMovementID("id")

if T="C" then
	select case ccur(ref("MetodoID"))
	case 2'check
		if ref("Cashed")="" then
			Cashed=0
			StatusID = 1
			'vai ter que ter uma verificação de pra qual conta foi o cheque pra colocar depositado, transferido, em caixa
			'...
		else
			Cashed=1
			StatusID = 4
		end if
		db_execute("insert into sys_financialReceivedChecks (BankID, CheckNumber, Holder, Document, CheckDate, Cashed, AccountAssociationID, AccountID, MovementID, StatusID, sysUser, Valor) values ('"&ref("BankID")&"', '"&ref("CheckNumber")&"', '"&ref("Holder")&"', '"&ref("Document")&"', '"&myDate(ref("CheckDate"))&"', "&Cashed&", "&AssociationAccountID&", "&AccountID&", "&LastMovementID&", "&StatusID&", "&session("User")&", "&treatvalzero(ValorPagto)&")")
		'grava o primeiro status do cheque recebido
		set getChequeID = db.execute("select id from sys_financialreceivedchecks where sysUser="&session("User")&" order by id desc LIMIT 1")
		ChequeID = getChequeID("id")
		db_execute("update sys_financialmovement set ChequeID="&ChequeID&" where id="&LastMovementID)
		db_execute("insert into chequemovimentacao (ChequeID, MovimentacaoID, Data, StatusID, sysUser) values ("&ChequeID&", "&LastMovementID&", '"&myDate(DataPagto)&"', "&StatusID&", "&session("User")&")")

	case 4'bank bill
		if ref("BankFee")<>"" then
			if ccur(ref("BankFee"))>0 then
				db_execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, MovementAssociatedID, Currency, Rate, sysUser) values ('Taxa boleto', '"&AccountAssociationIDDebit&"', '"&AccountIDDebit&"', 0, 0, 0, '"&treatVal(ref("BankFee"))&"', '"&myDate(DataPagto)&"', 'C', 'Fee', "&LastMovementID&", '"&ref("PaymentCurrency")&"', 1, "&session("User")&")")
			end if
		end if

	case 8, 9'credit card
		db_execute("insert into sys_financialCreditCardTransaction (TransactionNumber, AuthorizationNumber, MovementID, Parcelas) values ('"&ref("TransactionNumber")&"', '"&ref("AuthorizationNumber")&"', "&LastMovementID&","&ref("NumberOfInstallments")&")")
		set getTransactionID = db.execute("select * from sys_financialCreditCardTransaction order by id desc LIMIT 1")
		TransactionID = getTransactionID("id")

		'credit card account informations
		set getAssociation = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&AssociationAccountID)
		if not getAssociation.eof then
			set getAccountData = db.execute("select * from "&getAssociation("table")&" where id="&AccountID)
			if not getAccountData.EOF then
				queryTaxa = getTaxaAtual(AccountID,LastMovementID,ref("NumberOfInstallments"))
				set RetornoTaxaAtual2 = db.execute(queryTaxa)
				taxaAtual= ""
				taxaAtual = RetornoTaxaAtual2("taxaAtual")
				PercentageDeducted = taxaAtual
				DaysForCredit = getAccountData("DaysForCredit")
				NumberOfInstallments = ccur(ref("NumberOfInstallments"))
				c=0
				cardInstallmentValue = ccur(ValorPagto)/NumberOfInstallments
				DateToReceive = DataPagto
				while c<NumberOfInstallments
					c=c+1
					if not isnull(DaysForCredit) and DaysForCredit<>"" and isnumeric(DaysForCredit) and not isnull(DateToReceive) and DateToReceive<>"" and isdate(DateToReceive) then
						DateToReceive = dateAdd("d", DaysForCredit, DateToReceive)
						if weekday(DateToReceive)=1 then
							thisDateToReceive=dateAdd("d", 1, DateToReceive)
						elseif weekday(DateToReceive)=7 then
							thisDateToReceive=dateAdd("d", 2, DateToReceive)
						else
							thisDateToReceive=DateToReceive
						end if
					end if
					db_execute("insert into sys_financialCreditCardReceiptInstallments (DateToReceive, Fee, Value, TransactionID, InvoiceReceiptID) values ("&myDatenull(thisDateToReceive)&", "&PercentageDeducted&", "&treatValnull(cardInstallmentValue)&", "&TransactionID&", 0)")
				wend
			end if
		end if
	end select
else
	select case ccur(ref("MetodoID"))
	case 2'check
		if ref("Cashed")="" then
			Cashed=0
		else
			Cashed=1
		end if
		db_execute("insert into sys_financialIssuedChecks (CheckNumber, CheckDate, Cashed, AccountAssociationID, AccountID, MovementID) values ('"&ref("CheckNumber")&"', '"&myDate(ref("CheckDate"))&"', "&Cashed&", "&AssociationAccountID&", "&AccountID&", "&LastMovementID&")")
	case 5, 6, 7
		if ref("BankFee")<>"" then
			if ccur(ref("BankFee"))>0 then
				db_execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, MovementAssociatedID, Currency, Rate, sysUser) values ('Taxa de transfer&ecirc;ncia', '"&AccountAssociationIDCredit&"', '"&AccountIDCredit&"', 0, 0, 0, '"&treatVal(ref("BankFee"))&"', '"&myDate(DataPagto)&"', 'C', 'Fee', "&LastMovementID&", '"&ref("PaymentCurrency")&"', 1, "&session("User")&")")
			end if
		end if
	case 10
		db_execute("insert into sys_financialCreditCardTransaction (TransactionNumber, AuthorizationNumber, MovementID, Parcelas) values ('"&ref("TransactionNumber")&"', '"&ref("AuthorizationNumber")&"', "&LastMovementID&", "&ref("NumberOfInstallments")&")")
		set getTransactionID = db.execute("select * from sys_financialCreditCardTransaction order by id desc LIMIT 1")
		TransactionID = getTransactionID("id")

		'credit card account informations
		set getAssociation = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&AssociationAccountID)
		if not getAssociation.eof then
			set getAccountData = db.execute("select * from "&getAssociation("table")&" where id="&AccountID)
			if not getAccountData.EOF then
				DueDay = getAccountData("DueDay")
				NumberOfInstallments = ccur(ref("NumberOfInstallments"))
				c=0
				cardInstallmentValue = ccur(ValorPagto)/NumberOfInstallments
				
				DateToPay = DataPagto
				'assemble payment date with the due day
				DateToPay = cDate( DueDay&"/"&month(DataPagto)&"/"&year(DataPagto) )
				if DateToPay<DataPagto then
					DateToPay = dateAdd("m", 1, DateToPay)
				end if
				'verify if it is in the best buy date
				if DateDiff("d", Payment, DateToPay)<9 then
					DateToPay = dateAdd("m", 1, DateToPay)
				end if
				while c<NumberOfInstallments
					c=c+1
					DateToPay = dateAdd("m", DaysForCredit*c, DateToPay)
					if weekday(DateToPay)=1 then
						DateToPay=dateAdd("d", 1, DateToPay)
					elseif weekday(DateToPay)=7 then
						DateToPay=dateAdd("d", 2, DateToPay)
					end if
					db_execute("insert into sys_financialCreditCardPaymentInstallments (DateToPay, Value, TransactionID) values ('"&myDate(DateToPay)&"', '"&treatVal(cardInstallmentValue)&"', "&TransactionID&")")
				wend
			end if
		end if
	end select
end if

'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
if session("OtherCurrencies")<>"" then
	PaymentCurrency = ref("PaymentCurrency")
	InvoiceCurrency = ref("Currency")
	if PaymentCurrency<>InvoiceCurrency then
		Rate = 1
		if InvoiceCurrency=session("DefaultCurrency") then
			ValorPagto = ValorPagto / Rate
		else
			ValorPagto = ValorPagto * Rate
		end if
	end if
end if
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'check how much cash each plot
splCheckedInstallments = split(ref("Parcela"), ", ")
available = ValorPagto
for i=0 to ubound(splCheckedInstallments)
	ParcelaID = splCheckedInstallments(i)

	alreadyDiscounted = 0
	'response.Write("select * from sys_financialDiscountPayments where InstallmentID="&ParcelaID)
	set checkAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&ParcelaID)
	while not checkAlreadyDiscounted.EOF
		alreadyDiscounted = alreadyDiscounted+checkAlreadyDiscounted("DiscountedValue")
	checkAlreadyDiscounted.movenext
	wend
	checkAlreadyDiscounted.close
	set checkAlreadyDiscounted=nothing
	
	set getParcela = db.execute("select * from sys_financialmovement where id="&ParcelaID)
	if getParcela.eof then
		InstallmentValue = 0
	else
		InstallmentValue = getParcela("Value")
	end if

	if InstallmentValue>alreadyDiscounted then
		discountedValue = InstallmentValue-alreadyDiscounted
	else
		discountedValue = 0
	end if

	if available<=discountedValue then
		discountedValue = available
	end if

	if available>0 then
		valueToDiscountNow = discountedValue-alreadyDiscounted
		db_execute("insert into sys_financialDiscountPayments (InstallmentID, MovementID, DiscountedValue) values ("&ParcelaID&", "&LastMovementID&", '"&treatVal(discountedValue)&"')")
		available = available - discountedValue
	end if

	call getValorPago(ParcelaID, NULL)


next

if ref("CompID")<>"" then
	set getWR = db.execute("select * from wr where InvoiceID="&ref("InvoiceID"))
	if not getWR.EOF then
		db_execute("update comprovantes set Sta='U' where wrid="&getWR("id"))
	end if
end if
%>
$('.parcela').prop('checked', false);
$("#modal-table").modal("hide");
geraParcelas('N');
<%if ref("Lancto")="Dir" then%>
window.opener.ajxContent('Conta', <%=AccountIDInvoice%>, '1', 'divHistorico');
<%end if%>
<!--#include file="connect.asp"-->