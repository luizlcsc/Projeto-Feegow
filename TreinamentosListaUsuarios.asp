<!--#include file="connect.asp"-->
<table class="table table-condensed table-hover">
    <tbody>
        <%
        q = req("U")
        set u = db.execute("SELECT lu.id, upper(ifnull(lu.Nome,'')) Nome, lower(lu.email) Email, upper(IFNULL(p.NomePaciente, '')) Empresa FROM cliniccentral.licencasusuarios lu LEFT JOIN cliniccentral.licencas l ON l.id=lu.LicencaID LEFT JOIN clinic5459.pacientes p ON p.id=l.Cliente WHERE Email<>'' AND senha<>'' AND Email NOT LIKE '%-' AND l.`Status`<>'B' AND (Email LIKE '%"& q &"%' OR Nome LIKE '%"& q &"%') ORDER BY lu.Nome, lu.Email LIMIT 100")
        while not u.eof
            %>
            <tr onclick="$('#Usuario').val('<%= u("Email") &" :: "& u("Nome") %>'); $('#LicencaUsuarioID').val('<%= u("id") %>'); $('#divUsuarios').css('display', 'none');">
                <td><%= u("Email") %></td>
                <td><%= u("Nome") %></td>
                <td><%= u("Empresa") %></td>
            </tr>
            <%
        u.movenext
        wend
        u.close
        set u=nothing
            %>
    </tbody>
</table>