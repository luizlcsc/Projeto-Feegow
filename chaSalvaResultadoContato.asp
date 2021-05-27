<!--#include file="connect.asp"-->
<%
CallID = req("CallID")
resClicado = ref("result")

db_execute("update chamadas set Resultado="&treatvalnull(ref("result")&", Subresultado="&treatvalnull(ref("subresult"&resClicado)&", Notas='"&ref("Notas"&CallID)&"' WHERE id="&CallID)

if ref("result"&CallID)<>"" then
	procSC = ref("result"&CallID)
end if
if ref("subresult"&CallID)<>"" then
	procSC = ref("subresult"&CallID)
end if


if procSC<>"" then
	set scr = db.execute("select s.* from chamadasscript s LEFT JOIN chamadasresultados r on s.id=r.ScriptID WHERE r.id="&procSC)
	if not scr.eof then
		%>
		$("#script").html('<%=scr("Texto")%>');
		<%
	else
		%>
		$("#script").html('');
		<%
	end if
end if
%>