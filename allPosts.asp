<%
ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database="&session("Banco")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString

db_execute("insert into cliniccentral.allposts(Post) values ('"&ref()&"')")
%>