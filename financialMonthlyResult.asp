<!--#include file="connect.asp"-->
<%
if req("currentYear")="" then
	currentYear = year(date())
else
	currentYear = req("currentYear")
end if
%>
<div class="page-header">
    <h1>
        Resultado Mensal<small><i class="far fa-double-angle-right"></i> sint&eacute;tico</small>
        
    </h1>
</div><!-- /.page-header -->

<div class="clearfix form-actions">
    <form method="get" action="">
    <div class="col-md-1">
    <label>Unidade</label><br>
    <select name="CompanyUnitID">
    	<option value="">Todas</option>
        <option value="0"<% If req("CompanyUnitID")="0" Then %> selected<% End If %>>Geral</option>
        <%
		set getUnits = db.execute("select * from sys_financialCompanyUnits where sysActive=1 and UnitName<>'' order by UnitName")
		while not getUnits.EOF
			%><option value="<%=getUnits("id")%>"<% If req("CompanyUnitID")=cstr(getUnits("id")) Then %> selected<% End If %>><%=getUnits("UnitName")%></option>
            <%
		getUnits.movenext
		wend
		getUnits.close
		set getUnits=nothing
		%>
    </select>
    </div>
	<div class="col-md-1">
        <input type="hidden" name="P" value="financialMonthlyResult">
        <label>Ano</label><br>
        <input type="text" class="form-control" name="currentYear" value="<%=currentYear%>">
    </div>
    <div class="col-md-1">
    <label>&nbsp;</label><br>
    	<button class="btn btn-sm btn-primary">Filtrar</button>
    </div>
    </form>
</div>


<table class="table table-striped table-bordered">
    <thead>
	<tr>
    	<th></th>
        <%
		currentMonth = 1
		while currentMonth<=12
			%>
			<th colspan="2" style="text-transform:capitalize"><%=(monthName(currentMonth))%></th>
			<%
			currentMonth = currentMonth+1
		wend
		%>
        <th colspan="2">TOTAL</th>
	</tr>
	<tr>
    	<th>DESPESAS</th>
        <%
		currentMonth = 1
		while currentMonth<=12
			%>
			<th><small>Prev.</small></th>
			<th><small>Real.</small></th>
			<%
			currentMonth = currentMonth+1
		wend
		%>
        <th><small>Prev.</small></th>
        <th><small>Real.</small></th>
	</tr>
    </thead>
    <%
	TotPrev = 0
	TotReal = 0
	set getExpenses = db.execute("select * from sys_financialExpenseType where sysActive=1 order by Name")
	while not getExpenses.EOF
	%>
    <tr>
    	<th><%=getExpenses("Name")%></th>
        <%
		currentMonth = 1
		PrevCat = 0
		RealCat = 0
		while currentMonth<=12
			Prev = 0
			Real = 0
			set getMovementBill = db.execute("select * from sys_financialMovement where CD='D' and MONTH(Date)="&currentMonth&" and YEAR(Date)="&currentYear&" and Type='Bill'")
			while not getMovementBill.eof
				set getInstallment = db.execute("select * from sys_financialInstallments where MovementID="&getMovementBill("id"))
				if not getInstallment.EOF then
					if req("CompanyUnitID")<>"" then
						strUnit = " and CompanyUnitID="&req("CompanyUnitID")
					end if
					set getInvoice = db.execute("select * from sys_financialInvoices where id="&getInstallment("InvoiceID")&strUnit)
					if not getInvoice.EOF then
						if getInvoice("AccountPlanID")=getExpenses("id") then
							if getMovementBill("Currency")=session("DefaultCurrency") then
								currentValue=getMovementBill("Value")
							else
								currentValue=getMovementBill("Value")/getMovementBill("Rate") 
							end if
							Prev = Prev+currentValue
							
							discounts = 0
							set getDiscounteds = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&getInstallment("id"))
							while not getDiscounteds.EOF
								discounts = getDiscounteds("DiscountedValue")
							getDiscounteds.movenext
							wend
							getDiscounteds.close
							set getDiscounteds=nothing
							if getMovementBill("Currency")=session("DefaultCurrency") then
								real=real+discounts
							else
								real=real+(discounts/getMovementBill("Rate"))
							end if
						end if
					end if
				end if
			getMovementBill.movenext
			wend
			getMovementBill.close
			set getMovementBill=nothing
			PrevCat = PrevCat+Prev
			RealCat = RealCat+Real
			%>
			<td class="text-right"><%=formatNumber(Prev,2)%></td>
			<td class="text-right"><%= formatNumber(Real,2) %></td>
			<%
			currentMonth = currentMonth+1
		wend
		%>
        <th class="text-right"><%= formatNumber(PrevCat,2) %></th>
        <th class="text-right"><%= formatNumber(RealCat,2) %></th>
    </tr>
    <%
		TotPrev = TotPrev+PrevCat
		TotReal = TotReal+RealCat
	getExpenses.movenext
	wend
	getExpenses.close
	set getExpenses=nothing
	
	RecLiqPrev = TotPrev
	RecLiqReal = TotReal
	%>
    <tr>
        <th colspan="25"></th>
        <th class="text-right"><%=formatnumber(TotPrev,2)%></th>
        <th class="text-right"><%=formatnumber(TotReal,2)%></th>
	</tr>












    <thead>
	<tr>
    	<th></th>
        <%
		currentMonth = 1
		while currentMonth<=12
			%>
			<th colspan="2" style="text-transform:capitalize"><%=(monthName(currentMonth))%></th>
			<%
			currentMonth = currentMonth+1
		wend
		%>
        <th colspan="2">TOTAL</th>
	</tr>
	<tr>
    	<th>RECEITAS</th>
        <%
		currentMonth = 1
		while currentMonth<=12
			%>
			<th><small>Prev.</small></th>
			<th><small>Real.</small></th>
			<%
			currentMonth = currentMonth+1
		wend
		%>
        <th><small>Prev.</small></th>
        <th><small>Real.</small></th>
	</tr>
    </thead>
    <%
	TotPrev = 0
	TotReal = 0
	set getIncomes = db.execute("select * from sys_financialIncomeType where sysActive=1 order by Name")
	while not getIncomes.EOF
	%>
    <tr>
    	<th><%=getIncomes("Name")%></th>
        <%
		currentMonth = 1
		PrevCat = 0
		RealCat = 0
		while currentMonth<=12
			Prev = 0
			Real = 0
			set getMovementBill = db.execute("select * from sys_financialMovement where CD='C' and MONTH(Date)="&currentMonth&" and YEAR(Date)="&currentYear&" and Type='Bill'")
			while not getMovementBill.eof
				set getInstallment = db.execute("select * from sys_financialInstallments where MovementID="&getMovementBill("id"))
				if not getInstallment.EOF then
					if req("CompanyUnitID")<>"" then
						strUnit = " and CompanyUnitID="&req("CompanyUnitID")
					end if
					set getInvoice = db.execute("select * from sys_financialInvoices where id="&getInstallment("InvoiceID")&strUnit)
					if not getInvoice.EOF then
						if getInvoice("AccountPlanID")=getIncomes("id") then
							if getMovementBill("Currency")=session("DefaultCurrency") then
								currentValue=getMovementBill("Value")
							else
								currentValue=getMovementBill("Value")/getMovementBill("Rate") 
							end if
							Prev = Prev+currentValue
							
							discounts = 0
							set getDiscounteds = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&getInstallment("id"))
							while not getDiscounteds.EOF
								discounts = getDiscounteds("DiscountedValue")
							getDiscounteds.movenext
							wend
							getDiscounteds.close
							set getDiscounteds=nothing
							if getMovementBill("Currency")=session("DefaultCurrency") then
								real=real+discounts
							else
								real=real+(discounts/getMovementBill("Rate"))
							end if
						end if
					end if
				end if
			getMovementBill.movenext
			wend
			getMovementBill.close
			set getMovementBill=nothing
			PrevCat = PrevCat+Prev
			RealCat = RealCat+Real
			%>
			<td class="text-right"><%=formatNumber(Prev,2)%></td>
			<td class="text-right"><%= formatNumber(Real,2) %></td>
			<%
			currentMonth = currentMonth+1
		wend
		%>
        <th class="text-right"><%= formatNumber(PrevCat,2) %></th>
        <th class="text-right"><%= formatNumber(RealCat,2) %></th>
    </tr>
    <%
		TotPrev = TotPrev+PrevCat
		TotReal = TotReal+RealCat
	getIncomes.movenext
	wend
	getIncomes.close
	set getIncomes=nothing
	RecLiqPrev = TotPrev-RecLiqPrev
	RecLiqReal = TotReal-RecLiqReal
	%>
    <tr>
        <th colspan="25"></th>
        <th class="text-right"><%=formatnumber(TotPrev,2)%></th>
        <th class="text-right"><%=formatnumber(TotReal,2)%></th>
	</tr>
    
    
    
    
    
    
    <tr>
    	<th colspan="25">Resultado L&iacute;quido</th>
        <th class="text-right"><%=formatnumber(RecLiqPrev,2)%></th>
        <th class="text-right"><%=formatnumber(RecLiqReal,2)%></th>
</table>