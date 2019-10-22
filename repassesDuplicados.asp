<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <table class="table table-striped table-hover">
            <thead>
                <tr>
                    <th>ItemInvoiceID</th>
                    <th>ItemDescontadoID</th>
                    <th>Valor</th>
                    <th>ContaCredito</th>
                    <th>FuncaoID</th>
                    <th>ParcelaID</th>
                    <th>- ItemContaAPagar</th>
                    <th>- sysDate</th>
                    <th>- id</th>
                    <th>- GrupoConsolidacao</th>
                </tr>
            </thead>
            <tbody>
                <%
                set rr = db.execute("select * from rateiorateios where sysDate="& mydatenull(req("Data")) &" order by ItemInvoiceID, FuncaoID, ParcelaID, ItemDescontadoID, Valor, ContaCredito")
                while not rr.eof
                    classe=""
'                    if uItemInvoiceID = rr("ItemInvoiceID") and uItemDescontadoID = rr("ItemDescontadoID") and uValor = rr("Valor") and uContaCredito = rr("ContaCredito") and uFuncaoID = rr("FuncaoID") and uParcelaID = rr("ParcelaID") then
                    if uItemInvoiceID = rr("ItemInvoiceID") and uFuncaoID = rr("FuncaoID") and uParcelaID = rr("ParcelaID") then
                        classe = "danger"
                    end if
                    %>
                    <tr class="<%= classe %>">
                        <td><%= rr("ItemInvoiceID") %></td>
                        <td><%= rr("ItemDescontadoID") %></td>
                        <td><%= rr("Valor") %></td>
                        <td><%= rr("ContaCredito") %></td>
                        <td><%= rr("FuncaoID") %></td>
                        <td><%= rr("ParcelaID") %></td>
                        <td><%= rr("ItemContaAPagar") %></td>
                        <td><%= rr("sysDate") %></td>
                        <td><%= rr("id") %></td>
                        <td><%= rr("GrupoConsolidacao") %></td>
                    </tr>
                    <%
                    uItemInvoiceID = rr("ItemInvoiceID")
                    uItemDescontadoID = rr("ItemDescontadoID")
                    uValor = rr("Valor")
                    uContaCredito = rr("ContaCredito")
                    uFuncaoID = rr("FuncaoID")
                    uParcelaID = rr("ParcelaID")
                rr.movenext
                wend
                rr.close
                set rr=nothing
                %>
            </tbody>
        </table>
    </div>
</div>
