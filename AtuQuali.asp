<%
response.Buffer

ConnString1 = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid=root;pwd=pipoca453;"
Set dbServ1 = Server.CreateObject("ADODB.Connection")
dbServ1.Open ConnString1

set lics = dbServ1.Execute("select id, Servidor from licencas where servidor like '%aws%'")
while not lics.eof

    response.flush()

    ConnString = "Driver={MySQL ODBC 8.0 ANSI Driver};Server="& lics("Servidor") &";Database=cliniccentral;uid=root;pwd=pipoca453;"
    Set dbServ = Server.CreateObject("ADODB.Connection")
    dbServ.Open ConnString

    response.write( lics("id") &"<br>")

    set q = dbServ.execute("select id, Qualidometro from licencasusuarios where not isnull(Qualidometro) and LicencaID="& lics("id"))
    while not q.eof
        dbServ1.Execute("update licencasusuarios set QualiServer="& q("Qualidometro") &" where id="& q("id") )
    q.movenext
    wend
    q.close
    set q=nothing

lics.movenext
wend
lics.close
set lics = nothing
%>
<%= time() %>