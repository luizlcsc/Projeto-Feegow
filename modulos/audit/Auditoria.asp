<!--#include file="./../../connect.asp"-->
<%
De = req("De")
Ate = req("Ate")
if De="" then
    De = date()
end if
if Ate="" then
    Ate = date()
end if

StatusAuditoria = "|1|,|4|"
%>
<form action="auditoriaItens.asp" id="frm" method="POST">
    <div class="panel mt25">
        <div class="panel-body">
            <div class="row">
                <%= quickfield("datepicker", "De", "De", 2, De, "", "", " required ") %>
                <%= quickfield("datepicker", "Ate", "Até", 2, De, "", "", " required ") %>
                <%= quickfield("empresaMultiIgnore", "Unidades", "Unidades", 2, Unidades, "", "", " required ") %>
                <%= quickfield("multiple", "StatusAuditoria", "Status", 2, StatusAuditoria, "select id, nomeStatus from cliniccentral.auditoria_status", "nomeStatus", " required ") %>
                <%= quickfield("multiple", "Eventos", "Eventos", 2, Eventos, "select * from cliniccentral.auditoria_eventos WHERE sysActive=1 order by Descricao", "Descricao", " required ") %>
                <div class="col-md-2">
                    <button class="btn btn-primary btn-block mt25"><i class="far fa-search"></i> Buscar</button>
                </div>
            </div>
        </div>
    </div>
</form>

<div class="row" id="divItens"></div>

<script type="text/javascript">
    $("#frm").submit(function(){
        $.post("modulos/audit/auditoriaItens.asp", $(this).serialize(), function(data){
            $("#divItens").html(data);
        });
        return false;
    });

    function submitItemAuditado(){
        $.post("modulos/audit/saveAuditoria.asp", $("#form-components").serialize(), function (data){
            showMessageDialog("Item auditado.", "warning");

            closeComponentsModal();
            $("#frm").submit();
        });
    }

    function ExibirDetalhesAuditoria(id){
        if(id){
            openComponentsModal("modulos/audit/DetalhesItemAuditoria.asp", {
                ItemID: id,
            }, 'Detalhes do item auditável - '+id, true, submitItemAuditado);
        }

    }

    function changeAuditoriaStatus(statusId, itemId){
        $.get("modulos/audit/getBadgeStatusAuditoria.asp",{StatusID: statusId}, function (data){
            $("#status-item-auditoria").html(data);
            $("#Auditoria_StatusID").val(statusId);
        });
    }

    function refetchSelectedItems(){
        var elementosSelecionados = $('.item-auditoria:checked');

        const $btnMarcarAuditado = $("#marcarAuditado");
        if(elementosSelecionados.length > 0){
            $btnMarcarAuditado.fadeIn();
        }else{
            $btnMarcarAuditado.fadeOut();
        }
    }

    function selecionarItens(eventoId, val){
        $('.item-auditoria[data-evento='+eventoId+']').prop('checked', val );

        refetchSelectedItems();
    }

    $(".crumb-active a").html("Auditoria");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("auditoria de ações");
    $(".crumb-icon a span").attr("class", "far fa-history");
</script>