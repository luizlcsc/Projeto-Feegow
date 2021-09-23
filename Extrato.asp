<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
    posModalPagar = "fixed"
%>
<!--#include file="invoiceEstilo.asp"-->
<div class="row">
    <div class="col-md-12">
    <br>
        <!--#include file="MioloExtrato.asp"-->
    </div>
</div>
<script type="text/javascript">
    $(".crumb-active a").html("Extrato");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("movimentação financeira");
    $(".crumb-icon a span").attr("class", "far fa-reorder");
    <%
    if aut("lancamentosI")=1 then
    %>
    $("#rbtns").html('<a onclick="transaction(0);" class="btn btn-sm btn-success pull-right" data-toggle="modal" href="#modal-table"><i class="far fa-exchange"></i><span class="menu-text"> Transferência</span></a>');
    <%
    end if
    %>
</script>