<!--#include file="./../connect.asp"-->
<%

function accountBalanceData(AccountID, Data)
    splAccountInQuestion = split(AccountID, "_")
    AccountAssociationID = splAccountInQuestion(0)
    AccountID = splAccountInQuestion(1)

    accountBalanceData = 0

    set getMovement = db_execute("select SUM(Valor) Saldo FROM (select COALESCE(IF(AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&",Value,value*-1),0)Valor from sys_financialMovement "&_
    "where ((AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&") or (AccountAssociationIDDebit="&AccountAssociationID&" and AccountIDDebit="&AccountID&")) and Date<='"&myDate(Data)&"' "&_
    ")t")

    if not getMovement.eof then
        accountBalanceData = getMovement("Saldo")
        if accountBalanceData&""="" then
            accountBalanceData = 0
        end if
    end if

    if AccountAssociationID=1 or AccountAssociationID=7 then
        accountBalanceData = accountBalanceData*(-1)
    end if

end function

function accountBalancePerDate(AccountID, Flag, Date)
	splAccountInQuestion = split(AccountID, "_")
	AccountAssociationID = splAccountInQuestion(0)
	AccountID = splAccountInQuestion(1)

    SaldoAnterior = 0

    if ref("Unidades")<>"" then
        sqlUnidades = " AND UnidadeID IN ("& replace(ref("Unidades"), "|", "") &") "
    end if

	accountBalancePerDate = 0
	set getMovement = db.execute("select * from sys_financialMovement where ((AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&") or (AccountAssociationIDDebit="&AccountAssociationID&" and AccountIDDebit="&AccountID&")) and Date<='"&myDate(Date)&"' and (UnidadeID<>-1 or ISNULL(UnidadeID)) "& sqlUnidades &" order by Date, id")

	if not getMovement.eof then
        while not getMovement.eof
            Value = getMovement("Value")
            AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
            AccountIDCredit = getMovement("AccountIDCredit")
            AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
            AccountIDDebit = getMovement("AccountIDDebit")
            PaymentMethodID = getMovement("PaymentMethodID")
            Rate = getMovement("Rate")
            'defining who is the C and who is the D
            'if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
            if AccountAssociationIDCredit&""=AccountAssociationID&"" and AccountIDCredit&""=AccountID&"" then
                CD = "C"
                'if getMovement("Currency")<>session("DefaultCurrency") then
                '	Value = Value / Rate
                'end if
				Balance = Balance+Value
                accountBalancePerDate = accountBalancePerDate+Value
            else
                'if getMovement("Currency")<>session("DefaultCurrency") then
                '	Value = Value / Rate
                'end if
                CD = "D"
				Balance = Balance-Value
                accountBalancePerDate = accountBalancePerDate-Value
            end if
            '-
            cType = getMovement("Type")

            'response.write(getMovement("id") &" : "& getMovement("Date") &" >> "&AccountAssociationIDCredit&":"&AccountAssociationIDDebit&" >> "& Value &" >> "& CD &" Saldo Ant: "& Balance &"  >> Saldo:"& accountBalancePerDate &"<br>" )

        getMovement.movenext
        wend
        getMovement.close
        set getMovement = nothing

    end if


	if (AccountAssociationID=1 or AccountAssociationID=7) and Balance<>0 then
		accountBalancePerDate = accountBalancePerDate*(-1)
	end if

	if Flag=1 then
		if accountBalancePerDate<0 then
			accountBalancePerDate = "<span class=""badge badge-danger arrowed-in badge-sm""><i class='icon-thumbs-down bigger-120'></i> Saldo negativo de R$&nbsp;"&formatnumber(accountBalancePerDate,2)&"</span>"
		elseif accountBalancePerDate>0 then
			accountBalancePerDate = "<span class=""badge badge-success arrowed-in badge-sm""><i class='icon-thumbs-up bigger-120'></i> Saldo positivo de R$&nbsp;"&formatnumber(accountBalancePerDate,2)&"</span>"
		else
			accountBalancePerDate = "<span class=""badge badge-sm arrowed-in"">Saldo: R$&nbsp;"&formatnumber(accountBalancePerDate,2)&"</span>"
		end if
	end if

end function
%>