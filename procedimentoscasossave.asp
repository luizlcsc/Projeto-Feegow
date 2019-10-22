<!--#include file="connect.asp"-->
<%
PK = replace(req("Casos"), "Casos", "")
db_execute("update procedimentoskits set Casos='"&ref("Casos"&PK)&"' where id="&PK)
%>