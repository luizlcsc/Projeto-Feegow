<!--#include file="connect.asp"-->
<%
if request.QueryString("T")="Form" then
	db_execute("update buiformspreenchidos set Autorizados='"&request.QueryString("S")&"' where id="&request.QueryString("I"))
end if
%>