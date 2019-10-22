<!--#include file="connect.asp"-->
<%
val = Int(req("AutoSalvarFormulario"))
db_execute("update sys_config SET AutoSalvarFormulario = "&val &" WHERE id = 1")
%>