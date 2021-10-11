<script>
    var upperSelectInput = true;
</script>
<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<style type="text/css">
    .btn-horario-multipla-filtros{
        border-radius: 0px;
    }

    .select2-search__field{
        text-transform: uppercase;
    }
</style>
<%if recursoAdicional(41)<>4 then%>
<br>
<div class="bs-component">
    <div class="alert alert-warning alert-dismissable">
    <i class="far fa-warning pr10"></i>
    <strong>Permissão negada!</strong> Este recurso não está disponível para sua licença.<br>
    </div>
</div>
<%
    Response.End
end if

idcarrinho = req("Carrinho")

if idcarrinho&"" <> "" then 
    sqlAgenda = "update agendacarrinho set Arquivado=now() where sysUser = "&Session("User")&" "
    db.execute(sqlAgenda)

    sqlAgenda = "update agendacarrinho set Arquivado=NULL and sysUser = "&Session("User")&" where id in ("&idcarrinho&")"
    db.execute(sqlAgenda)
end if

PaciID = req("PaciID")
sessaoAgenda = req("sessaoAgenda")&""
%>
<div class="panel mt10">
    <div class="panel-body">
        <div id="div-agendamento" style="display: none"></div>
        <form id="bAgenda">
<%
        AgendamentoID = 0
        if PaciID&"" <> "" then 
            PacienteID = PaciID
        end if
%>
			<input type="hidden" id="hiddenPendencia" value="">
            <input type="hidden" name="dataBusca" class="dataBusca" id="dataBusca" value="">
            <input type="hidden" name="agendamentoIDCarrinho" class="agendamentoIDCarrinho" id="agendamentoIDCarrinho" value="<%=AgendamentoID%>_">
            <!--<input type="hidden" name="agendamentoIDCarrinho2" class="agendamentoIDCarrinho2" id="agendamentoIDCarrinho2" value="<% 'AgendamentoID%>"> -->
            <div class="row">
                <div class="col-md-3 pacientemultipla">
                    <%= selectInsert("Paciente", "bPacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""agfilParametros(); parametros(this.id, this.value); paciente(); """, "", "paciente_multipla") %>
                    <input type="hidden" name="paciente_multipla" id="paciente_multipla" value="paciente_multipla">
                    <div class="text-right">
                        <a href="#" onclick="paciente()"> <i class="fa fa-info-circle"></i> Detalhes do Paciente</a>
                    </div>
                </div>
                <div class="col-md-3">
                    <%= quickfield("datepicker", "bData", "Data", "", date(), "", "", "") %>
                </div>
                <div class="col-md-3">
                    <%= quickfield("simpleSelect", "bRegiao", "Região", "", "", "select '' id, 'Todas' Regiao UNION ALL select distinct Regiao id , Regiao  from sys_financialcompanyunits WHERE sysActive=1 AND Regiao is not null and Regiao!=''", "Regiao", " semVazio ") %>
                </div>
                <div class="col-md-3">
                    <div class="btn-group btn-block" role="group" style="margin-top:20px">
                        <button style="width:50%" type="button" class="btn btn-default" onclick="propostas()"><i class="far fa-calendar"></i> Laboratório</button>
                        <button style="width:50%" onclick="Limpar(100)" class="btn btn-alert" type="button"><i class="far fa-eraser"></i>  Limpar</button>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-3" id="divComboGrupoProcedimento">
                    <%= quickfield("simpleSelect", "bGrupoID", "Grupo", "", "", "select id, NomeGrupo from procedimentosgrupos where TRUE ", "NomeGrupo", " onchange=""agfilParametros();recarregaCombo('carregaComboProcedimento',$(this).val())"" limitSQL") %>
                </div>
                <div id="divComboProcedimento" class="col-md-3">
                    <%= quickfield("simpleSelect", "bProcedimentoID", "Procedimento", "", "", "select id, NomeProcedimento from procedimentos p where TRUE ", "NomeProcedimento", "required onchange=""agfilParametros();recarregaCombo('carregaComboExecutor','',$(this).val(),$('#bProfissionalID').val());recarregaCombo('carregaComplemento','',$(this).val());recarregaCombo('carregaComboSubEspecializacao','',$(this).val())"" limitSQL") %>
                </div>    
                <div id="divComboProfissional" class="col-md-2">
                    <%= quickfield("simpleSelect", "bProfissionalID", "Executor", "", "", "select id, if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional from profissionais where sysActive=1 and ativo='on' order by if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial)", "NomeProfissional", " onchange=""agfilParametros();recarregaCombo('carregaComboProcedimento','',$('#bProcedimentoID').val(),$(this).val());""") %>
                    <div class="text-right">
                        <a href="#" onclick="profissionais()"> <i class="fa fa-user-md"></i> Histórico</a>
                    </div>
                </div>
                <div id="divComboSubEspecializacoes">
                    <div class="col-md-2">
                        <label for="bSubEspecializacoes"> Sub Especialidade</label>
                        <select class="class_especializacoes" name="bSubEspecializacoes">
                            <option value="0">Selecione</option>
                        </select>
                    </div>
                </div>
                <div id="divComboComplemento">
                    <div class="col-md-2 qf">
                        <label for="bComplementos"> Complemento</label>
                        <select class="class_complementos" name="bComplementos">
                            <option value="0">Selecione</option>
                        </select>
                    </div>
                </div>
            </div>
            <script>
                $('.class_complementos').select2();
                $('.class_especializacoes').select2();
            </script>

            
            <div class="col-md-12">
                <button type="button" class="btn btn-success btn-sm mt25 btn-block" onclick="cart('I');limparFiltros()"><i class="far fa-plus"></i> Adicionar Procedimento</button>
            </div>

            <div class="row mt10" >
                <div class="col-md-12" id="divCart" style="margin-top:20px">
                    
                </div>
            </div>
            
            <div class="row mt10" style="margin:15px 0">
                <div class="col-md-3">
                    <%= quickfield("text", "textHelp", "", 12, "", " input-sm ", "", " placeholder=""Digite um termo...""  ") %>
                </div>
                <div class="col-md-1">
                    <button onclick="ajudar()" type="button" class="btn btn-info btn-sm btn-block"><i class="far fa-life-ring"></i> Ajuda</button>
                </div>
                <div class="col-md-8">
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

<div id="modalpendencias" class="modalpendencias modal fade">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Restrições</h4>
      </div>
      <div class="modal-body modalpendenciasbody" >
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<div id="modalpendencias2" class="modalpendencias2 modal fade">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Restrições</h4>
      </div>
      <div class="modal-body modalpendenciasbody2" >
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<div id="modalObservacao" class="modal fade">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Observações</h4>
      </div>
      <div class="modal-body modalObservacaoBody" >
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<script type="text/javascript">

sessionStorage.setItem("sessaoAgenda", <% if sessaoAgenda <> "" then response.write(sessaoAgenda) else response.write("new Date().getTime()") end if%> )

$.post("Cart.asp?sessaoAgenda="+sessionStorage.getItem("sessaoAgenda"), function(data){
    $("#divCart").html(data);
});

$(document).ajaxSuccess(function(event,request,settings){
	if ( settings.url === "sii.asp" ) {
		var id = $("#bPacienteID").val();
		if (id != "" && id != "-1" && id != null && id != 'null') {
			paciente();
		}
	} 
});

function limparFiltros() {

    $("#bGrupoID").val("0").change();

    $.post("MultiplaFiltrosCombo.asp",{acao:'carregaComboExecutorAll'},function(data){
         $("#divComboProfissional").html(data);
    });

    $("#divComboComplemento").html(`
        <div class="col-md-2 qf">
            <label for="bComplementos"> Complemento</label>
            <select class="class_complementos" name="bComplementos">
                <option value="0">Selecione</option>
            </select>
        </div>`);
                    
    $("#divComboSubEspecializacoes").html(`
        <div class="col-md-2 qf">
            <label for="bSubEspecializacoes"> Sub Especialidade</label>
            <select class="class_especializacoes" name="bSubEspecializacoes">
                <option value="0">Selecione</option>
            </select>
        </div>
    `);

    $('.class_complementos').select2();
    $('.class_especializacoes').select2();
}

function recarregaCombo(acao, GrupoID, ProcedimentoID, ProfissionalID, EspecialidadeID){
    var Comboproced = false; var Comboexec = false;

    $.post("MultiplaFiltrosCombo.asp",{acao:acao, id:id, ProfissionalID: ProfissionalID, ProcedimentoID:ProcedimentoID, GrupoID:GrupoID, EspecialidadeID: EspecialidadeID},function(data){
        $("#divComboProfissional").off();
        switch (acao) {
            case 'carregaComboProcedimento':
                $("#divComboProcedimento").html(data);
                break;
            case 'carregaComboExecutor':
                $("#divComboProfissional").html(data);
                break;
            case 'carregaComboGrupo':
                $("#divComboGrupos").html(data);
                break;
            case 'carregaComplemento':
                 $("#divComboComplemento").html(data);
                 break
            case 'carregaComboSubEspecializacao':
                $("#divComboSubEspecializacoes").html(data);
                break;    
        }
    });
}

$(document).on('hide.bs.modal','#modal-components', function () {
        $.post("savePendencia.asp",{acao:"ExcluirSessao"},function(){});
    });

    $(window).unload(function() {
        $.post("savePendencia.asp",{acao:"ExcluirSessao"},function(){});
    });

    $(window).on('beforeunload', function() {
        $.post("savePendencia.asp",{acao:"ExcluirSessao"},function(){});
    });

    $(window).on('load', function() {
        $.post("savePendencia.asp",{acao:"ExcluirSessao"},function(){});
    });

//SLV
function cart(A, I){
    if(($("#bProcedimentoID").val()  == "" || $("#bProcedimentoID").val() == null || $("#bProcedimentoID").val() == 0) && A == "I" ){
        showMessageDialog("Escolha um procedimento", 'warning');
    }else{
        $.post("Cart.asp?A="+A+"&I="+I+"&sessaoAgenda="+sessionStorage.getItem("sessaoAgenda"), $("#bAgenda").serialize(), function(data){
        $("#divCart").html(data);
        total();
        });
        Limpar(2);
    }
}

function paciente(){
    var id = $("#bPacienteID").val();
    if( id != "" && id != "-1" && id != null && id != 'null'){

        //Finalizar os carrinhos com agendamentos e que não possuem invoice
        $.get('gerarInvoiceCarrinho.asp?PacienteID=' + id, function(result){
            eval(result)
        })
    }
}

function FinalizarBusca() {
    var PacienteID = $("#bPacienteID").val();

    var classeFind = ".allCarrinho";
    var idsCarrinho = "0";

    $(".allCarrinho").each(function(){
        idsCarrinho += "," + $(this).val();
    });
    
    $.post("FinalizarBusca.asp", {PacienteID: PacienteID, carrinhoID: idsCarrinho, sessaoAgenda: sessionStorage.getItem("sessaoAgenda")}, function(data) {
        
        eval(data);
    });
}

function ajudar(){
    var textHelp = $("#textHelp").val();
    textHelpMin = 2;
    if(textHelp.length >= textHelpMin ){
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.get("Help.asp?text=" + textHelp, function (data) { $("#modal").html( data ); });
    }else{
        showMessageDialog("Digite ao menos "+ textHelpMin +" caracters", 'warning');
    }
}

function buscar() {
    if ($("#BuscaSelecionada").val() > 0) {
        $("#dataBusca").val($("#bData").val())
        $("#divBusca").html("<div style='text-align:center'><i class='far fa-circle-o-notch fa-spin'></i> Carregando...</div>");
        $.post("CartBusca2.asp?Regiao=" + $("#bRegiao").val(), {  Data: $("#bData").val(), Regiao: $("#bRegiao").val(), sessaoAgenda: sessionStorage.getItem("sessaoAgenda") }, function (data) {
            $("#divBusca").html(data);
        });
    } else {
        showMessageDialog("Adicione um procedimento ", 'warning');
    }
}

function buscarAllZonas() {
    $("#divBusca").html("<div style='text-align:center'><i class='far fa-circle-o-notch fa-spin'></i> Carregando...</div>");
    $.post("CartBusca2.asp", {  Data: $("#bData").val(), Regiao: '', sessaoAgenda: sessionStorage.getItem("sessaoAgenda") }, function (data) {
        $("#divBusca").html(data);
    });
}

function buscarDias(turno) {
    $(".btnturno").removeClass("active")
    var valorData = $("#dataBusca").val().split("/")
    var busca = new Date(valorData[2], valorData[1] - 1, valorData[0],0,0,0);
    var elem = "";

    if(turno == undefined){
        turno = ''
        var data = new Date(busca.getTime() + (5 * 24 * 60 * 60 * 1000));
    }else if( turno == "menosdias"){
        var data = new Date(busca.getTime() - (5 * 24 * 60 * 60 * 1000));
        var hoje = new Date();

        if(hoje > data)
            data = hoje;
    }else{
        elem = $(this);
        var data = new Date(busca.getTime());
    }
    var nData = (data.getDate()) + "/" + (data.getMonth() + 1) + "/" + data.getFullYear();
    
    $("#dataBusca").val(nData);
    $("#divBusca").html("<div style='text-align:center'><i class='far fa-circle-o-notch fa-spin'></i> Carregando...</div>");
    $.post("CartBusca2.asp", {  Data: nData, Regiao: $("#bRegiao").val(), turno: turno, sessaoAgenda: sessionStorage.getItem("sessaoAgenda") }, function (data) {
        $("#divBusca").html(data);
    });
}

function agfilParametros(){

    if($("#bPacienteID").val() > 0){
    $.post("agfilParametros.asp", $(".agfil, #bPacienteID, #bageTabela").serialize(), function(data){ eval(data) });
    }
}

function submitAgendamento(check) {

    let valorPlano = null;

    if($("#rdValorPlanoV").prop("checked") && !$("#rdValorPlanoV").prop("disabled") ){
        valorPlano = "V";
    }

    if($("#rdValorPlanoP").prop("checked") && !$("#rdValorPlanoP").prop("disabled") ){
        valorPlano = "P";
    }

    if(valorPlano === null){
        new PNotify({
            title: 'Particular ou Convênio?',
            text: 'Selecione a forma do agendamento.',
            type: 'danger',
            delay: 2000
        });

        return false;
    }

    var repetir = $("#rpt").prop("checked");
    let checkin = $("#Checkin").length
    if(checkin === 1 && checkmultiplos === "1"){
        checkinMultiplo();
    }else{
        if(repetir){
            checkAgendasMarcadas().then((response) => {
                if(response.existeAgendamentosFuturos && check) {
                    bootbox();
                    return false;
                }
                saveAgenda();
                return false;
            });
        }else{
            saveAgenda();
        }
    }
}

var saveAgenda = function(){
    $("#btnSalvarAgenda").html('salvando');
    $("#btnSalvarAgenda").prop("disabled", true);
    
    $.post("saveAgenda.asp", $("#formAgenda").serialize())
        .done(function(data){
            
            eval(data);
            $("#btnSalvarAgenda").html('<i class="far fa-save"></i> Salvar');
                $("#btnSalvarAgenda").prop("disabled", false);
                crumbAgenda();

        })
        .fail(function(err){
            $("#btnSalvarAgenda").prop("disabled", true);
            
        });

    if(typeof callbackAgendaFiltros === "function"){
        callbackAgendaFiltros();
        crumbAgenda();
    }
}

checkAgendasMarcadas = function() {
  var header = { method: 'POST',
                 cache: 'default' };

  return fetch(`checkRepeticaoAgendamento.asp?${$("#formAgenda").serialize()}`, header)
		.then((promiseResponse) => {
				return promiseResponse.json();
            }
        );
}

function procs(A, I, LocalID, Convenios, GradeApenasProcedimentos, GradeApenasConvenios,Equipamento) {
    if(A=='I'){

        I = parseInt($("#nProcedimentos").val())-1;
        $("#nProcedimentos").val( I );
        let formapgt = $("[name=rdValorPlano]:checked").val();
        let convenioID = $("#ConvenioID").val();
        $.post("procedimentosagenda.asp", {
            A: A, I: I ,
            LocalID:LocalID,
            Convenios:Convenios,
            GradeApenasProcedimentos:GradeApenasProcedimentos,
            GradeApenasConvenios: GradeApenasConvenios,
            EquipamentoID: Equipamento,
            Forma: formapgt,
            ConvenioSelecionado: convenioID
            }, function (data) {
            addProcedimentos(I);
            $('#bprocs').append(data);

        });


    }else if(A=='X'){
        $("#la"+I).remove();
    }
}

function addProcedimentos(I) {
var pacienteId = $("#PacienteID").val();
var professionalId = $("#ProfissionalID").val();

        $.get("ListarProcedimentosPacote.asp", {
            contadorProcedimentos: I,
            PacienteID: pacienteId,
            ProfissionalID: professionalId
        }, function (data) {
            if(data.length > 0) {
                openModal(data, "Selecionar procedimento do pacote contratado", true, false);
            }
        });
};

function abreModalRestricao(liberar) {
    var checkin = $("#checkinID").val();
    var PacienteID = $("#PacienteID").val();
    var ProcedimentoSelecionadoID = $(".linha-procedimento-id");
    var ProfissionalID = $("#ProfissionalID").val();
    var ids = "";

    ProcedimentoSelecionadoID.each(function(i, obj){
        ids +=  + obj.value + ",";
    });
    ids += "0";

    if(PacienteID == "" || PacienteID == 0 || PacienteID == null){
        new PNotify({
            title: 'Campo obrigatório',
            text: 'Selecione um paciente',
            type: 'warning',
            delay: 2000
        });
    }else{
        $.ajax({
            type: 'GET',
            url: 'procedimentosListagemPaciente.asp?ProfissionalID='+ProfissionalID+'&ProcedimentoId=' + ids + '&PacientedId=' + PacienteID + '&requester=MultiplaPorFiltro&criarPendencia=Sim&Checkin=' + checkin,
            data: true
        }).done(function(data) { 
             $(".modalpendencias").modal("show")
             $(".modalpendenciasbody").html(data)

        });
    }

    return false;
}

function Limpar(all = 1) {

    if(all == 100){
        $("#divBusca").html("")
        cart("ALL")
        location.href="./?P=MultiplaFiltros2&Pers=1&&off=1";
    }
    var $form = $("#bAgenda");
    $form.find(':input').not(':button, :submit, :reset, :hidden, :checkbox, :radio, .input-mask-date, #bPacienteID').val('');
    $form.find(':checkbox, :radio').prop('checked', false);
    $(".select2-single, #bProcedimentoID").val([]);
    
    if(all == 1){
        $('#bPacienteID').val("");
        $('.pacientemultipla #bPacienteID').val(null);
        
        var id = "<%=PaciID%>";
        if (id != ""){
            location.href="./?P=MultiplaFiltros2&Pers=1";
        }
    
        $("#divBusca").html("")
        cart("ALL")
    }

    var today = new Date();
    var dd = today.getDate();

    var mm = today.getMonth()+1; 
    var yyyy = today.getFullYear();
    if(dd<10) 
    {
        dd='0'+dd;
    } 

    if(mm<10) 
    {
        mm='0'+mm;
    } 
    today = dd+'/'+mm+'/'+yyyy;

    $("#bData").val(today)
}

function ibAgenda(A, I) {

}

function RegistrarMultiplasPendencias() {
	
	$("#hiddenPendencia").val("sim");
    var PacienteID = $("#bPacienteID").val();
    var ProcedimentoSelecionadoID = $(".ProcedimentoSelecionadoID");
    var ids = "";

    ProcedimentoSelecionadoID.each(function(i, obj){
        ids += obj.value + ","
    });
    
    if(PacienteID == "" || PacienteID == 0 || PacienteID == null){
		$("#hiddenPendencia").val("");
        alert("Paciente não selecionado");
    } else if (ids == ""){
		$("#hiddenPendencia").val("");
       alert("Procedimento não selecionado");
   }else{
       ids += 0

        $.post("pendenciasUtilities.asp",{acao:"VerificaDuplicidade",PacienteID:PacienteID},function(data){
            if(data > 0){
                var confirmDuplicidade = confirm("Já existe pendência aberta para este paciente. Deseja continuar?");
                if(confirmDuplicidade == true) {
                    $.ajax({
                        type: 'GET',
                        url: 'procedimentosListagem.asp?ProcedimentoId=' + ids + '&PacientedId=' + PacienteID + '&requester=MultiplaPorFiltro&criarPendencia=Sim',
                        data: true
                    }).done(function(data) {
                        $(".modalpendencias").modal("show")
                        $(".modalpendenciasbody").html(data)
                    });
                }
            } else {
                $.ajax({
                    type: 'GET',
                    url: 'procedimentosListagem.asp?ProcedimentoId=' + ids + '&PacientedId=' + PacienteID + '&requester=MultiplaPorFiltro&criarPendencia=Sim',
                    data: true
                }).done(function(data) {
                    $(".modalpendencias").modal("show")
                    $(".modalpendenciasbody").html(data)
                });
            }
        })
    }
    return false;
}

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

}

    $(".crumb-active a").html("Agenda por Filtros");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "far fa-calendar");

    function ModalProcedimentosComPrioridade(){
         openComponentsModal("ProcedimentosComPrioridade.asp", {}, "Procedimentos com prioridade", true, "Adicionar procedimentos");
    }

    function AbrirPendencias(UnidadeID, BuscaID){
        var Regiao = $("#nRegiao").val();
		$("#hiddenPendencia").val("");
        
        openComponentsModal("RegistrarPendencia_new.asp", {
            UnidadeID: UnidadeID,
            Regiao: Regiao,
            BuscaID: BuscaID,
            MultiplaFiltros: "sim",
            PacienteID: $("#bPacienteID").val(),
            ProcedimentoID: $("#bProcedimentoID").val(),
        }, "Pendências", true, "", "", "", true);
    }

    function AbreAgendaDiaria(Data, ProfissionalID, UnidadeID){

        openComponentsModal("ModalAgendaDiaria.asp", {
            Data: Data,
            ProfissionalID: ProfissionalID
        }, "Exibir agenda", true);
    }

$(document).ready(function() {

  $("#bEspecialidadeID").on('change', function(){
															  
      var id = $(this).val();  
      if(id == "") id = 0;

    var idProc = $("#bProcedimentoID").val();  
      if(idProc == "") idProc = 0;
    $.get("comboProfissional.asp", {ProcedimentoID: idProc, Especialidade: id}, function(data) {
        $("#bProfissionalID").html(data).select2();
    })
        
  });

  $("#bProfissionalID").on('change', function(){

  });

  $("#bProcedimentoID").on('change', function(){
      var id = $(this).val();  
      var GrupoID= $("#GrupoID").val();

      if(id == "") id = 0;

    var idEsp = $("#bEspecialidadeID").val();  
      if(idEsp == "") idEsp = 0;
    $.get("comboProfissional.asp", {ProcedimentoID: id, Especialidade: idEsp}, function(data) {
        $("#bProfissionalID").html(data).select2();
    })									   
  });
});

$(".modal-footer .btn").on('click', function(){
    $("#modal-components").modal("hide");
    $("#modal-components").modal("show");
})

$("#bPacienteID").change(function(){
    if ($(this).val() > 0) {

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
    $("#rbtns").html("")
    return false;
}

function profissionais() {
    var profissionalID = $("#bProfissionalID").val();
    var Regiao = $("#bRegiao").val();
    let dataHora =  document.getElementById("bData").value;
    
    if( profissionalID > 0){
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.get("HistoricoProfissional.asp?ProfissionalID=" + profissionalID + "&Regiao=" + Regiao + "&Data="+dataHora,
            function (data) {
                $("#modal").html( data );
            }
        );
    }else{
        new PNotify({
            title: 'Campo Obrigatório!',
            text: 'Executor',
            type: 'warning',
            delay: 2000
        });
    }
}

function hist(P) {
    openComponentsModal('HistoricoPacienteAgenda.asp?PacienteID=' + P, false, 'Pacientes', true, false, 'lg')
}

var CarrinhoID = 0;
var Hora, id,Data, ProfissionalID, EspecialidadeID, PacienteID, TabelaID, ProcedimentoID, LocalID, ValorSelector, CarrinhoID, agendamentoID, agendamentoID2, ValorP;
var totalJanelas = 0;

function abreAgenda(Hora, id,Data, ProfissionalID, EspecialidadeID, TabelaID, ProcedimentoID, LocalID, ValorSelector, CarrinhoID, valorProcedimento, Encaixe) {
    
    window.CarrinhoID = CarrinhoID;
    
    var agendamentoID = $("#agendamentoIDCarrinho").val()
    var agendamentoID2 = $("#agendamentoIDCarrinho2").val()
    
    var Valor = $("#"+ValorSelector).val();
    var GradeID = 0;
    var PacienteID = $("#bPacienteID").val();

    Hora = Hora.replace(":", "");

    window.Hora = Hora;
    window.PacienteID = PacienteID;
    window.agendamentoID = agendamentoID;
    window.agendamentoID2 = agendamentoID2;
    window.id = id;
    window.Data = Data; 
    window.ProfissionalID = ProfissionalID; 
    window.EspecialidadeID = EspecialidadeID;
    window.TabelaID = TabelaID;
    window.ProcedimentoID = ProcedimentoID;
    window.LocalID = LocalID;
    window.ValorSelector = ValorSelector;
    
    window.ValorP = valorProcedimento;
    window.Encaixe = Encaixe;

    if(PacienteID == "" || PacienteID == 0 || PacienteID == null){
        new PNotify({
            title: 'Atenção!',
            text: 'Selecione um Paciente',
            type: 'warning',
            delay: 2000
        });
    }else{
        $.post("agendaVerificaDisponibilidade.asp",{pacienteID: PacienteID, profissionalID: ProfissionalID, hora: Hora, data: Data}, function(data){
            eval(data)
        })
    }
}

function abrirModalRestricao (ProfissionalID,ProcedimentoID,PacienteID) {
    $.ajax({
        type: 'GET',
        url: 'procedimentosListagem.asp?ProfissionalID='+ProfissionalID+'&ProcedimentoId=' + ProcedimentoID + '&PacientedId=' + PacienteID + '&requester=ModalPreparo&criarPendencia=Nao',
        data: true
    }).done(function(data) { 
            $(".modalpendencias").modal("show")
            $(".modalpendenciasbody").html(data)

    });
}


function enviar(totalPreparo){
    $.ajax({
            type: 'GET',
            url: 'procedimentosListagem.asp?totalPreparo='+totalPreparo+'&ProcedimentoId=' + window.ProcedimentoID+ '&PacientedId=' + window.PacienteID + '&ProfissionalID=' + window.ProfissionalID,
            data: true
        }).done(function(data) { 
             $(".modalpendencias").modal("show")
             $(".modalpendenciasbody").html(data)
        });
};

function abrirModalPreparo(){
    openComponentsModal('procedimentosModalPreparo.asp?ProcedimentoId=' + window.ProcedimentoID+ '&PacientedId=' + window.PacienteID+'&agendamentoID=' + window.agendamentoID + '&requester=AgendaMultipla&ProfissionalID=' + window.ProfissionalID, true, 'Preparo', true, '')
}

function abrirAgenda2(){

    var classeFind = ".agendamentoIDCarrinho2"+window.CarrinhoID;
    var idAgendamento = $(classeFind).val();

    $.ajax({
        type: "POST",
        url: "divAgendamento.asp?Requester=MultiplaFiltros&Valor="+window.ValorP+"&PacienteID="+window.PacienteID+"&horario=" + window.Hora + "&data=" + window.Data + "&profissionalID=" + 
                window.ProfissionalID + "&Encaixe=" + window.Encaixe + "&LocalID=" + window.LocalID + "&ProcedimentoID=" + window.ProcedimentoID+"&GradeID=0&EspecialidadeID="+window.EspecialidadeID+"&id=" + idAgendamento,
        success: function (data) {
            toogleAgendaContent(false);
            $("#div-agendamento").html(data);
        }
    });
};

function excluiAgendamento(ConsultaID, Confirma){
    
	$.ajax({
		type:"POST",
		url:"excluiAgendamento.asp?ConsultaID="+ConsultaID+"&Confirma="+Confirma,
		data:$("#formExcluiAgendamento").serialize(),
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}

function desistencia(){
    var PacienteID = $("#bPacienteID").val();

    if(PacienteID == "" || PacienteID == 0 || PacienteID == null){
        alert("Paciente não selecionado");
    }else{
        
        openComponentsModal("desistencia.asp", {
                   PacienteID: PacienteID,
                   sessaoAgenda: sessionStorage.getItem("sessaoAgenda")
               }, "Desistencia", true, "Desistencia do Agendamento");
    }
}

function callbackAgendaFiltros() {

    var PacienteID = $("#bPacienteID").val();
    var CarrinhoID = window.CarrinhoID;

    $.post("VinculaAgendamentoABusca.asp", {PacienteID: PacienteID, CarrinhoID: CarrinhoID}, function(data) {
        cart("FIND",CarrinhoID);
    });
};

function parametros(tipo, id){

    setTimeout(function() {
        var novo = false;
        if(id == "-1"){
            id = $("#"+tipo).val();
        }
        if(id != ""){
        $.ajax({
            type:"POST",
            url:"AgendaParametros.asp?tipo="+tipo+"&id="+id+"&ProfissionalID=1&Data="+$("#bData").val(),
            data:$("#formAgenda").serialize(),
            success:function(data){
                eval(data);
                if( novo ){
                    paciente();
                }
            }
        });
        }
    }, 200);
}

function propostas(){
    let stringParam = "";
    var PacienteID = $("#bPacienteID").val();
    if (PacienteID == null || PacienteID == "" || PacienteID == "-1"){
        showMessageDialog("Escolha um paciente", 'danger');
        return false;
    }
    window.open("./?P=Pacientes&Pers=1&I=" + PacienteID + "&isProposta=S","_blank")
}

function Receber(){
    var valorTotal = 0;
    valor = ""
    procedimento = ""
    AgendamentoID = ""

    $(".agendamentoIDCarrinho").each(function(index, obj){
        var id = obj.value;

        $.post("checkinLancto.asp", { LanctoCheckin : id }, function (v) { $('#divLanctoCheckin').html(v) });
    });
}

$(function(){
    localStorage.setItem("elementosProposta", []);
    $("#bPacienteID").on('select2:opening', function(){ 
        $('#bPacienteID').select2('val', '');
    })
});

function total(){
    
    var valorMinimoParcela = parseInt($("#valorMinimoParcela").val());
    var total = parseInt($("#totalValor").val());

    if(total > valorMinimoParcela){
        //$(".seisvezes").show();
    }else{
        //$(".seisvezes").hide();
    }
}

function mudarValor(value){
    alert(value)
}

var fechar = true;
var urlDirect = "";

$(function(){
    fechar = true

    $('body').on('hide.bs.modal', '.modal', function (ev) {
        if(!fechar){
            ev.preventDefault();
        }else{
            if(urlDirect != ""){
                location.href="./?P=MultiplaFiltros2&Pers=1";
            }
        }
    });
})

function voltarTela(){
    fechar = true;
    $.post("AgendamentoLaboratorial.asp",  $("#formprocedimentos").serialize()  , function (data) { $("#tela").html(data);
    $("#bProcedimentosID").trigger("change");});
}

function adicionarItens(totalItens, totalRestricoes){
    
    let idpaciente = $("#bPacienteID").val()
    
    if(idpaciente == ""){
        showMessageDialog("Escolha um paciente", 'danger');
        return false;
    }

    let ok = false
    let elementos = ""
    let param = ""
    let laboratorioAnterior
    let idsSelecionados = []
    let temErro = false
    let total = 0
	
	let valorUnit
	let id
	let check = false
	let laboratorio
	let qtde

    $(".itens-exames-laboratoriais").each(function() {

        $(this).find("td input[type='checkbox']").each(function() {
            valorUnit = this.dataset.valor_exame_laboratorio
            id = this.dataset.value
            check = this.checked
            laboratorio = this.dataset.laboratorio
        })

        $(this).find("td input[type='number']").each(function(){
            qtde = this.value
        })

        let profid = $("#bProfissionalIDFld_"+laboratorio).val()
        
        if(check){
            total++;
            if(profid == "" || profid == 0){
                temErro = true;
                alert("Escolha um profissional")
                return false;
            }

            if(idsSelecionados.indexOf(id) >= 0){
                temErro = true;
                showMessageDialog("O mesmo procedimento está selecionado para mais de 1 laboratório", "warning");
                return false;
            }

            idsSelecionados.push(id);
            
            ok = true;

            valorUnit = valorUnit.replace(",",".")

			if (laboratorio != laboratorioAnterior) {
				if (laboratorioAnterior > 0) {
					elementos = elementos+"-"
                    param = param+"-"
				} 
				elementos = elementos+laboratorio+"|"+profid+"|"+id+";"+qtde+";"+valorUnit
                param = param+laboratorio+"|"+profid+"|"+id
			   
			} else if(laboratorio == laboratorioAnterior) {
				elementos = elementos+","+id+";"+qtde+";"+valorUnit
                param = param+","+id
			}
			laboratorioAnterior = laboratorio
        }
    })

    if(total < totalRestricoes){
        ok = false;
        showMessageDialog("Selecione todos os itens", "warning");
    }

    if(ok && !temErro){
        if(elementos.length > 0){
            localStorage.setItem("elementosProposta", elementos)
            fechar = false

            $.post("PreparoExame.asp?idpaciente=" + idpaciente +"&param="+param, function (data) { $("#tela").html(data) })
        }
    }
    return false
}

function finalizarCadastro(){

    var idpaciente = $("#bPacienteID").val();
    
    if(idpaciente == ""){
        showMessageDialog("Escolha um paciente", 'danger');
        return false;
    }
    
    fechar = true;

    if($("#informoupaciente").is(":visible") === true){
        fechar = $("#informoupaciente").is(":checked")
    }

    if(fechar){
        
        let elementos = localStorage.getItem("elementosProposta")
        let splitParam = elementos.split("-")

        for(let i=0;i<splitParam.length;i++){

            $.post("propostaSaveMultipla.asp?idpaciente=" + idpaciente+"&param="+splitParam[i], function(data) { 
                    eval(data) 
            });
        }
        localStorage.clear("elementosProposta")
        //Limpar(100)
    }
    $("#modal-components").modal('hide')
}

function fechar2(){
    fechar = false;
    history.back(-1);
}
<%
if PaciID = "" then
%>
    Limpar(1);
<%
end if
%>

</script>

<div id="divLanctoCheckin"></div>

<div id="pagar" style="display:none; background-color:#fff; border:#ccc 1px solid; width:900px; position:absolute;  top:100px; left:20px; z-index:90009999990; box-shadow:#000000 15px;-webkit-box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.48);
-moz-box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.48);
box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.48); border-radius:5px;">
	Carregando...
</div>