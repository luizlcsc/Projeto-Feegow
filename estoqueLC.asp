<!--#include file="connect.asp"-->
<%
LancamentoID = req("LancamentoID")

if InvoiceID&""="" then
    InvoiceID = 0
end if
call estoqueLancaConta(LancamentoID, "eval", InvoiceID)
%>