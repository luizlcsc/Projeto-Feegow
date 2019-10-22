<!--#include file="connect.asp"-->
<%
Tipo = request.QueryString("Tipo")
ItemID = request.QueryString("ItemID")
if Tipo="Item" then
	db_execute("delete from itensinvoice where id="&ItemID)
	db_execute("update rateiorateios set ItemContaAPagar=NULL where ItemContaAPagar="&ItemID)
	db_execute("delete from rateiorateios where ItemInvoiceID="&ItemID)
else
	db_execute("delete from itensinvoice where GrupoID="&ItemID)
end if
%>