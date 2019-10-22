<!--#include file="connect.asp"-->
<%
if request.QueryString("T")="C" then 'close
	session("UsersChat") = replace(session("UsersChat"), "|"&request.QueryString("I")&"A|", "|"&request.QueryString("I")&"|")
	db_execute("update sys_users set novasmsgs=replace(novasmsgs, '|"&request.QueryString("I")&"|', '') where id="&session("User"))
else
	session("UsersChat") = replace(session("UsersChat"), "|"&request.QueryString("I")&"|", "|"&request.QueryString("I")&"A|")
end if
%>