<!--#include file="connect.asp"-->
<%
session.LCID=1046
splAccountIDInvoice = split(ref("AccountID"), "_")
AccountIDInvoice = splAccountIDInvoice(1)
AssociationAccountIDInvoice = splAccountIDInvoice(0)

splAccountID = split(ref("PaymentAccount"), "_")
AccountID = splAccountID(1)
AssociationAccountID = splAccountID(0)
PaymentDate = cdate(ref("PaymentDate"))
PaymentValue = ccur(ref("PaymentValue"))

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
UnidadeID = session("UnidadeID")
contabloqueadacred = verificaBloqueioConta(2, 1, AccountIDCredit, UnidadeID,PaymentDate)
contabloqueadadebt = verificaBloqueioConta(2, 1, AccountIDDebit, UnidadeID,PaymentDate)
if contabloqueadacred = "1" or contabloqueadadebt = "1" then
    response.end
end if
' #####################################################################################
db_execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Obs, Currency, Rate) values ('Pagamento', '"&AccountAssociationIDCredit&"', '"&AccountIDCredit&"', '"&AccountAssociationIDDebit&"', '"&AccountIDDebit&"', "&ref("PaymentMethod")&", '"&treatVal(PaymentValue)&"', '"&myDate(PaymentDate)&"', '"&reverse&"', 'Pay', '"&ref("Obs")&"', '"&ref("PaymentCurrency")&"', '"&treatVal(ref("PaymentRate"))&"')")
set getLastMovementID = db.execute("select id from sys_financialMovement order by id desc LIMIT 1")
LastMovementID = getLastMovementID("id")

db.execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Obs, Currency, Rate) values ('Pagamento', '"&AccountAssociationIDCredit&"', '"&AccountIDCredit&"', '"&AccountAssociationIDDebit&"', '"&AccountIDDebit&"', "&ref("PaymentMethod")&", '"&treatVal(PaymentValue)&"', '"&myDate(PaymentDate)&"', '"&reverse&"', 'Pay', '"&ref("Obs")&"', '"&ref("PaymentCurrency")&"', '"&treatVal(ref("PaymentRate"))&"')")
' set getLastMovementID = db.execute("select id from sys_financialMovement order by id desc LIMIT 1")
' LastMovementID = getLastMovementID("id")

LastMovementIDQ = db.execute("SELECT LAST_INSERT_ID() as Last")
LastMovementID = LastMovementIDQ("last") 
if T="C" then
	select case ccur(ref("PaymentMethod"))
	case 2'check
		if ref("Cashed")="" then
			Cashed=0
		else
			Cashed=1
		end if
		db_execute("insert into sys_financialReceivedChecks (BankID, CheckNumber, Holder, Document, CheckDate, Cashed, AccountAssociationID, AccountID, MovementID) values ('"&ref("BankID")&"', '"&ref("CheckNumber")&"', '"&ref("Holder")&"', '"&ref("Document")&"', '"&myDate(ref("CheckDate"))&"', "&Cashed&", "&AssociationAccountID&", "&AccountID&", "&LastMovementID&")")
	case 4'bank bill
		if ref("BankFee")<>"" then
			if ccur(ref("BankFee"))>0 then
				db_execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, MovementAssociatedID, Currency, Rate) values ('Taxa boleto', '"&AccountAssociationIDDebit&"', '"&AccountIDDebit&"', 0, 0, 0, '"&treatVal(ref("BankFee"))&"', '"&myDate(PaymentDate)&"', 'C', 'Fee', "&LastMovementID&", '"&ref("PaymentCurrency")&"', '"&treatval(getrate())&"')")
			end if
		end if

	case 8'credit card
		db_execute("insert into sys_financialCreditCardTransaction (TransactionNumber, AuthorizationNumber, MovementID) values ('"&ref("TransactionNumber")&"', '"&ref("AuthorizationNumber")&"', "&LastMovementID&")")
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
				' PercentageDeducted = getAccountData("PercentageDeducted")
				DaysForCredit = getAccountData("DaysForCredit")
				NumberOfInstallments = ccur(ref("NumberOfInstallments"))
				c=0
				cardInstallmentValue = ccur(PaymentValue)/NumberOfInstallments
				DateToReceive = PaymentDate
				while c<NumberOfInstallments
					c=c+1
					DateToReceive = dateAdd("d", DaysForCredit*c, DateToReceive)
					if weekday(DateToReceive)=1 then
						DateToReceive=dateAdd("d", 1, DateToReceive)
					elseif weekday(DateToReceive)=7 then
						DateToReceive=dateAdd("d", 2, DateToReceive)
					end if
					db_execute("insert into sys_financialCreditCardReceiptInstallments (DateToReceive, Fee, Value, TransactionID, InvoiceReceiptID) values ('"&myDate(DateToReceive)&"', '"&PercentageDeducted&"', '"&treatVal(cardInstallmentValue)&"', "&TransactionID&", 0)")
				wend
			end if
		end if
	end select
else
	select case ccur(ref("PaymentMethod"))
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
				db_execute("insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, MovementAssociatedID, Currency, Rate) values ('Taxa de transfer&ecirc;ncia', '"&AccountAssociationIDCredit&"', '"&AccountIDCredit&"', 0, 0, 0, '"&treatVal(ref("BankFee"))&"', '"&myDate(PaymentDate)&"', 'C', 'Fee', "&LastMovementID&", '"&ref("PaymentCurrency")&"', '"&treatval(getrate())&"')")
			end if
		end if
	case 10
		db_execute("insert into sys_financialCreditCardTransaction (TransactionNumber, AuthorizationNumber, MovementID) values ('"&ref("TransactionNumber")&"', '"&ref("AuthorizationNumber")&"', "&LastMovementID&")")
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
				cardInstallmentValue = ccur(PaymentValue)/NumberOfInstallments
				
				DateToPay = PaymentDate
				'assemble payment date with the due day
				DateToPay = cDate( DueDay&"/"&month(PaymentDate)&"/"&year(PaymentDate) )
				if DateToPay<PaymentDate then
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
		Rate = ccur(ref("PaymentRate"))
		if InvoiceCurrency=session("DefaultCurrency") then
			PaymentValue = PaymentValue / Rate
		else
			PaymentValue = PaymentValue * Rate
		end if
	end if
end if
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'check how much cash each plot
splCheckedInstallments = split(ref("InstallmentsToPay"), ", ")
available = PaymentValue
for i=0 to ubound(splCheckedInstallments)

	alreadyDiscounted = 0
	set checkAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&splCheckedInstallments(i))
	while not checkAlreadyDiscounted.EOF
		alreadyDiscounted = alreadyDiscounted+checkAlreadyDiscounted("DiscountedValue")
	checkAlreadyDiscounted.movenext
	wend
	checkAlreadyDiscounted.close
	set checkAlreadyDiscounted=nothing

	InstallmentValue = ccur(ref("ValueInstallment"&splCheckedInstallments(i)))

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
		db_execute("insert into sys_financialDiscountPayments (InstallmentID, MovementID, DiscountedValue) values ("&splCheckedInstallments(i)&", "&LastMovementID&", '"&treatVal(discountedValue)&"')")
		available = available - discountedValue
	end if
next

if ref("CompID")<>"" then
	set getWR = db.execute("select * from wr where InvoiceID="&ref("InvoiceID"))
	if not getWR.EOF then
		db_execute("update comprovantes set Sta='U' where wrid="&getWR("id"))
	end if
end if
%>