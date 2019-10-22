<!--#include file="connect.asp"-->
<%

response.charset = "utf-8"
%>

<table border="1" width="100%">
    <tr>
        <td>Data</td>
        <td>Profissionais</td>
        <td>Funcionários</td>
        <td>Clínicas/Consultórios</td>
    </tr>
<%
    Profissionais = 0
    Funcionarios = 0
    Clinicas = 0
    set dist = db.execute("select distinct month(DataHora) Mes, year(DataHora) Ano from cliniccentral.estatisticas order by DataHora")
    while not dist.eof
        set conta = db.execute("select (sum(ProfissionaisAtivos)+sum(ProfissionaisInativos)) as Profissionais, (sum(FuncionariosAtivos)+sum(FuncionariosInativos)) Funcionarios, (sum(Unidades)) Clinicas from cliniccentral.estatisticas where month(DataHora)="& dist("Mes") &" and year(DataHora)="& dist("Ano") &"")

        Profissionais = Profissionais+ccur(conta("Profissionais"))
        Funcionarios = Funcionarios+ccur(conta("Funcionarios"))
        Clinicas = Clinicas+ccur(conta("Clinicas"))
        %>
        <tr>
            <td><%= dist("Mes") &"/"& dist("Ano") %></td>
            <td><%= Profissionais %></td>
            <td><%= Funcionarios %></td>
            <td><%= Clinicas %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist=nothing
%>
</table>
