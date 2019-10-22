<!--#include file="connect.asp"-->
<table border="1">
<%
response.Buffer
set l = db.execute ("select * from cliniccentral.licencas where Servidor='localhost' and Status='C'")
while not l.eof
    response.Flush()
    set conta = db.execute("select count(id) total from cliniccentral.licencaslogins where date(DataHora)>='2018-09-01' and LicencaID="& l("id"))
    %>
    <tr>
    <%= "<td>"& l("id") &" </td><td> "& l("NomeContato") &" </td><td> "& l("NomeEmpresa") &" </td><td> "& l("Cliente") &" </td><td> "& conta("Total") &"</td><td> "& l("Cupom") &"</td>" %>
    </tr>
    <%
l.movenext
wend
l.close
set l = nothing
%>
</table>