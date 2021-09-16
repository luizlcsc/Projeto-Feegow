<!--#include file="connect.asp"-->
<%
'De      Pendente, Enviada, Finalizada
'Para    Pendente, Respondida, Finalizada
%>
<script type="text/javascript">
    $(".crumb-active a").html("Requisição de Estoque");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-icon a span").attr("class", "far fa-tasks");
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=Estoque_requisicao&I=N&Pers=1"><i class="far fa-plus"></i><span class="menu-text"> Inserir</span></a>');
</script>

<form id="frm">
    <br />
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <%=quickfield("simpleSelect", "StatusID", "Status", 3, "", "select id, NomeStatus from estoque_requisicao_status", "NomeStatus", " no-select2  empty ") %>

                <%=quickfield("datepicker", "DataPrazo", "Prazo até", 2, "", "", "", "") %>
                <%=quickfield("simpleSelect", "PrioridadeID", "Prioridade", 2, "", "select id, Prioridade from cliniccentral.tarefasprioridade order by id", "Prioridade", " no-select2  empty ") %>
                <div class="col-md-2">
                    <label>&nbsp;</label><br />
                    <button id="Buscar" class="btn btn-primary btn-block"><i class="far fa-search"></i> BUSCAR</button>
                </div>
            </div>
            <div class="row hidden" id="maisOpcoes">
            </div>

        </div>
    </div>

    <div class="panel">
        <div class="panel-body" id="lista">

        </div>
    </div>
</form>
<script type="text/javascript">
    $("#frm").submit(function () {
        $.post("listaRequisicaoResult.asp", $(this).serialize(), function (data) {
            $("#lista").html("<center><i class='far fa-circle-o-notch fa-spin'></i></center>");
            $("#lista").html(data);
        });
        return false;
    });
    $("#Buscar").click();
</script>