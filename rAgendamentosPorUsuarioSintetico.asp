<h2 class="text-center">AGENDAMENTOS POR USUÁRIO - SINTÉTICO</h2>

<%
TotalGeral = 0
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
                <th width="10%">DATA</th>
                <th width="20%">USUÁRIO</th>
                <%
                if ProcedimentosGrupos<>"" then
                    splPG = split(ProcedimentosGrupos, ", ")
                    for ig=0 to ubound(splPG)
                        GrupoID = replace(splPG(ig), "|", "")
                        NomeGrupo = ""
                        set pg = db.execute("select NomeGrupo from Procedimentosgrupos where id="& GrupoID)
                        if not pg.eof then
                            NomeGrupo = pg("NomeGrupo")
                        end if
                        %>
                        <th><%= NomeGrupo %></th>
                        <%
                        cCol = cCol+1
                    next
                end if

                if ProcedimentosTipos<>"" then
                    splPT = split(ProcedimentosTipos, ", ")
                    for it=0 to ubound(splPT)
                        TipoID = replace(splPT(it), "|", "")
                        TipoProcedimento = ""
                        set pt = db.execute("select TipoProcedimento from tiposprocedimentos where id="& TipoID)
                        if not pt.eof then
                            TipoProcedimento = pt("TipoProcedimento")
                        end if
                        %>
                        <th><%= TipoProcedimento %></th>
                        <%
                        cCol = cCol+1
                    next
                end if
                %>
                <th>TOTAL DE AGENDAMENTOS</th>
            </tr>
        </thead>
        <tbody>
            <%
            set usu = db.execute("select distinct Data, Usuario from cliniccentral.rel_agendamentosporusuario where UnidadeID="& un("UnidadeID") &" and sysUser="& session("User") &" and not isnull(idAgendamento) order by Data")
            while not usu.eof
                set conta = db.execute("select count(id) Total from cliniccentral.rel_agendamentosporusuario where UnidadeID="& un("UnidadeID") &" and Data="& mydatenull(usu("Data")) &" and Usuario="& usu("Usuario") &" and not isnull(idAgendamento) and sysUser="& session("User"))
                if usu("Usuario")=1 then
                    Nome = "Agendamento online"
                else
                    Nome = nameInTable(usu("Usuario"))
                end if
                %>
                <tr>
                    <td><%= usu("Data") %></td>
                    <td><%= Nome %></td>
                    <%
                    if ProcedimentosGrupos<>"" then
                        splPG = split(ProcedimentosGrupos, ", ")
                        for ig=0 to ubound(splPG)
                            GrupoID = replace(splPG(ig), "|", "")
                            set cpg = db.execute("select count(id) Total from cliniccentral.rel_agendamentosporusuario where UnidadeID="& un("UnidadeID") &" and Data="& mydatenull(usu("Data")) &" and Usuario="& usu("Usuario") &" and not isnull(idAgendamento) and sysUser="& session("User") &" and GrupoID="& GrupoID)
                            %>
                            <td><%= cpg("Total") %></td>
                            <%
                        next
                    end if

                    if ProcedimentosTipos<>"" then
                        splPT = split(ProcedimentosTipos, ", ")
                        for it=0 to ubound(splPT)
                            TipoID = replace(splPT(it), "|", "")
                            set cpt = db.execute("select count(id) Total from cliniccentral.rel_agendamentosporusuario where UnidadeID="& un("UnidadeID") &" and Data="& mydatenull(usu("Data")) &" and Usuario="& usu("Usuario") &" and not isnull(idAgendamento) and sysUser="& session("User") &" and TipoProcedimentoID="& TipoID)
                            %>
                            <td><%= cpt("Total") %></td>
                            <%
                        next
                    end if

                    TotalUN = TotalUN + ccur(conta("Total"))
                    TotalGeral = TotalGeral + ccur(conta("Total"))
                    %>
                    <th><%= conta("Total") %></th>
                </tr>
                <%
            usu.movenext
            wend
            usu.close
            set usu=nothing
            %>
        </tbody>
        <tfoot>
            <tr>
                <th colspan="<%= cCol %>"></th>
                <th class=""><%= TotalUN %></th>
            </tr>
        </tfoot>
    </table>
    <%
un.movenext
wend
un.close
set un=nothing
%>
<h3>Total geral: <%= TotalGeral %></h3>