<!--#include file="connect.asp"-->
<div class="panel-heading">
    <span class="panel-title"><i class="far fa-puzzle-piece"></i> Repasses Gerados</span>
</div>
<div class="panel-body">
    <%
    T = req("T")
    I = req("I")

    set rr = db.execute("select rr.*, iip.InvoiceID InvoiceAPagarID, ifnull((iip.ValorUnitario), 0) ValorItemInvoiceIDAPagar, ifnull((select sum(Valor) from itensdescontados where ItemID=rr.ItemContaAPagar), 0) ValorPago from rateiorateios rr LEFT JOIN itensinvoice iip ON iip.id=rr.ItemContaAPagar where rr.ContaCredito<>'0' AND "& T &"="& I)
    if rr.eof then
        %>
        Nenhum repasse gerado para esta conta.
        <%
    else
        %>
        <table class="table table-condensed table-bordered">
            <thead>
                <tr>
                    <th>Função</th>
                    <th>Conta</th>
                    <th>Repasse</th>
                    <th>Valor Pago</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                while not rr.eof
                    ValorItemInvoiceIDAPagar = fn(rr("ValorItemInvoiceIDAPagar"))
                    ValorPago = fn(rr("ValorPago"))
                    if (ValorPago)>=ValorItemInvoiceIDAPagar then
                        Status = "Quitado"
                    else
                        Status = "Pendente"
                    end if
                    %>
                    <tr>
                        <td><%= rr("Funcao") %></td>
                        <td><%= accountName( NULL, rr("ContaCredito") ) %></td>
                        <td><%= fn( rr("Valor") ) %></td>
                        <td><%= Status %></td>
                        <td>
                            <% if not isnull( rr("ItemContaAPagar") ) then %>
                                <a href="./?P=Invoice&CD=D&Pers=1&I=<%= rr("InvoiceAPagarID") %>" target="_blank" class="btn btn-xs btn-info">
                                    <i class="far fa-external-link"></i>
                                </a>
                            <% end if %>
                        </td>
                    </tr>
                    <%
                rr.movenext
                wend
                rr.close
                set rr=nothing
                %>
            </tbody>
        </table>
        <%
    end if
    %>
</div>