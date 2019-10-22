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
Data = req("Data")
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

'BLOCO 1
set l1 = db.execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE "& filtroData("ii.DataExecucao") &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &")")
set reps = db.execute("select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE "& filtroData("ii.DataExecucao") &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &") AND ContaCredito LIKE '%\_%'")
Repasses = reps("Repasses")
vl2 = l1("Valor")-Repasses

sql = "select fcx.CaixaID, fcx.Dinheiro Valor, fcx.Dinheiro Dinheiro, IFNULL(fcx.Credito, 0) Credito, IFNULL(fcx.Debito,0) Debito from caixa cx INNER JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID INNER join fechamentocaixa fcx on fcx.CaixaID=cx.id where cc.Empresa="& UnidadeID &" and "& filtroData("cx.dtFechamento") &" GROUP BY fcx.id"
'response.write(sql)
set l3 = db.execute(sql)

Dinheiro = 0
Credito = 0
Debito = 0

ValorFechamento = 0
RecebimentosNaoExecutados = 0
ValorCreditosUtilizados = 0
RepasseDeOutrasDatas = 0
RepassesNaoPagos = 0
vl4 = 0

if not l3.eof then
    while not l3.eof
    'vl4 = l1("Valor") - vl2
        CaixaID = l3("CaixaID")

        Dinheiro = Dinheiro + l3("Dinheiro")
        Credito = Credito + l3("Credito")
        Debito = Debito + l3("Debito")
        ValorFechamento = ValorFechamento + l3("Valor")

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


sqlRepasseOutrosDias="SELECT idesc.PagamentoID, mov.AccountIDDebit,mov.Value ValorPagamento,  mov.Date DataPagamento,  "&_
                      "SUM(round(rat.Valor)) ValorRepasse, ii.DataExecucao, rat.ContaCredito, (CASE "&_
                      "when mov.Date is null then 'NaoPago' "&_
                      "when ii.DataExecucao < mov.Date then 'DataDiferente' "&_
                      "end )Motivo "&_
                      " "&_
                      " FROM rateiorateios rat  "&_
                      " "&_
                      "INNER JOIN itensinvoice ii ON ii.id=rat.ItemInvoiceID "&_
                      "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                      "LEFT JOIN itensdescontados idesc ON rat.ItemContaAPagar=idesc.ItemID "&_
                      "LEFT JOIN sys_financialmovement mov  ON idesc.PagamentoID=mov.id "&_
                      " "&_
                      "WHERE ( "&_
                      "("& filtroData("ii.DataExecucao") &" and mov.Value is null)  "&_
                      " "&_
                      "or  "&_
                      "(ii.DataExecucao < mov.Date AND "& filtroData("mov.Date") &")"&_
                      " "&_
                      ") "&_
                      "AND i.CompanyUnitID="&UnidadeID&" "&_
                      "AND (rat.ContaCredito NOT IN ('0', '0_0')) "&_
                      " "&_
                      "GROUP BY Motivo"
set RepassesDiferentesSQL = db.execute(sqlRepasseOutrosDias )
if not RepassesDiferentesSQL.eof then

    while not RepassesDiferentesSQL.eof
        if RepassesDiferentesSQL("Motivo")="NaoPago" then
            RepassesNaoPagos= RepassesNaoPagos + RepassesDiferentesSQL("ValorRepasse")
        elseif RepassesDiferentesSQL("Motivo")="DataDiferente" then
            RepasseDeOutrasDatas= RepasseDeOutrasDatas + RepassesDiferentesSQL("ValorRepasse")
        end if
    RepassesDiferentesSQL.movenext
    wend
    RepassesDiferentesSQL.close
    set RepassesDiferentesSQL=nothing
end if

sqlUtilizacaoDeSaldo="SELECT SUM(ifnull(d.DiscountedValue,0))ValorUtilizado, movbill.InvoiceID FROM sys_financialmovement mov "&_
                     " "&_
                     "INNER JOIN sys_financialdiscountpayments d ON d.MovementID=mov.id "&_
                     "INNER JOIN sys_financialmovement movbill ON movbill.id=d.InstallmentID "&_
                     " "&_
                     "WHERE mov.`Type`='transfer' "&_
                     "AND mov.UnidadeID="&UnidadeID&"  "&_
                     "AND mov.AccountAssociationIDCredit=3 "&_
                     "AND "& filtroData("movbill.Date") &_
                     " AND d.DiscountedValue>0 "

set CreditosUtilizadosSQL = db.execute(sqlUtilizacaoDeSaldo)
if not CreditosUtilizadosSQL.eof then
    if not isnull(CreditosUtilizadosSQL("ValorUtilizado")) then
        ValorCreditosUtilizados=CreditosUtilizados + CreditosUtilizadosSQL("ValorUtilizado")
    end if
end if

vl4 = vl2 - ValorFechamento

'BLOCO 2
set pDesp = db.execute("select sum(m.Value) Despesas FROM sys_financialmovement m WHERE m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit NOT IN(1,7) AND NOT ISNULL(m.CaixaID) AND m.Date="& mData &" AND m.Type='Pay' AND m.UnidadeID="& UnidadeID &"")
Despesas = pDesp("Despesas")


sql = "SELECT sum(ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo)) Valor FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE "& filtroData("i.sysDate") &" AND i.CD='C' AND i.CompanyUnitID="& UnidadeID &" AND ii.Tipo='S' AND ii.Executado = ''"
set ServicosNaoExecutadosSQL = db.execute(sql)

if not ServicosNaoExecutadosSQL.eof then
    servicosNaoExecutados=ServicosNaoExecutadosSQL("Valor")
end if



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

'7 + 6 + 10 + 12 - 11 + 13

TotalDiferenca=  TotalCredito +  TotalDebito + ValorCreditosUtilizados + RepasseDeOutrasDatas - RepassesNaoPagos - servicosNaoExecutados

ResultadoFinal=vl4-TotalDiferenca
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
            <td>3. Fechamento de Caixa</td>
            <td class="text-right"><%= fn(ValorFechamento) %></td>
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
            <td>5. Entradas em dinheiro</td>
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
        <tr class="linha-fechamento" data-id="10">
            <td>10. Utilização de saldo de paciente</td>
            <td class="text-right"><%= fn(ValorCreditosUtilizados) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="11">
            <td>11. Repasses não pagos</td>
            <td class="text-right"><%= fn(RepassesNaoPagos) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="12">
            <td>12. Repasses pagos de outros dias</td>
            <td class="text-right"><%= fn(RepasseDeOutrasDatas) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="13">
            <td>13. Serviços não executados</td>
            <td class="text-right"><%= fn(servicosNaoExecutados) %></td>
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
<!-- Modal -->
<div id="modal-detalhamento-fechamento" class="modal fade" role="dialog">
  <div class="modal-dialog modal-lg">

    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Detalhamento</h4>
      </div>
      <div class="modal-body">
        <p>Carregando...</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
      </div>
    </div>

  </div>
</div>
<script >
setTimeout(function() {

    $(document).ready(function() {
        var $modal = $("#modal-detalhamento-fechamento");
        var $linhas = $("#tabelaFechamentoCaixa .linha-fechamento");

        function changeModalTitle(title){
            $modal.find(".modal-title").html(title);
        }

        $linhas.click(function() {
            var id = $(this).data("id");
            var title = $(this).find("td").first().text();

            $modal.find(".modal-body").html("Carregando...");

            changeModalTitle(title);

            $.get("DetalhamentoFechamentoCaixa.asp", {
                linhaId: id,
                data: "<%=Data%>",
                unidadeId: "<%=UnidadeID%>"
            }, function(data) {
                $modal.find(".modal-body").html(data);
            $modal.modal("show");
            });
        });
    });
}, 500);
</script>