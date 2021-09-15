<!--#include file="connect.asp"-->
<%

if session("OtherCurrencies")<>"" then
	Rate = getRate()
end if

if left(ref("PaymentAccount"), 2)="1_" then
	set getCurrentAccountCurrency = db.execute("select * from sys_financialCurrentAccounts where id="&replace(ref("PaymentAccount"), "1_", ""))
	if not getCurrentAccountCurrency.EOF then
		PaymentCurrency = getCurrentAccountCurrency("Currency")
	end if
else
	PaymentCurrency = session("DefaultCurrency")
end if
InvoiceCurrency = ref("Currency")

T=ref("T")
splInstallmentsToPay = split(ref("InstallmentsToPay"),", ")
checkedVal = 0
for i=0 to ubound(splInstallmentsToPay)
	if ref("difference"&splInstallmentsToPay(i))<>"" then
		checkedVal = checkedVal+ref("difference"&splInstallmentsToPay(i))
	else
		checkedVal = checkedVal+ref("ValueInstallment"&splInstallmentsToPay(i))
	end if
next

'if InvoiceCurrency=session("DefaultCurrency") then
'	if PaymentCurrency<>InvoiceCurrency then
'		checkedVal = checkedVal * Rate
'	end if
'else
'	if PaymentCurrency<>InvoiceCurrency then
'		checkedVal = checkedVal / Rate
'	end if
'end if

if PaymentCurrency<>InvoiceCurrency then
	if InvoiceCurrency=session("DefaultCurrency") then
		checkedVal = checkedVal * Rate
	else
		checkedVal = checkedVal / Rate
	end if
	%>
	<div class="col-md-6">
    <label>Taxa</label>
    <div class="input-group">
    <span class="input-group-addon">
    <strong><%=session("OtherCurrencies")%></strong>
    </span>
    <input class="form-control input-mask-brl" placeholder="" type="text" value="<%=formatnumber(Rate,2)%>" name="PaymentRate" id="PaymentRate" style="text-align:right" />
    </div>
    </div>
	<%
else
	%>
	<input type="hidden" name="PaymentRate" id="PaymentRate" value="<%=getRate()%>">
	<%
end if
%>
    <div class="col-md-12">
    <label>Valor Pago</label>
    <div class="input-group">
    <span class="input-group-addon">
    <strong><%=PaymentCurrency%><strong>
    <input type="hidden" name="PaymentCurrency" id="PaymentCurrency" value="<%= PaymentCurrency %>" />
    </strong></strong>
    </span>
    <input class="form-control input-mask-brl" placeholder="" type="text" value="<%=formatnumber(checkedVal,2)%>" name="PaymentValue" id="PaymentValue" style="text-align:right" />
    </div>
    </div>
    
    
    
    <div class="col-md-12">
    <label for="PrevisaoRetorno"> Data Pagto</label>
    <div class="input-group">
    <input id="PaymentDate" class="form-control date-picker" type="text" data-date-format="dd/mm/yyyy" placeholder="" name="PaymentDate" value="<%= date() %>">
    <span class="input-group-addon">
    <i class="far fa-calendar bigger-110"></i>
    </span>
    </div>
    </div>  
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
</script>