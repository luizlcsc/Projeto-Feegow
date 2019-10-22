<!--#include file="connect.asp"-->
<%
ItemID = req("ItemID")

set InvoiceSQL = db.execute("SELECT ii.InvoiceID, i.CD FROM itensinvoice ii INNER JOIN sys_financialinvoices i WHERE ii.id="&ItemID)
if not InvoiceSQL.eof then
    response.Redirect("?P=invoice&I="&InvoiceSQL("InvoiceID")&"&A=&Pers=1&T="&InvoiceSQL("CD")&"&Ent=")
end if
%>