<!--#include file="connect.asp"-->
<%
if De="" then
	De=request.QueryString("D")
end if
if Para="" then
	Para=request.QueryString("P")
end if
%>
<!--#include file="callTalk.asp"-->