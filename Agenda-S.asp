<style type="text/css">
.nomeProf {
    color: #fff;
    font-weight: bold;
    text-align: center;
    text-shadow: 1px 1px #000;
}
.carinha {
	margin:-2px 4px 1px 3px;
}
.item-agenda-1 {
	width:35%;
}
.item-agenda-2 {
	width:25%;
}
.item-agenda-3 {
	width:20%;
}
.item-agenda-4 {
	width:9%;
}
.hand {
	cursor:pointer;
}
.hand:hover {
	background-color:#F5FDEA;
}
.intervalo {
	background-color:#f3f3f3;
}
.spanNomePaciente {
	text-overflow: ellipsis;
    overflow: hidden;
    text-align: left;
	width:100%;
}
.modal-dialog{
	width:80%;
	min-width:380px;
	max-width:990px;
}
.nomePac {
    display: inline-block;
    max-width: 100px;
    overflow: hidden;
    position: relative;
    text-align: left;
    text-overflow: ellipsis;
    top: 6px;
    vertical-align: top;
    white-space: nowrap;
}
.nomeConv {
    max-width: 100px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.table-agenda td {
	cursor:pointer;
	padding:3px!important;
	font-size:10px!important;
}
.Locais {
    -webkit-transform: rotate(90deg);
    -moz-transform: rotate(90deg);
    -o-transform: rotate(90deg);
    -ms-transform: rotate(90deg);
    transform: rotate(90deg);
	max-width:24px;
	height:auto;
	white-space: nowrap;
}

#tblCalendario td {
	padding:0;
	/*height:30px!important;*/
}

body{
    overflow:hidden;
    overflow-y: scroll;
}

#GradeAgenda{
    overflow:scroll;
}

.table thead > tr > th, .table tbody > tr > th, .table tfoot > tr > th, .table thead > tr > td, .table tbody > tr > td, .table tfoot > tr > td {
	padding: 5px !important;
}
</style>
<link rel="stylesheet" href="assets/css/fullcalendar.css" />
<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalSecundario.asp"-->
<!-- PAGE CONTENT BEGINS -->


                
                
                
<br>

<div class="panel">
    <div class="row col-md-12" id="div-agendamento"></div>

	<div class="panel-body" id="GradeAgenda"></div>
</div>
<script type="text/javascript">
<!--#include file="funcoesAgenda1.asp"-->
function loadAgenda(Data, ProfissionalID){
	$("#GradeAgenda").html('<center>Carregando...</center>');
	$.ajax({
		type:"POST",
		url:"GradeAgenda-S.asp?Data="+Data+"&ProfissionalID="+ProfissionalID,
		success:function(data){
			$("#GradeAgenda").html(data);
		}
	});
}
loadAgenda($("#Data").val(), $("#ProfissionalID").val());


$("#GradeAgenda").innerHeight(window.innerHeight - 200);

$(window).resize(function () {
    $("#GradeAgenda").innerHeight(window.innerHeight - 200);
});

/*
function af(a) {
    var w = $("body").width();

    //    console.log(w);
    //    console.log( $("body").attr("class") );

    if (a == 'a') {
        $("#GradeAgenda").addClass("hidden");
        $("#div-agendamento").removeClass("hidden");

        if (w < 1400) {
            if (!$("body").hasClass("sb-l-m")) {
                $("#toggle_sidemenu_l").click();
            }
        }
    }
    if (a == 'f') {
        $("#GradeAgenda").removeClass("hidden");
        $("#div-agendamento").addClass("hidden");

        if (w < 1400) {
            if ($("body").hasClass("sb-l-m")) {
                $("#toggle_sidemenu_l").click();
            }
        }
    }
}





function abreAgenda(horario, id, data, LocalID){
    af('a');
    $("#div-agendamento").html('<i class="far fa-spinner fa-spin orange bigger-125"></i> Carregando...');
	$.ajax({
		type:"POST",
		url:"divAgendamento.asp?horario="+horario+"&id="+id+"&data="+data+"&profissionalID="+$("#ProfissionalID").val()+"&LocalID="+LocalID,
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
function abreBloqueio(BloqueioID, Data, Hora){
	$("#modal-agenda").modal('show');
	$.ajax({
		type:"POST",
		url:"divBloqueio.asp?BloqueioID="+BloqueioID+"&Data="+Data+"&Hora="+Hora+"&ProfissionalID="+$("#ProfissionalID").val(),
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}

*/

$("#ProfissionalID").change(function () {
    af('f');
	loadAgenda($('#Data').val(), $(this).val());
	$("#ProfissionalID").val($(this).val());
});/*
$("#AbrirEncaixe").click(function(){
  abreAgenda('00:00', 0, $('#Data').val(), $("#LocalEncaixe").val());
});

$("#AgendaObservacoes").change(function(){
	$.post("saveAgendaObservacoes.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val(),
	{Observacoes:$(this).val()},
	function(data,status){
		eval(data);
});
});	
	$.post("financialPaymentAccounts.asp",{
			   PaymentMethod:$("#PaymentMethod").val(),
			   T:$("#T").val(),
			   },function(data,status){
		  $("#divPaymentMethod").html(data);
		});
	
	
	
	
	$.ajax({
		type:"POST",
		url:"saveAgendaObservacoes.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val(),
		data: $(this).val(),
		success:function(data){
			alert('salvo');
		}
	});

function filaEspera(A){
	$.ajax({
		type:"POST",
		url:"FilaEspera.asp?ProfissionalID="+$("#ProfissionalID").val()+"&Data="+$("#Data").val()+"&A="+A,
		success: function(data){
			$("#fila").html(data);
		}
	});
}
function remarcar(AgendamentoID, Acao, Hora, LocalID, Data){
	if(Data==undefined){
		Data=$("#Data").val();
	}
	$.ajax({
		type:"POST",
		url:"Remarcar.asp?ProfissionalID="+$("#ProfissionalID").val()+"&Data="+Data+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
		success: function(data){
			eval(data);
		}
	});
}
function repetir(AgendamentoID, Acao, Hora, LocalID, Data){
	if(Data==undefined){
		Data=$("#Data").val();
	}
	$.ajax({
		type:"POST",
		url:"Repetir.asp?ProfissionalID="+$("#ProfissionalID").val()+"&Data="+Data+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
		success: function(data){
			eval(data);
		}
	});
}
function detalheFilaEspera(PacienteID, ProfissionalID, Acao){
	$.ajax({
		type:"POST",
		url:"detalheFilaEspera.asp?PacienteID="+PacienteID+"&ProfissionalID="+ProfissionalID+"&Acao="+Acao,
		success: function(data){
			$("#div-agendamento").html(data);
			$("#modal-agenda").modal("show");
		}
	});
}*/
    function oa(P){
        $("#modal").html("Carregando informa��es do profissional...");
        $("#modal-table").modal("show");
        $.get("ObsAgenda.asp?ProfissionalID=" + P, function (data) {
            $("#modal").html(data);
        });
    }


function imprimir(){
	$("#modal-agenda").modal("show");
	$("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='far fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgendaSPrint.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val()+"' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
}
</script>
