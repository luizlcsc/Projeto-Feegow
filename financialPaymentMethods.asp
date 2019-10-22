<!--#include file="connect.asp"-->
<%
splPaymentAccount = split(request.Form("PaymentAccount"),"_")
AccountAssociationID = splPaymentAccount(0)
PaymentAccount = splPaymentAccount(1)

if AccountAssociationID = "1" then'a primeira linha da tabela de AccountAssociation tem que ser sempre a de contas
	sql = "select sys_financialCurrentAccounts.*, sys_financialAccountType.AcceptedMethods from sys_financialCurrentAccounts LEFT JOIN sys_financialAccountType ON sys_financialCurrentAccounts.AccountType=sys_financialAccountType.id where sys_financialCurrentAccounts.id="&PaymentAccount
	set account = db.execute(sql)
	if not account.EOF then
		splPaymentMethods = split(account("AcceptedMethods"),"|")
		for i=0 to ubound(splPaymentMethods)
			if splPaymentMethods(i)<>"" then
				sqlPM = "select * from sys_financialPaymentMethod where id="&splPaymentMethods(i)
				set PaymentMethod=db.execute(sqlPM)
				if not PaymentMethod.EOF then
					%>
                    <div class="col-md-6">
					<label><input type="radio" class="ace" name="PaymentMethod" value="<%=PaymentMethod("id")%>"><span class="lbl"> <%=PaymentMethod("PaymentMethod")%></span></label>
                    </div>
					<%
				end if
			end if
		next
	end if
else
	%>
    <div class="col-md-12">
	<input type="hidden" name="PaymentMethod" id="PaymentMethod" value="3">Saldo de conta.
    </div>
	<%
end if%>
