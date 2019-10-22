<%
ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database="&session("Banco")&";uid=root;pwd=pipoca453;"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString

db_execute("insert into cliniccentral.allposts(Post) values ('"&request.form()&"')")
%>