<!--#include file="./../../../connect.asp"-->
<%
InvoiceID=req("InvoiceID")
itensMultiplosExecutados=ref("item-multiplos-executados")

if itensMultiplosExecutados<>"" then
    itensInvoiceID=split(itensMultiplosExecutados,",")


    for i=0 to ubound(itensInvoiceID)
        dd(itensInvoiceID(i))
    next
    sqlUpdate = "UPDATE itensinvoice SET Executado='S' WHERE InvoiceID = "&InvoiceID&" AND id in ("&itensInvoiceID&")"

    'db.execute(sqlUpdate)
end if
%>