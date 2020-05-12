<!--#include file="connect.asp"-->
<%
Ramal = req("Ramal")
db.execute("update sys_users set Ramal='' WHERE Ramal='"& Ramal &"'")
db.execute("update sys_users set Ramal='"& Ramal &"' WHERE id="& req("U"))
%>