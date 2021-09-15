<style type="text/css">
    .select2-container--open {
        z-index: 10003; /* form dialog z-index:10002 (computed)*/
    }

    .popover {
        z-index: 2000;
    }

    .nomeProf {
        color: #fff;
        font-weight: bold;
        text-align: center;
        text-shadow: 1px 1px #000;
    }

    .carinha {
        margin: -2px 4px 1px 3px;
    }

    .item-agenda-1 {
        width: 35%;
    }

    .item-agenda-2 {
        width: 25%;
    }

    .item-agenda-3 {
        width: 20%;
    }

    .item-agenda-4 {
        width: 9%;
    }

    .hand {
        cursor: pointer;
    }

        .hand:hover {
            background-color: #F5FDEA;
        }

    .intervalo {
        background-color: #f3f3f3;
    }

    .spanNomePaciente {
        text-overflow: ellipsis;
        overflow: hidden;
        text-align: left;
        width: 100%;
    }

    .modal-dialog {
        width: 90%;
        min-width: 380px;
        max-width: 1080px;
    }

    #div-secundario {
        width: 60%;
    }

    .nomePac {
        display: inline-block;
        max-width: 200px;
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
        cursor: pointer;
        padding: 3px !important;
    }

    .Locais {
        -webkit-transform: rotate(90deg);
        -moz-transform: rotate(90deg);
        -o-transform: rotate(90deg);
        -ms-transform: rotate(90deg);
        transform: rotate(90deg);
        max-width: 24px;
        height: auto;
        white-space: nowrap;
        /*writing-mode: tb-rl;*/
    }

    #tblCalendario td {
        padding: 0;
        /*height:30px!important;*/
    }

    .table thead > tr > th, .table tbody > tr > th, .table tfoot > tr > th, .table thead > tr > td, .table tbody > tr > td, .table tfoot > tr > td {
        padding: 5px !important;
    }
</style>
<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalSecundario.asp"-->

<br />







<div class="panel-body bg-light">
    <div class="row col-xs-12" id="div-agendamento"></div>
    <div class="row col-sm-12" id="GradeAgenda"></div>
</div>
<input type="hidden" id="TipoAgenda" value="Equipamento" />


<script type="text/javascript">
    function loadAgenda(Data, EquipamentoID){
        $("#GradeAgenda").html('<center>Carregando...</center>');
        $.ajax({
            type:"POST",
            url:"GradeAgenda-Equipamento.asp?Data="+Data+"&EquipamentoID="+EquipamentoID,
            success:function(data){
                $("#GradeAgenda").html(data);
            }
        });
    }
    <%
    if req("Conf")="" and req("AgendamentoID")="" then
        %>
        loadAgenda($("#Data").val(), $("#EquipamentoID").val());
    <%
    end if
    %>



function af(a){
    var w = $("body").width();
    
        //    console.log(w);
        //    console.log( $("body").attr("class") );

    if(a=='a'){
        $("#GradeAgenda").addClass("hidden");
        $("#div-agendamento").removeClass("hidden");

        if(w<1400){
            if(!$("body").hasClass("sb-l-m")){
                $("#toggle_sidemenu_l").click();
    }
    }
    }
    if(a=='f'){
        $("#GradeAgenda").removeClass("hidden");
        $("#div-agendamento").addClass("hidden");

        if(w<1400){
            if($("body").hasClass("sb-l-m")){
                $("#toggle_sidemenu_l").click();
    }
    }
    }
    }



function abreAgenda(horario, id, data, LocalID, ProfissionalID, GradeID){
    $("#div-agendamento").html('<div class="panel"><div class="panel-body"><i class="far fa-spinner fa-spin orange bigger-125"></i> Carregando...</div></div>');
    af('a');
    $.ajax({
        type:"POST",
        url:"divAgendamento.asp?horario="+horario+"&id="+id+"&data="+data+"&EquipamentoID="+$("#EquipamentoID").val()+"&LocalID="+LocalID+"&GradeID="+GradeID,
        success:function(data){
            $("#div-agendamento").html(data);
        }
    });
}
function abreBloqueio(BloqueioID, Data, Hora){
    if(BloqueioID==-1){
        return;
    }
    af('a');
    $.ajax({
        type:"POST",
        url:"divBloqueio.asp?BloqueioID="+BloqueioID+"&Data="+Data+"&Hora="+Hora+"&ProfissionalID=-"+$("#EquipamentoID").val(),
        success:function(data){
            $("#div-agendamento").html(data);
        }
    });
}
function changeMonth(newDate){
    $.ajax({
        type:"GET",
        url:"AgendamentoCalendarioEquipamento.asp?Data="+newDate+"&ta=EquipamentosAlocados",
        success:function(data){
            $("#divCalendario").html(data);
        }
    });
}


$("#EquipamentoID").change(function(){
    loadAgenda($('#Data').val(), $(this).val());
    $("#EquipamentoID").val($(this).val());
    if(typeof filaEspera !== "undefined"){
        filaEspera('');
    }
});

$("#AbrirEncaixe").click(function(){
    abreAgenda('00:00', 0, $('#Data').val(), $("#LocalEncaixe").val());
});

function remarcar(AgendamentoID, Acao, Hora, LocalID){
    $.ajax({
        type:"POST",
        url:"Remarcar.asp?tipoAgendamento=equipamento&EquipamentoID="+$("#EquipamentoID").val()+"&Data="+$("#Data").val()+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
        success: function(data){
            eval(data);
        }
    });
}

function repetir(AgendamentoID, Acao, Hora, LocalID){
    $.ajax({
        type:"POST",
        url:"Repetir.asp?tipoAgendamento=equipamento&EquipamentoID="+$("#EquipamentoID").val()+"&Data="+$("#Data").val()+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
        success: function(data){
            eval(data);
        }
    });
}
</script>
