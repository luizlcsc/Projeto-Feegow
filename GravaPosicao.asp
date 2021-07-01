<!--#include file="connect.asp"-->
<%
pTop=req("y")
pLeft=req("x")
id=req("id")
db_execute("update buiCamposForms set pTop="&pTop&", pLeft="&pLeft&" where id="&id)
%>Feito.