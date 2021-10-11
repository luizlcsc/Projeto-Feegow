<!--#include file="connect.asp"-->
<%

Acao = req("A")
id = req("I")
Data = ref("bData")
PacienteID = ref("bagePacienteID")
TabelaID = ref("bageTabela")
Unidades = ref("bUnidades")
Regiao = ref("bRegiao")
GrupoID = ref("bGrupoID")
ProcedimentoID = ref("bProcedimentoID")
ComplementoID = ref("bComplemento")
EspecialidadeID = ref("bEspecialidadeID")
SubespecialidadeID = ref("bSubespecialidadeID")
ProfissionalID = ref("bProfissionalID")
BuscaID = req("BuscaID")


set ab = db.execute("select ab.*, proc.NomeProcedimento, proc.Valor, comp.SubespecialidadeID, esp.Especialidade FROM agendabusca ab LEFT JOIN procedimentos proc ON proc.id=ab.ProcedimentoID LEFT JOIN profissionaissubespecialidades comp ON comp.id=ab.SubespecialidadeID LEFT JOIN especialidades esp ON esp.id=ab.EspecialidadeID WHERE ab.sysUser="& session("User") &" and isnull(ab.Cancelada) AND ab.id="&BuscaID)
if not ab.eof then
    %>

            <hr class="short alt" />
            <table data-busca="<%=BuscaID%>" class="tabela-resultado-horarios table table-condensed table-bordered table-hover table-striped">
            <%

            Data = ab("Data")
            uData = Data+4
            'lista as grades dos profissionais ordenando por unidade, ocorrencias
            Unidades = replace(Unidades, "|", "")
            if Unidades<>"" then
                sqlUn = " and l.UnidadeID IN ("& Unidades &") "
            end if
            UltimaUnidade="-1"
            set grades = db.execute("select ass.ProfissionalID, prof.NomeProfissional, esp.Especialidade, l.UnidadeID, u.NomeFantasia from agendabuscaprofissionais oc left join assfixalocalxprofissional ass on ass.ProfissionalID=oc.ProfissionalID LEFT JOIN profissionais prof ON prof.id=ass.ProfissionalID LEFT JOIN especialidades esp ON esp.id=prof.EspecialidadeID left join locais l on l.id=ass.LocalID left join sys_financialcompanyunits u ON u.id=l.UnidadeID where oc.sysUser="& session("User") & sqlUn &"  and not isnull(l.UnidadeID) GROUP BY oc.ProfissionalID, l.UnidadeID order by l.UnidadeID, oc.Ocorrencias desc")
            while not grades.eof
                ProfissionalID = grades("ProfissionalID")
                UnidadeID = grades("UnidadeID")
                if grades("UnidadeID")<>UltimaUnidade then
                    NomeUnidade = grades("NomeFantasia")
                    %>
                        <tr class="success">
                            <th></th>
                            <th><%= NomeUnidade %></th>
                            <%
                            nData = Data
                            while nData<uData
                                %>
                                <th><%= left(nData, 5) &" "& ucase(left(weekdayname(weekday(nData)), 3)) %></th>
                                <%
                                nData = nData+1
                            wend
                            %>
                        </tr>
                    <%
                end if
                set ab = db.execute("select ab.*, proc.Valor, proc.NomeProcedimento from agendabusca ab LEFT JOIN procedimentos proc ON proc.id=ab.ProcedimentoID where ab.sysUser="&session("User")&" and isnull(ab.Cancelada) and ab.ProfissionaisPerm like '%|"& ProfissionalID &"|%' and isnull(ab.AgendamentoID)")
                while not ab.eof
                    ProcedimentoID = ab("ProcedimentoID")

                    'response.write(ProcedimentoID&"|"&TabelaID&"|"&UnidadeID&"|"&ProfissionalID&"|"&EspecialidadeID&"|"&GrupoID)

                    ValorTabela = calcValorProcedimento(ProcedimentoID, TabelaID, UnidadeID, ProfissionalID, EspecialidadeID, GrupoID,0)

                %>
                <tr class="linha-unidade" style="display: none;" data-unidade="<%=UnidadeID%>" data-profissional="<%=ProfissionalID%>">
                    <td  style="vertical-align:top">
                        <%= ab("NomeProcedimento") %>
                        <br />
                        <div class="label label-primary">
                            R$ <%= fn(ValorTabela) %>
                        </div>
                    </td>
                    <td style="vertical-align:top">
                        <%= ucase(grades("NomeProfissional")&"") %> <br />
                        <small><%= grades("Especialidade") %></small>
                    </td>
                    <%
                    nData = Data
                    while nData<uData
                        DiaSemana = weekday(nData)
                        %>
                        <td style="vertical-align:top; width:230px" data-date="<%=nData%>" class="data-disponivel">
                            <%
                            set ass = db.execute("select ass.id, ass.HoraDe, ass.HoraA, ass.Intervalo, ass.LocalID FROM assfixalocalxprofissional ass LEFT JOIN locais l ON l.id=ass.LocalID WHERE ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="& DiaSemana &" and l.UnidadeID="& UnidadeID &" ORDER BY ass.HoraDe")
                            while not ass.eof
                                HoraDe = ass("HoraDe")
                                HoraA = ass("HoraA")
                                Intervalo = ass("Intervalo")
                                LocalID = ass("LocalID")
                                GradeID = ass("id")
                                Hora = HoraDe
                                conta = 0
                                while Hora<HoraA
                                    Exibe = 1
                                    if Exibe=1 then
                                        conta = conta+1
                                        classe = ProfissionalID &"_"& UnidadeID &"_"& replace(nData, "/", "") &"_"& replace(ft(Hora), ":", "")
                                        onclick = "abreAgenda("& replace(ft(Hora), ":", "") &", 0, '"&nData&"', "&LocalID&", "&ProfissionalID&", "&GradeID&", $('#bPacienteID').val(), '"& ProcedimentoID &"')"

                                        PeriodoHorario = ""

                                        HoraApenas = right(cdate(Hora), 8)

                                        if HoraApenas< right(cdate("12:00:00"),8) then
                                            PeriodoHorario = "M"
                                        elseif HoraApenas< right(cdate("19:00:00"),8) then
                                            PeriodoHorario = "T"
                                        elseif HoraApenas< right(cdate("00:00:00"),8) then
                                            PeriodoHorario = "N"
                                        end if
                                        %>
                                        <button style="width:70px" class="btn-horario-livre mt5 btn btn-xs btn-primary <%= classe %>" onclick="<%= onclick %>" data-periodo="<%=PeriodoHorario%>"><%= ft(Hora) %></button>
                                        <%
                                        if conta=3 then
                                            'response.Write("<br>")
                                            conta = 0
                                        end if
                                    end if
                                    Hora = dateadd("n", Intervalo, Hora)
                                wend
                            ass.movenext
                            wend
                            ass.close
                            set ass=nothing
                                %>
                        </td>
                        <%
                        nData = nData+1
                    wend
                    %>
                </tr>
                <%
                ab.movenext
                wend
                ab.close
                set ab = nothing

                if UnidadeID<>UltimaUnidade then
                    %>

                    <tr class="linha-unidade-resumo" data-unidade="<%=UnidadeID%>">
                        <td></td>
                        <td></td>
                        <%
                        nData = Data
                        while nData<uData
                            DiaSemana = weekday(nData)
                            %>
                            <td class="data-resumo" data-date="<%=nData%>" style="vertical-align:top; width:230px">
                                <span class="texto-horarios-lives"></span>
                                <button onclick="ExibeHorarios('<%=BuscaID%>', '<%=nData%>', '<%=UnidadeID%>')" type="button" style="display: none" class="btn-exibir-horarios btn btn-primary btn-xs btn-block">Expandir</button>
                            </td>
                            <%
                            nData = nData+1
                        wend
                        %>
                    </tr>
                    <%
                end if
                UltimaUnidade = grades("UnidadeID")

            grades.movenext
            wend
            grades.close
            set grades = nothing

            %>
            </table>
            <script type="text/javascript">
            <%
            set ag = db.execute("select a.Data, a.Hora, a.ProfissionalID, l.UnidadeID FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID WHERE a.Data BETWEEN "& mydatenull(Data) &" AND "& mydatenull(uData) &"")
            while not ag.eof
                %>
                $(".<%= ag("ProfissionalID") &"_"& ag("UnidadeID") &"_"& replace(ag("Data"), "/", "") &"_"& replace(ft(ag("Hora")), ":", "") %>").addClass("hidden");
                <%
            ag.movenext
            wend
            ag.close
            set ag = nothing
            %>
            </script>
    <%
end if
%>