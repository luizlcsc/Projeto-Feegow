<!--#include file="connect.asp"-->
<!--#include file="functionOcupacao.asp"-->


<style type="text/css">
    td, th {
        font-size: 7pt;
        padding:3px!important;
    }
</style>

<h2 class="text-center">Taxa de Ocupação</h2>

<div style="" class="hidden alert alert-warning">
    <strong>Atenção!</strong> Este relatório está sendo atualizado no momento.
</div>
<%
'server.ScriptTimeout = 200

response.Buffer

if ref("De")="" then
    De=date()
else
    De=cdate(ref("De"))
end if
if ref("Ate")="" then
    Ate=date()+7
else
    Ate=cdate(ref("Ate"))
end if

sqlLimitarProfissionais =""
if lcase(session("table"))="funcionarios" then
     set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
     if not FuncProf.EOF then
     profissionais=FuncProf("Profissionais")
        if not isnull(profissionais) and profissionais<>"" then
            profissionaisExibicao = replace(profissionais, "|", "")
            sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
        end if
     end if
elseif lcase(session("table"))="profissionais" then
     set FuncProf = db.execute("SELECT AgendaProfissionais FROM profissionais WHERE id="&session("idInTable"))
     if not FuncProf.EOF then
     profissionais=FuncProf("AgendaProfissionais")
        if not isnull(profissionais) and profissionais<>"" then
            profissionaisExibicao = replace(profissionais, "|", "")
            sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
        end if
     end if
end if

sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1)"

if ref("De")="" then
%>

        <form target="_blank" id="frmFiltros" method="post" action="PrintStatement.asp?R=OcupacaoMultipla">
            <div class="row">
                <%'=quickField("select", "filtroProcedimentoID", "Procedimento", 2, "", "select '' id, '-' NomeProcedimento UNION ALL select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' and OpcoesAgenda!=3 order by NomeProcedimento", "NomeProcedimento", " empty ") %>
                <%'=quickField("multiple", "Profissionais", "Profissionais", 2, ref("Profissionais"), "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais WHERE (NaoExibirAgenda != 'S' OR NaoExibirAgenda is null OR NaoExibirAgenda='') AND sysActive=1 and Ativo='on' "&sqlLimitarProfissionais&" ORDER BY NomeProfissional)t ORDER BY Ordem, NomeProfissional", "NomeProfissional", " empty ") %>
                <%=quickField("multiple", "Especialidade", "Especialidades", 2, ref("Especialidade"), "SELECT t.EspecialidadeID id, IFNULL(e.nomeEspecialidade, e.especialidade) especialidade FROM (	SELECT EspecialidadeID from profissionais WHERE ativo='on'	UNION ALL	select pe.EspecialidadeID from profissionaisespecialidades pe LEFT JOIN profissionais p on p.id=pe.ProfissionalID WHERE p.Ativo='on') t LEFT JOIN especialidades e ON e.id=t.EspecialidadeID WHERE NOT ISNULL(especialidade) AND e.sysActive=1 GROUP BY t.EspecialidadeID ORDER BY especialidade", "especialidade", " empty required ") %>
                <%'=quickField("multiple", "Convenio", "Convênios", 2, "", "select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' order by NomeConvenio", "NomeConvenio", " empty ") %>
                <%'=quickField("empresaMultiIgnore", "Unidades", "Unidades", 2, "", "", "", "") %>
                <%=quickField("multiple", "Locais", "Locais", 2, ref("Locais"), sqlAM, "NomeLocal", " empty ") %>
                <%'=quickField("multiple", "Equipamentos", "Equipamentos", 2, "", "SELECT id, NomeEquipamento FROM equipamentos WHERE sysActive=1 and Ativo='on' ORDER BY NomeEquipamento", "NomeEquipamento", " empty ") %>
                <%=quickField("datepicker", "De", "De", 2, De, "", "", "") %>
                <%=quickField("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
                <%=quickField("simpleCheckbox", "FormatoExportacao", "Exibir formato para exportação", "2", "", "", "", "")%>
                <div class="col-md-2">
                    <button class="btn mt25 btn-primary">Gerar</button>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 text-center">
                    <button id="buscar" class="btn btn-primary hidden mt10 btn-block" onclick="$(this).addClass('hidden')"><i class="far fa-search"></i> BUSCAR</button>
                </div>
            </div>
        </form>
<script >
$("#FormatoExportacao").change(function() {
    var exportarMarcado = $(this).prop("checked");

    $("#frmFiltros").attr("action", "PrintStatement.asp?R=OcupacaoMultipla" + (exportarMarcado ? "Exportacao" : ""));
});
</script>
<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->
</script>

<%
else

        'set u = db.execute("select distinct UnidadeID FROM agenda_horarios WHERE sysUser="& session("User"))
        'while not u.eof
        %>
<table class="table table-hover table-bordered table-condensed" _excel-name="Relatório de ocupação">
    <thead>
        <tr class="info">
            <th class="text-center success" >Data</th>
            <th class="text-center success" >Unidade</th>
            <th class="text-center success" >Especialidade</th>
            <%
            IF ref("TipoExibicao")="P" THEN
            %>
            <th class="text-center success" >Profissional</th>
            <%
            END IF
            %>
            <th class="text-center success" >TOT</th>
            <th class="text-center success" >LIV</th>
            <th class="text-center success" >BLQ</th>
            <th class="text-center success" >AGE</th>
            <th class="text-center success" >GRD</th>
            <th class="text-center success" >GRD ORG</th>
            <th class="text-center success" >OCU</th>
        </tr>
    </thead>
        <%
        De = cdate(ref("De"))
        Ate = cdate(ref("Ate"))
        DataN = De
        Locais = replace(ref("Locais"), "|", "")
        Especialidades = replace(ref("Especialidade"), "|", "") 

        Locais = replace(Locais, "UNIDADE_ID", "")


        splU = split(ref("Locais"), ", ")

        for j=0 to Ubound(splU)
            call ocupacao(ref("De"), ref("Ate"), ref("Especialidade"), "", "", "", splU(j),session("User") ,"always",True)
            UnidadeID = replace(replace(splU(j), "UNIDADE_ID", ""),"|","")

            sqlUnion = ", ( "&_
                " "&_
                "SELECT id EspecialidadeID, Especialidade FROM especialidades WHERE id in ("& Especialidades &") ORDER BY Especialidade "&_
                " "&_
                ") esp "

            
            IF ref("TipoExibicao")="P" THEN
                sqlBusca = " ro.ProfissionalID=p.ProfissionalID AND ro.EspecialidadeID=p.EspecialidadeID "
                sqlUnion = " , ( "&_
                       "SELECT p.id ProfissionalID, NomeProfissional, esp.id EspecialidadeID, especialidade "&_
                       "FROM profissionais p "&_
                       "LEFT JOIN profissionaisespecialidades pe ON pe.ProfissionalID=p.id "&_
                       "LEFT JOIN especialidades esp ON esp.id=p.EspecialidadeID or pe.EspecialidadeID=esp.id "&_
                       "WHERE p.Ativo='on' AND esp.id IN ("& Especialidades &") "&_
                       "ORDER BY Especialidade, NomeProfissional) p "
            else
                sqlBusca = " ro.EspecialidadeID=esp.EspecialidadeID "
            END IF

        sqlAll = "SELECT *, "&_
                " "&_
                " (select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data=dts.Data AND ro.Situacao IN('A') AND ro.sysUser="&session("User")&" AND ro.UnidadeID=und.UnidadeID AND "&sqlBusca&" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID)) A,  "&_
                "  "&_
                " (select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data=dts.Data AND ro.GradeOriginal=1 AND ro.sysUser="&session("User")&" AND ro.UnidadeID=und.UnidadeID AND "&sqlBusca&" ) GO,  "&_
                "  "&_
                " (select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data=dts.Data AND ro.GradeOriginal=2 AND ro.sysUser="&session("User")&" AND ro.UnidadeID=und.UnidadeID AND "&sqlBusca&" ) GOri,  "&_
                "  "&_
                " (select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data=dts.Data AND ro.Situacao IN('A') AND ro.sysUser="&session("User")&" AND ro.UnidadeID=und.UnidadeID AND "&sqlBusca&" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID) AND Encaixe=1) E,  "&_
                "  "&_
                " (select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data=dts.Data AND ro.Situacao IN('B') AND ro.sysUser="&session("User")&" AND ro.UnidadeID=und.UnidadeID AND "&sqlBusca&" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID)) AB,  "&_
                "  "&_
                " (select count(ro.Data) from agenda_horarios ro WHERE ro.Data=dts.Data AND ro.Situacao='B' AND ro.sysUser="&session("User")&" AND ro.UnidadeID=und.UnidadeID AND "&sqlBusca&" AND ISNULL(StaID)) VB,  "&_
                "  "&_
                " (select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data=dts.Data AND ro.Situacao='V' AND ro.sysUser="&session("User")&" AND ro.UnidadeID=und.UnidadeID AND "&sqlBusca&") V "&_
                "  "&_
                "  "&_
                "FROM "&_
                "(SELECT DISTINCT  DATA FROM agenda_horarios WHERE sysUser="&session("User")&" ORDER BY Data asc)dts "&_
                " "&_
                ", ( "&_
                " SELECT UnidadeID, NomeFantasia FROM ( "&_
                "SELECT 0 UnidadeID, NomeFantasia FROM empresa WHERE id=1 "&_
                "UNION ALL "&_
                "SELECT id UnidadeID,NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1 "&_
                ") u WHERE u.UnidadeID IN ("& UnidadeID &") "&_
                ") und  "&_
                "" & sqlUnion

                set OcupacaoSQL = db.execute(sqlAll)

                while not OcupacaoSQL.eof
                    NomeUnidade = OcupacaoSQL("NomeFantasia")
                    DataN=OcupacaoSQL("Data")
                    %>
                    <tr>
                        <th><%=DataN%></th>
                        <th><%=NomeUnidade%></th>
                        <th><%= OcupacaoSQL("Especialidade") %></th>
                        <%
                        IF ref("TipoExibicao")="P" THEN
                        %>
                        <th><%= OcupacaoSQL("NomeProfissional") %></th>
                        <%
                        END IF
                        %>
                        <%
                        De = cdate(ref("De"))
                        Ate = cdate(ref("Ate"))
                        VTotal = 0
                        ATotal = 0
                        BTotal = 0
                        TTotal = 0
                        VBTotal = 0
                        ABTotal = 0
                        GOriTotal = 0
                        GTotal = 0

                            'response.write( sqlConta &"<br>")
                            V = ccur(OcupacaoSQL("V"))
                            A = ccur(OcupacaoSQL("A"))
                            AB = ccur(OcupacaoSQL("AB"))
                            VB = ccur(OcupacaoSQL("VB"))
                            E = ccur(OcupacaoSQL("E"))
                            V = ccur(OcupacaoSQL("V"))
                            G = ccur(OcupacaoSQL("GO"))
                            GOri = ccur(OcupacaoSQL("GOri")) + G
                            T = V+A

                            VTotal = VTotal + V
                            ATotal = ATotal + A
                            ABTotal = ABTotal + AB
                            VBTotal = VBTotal + VB
                            GTotal = GTotal + G
                            GOriTotal = GOriTotal + GOri
                            TTotal = TTotal + T


                            TotalUtil = T-VB
                            if G>0 then
                                O = (A+AB)/G
                            else
                                O = 0
                            end if
                            ' if TotalUtil>0 then
                            '     O = A/G
                            ' else
                            '     O = 0
                            ' end if
                            %>
                            <td><a href="./?P=AgendaMultipla&Pers=1&Locais=|UNIDADE_ID<%= cint(UnidadeID) %>|&Especialidades=|<%= OcupacaoSQL("EspecialidadeID") %>|&Data=<%= DataN %>" target="_blank"><%= T %></a></td>
                            <td><%= V %></td>
                            <td><%= VB+AB %></td>
                            <td><%= A+AB %></td>
                            <td><%= G %></td>
                            <td><%= GOri %></td>
                            <td><%= formatnumber(O * 100, 0) %>%</td>
                            <%
                        %>
                    </tr>
                    <%
                    response.flush()
            OcupacaoSQL.movenext
            wend
            OcupacaoSQL.close
            set OcupacaoSQL=nothing
            
            response.flush()
        next
        'u.movenext
        'wend
        'u.close
        'set u = nothing
%>
</table>
<%
end if
        %>
