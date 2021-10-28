<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
dataDe = req("De")
dataAte = req("Ate")
usuario = req("Usuario")
sucesso = req("Sucesso")
sqldata = ""
sqlsucesso = ""

if sucesso <> "" then
    sqlsucesso = " AND Sucesso = "&sucesso
end if
if usuario <> "" then
    sqlUser = " AND l.UserID = "&ccur(usuario)&" "
end if
if dataDe <> "" then
    sqldata = " AND date(l.DataHora) between date("&mydatenull(dataDe)&") AND date("&mydatenull(dataAte)&")"
end if
sql = "SELECT l.*,lu.Nome FROM cliniccentral.licencaslogins L LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id = l.UserID WHERE l.LicencaID = '"&ccur(replace(session("Banco"), "clinic", ""))&"' "&sqlUser&" "&sqldata & sqlsucesso&"  ORDER BY l.DataHora Desc LIMIT 500"

set logs = dbc.execute(sql)
'response.write(sql)


%>
<div class="container">
<br><br>
    <table class="table">
        <thead>
          <tr>
            <th>Data e hora</th>
            <th>Sucesso</th>
            <th>Usuário</th>
            <th>IP</th>
            <th>Dispositivo</th>
          </tr>
        </thead>
        <tbody>
        <%
        while not logs.EOF
            sucesso = "<i style='color:green' class='far fa-check-circle'></i> <strong>Sucesso</strong>"
            if logs("Sucesso") = "0" then
                sucesso = "<i style='color:orange' class='far fa-exclamation-circle'></i> <strong>Sem sucesso</strong>"
            end if

            agente = logs("Agente")
            if InStr(1, agente, "Windows NT 10") > 0 then
                agente = "Windows 10"
            end if
            if InStr(1, agente, "Macintosh;") > 0 then
                agente = "Macintosh"
            end if
            if InStr(1, agente, "Windows NT 6.2") > 0 then
                agente = "Windows 8"
            end if
            if InStr(1, agente, "Linux; Android") > 0 then
                agente = "Windows 8"
            end if
            if InStr(1, agente, "iPhone; CPU iPhone") > 0 then
                agente = "iPhone"
            end if
            if InStr(1, agente, "Windows NT 6.3") > 0 then
                agente = "Windows 8"
            end if
            if InStr(1, agente, "Windows NT 6.1") > 0 then
                agente = "Windows 7"
            end if
            if InStr(1, agente, "Windows NT 6.0") > 0 then
                agente = "Windows Vista"
            end if
            if InStr(1, agente, "iPad") > 0 then
                agente = "iPad"
            end if
            if InStr(1, agente, "Windows NT 5.1") > 0 then
                agente = "Windows XP"
            end if
            %>
            <tr>
                <td>
                    <%=logs("DataHora")%>
                </td>
                <td>
                    <%=sucesso%>
                </td>
                <td>
                    <%=logs("Nome")%>
                </td>
                <td>
                    <%=logs("IP")%>
                </td>
                <td>
                    <%=agente%>
                </td>
            </tr>
            <%
        logs.movenext
        wend
        logs.close

        %>
        </tbody>
    </table>
</div>