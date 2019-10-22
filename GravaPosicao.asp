<!--#include file="connect.asp"-->
<%
pTop=request.QueryString("y")
pLeft=request.QueryString("x")
id=request.QueryString("id")
db_execute("update buiCamposForms set pTop="&pTop&", pLeft="&pLeft&" where id="&id)
%>Feito.