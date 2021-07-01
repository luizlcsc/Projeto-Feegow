<%
firstDueDate = ref("firstDueDate")
Recurrence = ccur(ref("Recurrence"))
RecurrenceType = ref("RecurrenceType")
Installments = ccur(ref("Installments"))
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