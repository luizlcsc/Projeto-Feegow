<!--#include file="connect.asp"-->
<%
ProcAtID = req("ProcAtID")
spl = split(ProcAtID, "_")

db_execute("update atendimentosprocedimentos set "&spl(0)&"='"&ref("Val")&"' where id="&spl(1))
%>