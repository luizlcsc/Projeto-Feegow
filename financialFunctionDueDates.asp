<%
firstDueDate = request.Form("firstDueDate")
Recurrence = ccur(request.Form("Recurrence"))
RecurrenceType = request.Form("RecurrenceType")
Installments = ccur(request.Form("Installments"))
DueDate = firstDueDate

if Installments>1 then
	if isDate(firstDueDate) and firstDueDate<>"" then
		cInstallments=1
		while cInstallments<Installments
			cInstallments=cInstallments+1
			DueDate = dateAdd(RecurrenceType, Recurrence, DueDate)
			%>
			$("#DueDateInstallment<%=cInstallments%>").val('<%=DueDate%>');
			<%
		wend
	end if
end if
%>/*sssss*/