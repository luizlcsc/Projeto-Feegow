<!--#include file="connect.asp"-->
<%
if req("T")="C" then 'close
	session("UsersChat") = replace(session("UsersChat"), "|"&req("I")&"A|", "|"&req("I")&"|")
	db_execute("update sys_users set novasmsgs=replace(novasmsgs, '|"&req("I")&"|', '') where id="&session("User"))
else
	session("UsersChat") = replace(session("UsersChat"), "|"&req("I")&"|", "|"&req("I")&"A|")
end if
%>