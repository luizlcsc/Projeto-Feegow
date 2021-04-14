<!--#include file="connect.asp"-->
<%
LicencaID = req("L")

set lic = db.execute("select p.NomePaciente, p.Cidade from cliniccentral.licencas l LEFT JOIN clinic5459.pacientes p ON p.id=l.Cliente where l.id="& LicencaID)
'Servidor = lic("Servidor")
'ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=192.168.193."& Servidor &";Database=clinic105;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'Set dbServ = Server.CreateObject("ADODB.Connection")
'dbServ.Open ConnString

response.write( lic("NomePaciente") &"<br>"& lic("Cidade") )
%>