<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
DominioID = req("DominioID")
Tipo = req("Tipo")
ItemID = req("ItemID")
FM = req("FM")
if Tipo="Item" then
    sqlDel = "delete from rateiofuncoes where id="&ItemID

    call gravaLogs(sqlDel, "AUTO", "Função de repasse removida", "DominioID")
	db_execute(sqlDel)
elseif Tipo="Adicionar" then
    sqlIns = "insert into rateiofuncoes (DominioID, sysUser, FM) values ("&DominioID&", "&session("User")&", '"&FM&"')"

	db_execute(sqlIns)

    call gravaLogs(sqlIns, "AUTO", "Função de repasse inserida", "DominioID")
else
    sqlDel = "delete from rateiofuncoes where DominioID="&DominioID
    call gravaLogs(sqlDel, "AUTO", "Domínio de repasse removido", "DominioID")

	db_execute(sqlDel)
end if
%>
quantidade(0);
