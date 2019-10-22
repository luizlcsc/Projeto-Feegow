<h2 class="text-center">AGENDAMENTOS POR USUÁRIO - ANALÍTICO</h2>

<%
set un = db.execute("select distinct UnidadeID from cliniccentral.rel_agendamentosporusuario where not isnull(idAgendamento) and sysUser="& session("User"))
while not un.eof
    cCol = 2
    TotalUN = 0

    set sqlUn = db.execute("select id, Nome FROM (SELECT id, NomeFantasia as Nome FROM sys_financialcompanyunits WHERE sysActive=1 UNION ALL SELECT 0 as id, NomeFantasia as Nome FROM empresa WHERE id=1)t WHERE id IN ("& un("UnidadeID") &")")
    if not sqlUn.eof then
        %>
        <h3><%= sqlUn("Nome") %></h3>
        <%
    end if
    %>
    <table class="table table-condensed table-hover">
        <thead>
            <tr>
                <th width="20%">USUÁRIO</th>
                <th width="10%">DATA AÇÃO</th>
                <th width="10%">HORA AÇÃO</th>
                <th width="10%">DATA AGENDADA</th>
                <th width="10%">HORA AGENDADA</th>
                <th width="25%">SERVIÇO</th>
                <th width="25%">PROFISSIONAL</th>
            </tr>
        </thead>
        <tbody>
            <%
            set ag = db.execute("select ra.*, proc.NomeProcedimento, prof.NomeProfissional from cliniccentral.rel_agendamentosporusuario ra LEFT JOIN procedimentos proc ON proc.id=ra.ProcedimentoID LEFT JOIN profissionais prof ON prof.id=ra.ProfissionalID where ra.sysUser="& session("User") &" and ra.UnidadeID="& un("UnidadeID") &" order by ra.Usuario, ra.Data, ra.Hora")
            while not ag.eof
                if ag("Usuario")=1 then
                    Nome = "Agendamento online"
                else
                    Nome = nameInTable(ag("Usuario"))
                end if
                %>
                <tr>
                    <td><%= Nome %></td>
                    <td><%= ag("Data") %></td>
                    <td><%= ft(ag("Hora")) %></td>
                    <td><%= ag("DataAG") %></td>
                    <td><%= ft(ag("HoraAG")) %></td>
                    <td><%= ag("NomeProcedimento") %></td>
                    <td><%= ag("NomeProfissional") %></td>
                </tr>
                <%
            ag.movenext
            wend
            ag.close
            set ag = nothing
                %>
        </tbody>
    </table>

    <%
un.movenext
wend
un.close
set un = nothing
%>