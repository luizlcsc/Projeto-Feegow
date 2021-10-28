<!--#include file="connect.asp"-->
<h1>Itens Cancelados</h1>
<table class="table table-condensed table-hover">
    <thead>
        <tr>
            <th>Recto.</th>
            <th>Data</th>
            <th>Profissional</th>
            <th>Procedimento</th>
            <th>Paciente</th>
            <th>Val. Serv.</th>
            <th>Val. Rep.</th>
            <th>Pagto</th>
        </tr>
    </thead>
    <tbody>

        <%
        set ii = db.execute("select ii.InvoiceID, ii.id, p.NomePaciente, ii.DataExecucao, rr.ContaCredito, rr.ItemContaAPagar, ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto) Valor, rr.Valor ValorRepasse, proc.NomeProcedimento, iap.id InvoiceAPagarID from itensinvoice ii LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN pacientes p ON p.id=i.AccountID LEFT JOIN rateiorateios rr ON rr.iteminvoiceid=ii.id LEFT JOIN itensinvoice iiap ON iiap.id=rr.ItemContaAPagar LEFT JOIN sys_financialinvoices iap ON iap.id=iiap.InvoiceID where ii.Executado='C' AND NOT ISNULL(rr.iteminvoiceid) ORDER BY rr.ContaCredito, ii.DataExecucao")
        while not ii.eof
            %>
            <tr>
                <td><a href="./?P=Invoice&Pers=1&CD=C&I=<%= ii("InvoiceID") %>" target="_blank" class="btn btn-primary btn-xs"><i class="far fa-arrow-down"></i></a></td>
                <td><%= ii("DataExecucao") %></td>
                <td><%= accountName(NULL, "ContaCredito") %></td>
                <td><%= ii("NomeProcedimento") %></td>
                <td><%= ii("NomePaciente") %></td>
                <td><%= fn(ii("Valor")) %></td>
                <td><%= fn(ii("ValorRepasse")) %></td>
                <td>
                    <% if not isnull(ii("InvoiceAPagarID")) then %>
                        <a class="btn btn-xs btn-warning" target="_blank" href="./?P=Invoice&Pers=1&CD=D&I=<%= ii("InvoiceAPagarID") %>"><i class="far fa-arrow-up"></i></a>
                    <% end if %>
                </td>
            </tr>
            <%
        ii.movenext
        wend
        ii.close
        set ii = nothing
        %>
    </tbody>
</table>
