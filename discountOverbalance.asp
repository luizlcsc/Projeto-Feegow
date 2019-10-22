<!--#include file="connect.asp"-->
<%
PaymentDate = date()'cdate(ref("PaymentDate"))

'TotalDesired = ccur(ref("PaymentValue"))

'''->desabilitado agora -> response.Write(ref("overbalance")&"|||")

overbalance = ref("overbalance")

overbalanceChecked = split(overbalance, ", ")
for i=0 to ubound(overbalanceChecked)
	splOverbalanceChecked = split(overbalanceChecked(i), "_")
	
	creditMovementID = splOverbalanceChecked(0)
	available = ccur(splOverbalanceChecked(1))
	
	'check how much cash each plot
	splCheckedInstallments = split(ref("InstallmentsToPay"), ", ")
	for j=0 to ubound(splCheckedInstallments)
	
		alreadyDiscounted = 0
		set checkAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&splCheckedInstallments(j))
		while not checkAlreadyDiscounted.EOF
			alreadyDiscounted = alreadyDiscounted+checkAlreadyDiscounted("DiscountedValue")
		checkAlreadyDiscounted.movenext
		wend
		checkAlreadyDiscounted.close
		set checkAlreadyDiscounted=nothing
	
		InstallmentValue = ccur(ref("ValueInstallment"&splCheckedInstallments(j)))
	
		if InstallmentValue>alreadyDiscounted then
			discountedValue = InstallmentValue-alreadyDiscounted
		else
			discountedValue = 0
		end if
	
		if available<=discountedValue then
			discountedValue = available
		end if
	
		if available>0 and discountedValue>0 then
			'valueToDiscountNow = discountedValue-alreadyDiscounted?????
			db_execute("insert into sys_financialDiscountPayments (InstallmentID, MovementID, DiscountedValue) values ("&splCheckedInstallments(j)&", "&creditMovementID&", '"&treatVal(discountedValue)&"')")
			available = available - discountedValue
		end if
	next
	
next



%>