﻿<%
Session.Timeout=600
session.LCID=1046
'ConnString = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&session("Banco")&";uid=root;pwd=pipoca453;"
ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database="&session("Banco")&";uid=root;pwd=pipoca453;"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString

function req(Val)
	req = replace(request.QueryString(Val), "'", "''")
end function

%>