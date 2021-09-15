<!--#include file="connect.asp"-->
<div class="panel-heading">
    <span class="panel-title">Detalhes das Despesas</span>
</div>
<div class="panel-body">
    <div class="col-md-12">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Conta</th>
                    <th>Descrição</th>
                    <th>Valor rateado</th>
                    <th>% Rateado</th>
                    <th>Valor</th>
                    <th class="hidden">Valor Total</th>
                    <th></th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                CategoriaID = req("C")
                Empresas = req("Empresas")

                set ii = db.execute("select ii.Descricao, ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo) ValorTotal, i.Value, ra.Valor ValorRateado, ii.InvoiceID, i.Rateado as InvoiceRateio, i.AssociationAccountID, i.AccountID FROM cliniccentral.rel_analise ra LEFT JOIN itensinvoice ii ON ii.id=ra.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE ra.CategoriaID="& CategoriaID &" AND ra.UsuarioID="& session("User"))
                    while not ii.eof
                        TotalRateado = 0
                        if ii("InvoiceRateio") then
                            sqlRateio = "select sum(porcentagem) valor, TipoValor from invoice_rateio where InvoiceID =  " & ii("InvoiceID")& " AND CompanyUnitID in ("& replace(Empresas, "|", "") &")"
                            'response.write(sqlRateio)
                            set iRat = db.execute(sqlRateio)
                            if not iRat.eof then 
                                TotalRateado = iRat("valor")
                                if iRat("TipoValor") = "P" then
                                    TotalRateado = (ii("ValorRateado") * iRat("valor")) / 100
                                end if
                            end if

                            PercentualRateado =  (ii("ValorRateado") / ii("ValorTotal")) * 100
                        end if
                        %>
                        <tr>
                            <td><%= accountName(ii("AssociationAccountID"), ii("AccountID")) %></td>
                            <td><%= ii("Descricao") %></td>
                            <td>
                                <% if ii("InvoiceRateio") then %> <%= fn(ii("ValorRateado")) %> <% end if %>
                            </td>
                            <td>
                                <% if ii("InvoiceRateio") then %> <%= fn(PercentualRateado)  %>% <% end if %>
                            </td>
                            <td><%= fn(ii("ValorTotal")) %></td>
                            <td class="hidden"><%= fn(ii("Value")) %></td>
                            <td>
                            <% if ii("InvoiceRateio") then %> 
                                    <span title="Despesa Rateada" class="label label-warning"><i class="far fa-share-alt"></i></span>
                            <% end if %> 
                            </td>
                            <td>
                                <a href="./?P=Invoice&Pers=1&CD=D&I=<%= ii("InvoiceID") %>" target="_blank" class="btn btn-xs btn-primary">
                                    <i class="far fa-external-link"></i>
                                </a>
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
    </div>
</div>