<!--#include file="connect.asp"-->
<table class="table table-striped table-condensed table-hover">
    <thead>
        <tr>
            <th>PROFISSIONAL</th>
            <th>ESPECIALIDADE</th>
            <th>BAIRRO</th>
            <th>CIDADE</th>
        </tr>
    </thead>
    <tbody>
    <%
    if session("banco")="clinic105" then
        cp = 0
        set l = db.execute("select l.id, b.Nome, b.Bairro, b.Cidade, b.Estado from cliniccentral.licencas l LEFT JOIN bafim.paciente b on b.id=l.Cliente WHERE l.Status='C' and b.Estado like '%"&req("Estado")&"%'")
        while not l.eof
            set cpl = db.execute("select count(id) total from clinic"&l("id")&".pacientes")
            npac = ccur(cpl("total"))
                cp = cp+npac
                %>
                <tr>
                    <td><%=ucase(l("Nome")) %></td>
                    <td><%=ucase(l("Bairro")) %></td>
                    <td><%=ucase(l("Cidade")) %></td>
                    <td><%=npac %></td>
                </tr>
                <%
        l.movenext
        wend
        l.close
        set l=nothing
    end if
    %>
    </tbody>
</table>
<%=cp %> pacientes.
