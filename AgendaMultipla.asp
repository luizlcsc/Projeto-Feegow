﻿<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalSecundario.asp"-->
<style type="text/css">
    .open:hover > .submenu {
        display: block;
    }
body{
//    overflow-y:hidden;
}

</style>
<%
sqlLimitarProfissionais =""
tipoUsuario =""
if lcase(session("table"))="funcionarios" then
     tipoUsuario ="funcionarios"
     set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
     if not FuncProf.EOF then
     profissionais=FuncProf("Profissionais")
        if not isnull(profissionais) and profissionais<>"" then
            profissionaisExibicao = replace(profissionais, "|", "")
            sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
        end if
     end if
elseif lcase(session("table"))="profissionais" then
     tipoUsuario ="profissionais"
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
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1 order by NomeFantasia)"
else
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia)NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1 order by NomeFantasia) UNION ALL (SELECT concat('G', id) id, concat('Grupo: ', NomeGrupo) NomeLocal from locaisgrupos where sysActive=1 order by NomeGrupo) UNION ALL (select l.id, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where l.sysActive=1 order by l.NomeLocal)"
end if

if aut("ageoutunidadesV")=0 then
    'response.write "SELECT Unidades FROM "&tipoUsuario&" WHERE id="&session("idInTable")
    set uniProf = db.execute("SELECT Unidades FROM "&tipoUsuario&" WHERE id="&session("idInTable"))
    if not uniProf.eof then
        uniWhere = " where id is null"
        if Len(uniProf("unidades"))>0 then
            spuni = replace(uniProf("unidades"),"|","")
            uniWhere = " where id in("&spuni&")"
         end if
        sqlAM = "SELECT CONCAT('UNIDADE_ID',id) as 'id', CONCAT('Unidade: ', NomeFantasia)NomeLocal FROM (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1 order by NomeFantasia )t "&uniWhere&" ORDER BY t.NomeFantasia"
        'response.write sqlAM
    end if
end if

if req("Data")<>"" then
    hData = req("Data")
else
    hData = date()
end if
%>

<div class="panel">
    <div class="panel-body">
        <form id="frmFiltros">
            <div class="row">
                <%=quickField("select", "filtroProcedimentoID", "Procedimento", 2, "", "select '' id, '-' NomeProcedimento UNION ALL select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' and OpcoesAgenda!=3 order by NomeProcedimento", "NomeProcedimento", " empty ") %>
                <%=quickField("multiple", "Profissionais", "Profissionais", 2, req("Profissionais"), "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais WHERE (NaoExibirAgenda != 'S' OR NaoExibirAgenda is null OR NaoExibirAgenda='') AND sysActive=1 and Ativo='on' "&sqlLimitarProfissionais&" ORDER BY NomeProfissional)t ORDER BY Ordem, NomeProfissional", "NomeProfissional", " empty ") %>
                <%=quickField("multiple", "Especialidade", "Especialidades", 2, req("Especialidades"), "SELECT t.EspecialidadeID id, IFNULL(e.nomeEspecialidade, e.especialidade) especialidade FROM (	SELECT EspecialidadeID from profissionais WHERE ativo='on'	UNION ALL	select pe.EspecialidadeID from profissionaisespecialidades pe LEFT JOIN profissionais p on p.id=pe.ProfissionalID WHERE p.Ativo='on') t LEFT JOIN especialidades e ON e.id=t.EspecialidadeID WHERE NOT ISNULL(especialidade) AND e.sysActive=1 GROUP BY t.EspecialidadeID ORDER BY especialidade", "especialidade", " empty ") %>
                <%=quickField("multiple", "Convenio", "Convênios", 2, "", "select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' order by NomeConvenio", "NomeConvenio", " empty ") %>
                <%'=quickField("empresaMultiIgnore", "Unidades", "Unidades", 2, "", "", "", "") %>
                <%=quickField("multiple", "Locais", "Locais", 2, sUnidadeID, sqlAM, "NomeLocal", " empty ") %>
                <%=quickField("multiple", "Equipamentos", "Equipamentos", 2, "", "SELECT id, NomeEquipamento FROM equipamentos WHERE sysActive=1 and Ativo='on' ORDER BY NomeEquipamento", "NomeEquipamento", "empty") %>
                <input type="hidden" id="hData" name="hData" value="<%= hData %>" />
            </div>
            <div class="row">
                <div class="col-md-12 text-center">
                    <button id="buscar" class="btn btn-primary hidden mt10 btn-block" onclick="$(this).addClass('hidden')"><i class="fa fa-search"></i> BUSCAR</button>
                </div>
            </div>
        </form>
    </div>
</div>

<%if getConfig("EquipamentosAgendaMultipla")=1 then %>
<script>
$(document).ready(function () {
    $("#Equipamentos option").prop('selected', true);
    $("#frmFiltros").submit()
})
</script>
<%end if%>

<input type="hidden" id="LocalPre" name="LocalPre" value="" />
<input type="hidden" id="ProfissionalPre" name="ProfissionalPre" value="" />

    <div class="panel-body bg-light pn">
       <div class="row col-xs-12" id="div-agendamento"></div>
       <div class="row col-sm-12 mn" id="GradeAgenda">
           <div class="col-md-12" id="contQuadro" style="border: 1px solid rgb(173, 173, 173); overflow: scroll; height: 914px;">
                <center>
                    <i class="fa fa-spinner fa-spin"></i> Carregando...
                </center>
            </div>
       </div>
    </div>


<script type="text/javascript">

    $("#frmFiltros select").change(function () {
        //loadAgenda();
        $("#buscar").removeClass("hidden");
    });

    $("#frmFiltros").submit(function(){
        loadAgenda();
        return false;
    });

    function loadAgenda() {
        $("#contQuadro").html("<center><i class='fa fa-spin fa-cog'></i> Carregando...</center>");
        $.post("AgendaMultiplaConteudo.asp", $("#frmFiltros, #HVazios").serialize(), function (data) {
            $("#contQuadro").html(data);
        });
        $("#buscar").addClass("hidden");
    }

    $("#contQuadro").innerHeight(window.innerHeight - 300);

    $(window).resize(function () {
        $("#contQuadro").innerHeight(window.innerHeight - 300);
    });

    <!--#include file="funcoesAgenda1.asp"-->

    function remarcar(AgendamentoID, Acao, Hora, LocalID, ProfissionalID){
        if(ProfissionalID==undefined){
            ProfissionalID = $("#ProfissionalID").val();
        }
        Data = $("#hData").val();
        $.ajax({
            type:"POST",
            url:"Remarcar.asp?ProfissionalID="+ProfissionalID+"&Data="+Data+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
            success: function(data){
                eval(data);
            }
        });
    }



    function changeMonth(newDate) {
        $.ajax({
            type: "GET",
            url: "AgendamentoCalendarioMultipla.asp?Data=" + newDate,
            success: function (data) {
                $("#divCalendario").html(data);
            }
        });
        $("#hData").val(newDate);
        loadAgenda();
    }


    function abreAgenda(horario, id, data, LocalID, ProfissionalID, EquipamentoID, GradeID) {
        // if( $("#EquipamentoPre").val()!="" ){
        //     EquipamentoID = $("#EquipamentoPre").val();
        // }
        if( $("#LocalPre").val()!="" ){
            LocalID = $("#LocalPre").val();
        }
        if ($("#ProfissionalPre").val() != "") {
            ProfissionalID = $("#ProfissionalPre").val();
        }
        if ($("#filtroProcedimentoID").val() != "") {
            var ProcedimentoID = $("#filtroProcedimentoID").val();
            EquipamentoID = "";
        }
        var EspecialidadeID = "";
        if ($("#Especialidade").val() != "") {
            EspecialidadeID = $("#Especialidade").val();
        }

        if(typeof ProfissionalID === "undefined"){
            ProfissionalID = "";
        }
        if(typeof EquipamentoID === "undefined"){
            EquipamentoID = "";
        }

        if(typeof GradeID === "undefined"){
            GradeID = "";
        }
        if(typeof LocalID === "undefined"){
            LocalID = "";
        }
        if(typeof data === "undefined"){
            data = "";
        }

        if(typeof ProcedimentoID === "undefined"){
            ProcedimentoID = "";
        }

        $("#div-agendamento").html('<i class="fa fa-spinner fa-spin orange bigger-125"></i> Carregando...');
        af('a');

        let UnidadeID="", UnidadesSelecionas = $("#Locais").val();

        if(UnidadesSelecionas){

            if(typeof UnidadesSelecionas[0] !== "undefined"){
                UnidadeID = UnidadesSelecionas[0].replace(new RegExp("\\|", 'g'), "");
                UnidadeID = UnidadeID.replace("UNIDADE_ID", "");
            }
        }

        $.ajax({
            type: "POST",
            url: "divAgendamento.asp?horario=" + horario + "&id=" + id + "&data=" + data + "&profissionalID=" + ProfissionalID + "&LocalID=" + LocalID + "&EquipamentoID=" + EquipamentoID + "&ProcedimentoID=" + ProcedimentoID+"&GradeID="+GradeID+"&EspecialidadeID="+EspecialidadeID+
            "&UnidadeID="+UnidadeID,
            success: function (data) {
                $("#div-agendamento").html(data);
            }
        });
    }

    function imprimir() {
        $("#modal-agenda").modal("show");
        //	$("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='fa fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgendaPrint.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val()+"' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
        $("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='fa fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgenda1Print.asp?Data=" + $("#Data").val() + "&ProfissionalID=" + $("#ProfissionalID").val() + "' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
    }

    <% if session("Banco")="clinic5760" or session("Banco")="clinic6118" then %>
        $("#contQuadro").html("Selecione os parâmetros acima para buscar na agenda.");
    <% else %>
        loadAgenda();
    <% end if%>

    function oa(P) {
        $("#modal").html("Carregando informações do profissional...");
        $("#modal-table").modal("show");
        $.get("ObsAgenda.asp?ProfissionalID=" + P, function (data) {
            $("#modal").html(data);
        });
    }

    <% if req("Data") <>"" then %>
        loadAgenda();
    <% end if %>

</script>