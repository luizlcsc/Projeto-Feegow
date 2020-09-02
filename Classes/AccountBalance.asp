<!--#include file="./../connect.asp"-->
<%

function accountBalancePerDate(AccountID, Flag, Date)
	splAccountInQuestion = split(AccountID, "_")
	AccountAssociationID = splAccountInQuestion(0)
	AccountID = splAccountInQuestion(1)

	accountBalancePerDate = 0
	set getMovement = db.execute("select * from sys_financialMovement where ((AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&") or (AccountAssociationIDDebit="&AccountAssociationID&" and AccountIDDebit="&AccountID&")) and Date<='"&myDate(Date)&"' order by Date")

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
                accountBalancePerDate = accountBalancePerDate+Value
            else
                'if getMovement("Currency")<>session("DefaultCurrency") then
                '	Value = Value / Rate
                'end if
                CD = "D"
                accountBalancePerDate = accountBalancePerDate-Value
            end if
            '-
            cType = getMovement("Type")
        getMovement.movenext
        wend
        getMovement.close
        set getMovement = nothing

    end if

	if AccountAssociationID=1 or AccountAssociationID=7 then
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