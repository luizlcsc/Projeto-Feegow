<!--#include file="connect.asp"-->
<div class="panel-heading">
    <span class="panel-title">Notas Fiscais</span>
</div>
<div class="panel-body">
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Emitente</th>
                <th>Valor</th>
                <th width="1%"></th>
            </tr>
        </thead>
        <tbody>
            <%
            InvoiceID = req("InvoiceID")

            set valInv = db.execute("select sum(ifnull(Value, 0)) Value from sys_financialmovement where Type='Bill' and InvoiceID="& InvoiceID)
            ValorInvoice = ccur(valInv("Value"))
            Restante = ValorInvoice

            set rr = db.execute("select rr.ContaCredito, ii.InvoiceID from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID where ContaCredito NOT IN('', '0') AND ii.InvoiceID="& InvoiceID &" GROUP BY rr.ContaCredito")
            while not rr.eof
                sql = "select ifnull(sum(rr.Valor), 0) Subtotal from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID where ContaCredito='"& rr("ContaCredito") &"' AND ii.InvoiceID="& InvoiceID 
                'response.write( sql &"<br>")
                set soma = db.execute( sql )
                Subtotal = ccur(soma("Subtotal"))
                Restante = Restante - Subtotal
                %>
                <tr>
                    <td><%= ucase(accountName(NULL, rr("ContaCredito"))) %></td>
                    <td class="text-right"><%= fn(Subtotal) %></td>
                    <td>
                        <%
                        if PossuiNFe then
                            %>
                            <button class="btn btn-sm btn-warning btn-block">EMITIR NFe</button>
                            <% else %>
                            <button class="btn btn-sm btn-alert btn-block">EMITIR RECIBO</button>
                            <%
                        end if
                        %>
                    </td>
                </tr>
                <%
            rr.movenext
            wend
            rr.close
            set rr = nothing
                
            %>

            <tr>
                <td>EMPRESA</td>
                <td class="text-right"><%= fn(Restante) %></td>
                <td>
                    <button class="btn btn-sm btn-warning btn-block">EMITIR NFe</button>
                </td>
            </tr>

        </tbody>
    </table>
</div>