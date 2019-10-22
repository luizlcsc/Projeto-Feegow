<!--#include file="connect.asp"-->
<%response.charset="utf-8" %>
<table class="table table-bordered">
    <thead>
        <tr>
            <th>Cód. Cliente</th>
            <th>Cliente</th>
            <th>CPF/CNPJ</th>
            <th>Cidade</th>
            <th>Data do Aceite</th>
    </thead>
    <tbody>
    <%
    set l = db.execute("select if(l.Cliente=515, l.NomeEmpresa, c.NomePaciente) NomeCliente, l.id, l.Cliente, if(isnull(c.Documento) or c.Documento='', c.CPF, c.Documento) CPF, c.Cidade, l.DataHora from cliniccentral.licencas l LEFT JOIN clinic5459.pacientes c ON c.id=l.Cliente WHERE l.Status='C' ORDER BY c.NomePaciente")
    while not l.eof
        %>
        <tr>
            <td><%= l("id")&"-"&l("Cliente") %></td>
            <td><%= ucase(l("NomeCliente")&"") %></td>
            <td><%= l("CPF") %></td>
            <td><%= ucase(l("Cidade")&"") %></td>
            <td><%= l("DataHora") %></td>
        </tr>
        <%
    l.movenext
    wend
    l.close
    set l=nothing
    %>
    </tbody>
</table>
