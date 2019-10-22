<!--#include file="connect.asp"-->
<%
ItemInvoiceID = req("ItemInvoiceID")
TabelaCorretaID = req("TabelaCorretaID")

set inv = db.execute("select InvoiceID from itensinvoice WHERE id="& ItemInvoiceID)

'response.write("update sys_financialinvoices SET Corrigido=1, TabelaID="& TabelaCorretaID &" WHERE id="& inv("InvoiceID"))
db_execute("update sys_financialinvoices SET Corrigido=1, TabelaID="& TabelaCorretaID &" WHERE id="& inv("InvoiceID"))
%>