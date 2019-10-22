﻿<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<input type="hidden" id="Checkin" value="1" />
<%
    StaChk = "|1|, |4|, |5|, |7|, |15|"
%>
<input type="hidden" id="reqAgendamentoID" value="<%= req("AgendamentoID") %>" />

<div class="panel mt15">
    <div id="GradeAgenda"></div>
    <div id="div-agendamento"></div>
</div>



<script>
    $(".crumb-active a").html("Checkin");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("<%= date() %>");
    $(".crumb-icon a span").attr("class", "fa fa-check");


    $("#frm-filtros").submit(function(){
        $("#GradeAgenda").html("Carregando...");
        $.post("checkinContent.asp?AgendamentoID="+ $("#reqAgendamentoID").val(), $(this).serialize(), function(data){
            $("#GradeAgenda").html(data);

            $(".muda-status").on("click", function() {
                var statusId = $(this).data("value");
                var agendamentoId = $(this).parents("tr").data("id");

                $.post("AlteraStatusAgendamento.asp", {
                   A: agendamentoId,
                   S: statusId
                }, function(data) {
                    eval(data);
                });
            });
            
        });
        $("#reqAgendamentoID").val("");
        return false;
    });


    $("#frm-filtros").submit();


    <!--#include file="funcoesAgenda1.asp"-->



    function abreAgenda(horario, id, data, LocalID, ProfissionalID, EquipamentoID) {

        $("#div-agendamento").html('<i class="fa fa-spinner fa-spin orange bigger-125"></i> Carregando...');
        af('a');
        $.ajax({
            type: "POST",
            url: "divAgendamento.asp?horario=" + horario + "&id=" + id + "&data=" + data + "&profissionalID=" + ProfissionalID + "&LocalID=" + LocalID + "&EquipamentoID=" + EquipamentoID +"&Checkin=1",
            success: function (data) {
                $("#div-agendamento").html(data);
            }
        });
    }



    function crumbAgenda(){
    }

    function loadAgenda(){
        $("#frm-filtros").submit();
    }


</script>