﻿<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<%
    StaChk = "|1|, |4|, |5|, |7|, |15|"
%>

<div class="panel mt15">
    <form id="frm">
        <div class="panel-heading">
            <span class="panel-title"><i class="fa fa-filter"></i> Filtros</span>
            <span class="panel-controls">
                <button class="btn btn-sm btn-primary">FILTRAR</button>
            </span>
        </div>
        <div class="panel-body">
            <div class="row">
                <%= quickfield("multiple", "fStaID", "Status", 4, StaChk, "select id, StaConsulta from staconsulta", "StaConsulta", "") %>
                <%= quickfield("text", "fNomePaciente", "Paciente", 4, "", "", "", "") %>
                <%= quickfield("simpleSelect", "fProfissionalID", "Profissional", 4, "", "select id, if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional from profissionais where sysActive=1 and ativo='on' order by if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial)", "NomeProfissional", "") %>
            </div>
        </div>
    </form>
</div>

<div class="panel">
    <div id="GradeAgenda"></div>
    <div id="div-agendamento"></div>
</div>



<script>
    $(".crumb-active a").html("Checkin");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("<%= date() %>");
    $(".crumb-icon a span").attr("class", "fa fa-check");


    $("#frm").submit(function(){
        $("#GradeAgenda").html("Carregando...");
        $.post("checkinContent.asp", $(this).serialize(), function(data){
            $("#GradeAgenda").html(data);
        });
        return false;
    });


    $("#frm").submit();


    <!--#include file="funcoesAgenda1.asp"-->



    function abreAgenda(horario, id, data, LocalID, ProfissionalID, EquipamentoID) {

        $("#div-agendamento").html('<i class="fa fa-spinner fa-spin orange bigger-125"></i> Carregando...');
        af('a');
        $.ajax({
            type: "POST",
            url: "divAgendamento.asp?horario=" + horario + "&id=" + id + "&data=" + data + "&profissionalID=" + ProfissionalID + "&LocalID=" + LocalID + "&EquipamentoID=" + EquipamentoID,
            success: function (data) {
                $("#div-agendamento").html(data);
            }
        });
    }



    function crumbAgenda(){
    }

    function loadAgenda(){
        $("#frm").submit();
    }

</script>