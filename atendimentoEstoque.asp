<!--#include file="connect.asp"-->
<div class="panel-heading no-print">
    <span class="panel-title">Atendimento - Saída de Produto</span>
    <span class="panel-controls">
        <button type="button" class="btn btn-sm btn-default" data-dismiss="modal">Fechar</button>
    </span>
</div>
<div class="panel-body no-print">
    <div class="row">
        <%
        'Se estiver no lancto do ItemInvoiceID, exibe os lanctos deste item invoice., Tanto pra C quanto pra D.
        AtendimentoID = req("AtendimentoID")
        if AtendimentoID<>"" then

            server.Execute("Lancamentos.asp")

        end if
        %>
    </div>
    <!--#include file="chamaBuscaProdutoLancto.asp"-->
</div>

<div class="panel-footer no-print">
</div>
