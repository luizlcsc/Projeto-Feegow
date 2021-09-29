<!--#include file="connect.asp"-->
<%
De = req("De")
Ate = req("Ate")
Unidades = req("U")
GrupoID = req("G")
%>
<h4>Detalhamento de Produção</h4>


<table class="table table-condensed table-hover table-bordered">
<%
    set sep = db.execute("select * from (select distinct(m.PaymentMethodID) MetodoID, pm.PaymentMethod FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN itensdescontados idesc ON idesc.ItemID=ii.id LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& myDateNull(Ate) &" AND i.CompanyUnitID="& Unidades &" AND ifnull(proc.GrupoID, 0)="& GrupoID &" AND NOT ISNULL(proc.GrupoID) AND ii.Executado='S' AND ii.Tipo='S' AND NOT ISNULL(m.PaymentMethodID)) pagos UNION ALL (select '-1', 'Não pagos')")
    while not sep.eof
        tValorDescontado = 0
        Quantidade = 0
        Total = 0
        tValorRepasse = 0
        tValorLiquido = 0
        %>
        <thead>
            <tr>
                <th colspan="12"><%= sep("PaymentMethod") %></th>
            </tr>
            <tr>
                <th>Conta</th>
                <th>Data</th>
                <th>Paciente</th>
                <th>Procedimento</th>
                <th>Quantidade</th>
                <th>Valor do Serviço</th>
                <th>Valor Recebido</th>
                <th>Valor Repasse</th>
                <th>Valor Líquido</th>
                <th>Situação do Repasse</th>
            </tr>
        </thead>
        <tbody>
            <%
            if sep("MetodoID")&""<>"-1" then
                set ii = db.execute("select idesc.id ItemDescontadoID, m.PaymentMethodID, ii.id ItemInvoiceID, ii.InvoiceID, ii.DataExecucao, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, ii.Quantidade, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal, idesc.Valor ValorDescontado FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN itensdescontados idesc ON idesc.ItemID=ii.id LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID WHERE ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& myDateNull(Ate) &" AND i.CompanyUnitID="& Unidades &" AND ifnull(proc.GrupoID, 0)="& GrupoID &" AND NOT ISNULL(proc.GrupoID) AND ii.Executado='S' AND m.PaymentMethodID="& treatvalnull(sep("MetodoID")) &" ORDER BY ii.DataExecucao")
                sqlIDesc = ""
            else
                set ii = db.execute("select '0' ItemDescontadoID, '-1' PaymentMethodID, ii.id ItemInvoiceID, ii.InvoiceID, ii.DataExecucao, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, ii.Quantidade, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal, (select ifnull(sum(Valor), 0) from itensdescontados where ItemID=ii.id) ValorDescontado FROM itensinvoice ii LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN sys_financialinvoices i ON ii.InvoiceID=i.id WHERE ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& myDateNull(Ate) &" AND i.CompanyUnitID="& Unidades &" AND ifnull(proc.GrupoID, 0)="& GrupoID &" AND NOT ISNULL(proc.GrupoID) AND ii.Executado='S' AND (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))>(select ifnull(sum(Valor), 0) from itensdescontados where ItemID=ii.id)")
                sqlIDesc = " AND (ISNULL(rr.ItemDescontadoID) OR rr.ItemDescontadoID=0) "
            end if
            while not ii.eof
                Quantidade = Quantidade + ii("Quantidade")
                Total = Total+ii("ValorTotal")
                tValorDescontado = tValorDescontado+ii("ValorDescontado")
                if sep("MetodoID")&""<>"-1" then
                    sqlIDesc = " AND rr.ItemDescontadoID="& ii("ItemDescontadoID") &" "
                end if
                
                TotalRepasse = 0
                ValorPago = 0
                set rr = db.execute("select rr.Valor, (iip.Quantidade*(iip.ValorUnitario+iip.Acrescimo-iip.Desconto)) ValorItemAPagar, (select ifnull(sum(Valor), 0) from itensdescontados where ItemID=rr.ItemContaAPagar) ValorPagoItemP from rateiorateios rr LEFT JOIN itensinvoice iip ON iip.id=rr.ItemContaAPagar WHERE ContaCredito LIKE '%\_%' AND ItemInvoiceID="& ii("ItemInvoiceID") &" "& sqlIDesc &" ")
                while not rr.eof
                    TotalRepasse = TotalRepasse+rr("Valor")
                    BalancoPagto = rr("ValorItemAPagar") - rr("ValorPagoItemP")
                    if BalancoPagto=0 then
                        SituacaoRepasse = "<i class='far fa-check text-success'></i> Quitado"
                    else
                        SituacaoRepasse = "<i class='far fa-exclamation-circle text-danger'></i> Pendente"
                    end if
                rr.movenext
                wend
                rr.close
                set rr = nothing
                if TotalRepasse=0 then
                    SituacaoRepasse = "-"
                end if
                ValorLiquido = ii("ValorTotal")-TotalRepasse
                tValorRepasse = tValorRepasse + TotalRepasse
                tValorLiquido = tValorLiquido + ValorLiquido
                %>
                <tr>
                    <td><a class="btn btn-xs btn-primary" target="_blank" href="./?P=Invoice&Pers=1&I=<%= ii("InvoiceID") %>"><i class="far fa-external-link"></i></a>
                        <%'= ii("PaymentMethodID") %>

                    </td>
                    <td><%= ii("DataExecucao") %></td>
                    <td><%= accountName(ii("AssociationAccountID"), ii("AccountID")) %></td>
                    <td><%= ii("NomeProcedimento") %></td>
                    <td class="text-right"><%= ii("Quantidade") %></td>
                    <td class="text-right"><%= fn(ii("ValorTotal")) %></td>
                    <td class="text-right"><%= fn(ii("ValorDescontado")) %></td>
                    <td class="text-right"><%= fn(TotalRepasse) %></td>
                    <td class="text-right"><%= fn(ValorLiquido) %></td>
                    <td class="text-right"><%= SituacaoRepasse %></td>
                </tr>
                <%
            ii.movenext
            wend
            ii.close
            set ii = nothing
                %>
            <tr>
                <th colspan="4"></th>
                <th class="text-right"><%= Quantidade %></th>
                <th class="text-right"><%= fn(Total) %></th>
                <th class="text-right"><%= fn(tValorDescontado) %></th>
                <th class="text-right"><%= fn(tValorRepasse) %></th>
                <th class="text-right"><%= fn(tValorLiquido) %></th>
            </tr>
        </tbody>
        <%
    sep.movenext
    wend
    sep.close
    set sep = nothing
    %>
</table>