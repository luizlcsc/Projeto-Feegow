<!--#include file="connect.asp"-->
<%

'vaklidar se o valor da invoice e do rateio estao iguais

porcentagemString = ref("porcentagem")
porcentagemidString = ref("porcentagemid")
CompanyUnitNfeID = 0
invoiceId = ref("invoiceId")
tipoValor = ref("tipoValor")

db_execute("delete from invoice_rateio where InvoiceID = "&invoiceId)

porcentagem = Split(porcentagemString, "|")
porcentagemid = Split(porcentagemidString, "|")

TemAlgumMaiorQueZero=False

for i = 0 to uBound(porcentagem)
    id = porcentagemid(i)
    valor = porcentagem(i)
    if valor<>""  then

        if Cdbl(valor) > 0 then
            TemAlgumMaiorQueZero=true
            valor = (valor)
            db_execute("insert into invoice_rateio (InvoiceID, CompanyUnitNfeID, CompanyUnitID, porcentagem, TipoValor, DataHora, DHUP) values("&invoiceId&", "&CompanyUnitNfeID&", "&id&", "&valor&", '"&tipoValor&"', NOW(), NOW())")
        end if
    end if
next

if TemAlgumMaiorQueZero then
    db.execute("UPDATE sys_financialinvoices SET Rateado=1 WHERE id="&invoiceId)
else
    db.execute("UPDATE sys_financialinvoices SET Rateado=0 WHERE id="&invoiceId)
end if

Response.write("Rateio cadastrado com sucesso")


%>