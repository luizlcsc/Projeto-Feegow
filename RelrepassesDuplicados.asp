<!--#include file="connect.asp"-->
<%
TotalRepasse = 0
%>
<div class="panel">
    <div class="panel-body">
        <table class="table table-striped table-hover">
            <thead>
                <tr>
                    <th class="hidden">id</th>
                    <th>Data</th>
                    <th>Profissional</th>
                    <th>Paciente</th>
                    <th>Forma Recto.</th>
                    <th>Valor</th>
                    <th>Receita</th>
                    <th>Repasse</th>
                </tr>
            </thead>
            <tbody>
                <%
                c = 0
                set rr = db.execute("select * from rateiorateios where GrupoConsolidacao>1 and Valor>0 and ItemContaAPagar is not null order by sysDate")
                while not rr.eof
                    classeDuplicado=""
                    FormaRecto = ""

                    set vcaPrin = db.execute("select rr.*, ii.InvoiceID, i.AssociationAccountID, i.AccountID, iip.InvoiceID InvoiceID_APagar from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN itensinvoice iip ON iip.id=rr.ItemContaAPagar where rr.GrupoConsolidacao=1 and not isnull(rr.ItemContaAPagar) and rr.ItemInvoiceID="& rr("ItemInvoiceID") &" and rr.ItemDescontadoID="& rr("ItemDescontadoID") &" and rr.ContaCredito='"& rr("ContaCredito") &"' and rr.FuncaoID="& rr("FuncaoID") &" and rr.ParcelaID="& rr("ParcelaID"))
                    if not vcaPrin.eof then
                        c = c+1
                        TotalRepasse = TotalRepasse+rr("Valor")
                        set idesc = db.execute("select pm.PaymentMethod from itensdescontados idesc LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE idesc.id="& vcaPrin("ItemDescontadoID"))
                        if not idesc.eof then
                            FormaRecto = idesc("PaymentMethod")
                        end if
                        %>
                        <tr class="info">
                            <td class="hidden"><%= vcaPrin("id") %></td>
                            <td><%= vcaPrin("sysDate") %></td>
                            <td><%= accountName("", vcaPrin("ContaCredito")) %></td>
                            <td><%= accountName(vcaPrin("AssociationAccountID"), vcaPrin("AccountID")) %></td>
                            <td><%= FormaRecto %></td>
                            <td class="text-right">R$ <%= fn(vcaPrin("Valor")) %></td>
                            <td><a href="./?P=Invoice&Pers=1&CD=C&I=<%= vcaPrin("InvoiceID") %>" target="_blank" class="btn btn-xs btn-default">RECEITA</a></td>
                            <td><a href="./?P=Invoice&Pers=1&CD=D&I=<%= vcaPrin("InvoiceID_APagar") %>" target="_blank" class="btn btn-xs btn-default">REPASSE</a></td>
                            <td></td>
                        </tr>
                        <%
                        classeDuplicado = ""
                        %>
                        <tr class="<%= classeDuplicado %>">
                            <td class="hidden"><%= rr("id") %></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td><% 
                                if vcaPrin("ItemContaAPagar")<>rr("ItemContaAPagar") then
                                    set invAP = db.execute("select InvoiceID from itensinvoice where id="& rr("ItemContaAPagar"))
                                    if not invAP.eof then
                                        %>
                                        <a href="./?P=Invoice&Pers=1&CD=D&I=<%= vcaPrin("InvoiceID_APagar") %>" target="_blank" class="btn btn-xs btn-warning">REPASSE</a>
                                        <% 
                                    end if 
                                end if
                                        %>
                            </td>
                        </tr>
                        <%
                    end if
                rr.movenext
                wend
                rr.close
                set rr=nothing
                %>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="4"><%= c %> duplicados</th>
                    <th class="text-right">R$ <%= fn(TotalRepasse) %></th>
                </tr>
            </tfoot>
        </table>
    </div>
</div>
