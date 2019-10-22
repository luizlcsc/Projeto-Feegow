<!--#include file="connect.asp"-->
<%
InvoiceID=ref("InvoiceID")
CnpjCorreto=ref("cnpjC")
CnpjAntigo=ref("cnpjA")
numero=ref("numero")

set UltimaNumeracaoSQL = db.execute("SELECT numero FROM nfe_notasemitidas where cnpj='"&CnpjAntigo&"' AND situacao in (0, 1, 3, 13)")
if not UltimaNumeracaoSQL.eof then
    numeroNovo = UltimaNumeracaoSQL("numero") + 1

    if CnpjCorreto="" then

    else
        sqlUpdate =  "UPDATE recibos SET cnpj='"&CnpjCorreto&"', numerorps='"&numero&"' WHERE InvoiceID="&InvoiceID&" AND cnpj='"&cnpjAntigo&"' AND RPS='S'"
        'response.write(sqlUpdate)
        db.execute(sqlUpdate)

        db.execute("UPDATE nfe_notasemitidas SET situacao=-1 WHERE InvoiceID="&InvoiceID&" AND cnpj='"&CnpjAntigo&"'")
    end if
end if
%>