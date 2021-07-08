
<!--#include file="functions.asp"-->
<%

Session.Contents.Remove("AutenticadoPHP")

Token = ref("t")

Response.Cookies("tk") = Token
Response.Cookies("tk").Expires = Date() + 1
%>