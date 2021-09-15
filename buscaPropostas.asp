<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Propostas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("gerenciar propostas e orçamentos");
    $(".crumb-icon a span").attr("class", "far fa-files-o");
    <%
    if aut("propostasI")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success" href="?P=PacientesPropostas&PropostaID=N&Pers=1"><i class="far fa-plus"></i> INSERIR</a>');
    <%
    end if
    %>
</script>

<form id="frmProposta">
<br />
    <div class="panel mn">
        <div class="panel-body">
        <div class="row">
            <%=quickfield("datepicker", "De", "De", 2, dateadd("d", -7, date()), "", "", "") %>
            <%=quickfield("datepicker", "Ate", "Até", 2, date(), "", "", "") %>
            <%'=quickfield("multiple", "Procedimentos", "Filtrar Procedimentos", 2, "", "select p.id, p.NomeProcedimento from procedimentos p WHERE Ativo='ON' AND sysActive=1 ORDER BY p.NomeProcedimento LIMIT 1000", "NomeProcedimento", "") %>
            <%=quickfield("multiple", "Unidades", "Filtrar Unidades", 2 , "|"&session("UnidadeID")&"|", "SELECT 0 as id,NomeEmpresa as NomeFantasia  FROM empresa UNION SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive = 1", "NomeFantasia", "") %>
            <%=quickfield("users", "EmitidaPor", "Emitida por", 2, "", "", "", "") %>
            <%=quickfield("multiple", "Status", "Status", 2, "|1|", "select id, NomeStatus from propostasstatus", "NomeStatus", " required ") %>
        </div>
        <div class="row mt10">

            <div class="col-md-2 col-md-offset-7 mt20">
                <button class="btn btn-block btn-primary"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
        </div>
</form>

<div id="resPropostas">
</div>

<script type="text/javascript">
    $("#frmProposta").submit(function () {
        d = $("#resPropostas");
        d.html('<center><i class="far fa-circle-o-notch fa-spin"></i> Buscando...</center>')
       $.post("listaPropostas.asp", $(this).serialize(), function (data) {
            d.html(data);
        });
        return false;
    });
    function openTab(url) {
          const link = document.createElement('a');
          link.href = url;
          link.target = '_blank';
          document.body.appendChild(link);
          link.click();
          link.remove();
        }

    var whatsAppAlertado = false;
    function AlertarWhatsapp(Celular, Texto, id) {
        if(!whatsAppAlertado){
            whatsAppAlertado=true;
            showMessageDialog("<strong>Atenção!</strong> Para enviar uma mensagem via WhatsApp é preciso ter a ferramenta instalada em seu computador.  <a target='_blank' href='https://www.whatsapp.com/download/'>Clique aqui para instalar.</a>",
            "warning", "Instalar o WhatsApp", 60 * 1000);
        }
        var url = "whatsapp://send?phone="+Celular+"&text="+Texto;
        $("#wpp-"+id).html("<i class='success far fa-check-circle'></i>");
        openTab(url);
    }
</script>