<%
Pago=0
set MovSQL = dbc.execute("select id,Date  from clinic5459.sys_financialmovement where InvoiceID ="&CId&" and CD='C'")
if not MovSQL.eof then
    MovID = MovSQL("id")
    Vencimento = MovSQL("Date")
end if

set pagtos = dbc.execute("select * from clinic5459.sys_financialdiscountpayments where InstallmentID="&MovID&"")
while not pagtos.eof
	ValorDesc=pagtos("DiscountedValue")
Pago = Pago+ValorDesc
pagtos.movenext
wend
pagtos.close
set pagtos = nothing

set pwr = dbc.execute("select Value from clinic5459.sys_financialinvoices where id ="&CId)
Total = formatnumber(pwr("Value"),2)

Devedor = formatnumber(pwr("Value")-Pago,2)

if Pago = 0 then

	msg = "N&Atilde;O PAGA"
	cor = "#FF0000"
	classe = "danger"
end if
if Pago >= pwr("Value") then
	msg = "QUITADA"
	cor = "#006600"
	classe = "success"
end if
if Pago > pwr("Value") then
	msg = "QUITADA"
	cor = "#006600"
	classe = "success"
end if
if Pago < pwr("Value") and Pago > ccur(0) then
    ValExiAtu = Devedor
    if isnull(ValExiAtu) then
        ValExiAtu="0"
    end if
    if ccur("1,00")=100 then
        ExiVal=replace(ValExiAtu,",","@")
        ExiVal=replace(Exival,".",",")
        ExiVal=replace(Exival,"@",".")
    else
        ExiVal=ValExiAtu
    end if

	msg = "PARCIALMENTE PAGA - Deve: R$&nbsp;"&ExiVal
	cor = "#FFCC00"
	classe = "warning"
end if
if Devedor=0 then
	msg = "QUITADA"
	cor = "#006600"
	classe = "success"
end if



%>
