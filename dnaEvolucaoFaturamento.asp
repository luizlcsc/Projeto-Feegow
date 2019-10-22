<!--#include file="connect.asp"-->
<%

response.charset = "utf-8"
%>

<table border="1" width="100%">
    <tr>
        <td>Mes</td>
        <td>Valor</td>
        <td>Funcionários</td>
        <td>Clínicas/Consultórios</td>
    </tr>
<%
    set dist = db.execute("select distinct month(DataHora) Mes, year(DataHora) Ano from cliniccentral.estatisticas order by DataHora")
    while not dist.eof
        set conta = db.execute("select sum(Value) Valor from clinic5459.sys_financialmovement where Type='Bill' and month(Date)="& dist("Mes") &" and year(Date)="& dist("Ano") &"")

        %>
        <tr>
            <td><%= dist("Mes") &"/"& dist("Ano") %></td>
            <td><%= conta("Valor") %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist=nothing
%>
</table>
