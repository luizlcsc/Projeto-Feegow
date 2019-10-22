<!--#include file="connect.asp"-->
<%
set lic = db.execute("select id, ultimoBackup, nomeContato, NomeEmpresa, Servidor from cliniccentral.licencas where date(ultimoBackup)<>curdate() and Status<>'T' and Servidor='192.168.193.45' order by id limit 1")
if not lic.eof then
    ConnStringDB = "Driver={MySQL ODBC 5.3 ANSI Driver};Server="& lic("Servidor") &";Database=clinic"&lic("id")&";uid=root;pwd=pipoca453;"
    Set dbDB = Server.CreateObject("ADODB.Connection")
    dbDB.Open ConnStringDB
    %>
    <h3><%= lic("id") &" - "& lic("NomeEmpresa") &" - "& lic("NomeContato") %></h3>
    <%
    response.Buffer
    set c = dbDB.execute("select i.* from information_schema.`TABLES` i where i.TABLE_SCHEMA='clinic"& lic("id") &"' and i.TABLE_TYPE='BASE TABLE'")
    while not c.eof
        response.Flush()

        response.write(c("TABLE_NAME") & "...<br>")
        dbDB.execute("ALTER TABLE `"& c("TABLE_NAME") &"`	ADD COLUMN `DHUp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")


    c.movenext
    wend
    c.close
    set c=nothing
    %>
    <script type="text/javascript">
        location.reload();
    </script>
    <%
    db.execute("update cliniccentral.licencas set ultimoBackup=now() where id="& lic("id"))
end if
%>