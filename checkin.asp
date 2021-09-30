<!--#include file="connect.asp"-->
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
    $(".crumb-icon a span").attr("class", "far fa-check");


    $("#frm-filtros").submit(function(){
        $("#GradeAgenda").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
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

        $("#div-agendamento").html(`<div class='p10'><center><i class="far fa-circle-o-notch fa-spin orange bigger-125"></i> Carregando...</center></div>`);
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