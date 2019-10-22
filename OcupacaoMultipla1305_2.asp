<!--#include file="connect.asp"-->
<!--#include file="functionOcupacao.asp"-->

<%'= request.form() %>

<style type="text/css">
    td, th {
        font-size: 7pt;
        padding:3px!important;
    }
</style>

<h2 class="text-center">Taxa de Ocupação</h2>

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

if session("Banco")="clinic5760" or session("Banco")="clinic6118" or session("Banco")="clinic5968" or session("Banco")="clinic6259" then
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
                <div class="col-md-2">
                    <button class="btn mt25 btn-primary">Gerar</button>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 text-center">
                    <button id="buscar" class="btn btn-primary hidden mt10 btn-block" onclick="$(this).addClass('hidden')"><i class="fa fa-search"></i> BUSCAR</button>
                </div>
            </div>
        </form>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->
</script>

<%
else

        call ocupacao(ref("De"), ref("Ate"), ref("Especialidade"), "", "", "", ref("Locais"))    
        'set u = db.execute("select distinct UnidadeID FROM rel_ocupacao WHERE sysUser="& session("User"))
        'while not u.eof
        splU = split(ref("Locais"), ", ")
        for j=0 to Ubound(splU)
            UnidadeID = replace(replace(splU(j), "UNIDADE_ID", ""), "|", "")
		    if UnidadeID="0" then
			    set un = db.execute("select NomeFantasia from empresa")
		    else
			    set un = db.execute("select NomeFantasia from sys_financialcompanyunits where id="& UnidadeID )
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
                            <th class="text-center" colspan="5"><%= Data %></th>
                            <%
                            Data = Data+1
                        wend
                        %>
                        <th class="text-center success" colspan="5">TOTAL</th>
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
                            <th>OCU</th>
                            <%
                            Data = Data+1
                        wend
                        %>
                        <th class="success">TOT. </th>
                        <th class="success">TOT. LIV</th>
                        <th class="success">TOT. BLQ</th>
                        <th class="success">TOT. AGE</th>
                        <th class="success">TOT. OCU</th>
                    </tr>
                </thead>
            <%
            'set distEsp = db.execute("SELECT DISTINCT esp.Especialidade, ro.EspecialidadeID FROM rel_ocupacao ro LEFT JOIN especialidades esp ON esp.id=ro.EspecialidadeID ORDER BY esp.Especialidade")
            set distEsp = db.execute("SELECT id EspecialidadeID, Especialidade FROM especialidades WHERE id IN("& replace(ref("Especialidade"), "|", "") &") ORDER BY Especialidade")
            while not distEsp.eof
                %>
                <tr>
                    <th><%= distEsp("Especialidade") %></th>
                    <%
                    De = cdate(ref("De"))
                    Ate = cdate(ref("Ate"))
                    Data = De
                    VTotal = 0
                    ATotal = 0
                    BTotal = 0
                    TTotal = 0

                    while Data<=Ate
                        sqlConta = "select (select count(id) from rel_ocupacao where EspecialidadeID="& distEsp("EspecialidadeID") &" AND sysUser="& session("User") &" AND UnidadeID="& UnidadeID &" AND Data="& mydatenull(Data) &" AND Situacao='V') V, "&_
                        "(select count(id) from rel_ocupacao where EspecialidadeID="& distEsp("EspecialidadeID") &" AND UnidadeID="& UnidadeID &" AND StaID NOT IN(11,15) AND sysUser="& session("User") &" AND Data="& mydatenull(Data) &" AND NOT ISNULL(StaID)) A, "&_
                        "(select count(id) from rel_ocupacao where EspecialidadeID="& distEsp("EspecialidadeID") &" AND UnidadeID="& UnidadeID &" AND sysUser="& session("User") &" AND Data="& mydatenull(Data) &" AND Situacao='B') B"
                        'response.write( sqlConta &"<br>")
                        set conta = db.execute( sqlConta )
                        V = ccur(conta("V"))
                        A = ccur(conta("A"))
                        B = ccur(conta("B"))
                        T = V+A

                        VTotal = VTotal + V
                        ATotal = ATotal + A
                        BTotal = BTotal + B
                        TTotal = TTotal + T

                        TotalUtil = T-B
                        if TotalUtil>0 then
                            O = A/TotalUtil
                        else
                            O = 0
                        end if
                        %>
                        <td><%= T %></td>
                        <td><%= V %></td>
                        <td><%= B %></td>
                        <td><%= A %></td>
                        <td><%= formatnumber(O * 100, 0) %>%</td>
                        <%
                        Data = Data+1
                    wend
                    %>
                    <td><%= TTotal %></td>
                    <td><%= VTotal%></td>
                    <td><%= BTotal %></td>
                    <td><%= ATotal  %></td>
                    <td><%= "" %></td>
                </tr>
                <%
            distEsp.movenext
            wend
            distEsp.close
            set distEsp = nothing
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
