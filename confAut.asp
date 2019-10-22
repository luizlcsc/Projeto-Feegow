<%

Session.Contents.Remove("AutenticadoPHP")

Token = Request.Form("t")

Response.Cookies("tk") = Token
Response.Cookies("tk").Expires = Date() + 1
%>