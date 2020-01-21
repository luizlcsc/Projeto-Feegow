<!--#include file="connect.asp"-->
<div class="panel-heading">
    <span class="panel-title">Posição de Estoque</span>
    <span class="panel-controls">
        <button type="button" class="btn btn-sm btn-default" data-dismiss="modal">Fechar</button>
    </span>
</div>
<div class="panel-body">
    <div class="row">
        <div class="col-md-12">
        <%
        'Se estiver no lancto do ItemInvoiceID, exibe os lanctos deste item invoice., Tanto pra C quanto pra D.
        ItemInvoiceID = req("ItemInvoiceID")
        ProdutoInvoiceID = req("ProdutoInvoiceID")
        if ItemInvoiceID<>"" or ProdutoInvoiceID<>"" then

            server.Execute("Lancamentos.asp")

        end if
        %>
        <!--#include file="chamaBuscaProdutoLancto.asp"-->
        </div>
    </div>
</div>

<div class="panel-footer">
</div>