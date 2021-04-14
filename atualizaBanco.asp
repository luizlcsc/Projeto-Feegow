<!--#include file="connect.asp"-->
<%
'on error resume next

set b = db.execute("select * from cliniccentral.updates_recebidos where isnull(Executado) order by id")
while not b.eof
    if b("Banco")="" then
        Banco = "cliniccentral"
    else
        Banco = b("Banco")
    end if
    CliString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database="&Banco&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
    Set Clidb = Server.CreateObject("ADODB.Connection")
    Clidb.Open CliString

    Clidb.execute( b("codigoSQL") )
    db_execute("update cliniccentral.updates_recebidos set executado=1 where id="&b("id"))
b.movenext
wend
b.close
set b=nothing
%>