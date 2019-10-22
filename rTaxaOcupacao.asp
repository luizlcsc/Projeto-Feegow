<!--#include file="connect.asp"-->
<%
Mes = req("Mes")
Ano = req("Ano")
Unidades = replace(req("Unidades"), "|", "")

response.Buffer
%>
<h2 class="text-center">TAXA DE OCUPAÇÃO DE AGENDAS <br /> <small><%= ucase(monthname(Mes)) %></small></h2>

<div class="container">
    <table class="table table-striped table-bordered table-hover">
        <tbody>
            <%
            'set prof = db.execute("select group_concat(distinct ProfissionalID) Profissionais from agendaocupacoes where month(Data)="& Mes &" AND year(Data)="& Ano &" AND not isnull(ProfissionalID)")
            'Profissionais = prof("Profissionais")
            '    response.write(Profissionais)
            set esp = db.execute("select group_concat(distinct prof.EspecialidadeID) Especialidades from profissionais prof LEFT JOIN agendaocupacoes ao ON ao.ProfissionalID=prof.id where month(ao.Data)="& Mes &" AND year(ao.Data)="& Ano &" AND not isnull(ao.ProfissionalID)")
            Especialidades = esp("Especialidades")
                'response.Write(Especialidades)
            splEsp = split(Especialidades, ",")
            for i=0 to ubound(splEsp)
                strGrades = ""
                strAgendamentos = ""
                strBloqueios = ""
                strLivres = ""
                response.Flush()
                set pEsp = db.execute("select id, especialidade from especialidades where id="& splEsp(i))
                if not pEsp.eof then
                    Especialidade = pEsp("Especialidade")
                    EspecialidadeID = pEsp("id")
                    %>
                    <tr class="success">
                        <th colspan="100"><%= Especialidade %></th>
                    </tr>
                    <tr>
                        <th></th>
                        <%
                        UnidadesOrdem = ""
                        set u = db.execute("select * from (select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia FROM sys_financialcompanyunits) t WHERE id IN("& Unidades &")")
                        while not u.eof
                            UnidadesOrdem = UnidadesOrdem &", "& U("id")
                            %>
                            <th><%= left(u("NomeFantasia"), 14) %></th>
                            <%
                        u.movenext
                        wend
                        u.close
                        set u=nothing
                        %>
                    </tr>
                    <tr>
                        <th>Número de agendas</th>
                        <%
                        splUO = split(UnidadesOrdem, ", ")
                        for j=1 to ubound(splUO)
                            UnidadeID = splUO(j)

                            set pg = db.execute("SELECT count(DISTINCT ao.LocalID, ao.DATA, prof.EspecialidadeID) grades FROM agendaocupacoes ao LEFT JOIN locais l ON l.id=ao.LocalID LEFT JOIN profissionais prof ON prof.id=ao.ProfissionalID WHERE MONTH(DATA)="& Mes &" AND YEAR(DATA)="& Ano &" AND l.UnidadeID="& UnidadeID &" AND prof.EspecialidadeID="& EspecialidadeID)
                            Grades = pg("Grades")

                            strGrades = strGrades &"|"& Grades
                            %>
                            <td><%= Grades %></td>
                            <%
                        next
                        %>
                    </tr>
                    <tr>
                        <th>Horários agendados</th>
                        <%
                        splUO = split(UnidadesOrdem, ", ")
                        for j=1 to ubound(splUO)
                            UnidadeID = splUO(j)

                            set pg = db.execute("SELECT ifnull(SUM(HAgendados),0) Agendamentos FROM agendaocupacoes ao LEFT JOIN locais l ON l.id=ao.LocalID LEFT JOIN profissionais prof ON prof.id=ao.ProfissionalID WHERE MONTH(DATA)="& Mes &" AND YEAR(DATA)="& Ano &" AND l.UnidadeID="& UnidadeID &" AND prof.EspecialidadeID="& EspecialidadeID)
                            Agendamentos = pg("Agendamentos")

                            strAgendamentos = strAgendamentos &"|"& Agendamentos

                            %>
                            <td><%= Agendamentos %></td>
                            <%
                        next
                        %>
                    </tr>
                    <tr>
                        <th>Horários bloqueados</th>
                        <%
                        splUO = split(UnidadesOrdem, ", ")
                        for j=1 to ubound(splUO)
                            UnidadeID = splUO(j)

                            set pg = db.execute("SELECT ifnull(SUM(HBloqueados),0) Bloqueios FROM agendaocupacoes ao LEFT JOIN locais l ON l.id=ao.LocalID LEFT JOIN profissionais prof ON prof.id=ao.ProfissionalID WHERE MONTH(DATA)="& Mes &" AND YEAR(DATA)="& Ano &" AND l.UnidadeID="& UnidadeID &" AND prof.EspecialidadeID="& EspecialidadeID)
                            Bloqueios = pg("Bloqueios")

                            strBloqueios = strBloqueios &"|"& Bloqueios

                            %>
                            <td><%= Bloqueios %></td>
                            <%
                        next
                        %>
                    </tr>
                    <tr>
                        <th>Horários livres</th>
                        <%
                        splUO = split(UnidadesOrdem, ", ")
                        for j=1 to ubound(splUO)
                            UnidadeID = splUO(j)

                            set pg = db.execute("SELECT ifnull(SUM(HLivres),0) Livres FROM agendaocupacoes ao LEFT JOIN locais l ON l.id=ao.LocalID LEFT JOIN profissionais prof ON prof.id=ao.ProfissionalID WHERE MONTH(DATA)="& Mes &" AND YEAR(DATA)="& Ano &" AND l.UnidadeID="& UnidadeID &" AND prof.EspecialidadeID="& EspecialidadeID)
                            Livres = pg("Livres")
                            strLivres = strLivres &"|"& Livres

                            %>
                            <td><%= Livres %></td>
                            <%
                        next
                        %>
                    </tr>
                    <%
                    splGrades = split(strGrades, "|")
                    splAgendamentos = split(strAgendamentos, "|")
                    splBloqueios = split(strBloqueios, "|")
                    splLivres = split(strLivres, "|")
                    %>
                    <tr>
                        <th>Agendamentos por grade</th>
                        <%
                        splUO = split(UnidadesOrdem, ", ")
                        for j=1 to ubound(splUO)
                            UnidadeID = splUO(j)
                            if ccur(splGrades(j))>0 then
                                AgendamentosPorGrade = fn(ccur(splAgendamentos(j))/ccur(splGrades(j)))
                            else
                                AgendamentosPorGrade = 0
                            end if
                            %>
                            <td><%= AgendamentosPorGrade %></td>
                            <%
                        next
                        %>
                    </tr>
                    <tr>
                        <th>Capacidade da agenda</th>
                        <%
                        splUO = split(UnidadesOrdem, ", ")
                        for j=1 to ubound(splUO)
                            UnidadeID = splUO(j)
                            CapacidadeAgenda = ccur(splAgendamentos(j)) + ccur(splBloqueios(j)) + ccur(splLivres(j))
                            %>
                            <td><%= CapacidadeAgenda %></td>
                            <%
                        next
                        %>
                    </tr>
                    <tr>
                        <th>Taxa de ocupação</th>
                        <%
                        splUO = split(UnidadesOrdem, ", ")
                        for j=1 to ubound(splUO)
                            UnidadeID = splUO(j)
                            HorariosTotais = ccur(splAgendamentos(j)) + ccur(splBloqueios(j)) + ccur(splLivres(j))
                            if HorariosTotais>0 then
                                TaxaOcupacao = ccur(splAgendamentos(j)) / ( HorariosTotais )
                                TaxaOcupacao = TaxaOcupacao*100
                            else
                                TaxaOcupacao = 100
                            end if
                            %>
                            <td><%= fn(TaxaOcupacao) %>%</td>
                            <%
                        next
                        %>
                    </tr>
                    <%
                end if
            next
            %>
        </tbody>
    </table>
</div>
