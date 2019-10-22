<!--#include file="connect.asp"-->
<%
DominioID = request.QueryString("DominioID")
Tipo = request.QueryString("Tipo")
ItemID = request.QueryString("ItemID")
FM = request.QueryString("FM")
if Tipo="Item" then
	db_execute("delete from rateiofuncoes where id="&ItemID)
elseif Tipo="Adicionar" then
	db_execute("insert into rateiofuncoes (DominioID, sysUser, FM) values ("&DominioID&", "&session("User")&", '"&FM&"')")
else
	db_execute("delete from rateiofuncoes where DominioID="&DominioID)
end if
%>
quantidade(0);
