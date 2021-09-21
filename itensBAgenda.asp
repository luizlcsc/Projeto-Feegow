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

if Acao="I" then
    if ProcedimentoID="0" and EspecialidadeID="0" and SubespecialidadeID="0" and ProfissionalID="0" then
        erro = "Selecione um parâmetro para a busca"
    end if
    sqlvca = "select id from agendabusca where sysUser="& session("User") &" and Data="& mydatenull(Data) &" and PacienteID="& treatvalzero(PacienteID) &" and TabelaID="& treatvalzero(TabelaID) &" and Unidades='"& Unidades &"' and GrupoID="& treatvalzero(GrupoID) &" and ProcedimentoID="& treatvalzero(ProcedimentoID) &" and EspecialidadeID="& treatvalzero(EspecialidadeID) &" and SubespecialidadeID="& treatvalzero(SubespecialidadeID) &" and isnull(Cancelada)"
    set vca = db.execute( sqlvca )
    'response.Write( sqlvca )
    if not vca.eof then
        erro = "Já existe uma busca com esses parâmetros"
    end if
    if erro<>"" then
        %>
        <script type="text/javascript">
            showMessageDialog("<%= erro %>", "warning");
        </script>
        <%
    else
        db.execute("update agendabusca set Data="& mydatenull(Data) &" where sysUser="& session("User") &" and isnull(Cancelada)")
        'bater especialidades
        if EspecialidadeID<>"0" then
            sqlEsp = " and (p.EspecialidadeID="& EspecialidadeID &" OR pe.EspecialidadeID="& EspecialidadeID &")"
        end if
        if SubespecialidadeID<>"0" then
            sqlSubEsp = " and psub.SubespecialidadeID = "& SubespecialidadeID
        end if
        if ProfissionalID<>"0" then
            sqlProf = " and p.id = "& ProfissionalID
        end if
        'ver no cadastro do procedimento
        set proc = db.execute("select ifnull(OpcoesAgenda, 0) OpcoesAgenda, SomenteProfissionais, SomenteEspecialidades, SomenteLocais from procedimentos where id="& ProcedimentoID)

        if not proc.eof then
            SomenteProfissionais = replace(proc("SomenteProfissionais")&"", "|", "")
            SomenteEspecialidades = replace(proc("SomenteEspecialidades")&"", "|", "")
            SomenteLocais = replace(proc("SomenteLocais")&"", "|", "")
            OpcoesAgenda = ccur(proc("OpcoesAgenda"))

            if OpcoesAgenda=3 then
                sqlProc = " and 0 "
            elseif OpcoesAgenda=4 then
                if SomenteProfissionais<>"" then
                    sqlProc = " and p.id IN ("& SomenteProfissionais &") "
                end if
                if SomenteEspecialidades<>"" then
                    sqlEspProc = " and p.EspecialidadeID IN ("& SomenteEspecialidades &") "
                end if
                if SomenteProfissionais<>"" and SomenteEspecialidades<>"" then
                    sqlProc = " and (p.id IN ("& SomenteProfissionais &") "
                    sqlEspProc = " OR p.EspecialidadeID IN ("& SomenteEspecialidades &") )"
                end if
            end if
        end if

        if SomenteLocais<>"" then
            set uns = db.execute("select group_concat(distinct concat('|', l.UnidadeID, '|')) UnidadesPerm from locais l where id in("& SomenteLocais &")")
            UnidadesPerm = uns("UnidadesPerm")
        end if

        if Regiao<>"" then
            set UnidadesDaRegiaoSQL = db.execute("SELECT CONCAT('|',GROUP_CONCAT(id SEPARATOR '|,|'),'|') Unidades FROM sys_financialcompanyunits WHERE sysActive=1 AND Regiao='"&Regiao&"'")

            if not UnidadesDaRegiaoSQL.eof then
                Unidades=UnidadesDaRegiaoSQL("Unidades")
            end if
        end if

        'ver no cadastro do profissional
        sqlProfs = "select group_concat( concat('|', t.id, '|')) ProfissionaisPerm from (SELECT p.id FROM profissionais p LEFT JOIN profissionaisespecialidades pe ON pe.ProfissionalID=p.id LEFT JOIN profissionaissubespecialidades psub ON psub.ProfissionalID=p.id where p.sysActive=1 and p.Ativo='on' "& sqlEsp & sqlProf & sqlProc & sqlEspProc&sqlSubEsp& sqlProf&" GROUP BY p.id)t"
        'response.write( sqlProfs )
        set pprofs = db.execute( sqlProfs )
        ProfissionaisPerm = pprofs("ProfissionaisPerm")&""

        db.execute("insert into agendabusca set sysUser="& session("User") &", Data="& mydatenull(Data) &", PacienteID="& treatvalzero(PacienteID) &", TabelaID="& treatvalzero(TabelaID) &", Unidades='"& Unidades &"', GrupoID="& treatvalzero(GrupoID) &", ProcedimentoID="& treatvalzero(ProcedimentoID) &",ComplementoID="& treatvalzero(ComplementoID) &", EspecialidadeID="& treatvalzero(EspecialidadeID) &", SubespecialidadeID="& treatvalzero(SubespecialidadeID)&", ProfissionaisPerm='"& ProfissionaisPerm &"', UnidadesPerm='"& UnidadesPerm &"'")
    end if

elseif Acao="X" then
    db.execute("update agendabusca set Cancelada=NOW() where id="& id)
end if

set ab = db.execute("select ab.*, proc.NomeProcedimento, proc.Valor, comp.SubespecialidadeID, esp.Especialidade FROM agendabusca ab LEFT JOIN procedimentos proc ON proc.id=ab.ProcedimentoID LEFT JOIN profissionaissubespecialidades comp ON comp.id=ab.SubespecialidadeID LEFT JOIN especialidades esp ON esp.id=ab.EspecialidadeID WHERE ab.sysUser="& session("User") &" and isnull(ab.Cancelada)")
if not ab.eof then
    %>
        <div class="panel-heading mt10"><span class="panel-title">BUSCAS SELECIONADAS</span></div>

        <%
        PriData = cdate(Data)
        UltData = PriData+3

        db.execute("delete from agendabuscaprofissionais where sysUser="& session("User"))
        while not ab.eof
            Data = ab("Data")
            BuscaID = ab("id")
            NomeProcedimento = ab("NomeProcedimento")
            NomeEspecialidade = ab("Especialidade")
            NomeComplemento = ab("NomeComplemento")
            ProfissionaisPerm = ab("ProfissionaisPerm")&""
            UnidadesPerm = ab("UnidadesPerm")
            Valor = fn(ab("Valor"))
            Unidades = ab("Unidades")
            AgendamentoID = ab("AgendamentoID")


            ValorTabela = calcValorProcedimento(ProcedimentoID, TabelaID, UnidadeID, ProfissionalID, EspecialidadeID, GrupoID)
            %>
        <div class="panel-body">

            <table class="table table-condensed table-bordered table-hover table-striped">
                <thead>
                    <tr class="info">
                        <th>Data</th>
                        <th>Procedimento</th>
                        <th>Especialidade</th>
                        <th>Complemento</th>
                        <th>Valor</th>
                        <th width="1%"></th>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                        <tr>
                            <td><%= Data %></td>
                            <td><%= NomeProcedimento %></td>
                            <td><%= NomeEspecialidade %></td>
                            <td><%= NomeComplemento %></td>
                            <td class="text-right"><%= ValorTabela %></td>
                            <td>
                                <% if isnull(AgendamentoID) then %>
                                    <button onclick="AbrirPendencias('<%=UnidadeID%>', '<%=BuscaID%>')" type="button" style="display: none" class="btn-pendencia btn btn-xs btn-dark"><i class="far fa-life-ring" title="Abrir Pendência"></i></button>
                                <% else %>
                                    <button type="button" class="btn btn-xs btn-success" onclick="abreAgenda('', <%= AgendamentoID %>, '', '', '')"><i class="far fa-check" title="Agendado"></i></button>
                                <% end if %>
                            </td>
                            <td><button onclick="ibAgenda('X', <%= ab("id") %>)" type="button" class="btn btn-xs btn-danger" title="Excluir"><i class="far fa-remove"></i></button></td>
                        </tr>
                </tbody>
            </table>
            <div class="agenda-busca-conteudo" data-id="<%=ab("id")%>"></div>
        </div>

            <%


            if ProfissionaisPerm<>"" then
                splPP = split(ProfissionaisPerm, ",")
                for i=0 to ubound(splPP)
                    'response.write(0)
                    ProfissionalP = replace(splPP(i), "|", "")
                    set vcaPP = db.execute("select id from agendabuscaprofissionais where sysUser="&session("User")&" and ProfissionalID="& ProfissionalP)
                    if vcaPP.eof then
                        db.execute("insert into agendabuscaprofissionais set sysUser="& session("User") &", Ocorrencias=1, ProfissionalID="& ProfissionalP )
                    else
                        db.execute("update agendabuscaprofissionais set Ocorrencias=Ocorrencias+1 where id="& vcaPP("id"))
                    end if
                next
            end if
        ab.movenext
        wend
        ab.close
        set ab = nothing


        %>


    <%
end if
%>