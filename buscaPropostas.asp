<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Propostas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("gerenciar propostas e orçamentos");
    $(".crumb-icon a span").attr("class", "fa fa-files-o");
    <%
    if aut("propostasI")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success" href="?P=PacientesPropostas&PropostaID=N&Pers=1"><i class="fa fa-plus"></i> INSERIR</a>');
    <%
    end if
    %>
</script>

<form id="frmProposta">
<br />
    <div class="panel mn">
        <div class="panel-body">
        <%=quickfield("datepicker", "De", "De", 2, dateadd("m", -1, date()), "", "", "") %>
        <%=quickfield("datepicker", "Ate", "Até", 2, date(), "", "", "") %>
        <%=quickfield("multiple", "Status", "Status", 2, "|1|", "select id, NomeStatus from propostasstatus", "NomeStatus", " required ") %>
        <%=quickfield("users", "EmitidaPor", "Emitida por", 2, "", "", "", "") %>
        <%=quickfield("multiple", "Unidades", "Filtrar Unidades", 2 , "|"&session("UnidadeID")&"|", "SELECT 0 as id,NomeEmpresa as NomeFantasia  FROM empresa UNION SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive = 1", "NomeFantasia", "") %>
        <%=quickfield("multiple", "Procedimentos", "Filtrar Procedimentos", 2, "", "select distinct ip.ItemID id, p.NomeProcedimento from itensproposta ip LEFT JOIN procedimentos p on p.id=ip.ItemID WHERE NOT ISNULL(p.NomeProcedimento) ORDER BY trim(p.NomeProcedimento)", "NomeProcedimento", "") %>
        <div class="col-md-2 col-md-offset-10">
            <label>&nbsp;</label><br />
            <button class="btn btn-block btn-primary">Buscar</button>
        </div>
    </div>
        </div>
</form>

<div id="resPropostas">
</div>

<script type="text/javascript">
    $("#frmProposta").submit(function () {
        d = $("#resPropostas");
        d.html('<center><i class="fa fa-circle-o-notch fa-spin"></i> Buscando...</center>')
       $.post("listaPropostas.asp", $(this).serialize(), function (data) {
            d.html(data);
        });
        return false;
    });
</script>