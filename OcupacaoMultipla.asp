<!--#include file="connect.asp"-->
<!--#include file="functionOcupacao.asp"-->


<style type="text/css">
    td, th {
        font-size: 7pt;
        padding:3px!important;
    }
</style>

<h2 class="text-center">Taxa de Ocupação</h2>

<div style="display: none" class="alert alert-warning">
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

if session("Banco")="clinic5760" or session("Banco")="clinic6118" or session("Banco")="clinic5968" or session("Banco")="clinic6259" or session("Banco")="clinic6629" then
    'sUnidadeID = "|"& session("UnidadeID") &"|"
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1)"
else
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia)NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1) UNION ALL (SELECT concat('G', id) id, concat('Grupo: ', NomeGrupo) NomeLocal from locaisgrupos where sysActive=1 order by NomeGrupo) UNION ALL (select l.id, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where l.sysActive=1 order by l.NomeLocal)"
end if

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
        splU = split(ref("Locais"), ", ")
        for j=0 to Ubound(splU)
            call ocupacao(ref("De"), ref("Ate"), ref("Especialidade"), "", "", "", splU(j))    
            UnidadeID = replace(replace(splU(j), "UNIDADE_ID", ""), "|", "")
		    if UnidadeID="0" then
			    set un = db.execute("select NomeFantasia from empresa")
		    else
			    set un = db.execute("select NomeFantasia from sys_financialcompanyunits where id="& treatvalzero(UnidadeID) )
		    end if
		    if un.EOF then
			    NomeUnidade = ""
		    else
			    NomeUnidade = un("NomeFantasia")
		    end if


            %>
            <h1><%= NomeUnidade %></h1>
            <table class="table table-hover table-bordered table-condensed" _excel-name="<%= NomeUnidade %>">
                <thead>
                    <tr class="info">
                        <th></th>
                        <%
                        De = cdate(ref("De"))
                        Ate = cdate(ref("Ate"))
                        Data = De
                        while Data<=Ate
                            %>
                            <th class="text-center" colspan="7"><%= Data %></th>
                            <%
                            Data = Data+1
                        wend
                        %>
                        <th class="text-center success" colspan="6">TOTAL</th>
                    </tr>
                    <tr class="info">
                        <th></th>
                        <%
                        De = cdate(ref("De"))
                        Ate = cdate(ref("Ate"))
                        Data = De
                        while Data<=Ate
                            %>
                            <th>TOT</th>
                            <th>LIV</th>
                            <th>BLQ</th>
                            <th>AGE</th>
							<th>GRD</th>
							<th>GRD ORG</th>
                            <th>OCU</th>
                            <%
                            Data = Data+1
                        wend
                        %>
                        <th class="success">TOT. </th>
                        <th class="success">TOT. LIV</th>
                        <th class="success">TOT. BLQ</th>
                        <th class="success">TOT. AGE</th>
                        <th class="success">TOT. GRD</th>
                    </tr>
                </thead>
            <%
            'set distEsp = db.execute("SELECT DISTINCT esp.Especialidade, ro.EspecialidadeID FROM agenda_horarios ro LEFT JOIN especialidades esp ON esp.id=ro.EspecialidadeID ORDER BY esp.Especialidade")
            set prof = db.execute("SELECT id EspecialidadeID, Especialidade FROM especialidades WHERE id IN("& replace(ref("Especialidade"), "|", "") &") ORDER BY Especialidade")
            while not prof.eof
                %>
                <tr>
                    <th><%= prof("Especialidade") %></th>
                    <%
                    De = cdate(ref("De"))
                    Ate = cdate(ref("Ate"))
                    DataN = De
                    VTotal = 0
                    ATotal = 0
                    BTotal = 0
                    TTotal = 0
					VBTotal = 0
					ABTotal = 0
                    GOriTotal = 0
					GTotal = 0

                    while DataN<=Ate
'                        sqlConta = "select "&_
'					    "(select count(ro.Data) from agenda_horarios ro WHERE ro.Data="& mydatenull(Data) &" AND ro.Situacao IN('A') AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID)) A, "&_
'					    "(select count(ro.Data) from agenda_horarios ro WHERE ro.Data="& mydatenull(Data) &" AND ro.Situacao IN('B') AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID)) AB, "&_
'					    "(select count(ro.Data) from agenda_horarios ro WHERE ro.Data="& mydatenull(Data) &" AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ro.Encaixe=1) E, "&_
'					    "(select count(ro.Data) from agenda_horarios ro WHERE ro.Data="& mydatenull(Data) &" AND ro.Situacao='B' AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ISNULL(StaID)) VB, "&_
'					    "(select count(ro.Data) from agenda_horarios ro WHERE ro.Data="& mydatenull(Data) &" AND ro.Situacao='V' AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ISNULL(StaID)) V"
						sqlConta = "select "&_
						"(select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.Situacao IN('A') AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID)) A, "&_
						"(select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.GradeOriginal=1 AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &"  ) GO, "&_
						"(select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.GradeOriginal=2 AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &"  ) GOri, "&_
						"(select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.Situacao IN('A') AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID) AND Encaixe=1) E, "&_
						"(select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.Situacao IN('B') AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID)) AB, "&_
					    "(select count(ro.Data) from agenda_horarios ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.Situacao='B' AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ISNULL(StaID)) VB, "&_
						"(select count(ro.ProfissionalID) from agenda_horarios ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.Situacao='V' AND ro.sysUser="& session("User") &" AND ro.UnidadeID="& treatvalnull(UnidadeID) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &") V"

                        'response.write( sqlConta &"<br>")
                        set conta = db.execute( sqlConta )
                        V = ccur(conta("V"))
                        A = ccur(conta("A"))
                        AB = ccur(conta("AB"))
                        VB = ccur(conta("VB"))
						E = ccur(conta("E"))
						V = ccur(conta("V"))
						G = ccur(conta("GO"))
                        GOri = ccur(conta("GOri")) + G
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

                        if not isnumeric(UnidadeID) then
                            UnidadeID=""
                        else
                            UnidadeID=cint(UnidadeID)
                        end if
                        %>
                        <td><a href="./?P=AgendaMultipla&Pers=1&Locais=|UNIDADE_ID<%= UnidadeID %>|&Especialidades=|<%= prof("EspecialidadeID") %>|&Data=<%= DataN %>" target="_blank"><%= T %></a></td>
                        <td><%= V %></td>
                        <td><%= VB+AB %></td>
                        <td><%= A+AB %></td>
                        <td><%= G %></td>
                        <td><%= GOri %></td>
                        <td><%= formatnumber(O * 100, 0) %>%</td>
                        <%
                        DataN = DataN+1
                    wend
                    %>
                    <th><%= TTotal %></th>
                    <th><%= VTotal%></th>
                    <th><%= VBTotal + ABTotal %></th>
                    <th><%= ATotal+ABTotal  %></th>
                    <th><%= GTotal  %></th>
                </tr>
                <%
            prof.movenext
            wend
            prof.close
            set prof = nothing
            %>

            </table>
            <%
        next
        'u.movenext
        'wend
        'u.close
        'set u = nothing
end if
        %>
