<!--#include file="connect.asp"-->
<%
db_execute("update sys_financialexpensetype set Rateio="&ref("Checked")&" where id="&ref("I"))
%>