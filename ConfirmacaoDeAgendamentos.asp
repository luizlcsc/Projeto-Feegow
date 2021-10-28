<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<%
StaChk = "|1|, |4|, |5|, |7|, |15|"

AdicionarObservacoesAoAlterarStatus = getConfig("AdicionarObservacoesAoAlterarStatus")
%>


<div class="panel mt15">
    <div id="GradeAgenda"></div>
    <div id="div-agendamento"></div>
</div>



<script>
    $(".crumb-active a").html("Confirmação de agendamentos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-icon a span").attr("class", "far fa-check");

    function confirmaAlteracao (statusId, agendamentoId, obs) {
         $.post("AlteraStatusAgendamento.asp", {
            A: agendamentoId,
            S: statusId,
            O: obs ? obs : ""
         }, function(data) {
             eval(data);
         });
    }
    var AdicionarObservacoesAoAlterarStatus = "<%=AdicionarObservacoesAoAlterarStatus%>";

    function AlterarStatus(statusId, agendamentoId, obs, AbrirModal, CanalID){


        if(AdicionarObservacoesAoAlterarStatus==="1" || AbrirModal){
            openComponentsModal("ConfirmaAlteracaoStatus.asp", {canalId: CanalID, obs: obs, statusId: statusId, agendamentoId: agendamentoId}, "Alterar status", true,
                function ConfirmaAlteracaoDeStatus() {
                    $.post("AlteraStatusAgendamento.asp", {
                        A: $("#agendamento-id-confirmacao").val(),
                        O: $("#ObsConfirmacao").val(),
                        S: $("input[name=status-confirmacao]:checked").val(),
                     }, function(data) {
                         eval(data);
                         closeComponentsModal()
                     });
                }, "md"
            );
            return;
        }else{
            confirmaAlteracao(statusId, agendamentoId);
        }


    }


    $("#frm-filtros").submit(function(){
        $("#GradeAgenda").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.post("confirmacaoDeAgendamentosContent.asp", $(this).serialize(), function(data){
            $("#GradeAgenda").html(data);

        });
        return false;
    });


    $("#frm-filtros").submit();


    <!--#include file="funcoesAgenda1.asp"-->



    function abreAgenda(horario, id, data, LocalID, ProfissionalID, EquipamentoID) {

        $("#div-agendamento").html('<i class="far fa-spinner fa-spin orange bigger-125"></i> Carregando...');
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

    var whatsAppAlertado = false;
    function AlertarWhatsapp(Celular, Texto, id) {
        var TipoLinkWhatsApp = $("#TipoLinkWhatsApp").val();

        if(!whatsAppAlertado){
            whatsAppAlertado=true;
            showMessageDialog("<strong>Atenção!</strong> Para enviar uma mensagem via WhatsApp é preciso ter a ferramenta instalada em seu computador.  <a target='_blank' href='https://www.whatsapp.com/download/'>Clique aqui para instalar.</a>",
            "warning", "Instalar o WhatsApp", 60 * 1000);
        }
        localStorage.setItem("TipoLinkWhatsApp", TipoLinkWhatsApp);

        var url = TipoLinkWhatsApp+"?phone="+Celular+"&text="+Texto;
        $("#wpp-"+id).html("<i class='success far fa-check-circle'></i>");

        if(AdicionarObservacoesAoAlterarStatus == "1"){
            AlterarStatus(1, id, "Contato via WhatsApp", true, 1);
        }

        openTab(url);
    }

    function openTab(url) {
      const link = document.createElement('a');
      link.href = url;
      link.target = '_blank';
      document.body.appendChild(link);
      link.click();
      link.remove();
    }

</script>