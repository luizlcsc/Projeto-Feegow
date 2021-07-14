<%
Session.Timeout=600
session.LCID=1046
ConnString = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&session("Banco")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString
%>