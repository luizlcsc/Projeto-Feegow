<!--#include file="connect.asp"-->
<%
if req("T")="Form" then
	db_execute("update buiformspreenchidos set Autorizados='"&req("S")&"' where id="&req("I"))
end if
%>