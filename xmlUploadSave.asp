<!--#include file="connect.asp"-->
<%
db_execute("insert into retornoxml (Arquivo, sysUser) values ('"& req("FileName") &"', "& session("User") &")")
%>