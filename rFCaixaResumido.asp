<!--#include file="connect.asp"-->

<style type="text/css">
    @media print {
        td, th {
            #font-size:10px;
        }
    }
</style>

<%
UnidadeID = req("UnidadeID")
De = cdate(req("De"))
Ate = cdate(req("Ate"))
mData = mydatenull(Data)
MC = req("MC")
UsarDataMensal=req("UsarDataMensal")

if UsarDataMensal="S" then
    DataString = ucase(monthname(month(Data)))
else
    TipoPeriodoData="DIA"
    DataString = Data
end if

function filtroData(dataColuna)
    if TipoPeriodoData="DIA" then
        filtroData = " (DATE("&dataColuna&")="&mydatenull(Data)&") "
    else
        filtroData = " (MONTH("&dataColuna&")=MONTH("&mydatenull(Data)&") and YEAR("&dataColuna&")=YEAR("&mydatenull(Data)&")) "
    end if
end function

set u = db.execute("select id, NomeFantasia from (select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits) t where id="& UnidadeID)
if not u.eof then
    NomeFantasia = u("NomeFantasia")
end if
    
Data = De
while Data<=Ate
    mData = mydatenull(Data)


    'BLOCO 1
    'set l1 = db.execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE "& filtroData("ii.DataExecucao") &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &")")
    set l1 = db.execute("select sum(Value) Valor from sys_financialmovement where not isnull(CaixaID) AND ((AccountAssociationIDDebit=7 AND AccountAssociationIDCredit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")

    set entDC = db.execute("select sum(Value) Valor from sys_financialmovement where not isnull(CaixaID) AND PaymentMethodID IN (1, 2) AND ((AccountAssociationIDDebit=7 AND AccountAssociationIDCredit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
    EntDinheiroCheque = entDC("Valor")
    'response.write("<br> Entradas em dinheiro: "& EntDinheiroCheque)
    set saiD = db.execute("select sum(Value) Valor from sys_financialmovement where not isnull(CaixaID) AND PaymentMethodID IN (1) AND ((AccountAssociationIDCredit=7 AND AccountAssociationIDDebit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
    SaiDinheiro = saiD("Valor")
    'response.write("<br> SaiDinheiro: "& SaiDinheiro)
    FechamentoCaixaCalculado = EntDinheiroCheque - SaiDinheiro
    'response.write("<br> FechamentoCaixaCalculado: "& FechamentoCaixaCalculado)


    set reps = db.execute("select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE "& filtroData("ii.DataExecucao") &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &") AND ContaCredito LIKE '%\_%'")
    Repasses = reps("Repasses")
    vl2 = l1("Valor")-Repasses

    sql = "select fcx.CaixaID, fcx.Dinheiro Valor, fcx.DinheiroInformado, fcx.Dinheiro Dinheiro, IFNULL(fcx.Credito, 0) Credito, IFNULL(fcx.Debito,0) Debito from caixa cx INNER JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID INNER join fechamentocaixa fcx on fcx.CaixaID=cx.id where cc.Empresa="& UnidadeID &" and "& filtroData("cx.dtFechamento") &" GROUP BY fcx.CaixaID"
    'response.write(sql)
    set l3 = db.execute(sql)

    Dinheiro = 0
    Credito = 0
    Debito = 0

    'ValorFechamento = 0
    ValorFechamentoInformado = 0
    RecebimentosNaoExecutados = 0
    vl4 = 0

    if not l3.eof then
        while not l3.eof
        'vl4 = l1("Valor") - vl2
            CaixaID = l3("CaixaID")

            Dinheiro = Dinheiro + l3("Dinheiro")
            Credito = Credito + l3("Credito")
            Debito = Debito + l3("Debito")
            'ValorFechamento = ValorFechamento + l3("Valor")
            ValorFechamentoInformado = ValorFechamentoInformado + l3("DinheiroInformado")

            sqlNaoPago="SELECT sum(Value-IFNULL(ValorPago, 0)) ValorAberto FROM sys_financialmovement WHERE (ValorPago < Value or ValorPago IS NULL) AND CaixaID="&CaixaID&" AND CD='C' AND Type='Bill'"

            set MovementsNaoPagasSQL = db.execute(sqlNaoPago )
            if not MovementsNaoPagasSQL.eof then
                if not isnull(MovementsNaoPagasSQL("ValorAberto")) then
                    RecebimentosNaoExecutados=RecebimentosNaoExecutados + MovementsNaoPagasSQL("ValorAberto")
                end if
            end if

        l3.movenext
        wend
        l3.close
        set l3=nothing
    end if


    vl4 = vl2 - ValorFechamentoInformado

    'BLOCO 2
    set pDesp = db.execute("select sum(m.Value) Despesas FROM sys_financialmovement m WHERE m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit NOT IN(1,7) AND NOT ISNULL(m.CaixaID) AND m.Date="& mData &" AND m.Type='Pay' AND m.UnidadeID="& UnidadeID &"")
    Despesas = pDesp("Despesas")




    sqlDebitoECredito = "select idesc.id ItemDescontadoID, m.PaymentMethodID, ii.id ItemInvoiceID, ii.InvoiceID, ii.DataExecucao, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, ii.Quantidade, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal, idesc.Valor ValorDescontado FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN itensdescontados idesc ON idesc.ItemID=ii.id LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID WHERE "& filtroData("ii.DataExecucao") &" AND i.CompanyUnitID="& UnidadeID &" AND ii.Executado='S' AND m.PaymentMethodID IN (8,9) ORDER BY ii.DataExecucao"
    set RecebimentosDebitoECreditoSQL= db.execute(sqlDebitoECredito)
    TotalCredito = 0
    TotalDebito = 0

    while not RecebimentosDebitoECreditoSQL.eof

        TotalRepasse = 0
        ValorPago = 0
        set rr = db.execute("select rr.Valor, (iip.Quantidade*(iip.ValorUnitario+iip.Acrescimo-iip.Desconto)) ValorItemAPagar, (select ifnull(sum(Valor), 0) from itensdescontados where ItemID=rr.ItemContaAPagar) ValorPagoItemP from rateiorateios rr LEFT JOIN itensinvoice iip ON iip.id=rr.ItemContaAPagar WHERE ContaCredito LIKE '%\_%' AND ItemInvoiceID="& RecebimentosDebitoECreditoSQL("ItemInvoiceID") &" "& sqlIDesc &" ")
        while not rr.eof
            TotalRepasse = TotalRepasse+rr("Valor")
            BalancoPagto = rr("ValorItemAPagar") - rr("ValorPagoItemP")
        rr.movenext
        wend
        rr.close
        set rr = nothing

        ValorLiquido = RecebimentosDebitoECreditoSQL("ValorTotal")-TotalRepasse

        if RecebimentosDebitoECreditoSQL("PaymentMethodID")=8 then
            TotalCredito= TotalCredito +ValorLiquido
        elseif RecebimentosDebitoECreditoSQL("PaymentMethodID")=9 then
            TotalDebito= TotalDebito +ValorLiquido
        end if
    RecebimentosDebitoECreditoSQL.movenext
    wend
    RecebimentosDebitoECreditoSQL.close
    set RecebimentosDebitoECreditoSQL=nothing


    %>
    <br>
    <div class="alert alert-warning hidden">
        <strong>Atenção!</strong> Este relatório está sendo atualizado. Tente novamente mais tarde.
    </div>
    <h2 class="text-center">Fechamento de Caixa <br />
        <small> <%= DataString %> - <%= NomeFantasia %></small>
    </h2>
    <style>
    #tabelaFechamentoCaixa .linha-fechamento {
        cursor: pointer;
    }
    </style>
    <table class="table table-condensed table-hover table-bordered" id="tabelaFechamentoCaixa">
        <thead>
            <tr class="info">
                <th>Descrição</th>
                <th>Valor</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>1. Produção bruta</td>
                <td class="text-right"><%= fn(l1("Valor")) %></td>
            </tr>
            <tr>
                <td>2. Produção livre de repasses</td>
                <td class="text-right"><%= fn(vl2) %></td>
            </tr>
            <tr>
                <td>3. Fechamento de Caixa Calculado</td>
                <td class="text-right"><%= fn(FechamentoCaixaCalculado) %></td>
            </tr>
            <tr style="cursor:pointer" onclick="window.open('PrintStatement.asp?R=rRelatorioCaixa&Tipo=Diario&Data=<%= Data %>&UnidadeID=<%= UnidadeID %>')">
                <td>3.1. Fechamento de Caixa</td>
                <td class="text-right"><%= fn(ValorFechamentoInformado) %></td>
            </tr>
            <tr>
                <td>3.2. Diferença de Caixas</td>
                <td class="text-right"><%= fn(ValorFechamentoInformado - FechamentoCaixaCalculado) %></td>
            </tr>
            <tr>
                <td>4. Diferença Produção x Fechamento</td>
                <td class="text-right"><%= fn(vl4) %></td>
            </tr>
        </tbody>
        <thead>

            <tr class="info">
                <th>Análise da Diferença</th>
                <th>Valor</th>
            </tr>
        </thead>
        <tbody>
            <tr class="linha-fechamento" data-id="5">
                <td>5. Entradas em dinheiro menos saídas</td>
                <td class="text-right"><%= fn(Dinheiro) %></td>
            </tr>
            <tr class="linha-fechamento" data-id="6">
                <td>6. Entradas em cartão de crédito</td>
                <td class="text-right"><%= fn(TotalCredito) %></td>
            </tr>
            <tr class="linha-fechamento" data-id="7">
                <td>7. Entradas em cartão de débito</td>
                <td class="text-right"><%= fn(TotalDebito) %></td>
            </tr>
            <tr class="linha-fechamento" data-id="8">
                <td>8. Despesas</td>
                <td class="text-right"><%= fn(Despesas) %></td>
            </tr>
            <tr class="linha-fechamento" data-id="9">
                <td>9. Atendimentos não pagos</td>
                <td class="text-right"><%= fn(RecebimentosNaoExecutados) %></td>
            </tr>
        </tbody>
        <tfoot>
            <tr class="warning">
                <td>Total de diferença</td>
                <td class="text-right"><%= fn(TotalDiferenca) %></td>
            </tr>
            <tr>
                <th>Resultado final</th>
                <th class="text-right"><%= fn(ResultadoFinal) %></th>
            </tr>
        </tfoot>
    </table>

    <%
    Data = Data+1
 wend
%>