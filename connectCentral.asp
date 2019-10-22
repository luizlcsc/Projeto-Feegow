<%
'ConnStringCentral = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=cliniccentral;uid=root;pwd=pipoca453;"
ConnStringCentral = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid=root;pwd=pipoca453;"
Set dbc = Server.CreateObject("ADODB.Connection")
dbc.Open ConnStringCentral
%>