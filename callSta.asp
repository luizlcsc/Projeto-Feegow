<!--#include file="connect.asp"-->
<%
callID = req("callID")
StaID = req("StaID")

if StaID="-1" then
	db_execute("update chamadas set RejeitadaPor=concat(RejeitadaPor, '|"&session("User")&"|') WHERE id="&callID)
elseif StaID="1" then
	db_execute("update chamadas set sysUserAtend="&session("User")&", DataHoraAtend=NOW(), StaID=1 WHERE id="&callID)
elseif StaID="2" then
	db_execute("update chamadas set StaID=2 WHERE id="&callID)
end if
%>
$("#interacao").html("");