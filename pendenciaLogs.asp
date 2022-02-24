<!--#include file="connect.asp"-->
<br>
<div class="panel">
    <div class="panel-body">
        <div class="row">
            <script src="https://kit.fontawesome.com/c9f4259ec7.js" crossorigin="anonymous"></script>
            <div class="main-app" style="background-color: white;">

                <% = quickfield("simpleSelect", "paciente", "Paciente", 3, "", "SELECT id, nomepaciente FROM pacientes WHERE id IN (SELECT pacienteid FROM pendencias) ORDER BY 2", "nomepaciente", "") %>
                <% = quickfield("simpleSelect", "usuario", "Usuário", 3, "", "SELECT id, nome FROM cliniccentral.licencasusuarios WHERE id IN (SELECT sysUser FROM pendencias) ORDER BY 2", "nome", "") %>
                <% = quickfield("datepicker", "DataDe", "Data de", 2, "", "", "", "") %>
                <% = quickfield("datepicker", "DataAte", "Até", 2, "", "", "", "") %>

            
                <div class="col-md-2">
                    <label>&nbsp;</label><br/>
                    <button id="Buscar" class="btn btn-sm btn-primary btn-block"><i class="fa fa-search"></i> Buscar</button>
                </div>
                <div class="col-md-12 main-table">
                    <div style="display: table; text-align:center; font-size: 45px; padding: 40px; margin: 0 auto" class="row loading">
                        <i class="fa fa-spin fa-circle-o-notch"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>

    $(".crumb-active a").html("Pendências LOG");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "fa fa-exclamation-circle");

    function logBusca(){
        let pacienteID = $("#paciente").val();
        let usuarioID = $("#usuario").val();
        let dataDe = $("#DataDe").val();
        let dataAte = $("#DataAte").val();

        $.get('pendenciaLogBusca.asp?pacienteID=' + pacienteID+'&usuarioID='+usuarioID+'&dataDe='+dataDe+'&dataAte='+dataAte, function(result){
            $(".main-table").html('<div style="display: table; text-align:center; font-size: 45px; padding: 40px; margin: 0 auto" class="row loading"><i class="fa fa-spin fa-circle-o-notch"></i></div>')
            $(".main-table").html(result);
        })
    }

    $(document).ready(function() {
        logBusca();
    });


    $('#Buscar').on('click', function(){
        logBusca();
    });

    function logDetails(usuarioID, pendenciaID) {
        $.get('pendenciaLogsDetails.asp?pendenciaID=' + pendenciaID+'&usuarioID='+usuarioID, function(result){
            $(".main-table").html('<div style="display: table; text-align:center; font-size: 45px; padding: 40px; margin: 0 auto" class="row loading"><i class="fa fa-spin fa-circle-o-notch"></i></div>')
            $(".main-table").html(result);
        })
    }
</script>
