<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
'URGENTE: agendamultiplaconteudo.asp ESTAVA DESATUALIZADO QUANDO COPIEI O CONTEÚDO - RECOMPARAR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%>

<style type="text/css">
    .btn-3 {
        width:33%;
    }
    .btn-2 {
        width:50%;
    }
</style>
<script>
$(function(){
    Limpar();
});
</script>

    <div class="panel mt20 mbn">
        <div class="panel-body">
        <div id="div-agendamento" style="display: none"></div>
        <form id="bAgenda">
        <%
        set UltimaBuscaSQL = db.execute("SELECT PacienteID, TabelaID FROM agendacarrinho ac WHERE ac.sysUser="& session("User") &" and isnull(ac.Arquivado) AND PacienteID IS NOT NULL")
        if not UltimaBuscaSQL.eof then
            PacienteID=UltimaBuscaSQL("PacienteID")
            TabelaID=UltimaBuscaSQL("TabelaID")
        end if
        %>

            <div class="row">
                <div class="col-md-3">
                    <div class="btn-group btn-block" role="group" aria-label="Basic example">
                        <button type="button" class="btn btn-3 btn-default" onclick="paciente()"><i class="far fa-user"></i> <br /> Paciente</button>
                        <button type="button" class="btn btn-3 btn-default" onclick="paciente()"><i class="far fa-calendar"></i> <br /> Agendamento</button>
                        <a href="?P=AgendamentoLaboratorial&Pers=1" class="btn btn-3 btn-default" ><i class="far fa-medkit"></i> <br /> Laboratórios</a>
                    </div>
                    
                
                
                
                
                </div>
                <div class="col-md-5">
                    <%= selectInsert("Paciente", "bPacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""agfilParametros();""", "required", "") %>
                </div>
                <%= quickfield("simpleSelect", "bageTabela", "Tabela", 2, TabelaID, "select id, NomeTabela from tabelaparticular where sysActive=1 order by NomeTabela", "NomeTabela", " no-select2 onchange='agfilParametros()' ") %>
                <div class="col-md-2">
                    <div class="btn-group btn-block" role="group" aria-label="Basic example">
                        <button onclick="Limpar()" class="btn btn-2 btn-default" type="button"><i class="far fa-eraser"></i> <br /> Limpar</button>
                        <button type="button" class="btn btn-2 btn-alert" onclick="profissionais()"><i class="far fa-user-md"></i> <br /> Profissionais</button>
                    </div>
                </div>
            </div>
            <div class="row">
                <%= quickfield("simpleSelect", "bGrupoID", "Grupo", 3, "", "select id, NomeGrupo from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", " no-select2 ") %>
                <%= quickfield("simpleSelect", "bProcedimentoID", "Procedimento", 4, "", "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' and ifnull(OpcoesAgenda, 0)<>3 order by NomeProcedimento", "NomeProcedimento", " empty ") %>
                <%= quickfield("simpleSelect", "bComplementoID", "Complemento", 2, "", "select id, NomeComplemento from complementos where sysActive=1 and length(NomeComplemento)>1 order by NomeComplemento", "NomeComplemento", " empty ") %>
                <div class="col-md-1">
                    <button type="button" class="btn btn-success btn-sm mt25 btn-block" onclick="cart('I')"><i class="far fa-plus"></i></button>
                </div>
                <%= quickfield("simpleSelect", "bRegiao", "Zona", 2, "", "select '' id, 'Todas' Regiao UNION ALL select distinct Regiao id , Regiao  from sys_financialcompanyunits WHERE sysActive=1 AND Regiao is not null and Regiao!=''", "Regiao", " semVazio ") %>
            </div>
            <div class="row">
                <%= quickfield("datepicker", "bData", "Data", 2, date(), "", "", "") %>
                <%= quickfield("simpleSelect", "bEspecialidadeID", "Especialidade", 3, "", "select t.EspecialidadeID id, if(e.especialidade='' or isnull(e.especialidade), nomeespecialidade, especialidade) NomeEspecialidade from ( select p.EspecialidadeID from profissionais p union all select distinct especialidadeid from profissionaisespecialidades ) t LEFT JOIN especialidades e ON e.id=t.EspecialidadeID WHERE NOT ISNULL(t.EspecialidadeID) GROUP BY t.EspecialidadeID", "NomeEspecialidade", " empty ") %>
                <%= quickfield("simpleSelect", "bSubespecialidadeID", "Especializações", 4, "", "select id, Subespecialidade from subespecialidades where sysActive=1 order by Subespecialidade", "Subespecialidade", " empty ") %>
                <%= quickfield("simpleSelect", "bProfissionalID", "Executor", 3, "", "select id, if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional from profissionais where sysActive=1 and ativo='on' order by if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial)", "NomeProfissional", " empty ") %>
            </div>
            <div class="row mt10">
                <div class="col-md-12" id="divCart">
                    <% server.Execute("Cart.asp") %>
                </div>
            </div>
            <div class="row mt10">
                <div class="col-md-12">
                    <button onclick="buscar()" type="button" class="btn btn-primary btn-sm btn-block"><i class="far fa-search"></i> Buscar por horários</button>
                </div>
            </div>
            <div class="row mt10">
                <div class="col-md-12" id="divBusca">
                    
                </div>
            </div>
        </form>

        </div>
    </div>

<div class="panel mt10">
    <div class="row col-xs-12" id="div-agendamento"></div>
    <div id="GradeAgenda"></div>
</div>

<div class="panel  mt10">
    <div class="row col-xs-12" id="UnidadesBusca"></div>
</div>

<div class="row">
    <div class="col-md-4"></div>
    <div class="col-md-2">
        <button type="button" class="btn btn-warning mt15 btn-block btn-xs" title="Desistência"><i class="far fa-remove"></i> Desistência</button>
    </div>
    <div class="col-md-2">
        <button onclick="RegistrarMultiplasPendencias()" type="button" class="btn btn-danger mt15 btn-block btn-xs" title="Pendência"><i class="far fa-puzzle-piece"></i> Pendência</button>
    </div>
    <div class="col-md-2">
        <button onclick="FinalizarBusca()" type="button" class="btn btn-primary mt15 btn-block btn-xs" title="Finalizar busca"><i class="far fa-check"></i> Finalizar</button>
    </div>
    <div class="col-md-2">
        <button onclick="Receber()" type="button" class="btn btn-success mt15 btn-block btn-xs" title="Receber do paciente"><i class="far fa-dollar"></i> Receber </button>
    </div>
</div>


<script type="text/javascript">
//SLV
function cart(A, I){
    $.post("Cart.asp?A="+A+"&I="+I, $("#bAgenda").serialize(), function(data){
       $("#divCart").html(data);
    });
}

function paciente(){
    var id = $("#bPacienteID").val();

    if( id != "" && id != null){
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.get("HistoricoPaciente.asp?PacienteID=" + id, function (data) { $("#modal").html( data ); });
    }
}

function FinalizarBusca() {
    var PacienteID = $("#bPacienteID").val();

    $.post("FinalizarBusca.asp", {PacienteID: PacienteID}, function(data) {
        Limpar();
        eval(data);
       var $tableCarrinho = $("#divCart").find("table");
       if($tableCarrinho){
           $tableCarrinho.remove();
           $("#divBusca").html("");
       }
    });
}

function buscar() {
    //if( $('#bPacienteID').val()=='' || $('#bPacienteID').val()== null ){
    //    alert('Selecione um paciente.');
    //    return false;
    //}else{
        $("#divBusca").html("<div style='text-align:center'><i class='far fa-circle-o-notch fa-spin'></i> Carregando!...</div>");
        $.post("CartBusca.asp", { Data: $("#bData").val(), Regiao: $("#bRegiao").val() }, function (data) {
            $("#divBusca").html(data);
        });
    //}
}

function agfilParametros(){
    if($("#bPacienteID").val() > 0){
    $.post("agfilParametros.asp", $(".agfil, #bPacienteID, #bageTabela").serialize(), function(data){ eval(data) });
    }
}


//VNC
function Limpar() {
    var $form = $("#bAgenda");
    $form.find(':input').not(':button, :submit, :reset, :hidden, :checkbox, :radio, .input-mask-date').val('0');
    $form.find(':checkbox, :radio').prop('checked', false);
    $('.select2-single, #bProcedimentoID, #bPacienteID').val(null).trigger("change")
    $(".select2-single, #bProcedimentoID, #bPacienteID").val([]);

    cart("ALL")
}

function ibAgenda(A, I) {
//    $.post("MultiplaFiltrosBusca.asp?A="+A+"&I="+I, $("#bAgenda").serialize(), function (data) { $("#GradeAgenda").html(data) });
}

function RegistrarMultiplasPendencias() {
    var pendencias = [];
    var $pendenciasSelecionadas = $("input[name='BuscaSelecionada']:checked");

    $.each($pendenciasSelecionadas, function() {
        pendencias.push($(this).val())
    });

    AbrirPendencias(0, pendencias)
}

function parametros(tipo, id){
    setTimeout(function() {
        if(id == -1){
            id = $("#"+tipo).val();
        }
        $.ajax({
            type:"POST",
            url:"AgendaParametros.asp?tipo="+tipo+"&id="+id,
            data:$("#formAgenda").serialize(),
            success:function(data){
                eval(data);
            }
        });
    }, 100);
}
//ibAgenda();

<!--#include file="funcoesAgenda1.asp"-->

function GerarGrade(){

}

function calculaHorariosLivres(BuscaID) {
    var $tableBusca = $(".tabela-resultado-horarios[data-busca="+BuscaID+"]");

    var $unidadesNaBusca = $tableBusca.find(".linha-unidade");

    $.each($unidadesNaBusca, function() {
        var $unidade = $(this);
        var unidadeId = $unidade.data('unidade');
        var $datas = $unidade.find('.data-disponivel');

        $.each($datas, function() {
          var date = $(this).data("date");

          var $horarios = $(this).find(".btn-horario-livre");
          var horariosDisponiveis = $horarios.length;
          var $unidadeResumo = $(".linha-unidade-resumo[data-unidade="+unidadeId+"]");
          var $resumoData = $unidadeResumo.find(".data-resumo[data-date='"+date+"']");

          if(horariosDisponiveis){
              var horariosManha = $horarios.filter("[data-periodo='M']").length;
              var horariosTarde = $horarios.filter("[data-periodo='T']").length;

              var str = "<strong>"+horariosManha + "M / "+horariosTarde+"T</strong>";

              $resumoData.find(".btn-exibir-horarios").fadeIn().html(str);
          }

        });
    });
}

function ExibeHorarios(BuscaID, Data, UnidadeID) {
    var $busca = $(".tabela-resultado-horarios[data-busca="+BuscaID+"]");
    var $linhaResumo = $busca.find(".linha-unidade-resumo[data-unidade="+UnidadeID+"]");
    var $linhaUnidade = $busca.find(".linha-unidade[data-unidade='"+UnidadeID+"']");

    $linhaResumo.fadeOut(function() {
        $linhaUnidade.fadeIn();
    });
}

function loadAgenda(){
    //ibAgenda('');
}

    $(".crumb-active a").html("Agenda por Filtros");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "far fa-calendar");

    $("#bGrupoID").change(function() {
        $.get("comboGrupoProcedimento.asp", {GrupoID: $(this).val()}, function(data) {
            $("#bProcedimentoID").html(data).select2();
        })
    });

    function ModalProcedimentosComPrioridade(){
         openComponentsModal("ProcedimentosComPrioridade.asp", {}, "Procedimentos com prioridade", true, "Adicionar procedimentos");
    }

    function AbrirPendencias(UnidadeID, BuscaID){
        var Regiao = $("#nRegiao").val();

        openComponentsModal("RegistrarPendencia.asp", {
            UnidadeID: UnidadeID,
            Regiao: Regiao,
            BuscaID: BuscaID,
            PacienteID: $("#bPacienteID").val(),
            ProcedimentoID: $("#bProcedimentoID").val(),
            // Datas: $("#bData").val()
        }, "Pendências", true, "Adicionar pendência");
    }

    function AbreAgendaDiaria(Data, ProfissionalID, UnidadeID){

        openComponentsModal("ModalAgendaDiaria.asp", {
            Data: Data,
            ProfissionalID: ProfissionalID
        }, "Exibir agenda", true);
    }

$(document).ready(function() {
  setTimeout(function() {
    $("#toggle_sidemenu_l").click()
  }, 500);
});

$("#bPacienteID").change(function(){
    if ($(this).val() > 0) {
        hist( $(this).val() );
    }
});

function toogleAgendaContent(showForm=false, cb) {
    var $form = $("#bAgenda");
    var $divAgenda = $("#div-agendamento");

    if(showForm){
        $divAgenda.fadeOut(function() {
            $form.fadeIn(function() {
                if(cb){
                    cb();
                }
            })
        });
    }else{
        $form.fadeOut(function() {
            $divAgenda.fadeIn(function() {
                if(cb){
                    cb();
                }
            })
        });
    }
}

function af(AbreFecha) {
    if(AbreFecha==="f"){
        toogleAgendaContent(true);
    }
}

function crumbAgenda(){
    return false;
}

function profissionais(){
    var id = $("#bProfissionalID").val();

    if( id != "" && id != null){
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.get("HistoricoProfissional.asp?ProfissionalID=" + id, function (data) { $("#modal").html( data ); });
    }
}

function hist(P) {
    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10"><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.get("HistoricoPaciente.asp?PacienteID=" + P, function (data) { $("#modal").html( data ); });
}

var CarrinhoID = 0;

function abreAgenda(Hora, id,Data, ProfissionalID, EspecialidadeID, TabelaID, ProcedimentoID, LocalID, ValorSelector, CarrinhoID) {
            window.CarrinhoID = CarrinhoID;
            // $("#div-agendamento").html('<i class="far fa-spinner fa-spin orange bigger-125"></i> Carregando...');

            var Valor = $("#"+ValorSelector).val();
            var GradeID = 0;
            var PacienteID = $("#bPacienteID").val();

            Hora = Hora.replace(":", "");

            $.ajax({
                type: "POST",
                url: "divAgendamento.asp?Requester=MultiplaFiltros&Valor="+Valor+"&PacienteID="+PacienteID+"&horario=" + Hora + "&data=" + Data + "&profissionalID=" + ProfissionalID + "&LocalID=" + LocalID + "&ProcedimentoID=" + ProcedimentoID+"&GradeID="+GradeID+"&EspecialidadeID="+EspecialidadeID,
                success: function (data) {
                    $("#div-agendamento").html(data);
                    toogleAgendaContent(false);
                }
            });
}
function callbackAgendaFiltros() {

    var PacienteID = $("#bPacienteID").val();


    $.post("VinculaAgendamentoABusca.asp", {PacienteID: PacienteID, CarrinhoID: CarrinhoID}, function(data) {
    //
        cart(null,null);
    });
};
</script>
