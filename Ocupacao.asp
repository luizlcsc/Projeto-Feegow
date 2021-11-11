<!--#include file="connect.asp"-->
<%
Data = date()

'function ocupacao(De, Ate, refEspecialidade, reffiltroProcedimentoID, rfProfissionais, rfConvenio, rfLocais)

if session("Banco")="clinic5760" or session("Banco")="clinic6118" or session("Banco")="clinic5968" or session("Banco")="clinic6259" then
    'sUnidadeID = "|"& session("UnidadeID") &"|"
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1)"
else
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia)NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1) UNION ALL (SELECT concat('G', id) id, concat('Grupo: ', NomeGrupo) NomeLocal from locaisgrupos where sysActive=1 order by NomeGrupo) UNION ALL (select l.id, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where l.sysActive=1 order by l.NomeLocal)"
end if

%>
<div class="panel mt15">
    <div class="panel-body">
        <form id="frmO">
            <%= quickfield("multiple", "Especialidades", "Especialidades", 4, "", "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", " onchange='ot()'") %>
            <%'= quickfield("simpleSelect", "Especialidades", "Especialidade", 4, "", "select concat('|', id, '|') id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", " onchange='ot()'") %>
            <%= quickfield("datepicker", "Data", "Data", 2, Data, "", "", " onchange='ot()' ") %>
            <%'= quickfield("empresa", "Unidade", "Unidade", 2, session("UnidadeID"), "", "", " onchange='ot()' ") %>
			<%=quickField("multiple", "Unidade", "Unidades", 2, sUnidadeID, sqlAM, "NomeLocal", " empty  onchange='ot()' ") %>

        </form>
        <div class="col-md-4">
            <div class="row">
                <div class="col-md-3 label label-sm btn-default">Vazia</div>
                <div class="col-md-3 label label-sm btn-info">Até 25%</div>
                <div class="col-md-3 label label-sm btn-system">Até 50%</div>
                <div class="col-md-3 label label-sm btn-alert">Até 75%</div>
            </div>
            <div class="row mt5">
                <div class="col-md-3 label label-sm btn-warning">Até 100%</div>
                <div class="col-md-3 label label-sm btn-danger">Lotada</div>
                <div class="col-md-3 label label-sm btn-dark">Não atende</div>
                <div class="col-md-3 label label-sm btn-primary">* Exceção</div>
            </div>
        </div>
    </div>
</div>
<div class="panel">
    <div class="panel-body" id="divOT">
        Selecione acima as especialidades que deseja visualizar.
    </div>
</div>
<script type="text/javascript">
$(".crumb-active a").html("Mapa de agenda");
$(".crumb-link").removeClass("hidden");
$(".crumb-link").html("taxa de ocupação das agendas");
$(".crumb-icon a span").attr("class", "falr fa-map");

function ot(){
        $("#divOT").html("<div class='text-center'>Carregando...</div>");
    $.post("OcupacaoTabela.asp", $("#frmO").serialize(), function(data){ 
        $("#divOT").html(data);
    });
}
//ot();
</script>