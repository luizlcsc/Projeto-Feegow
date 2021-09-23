<!--#include file="connect.asp"-->
<%
Unidades=req("Unidades")
Profissionais=req("Profissionais")
ProcedimentoID = req("ProcedimentoID")
UnidadesSelecionadas = ""
ExibeBotaoBusca = False

if Profissionais&"" <> "" then
    if instr(Profissionais, "|")>0 then
        Profissionais = replace(Profissionais,"|","")
    end if
    sqlLimitarProfissionais = " AND p.id in ("&Profissionais&") "
end if

set sysConf = db.execute("select * from sys_config")

if sysConf("ConfigGeolocalizacaoProfissional")="S" and recursoAdicional(39)=4  then
    if sqlLimitarProfissionais&"" = "" and req("R") = "0" then
        sqlLimitarProfissionais = " AND p.id in (0) "
    end if
end if

if Unidades<>"" then
    UnidadesSelecionadas="|UNIDADE_ID"&replace(Unidades, ",","|,|UNIDADE_ID")&"|"
    Unidades="|"&replace(Unidades, ",","|,|")&"|"
    ExibeBotaoBusca=True
else
    Unidades= session("Unidades")
end if
if ModoFranquiaUnidade then
    Unidades = "|"&session("UnidadeID")&"|"
    UnidadesSelecionadas="|UNIDADE_ID"&replace(Unidades, "|","")&"|"
end if
if req("Data")<>"" then
    hData = req("Data")
else
    hData = date()
end if

if getConfig("ExibirApenasUnidadesNoFiltroDeLocais") then

    if sysConf("ConfigGeolocalizacaoProfissional")="S" and recursoAdicional(39)=4  then

        sqlAM = " (select CONCAT('UNIDADE_ID', 0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal, CONCAT('|',0,'|') as Unidades FROM empresa e            "&chr(13)&_
                " JOIN profissionais p ON p.Unidades LIKE CONCAT('%|',0,'|%')                                                                                   "&chr(13)&_
                " WHERE e.id = 1 "&sqlLimitarProfissionais                                                                                                       &chr(13)&_
                " GROUP BY NomeLocal                                                                                                                            "&chr(13)&_
                " ) UNION ALL                                                                                                                                   "&chr(13)&_
                " (select CONCAT('UNIDADE_ID', fcu.id), CONCAT('Unidade: ', NomeFantasia) NomeLocal, CONCAT('|',fcu.id,'|') as Unidades                         "&chr(13)&_
                "  FROM sys_financialcompanyunits fcu                                                                                                           "&chr(13)&_
                "  LEFT JOIN profissionais p ON p.Unidades LIKE CONCAT('%|',fcu.id,'|%')                                                                        "&chr(13)&_
                "  WHERE fcu.sysActive = 1                                                                                                                      "&chr(13)&_
                sqlLimitarProfissionais                                                                                                                          &chr(13)&_
                " GROUP BY NomeLocal                                                                                                                            "&chr(13)&_
                "  order by fcu.NomeFantasia) "
    else
        sqlAM = " (select CONCAT('UNIDADE_ID', 0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal, CONCAT('|',0,'|') as Unidades FROM empresa WHERE id = 1 "&chr(13)&_
            " AND 0 in ("&replace(Unidades, "|","")&")                                                                                                     "&chr(13)&_
            " GROUP BY NomeLocal                                                                                                                            "&chr(13)&_
            " ) UNION ALL                                                                                                                                   "&chr(13)&_
            " (select CONCAT('UNIDADE_ID', id), CONCAT('Unidade: ', NomeFantasia) NomeLocal, CONCAT('|',id,'|') as Unidades                                 "&chr(13)&_
            "  FROM sys_financialcompanyunits                                                                                                               "&chr(13)&_
            "  WHERE sysActive = 1                                                                                                                          "&chr(13)&_
            "  AND id in ("&replace(Unidades, "|","")&")                                                                                                    "&chr(13)&_
            " GROUP BY NomeLocal                                                                                                                            "&chr(13)&_
            "  order by NomeFantasia) "
    end if
else
    if sysConf("ConfigGeolocalizacaoProfissional")="S" and recursoAdicional(39)=4  then
        sqlAM = " (select CONCAT('UNIDADE_ID', 0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal, CONCAT('|',0,'|') as Unidades FROM empresa e                         "&chr(13)&_
            " JOIN profissionais p ON p.Unidades LIKE CONCAT('%|',0,'|%')                                                                                                    "&chr(13)&_
            " WHERE e.id = 1 "&sqlLimitarProfissionais                                                                                                                        &chr(13)&_
            " GROUP BY NomeLocal                                                                                                                                             "&chr(13)&_
            " ) UNION ALL                                                                                                                                                    "&chr(13)&_
            " (select CONCAT('UNIDADE_ID', fcu.id) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal, CONCAT('|',fcu.id,'|') as Unidades                                  "&chr(13)&_
            "  FROM sys_financialcompanyunits fcu                                                                                                                            "&chr(13)&_
            "  LEFT JOIN profissionais p ON p.Unidades LIKE CONCAT('%|',fcu.id,'|%')                                                                                         "&chr(13)&_
            "  WHERE fcu.sysActive = 1 "&sqlLimitarProfissionais                                                                                                              &chr(13)&_
            " GROUP BY NomeLocal                                                                                                                                             "&chr(13)&_
            "  order by NomeFantasia)                                                                                                                                        "&chr(13)&_
            " UNION ALL                                                                                                                                                      "&chr(13)&_
            " (SELECT concat('G', id) id, concat('Grupo: ', NomeGrupo) NomeLocal                                                                                             "&chr(13)&_
            "        ,(SELECT GROUP_CONCAT(distinct CONCAT('|',locais.UnidadeID,'|')) FROM locais WHERE locaisgrupos.Locais like CONCAT('%|',Locais.id,'|%'))                "&chr(13)&_
            "  from locaisgrupos                                                                                                                                             "&chr(13)&_
            "  where sysActive = 1                                                                                                                                           "&chr(13)&_
            "  order by NomeGrupo)                                                                                                                                           "&chr(13)&_
            " UNION ALL                                                                                                                                                      "&chr(13)&_
            " (select l.id,                                                                                                                                                  "&chr(13)&_
            "         CONCAT(l.NomeLocal,                                                                                                                                    "&chr(13)&_
            "               IF(l.UnidadeID = 0, IFNULL(concat(' - ', e.Sigla), ''), IFNULL(concat(' - ', fcu.Sigla), ''))) NomeLocal,CONCAT('|',l.UnidadeID,'|') as Unidades "&chr(13)&_
            "  from locais l                                                                                                                                                 "&chr(13)&_
            "           LEFT JOIN empresa e ON e.id = IF(l.UnidadeID = 0, 1, 0)                                                                                              "&chr(13)&_
            "           LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID                                                                                      "&chr(13)&_
            "  LEFT JOIN profissionais p ON p.Unidades LIKE CONCAT('%|',l.UnidadeID,'|%')                                                                                    "&chr(13)&_
            "  where l.sysActive = 1 "&sqlLimitarProfissionais                                                                                                                &chr(13)&_
            "  order by l.NomeLocal) "
    else
        sqlAM = " (select CONCAT('UNIDADE_ID', 0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal, CONCAT('|',0,'|') as Unidades FROM empresa WHERE id = 1                  "&chr(13)&_
                " AND 0 in ("&replace(Unidades, "|","")&")                                                                                                                      "&chr(13)&_
                " GROUP BY NomeLocal                                                                                                                                             "&chr(13)&_
                " ) UNION ALL                                                                                                                                                    "&chr(13)&_
                " (select CONCAT('UNIDADE_ID', id), CONCAT('Unidade: ', NomeFantasia) NomeLocal, CONCAT('|',id,'|') as Unidades                                                  "&chr(13)&_
                "  FROM sys_financialcompanyunits                                                                                                                                "&chr(13)&_
                "  WHERE sysActive = 1                                                                                                                                           "&chr(13)&_
                "  AND id in ("&replace(Unidades, "|","")&")                                                                                                                     "&chr(13)&_
                " GROUP BY NomeLocal                                                                                                                                             "&chr(13)&_
                "  order by NomeFantasia)                                                                                                                                        "&chr(13)&_
                " UNION ALL                                                                                                                                                      "&chr(13)&_
                " (SELECT concat('G', id) id, concat('Grupo: ', NomeGrupo) NomeLocal                                                                                             "&chr(13)&_
                "        ,(SELECT GROUP_CONCAT(distinct CONCAT('|',locais.UnidadeID,'|')) FROM locais WHERE locaisgrupos.Locais like CONCAT('%|',Locais.id,'|%'))                "&chr(13)&_
                "  from locaisgrupos                                                                                                                                             "&chr(13)&_
                "  where sysActive = 1                                                                                                                                           "&chr(13)&_
                "  order by NomeGrupo)                                                                                                                                           "&chr(13)&_
                " UNION ALL                                                                                                                                                      "&chr(13)&_
                " (select l.id,                                                                                                                                                  "&chr(13)&_
                "         CONCAT(l.NomeLocal,                                                                                                                                    "&chr(13)&_
                "                IF(l.UnidadeID = 0, IFNULL(concat(' - ', e.Sigla), ''), IFNULL(concat(' - ', fcu.Sigla), ''))) NomeLocal,CONCAT('|',l.UnidadeID,'|') as Unidades"&chr(13)&_
                "  from locais l                                                                                                                                                 "&chr(13)&_
                "           LEFT JOIN empresa e ON e.id = IF(l.UnidadeID = 0, 1, 0)                                                                                              "&chr(13)&_
                "           LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID                                                                                      "&chr(13)&_
                "  AND fcu.id in ("&replace(Unidades, "|","")&")                                                                                                                 "&chr(13)&_
                "  where l.sysActive = 1                                                                                                                                         "&chr(13)&_
                "  order by l.NomeLocal) "
    end if

end if

if Profissionais<>"" then
    sqlProfissionais = "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' "&_
                   "UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais WHERE (NaoExibirAgenda != 'S' OR NaoExibirAgenda is null OR NaoExibirAgenda='') "&_
                   "AND sysActive=1 and Ativo='on' "&sqlLimitarProfissionais&" AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('"&Unidades&"',''),'-999')),TRUE) ORDER BY NomeProfissional)t "&_
                   "ORDER BY Ordem, NomeProfissional"
else
    sqlProfissionais = "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' "&_
                   "UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais WHERE (NaoExibirAgenda != 'S' OR NaoExibirAgenda is null OR NaoExibirAgenda='') "&_
                   "AND sysActive=1 and Ativo='on' AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('"&Unidades&"',''),'-999')),TRUE) ORDER BY NomeProfissional)t "&_
                   "ORDER BY Ordem, NomeProfissional"
end if
%>

<style type="text/css">
    .multiselect.btn {
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .multiselect.btn .caret {
        position: absolute;
        right: 15px;
        top: 15px;
    }
</style>

<div class="row">
    <% if getConfig("multiplaExibirCampoProcedimento") then %>
        <div class="col-md-2">
            <%= selectInsert("Procedimento", "filtroProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " ", "", "") %>
        </div>
    <% end if %>

    <%=quickField("multiple", "Profissionais", "Profissionais", 2, req("Profissionais"), "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais p WHERE (NaoExibirAgenda != 'S' OR NaoExibirAgenda is null OR NaoExibirAgenda='') AND sysActive=1 and Ativo='on' "&sqlLimitarProfissionais&" ORDER BY NomeProfissional)t ORDER BY Ordem, NomeProfissional", "NomeProfissional", " empty ") %>
    <%=quickField("multiple", "Especialidade", "Especialidades", 2, req("Especialidades"), "SELECT t.EspecialidadeID id, IFNULL(e.nomeEspecialidade, e.especialidade) especialidade FROM (	SELECT EspecialidadeID from profissionais p WHERE ativo='on' "&sqlLimitarProfissionais&"	UNION ALL	select pe.EspecialidadeID from profissionaisespecialidades pe LEFT JOIN profissionais p on p.id=pe.ProfissionalID WHERE p.Ativo='on' "&sqlLimitarProfissionais&") t LEFT JOIN especialidades e ON e.id=t.EspecialidadeID WHERE NOT ISNULL(especialidade) AND e.sysActive=1 GROUP BY t.EspecialidadeID ORDER BY especialidade", "especialidade", " empty ") %>

    <% if getConfig("multiplaExibirCampoConvenios") then %>
        <%=quickField("multiple", "Convenio", "Convênios", 2, "", "select c.id, c.NomeConvenio from convenios c LEFT JOIN profissionais p ON p.SomenteConvenios LIKE CONCAT('%|',c.id,'|%') where c.sysActive=1 and c.Ativo='on' "&sqlLimitarProfissionais&franquia(" AND  COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")&" GROUP BY c.id order by c.NomeConvenio", "NomeConvenio", " empty ") %>
    <% end if %>

    <%=quickField("multiple", "Locais", "Locais", 2, sUnidadeID, sqlAM, "NomeLocal", " empty ")%>

    <% if getConfig("multiplaExibirCampoEquipamentos") then %>
        <%=quickField("multiple", "Equipamentos", "Equipamentos", 2, "", "SELECT e.id, e.NomeEquipamento FROM equipamentos e LEFT JOIN profissionais p ON p.Unidades LIKE CONCAT('%|',e.UnidadeID,'|%') WHERE e.sysActive=1 and e.Ativo='on' "&sqlLimitarProfissionais&franquia("AND COALESCE(cliniccentral.overlap(CONCAT('|',UnidadeID,'|'), COALESCE(NULLIF('|0|', ''), '-999')),true)")&" GROUP BY e.id ORDER BY NomeEquipamento", "NomeEquipamento", "empty") %>
    <% end if %>
    <input type="hidden" id="hData" name="hData" value="<%= hData %>" />

    <%
    if getConfig("ExibirProgramasDeSaude") = 1 then
        sqlProgramasSaude = "SELECT prog.id, prog.NomePrograma FROM programas prog " &_
                            "LEFT JOIN profissionaisprogramas pp ON pp.ProgramaID = prog.id AND pp.sysActive = 1 " &_
                            "LEFT JOIN profissionais p ON pp.ProfissionalID = p.id " &_
                            "WHERE prog.sysActive = 1 " & sqlLimitarProfissionais & " " &_
                            "GROUP BY prog.id ORDER BY prog.NomePrograma"
        response.write quickField("multiple", "Programas", "Programas de Saúde", 2, req("Programas"), sqlProgramasSaude, "NomePrograma", " empty ")
    end if
    %>
</div>
<div class="row">
    <div class="col-md-12 text-center">
        <button id="buscar" class="btn btn-primary <% if not ExibeBotaoBusca then %>hidden<% end if%> mt10 btn-block" onclick="$(this).addClass('hidden')"><i class="far fa-search"></i> BUSCAR</button>
    </div>
</div>

<script >
    <% if ModoFranquiaUnidade then %>
        $( document ).ready(function() {
            loadAgenda();
        });
    <%  end if %>
$("#frmFiltros select").change(function () {
    //loadAgenda();
    $("#buscar").removeClass("hidden");
});
<!--#include file="JQueryFunctions.asp"-->
</script>