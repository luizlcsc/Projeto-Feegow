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
'set l1 = db.execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE "& filtroData("ii.DataExecucao") &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &")")
set l1 = db.execute("select sum(Value) Valor from sys_financialmovement where not isnull(CaixaID) AND ((AccountAssociationIDDebit=7 AND AccountAssociationIDCredit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")

'soma de entradas cartao de credito
set pentCCred = db.execute("select ifnull(sum(Value),0) Valor from sys_financialmovement where not isnull(CaixaID) AND PaymentMethodID IN (8) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
entCCred = pentCCred("Valor")
'response.write( entCCred &"<br>")

'soma de entradas cartao de debito
set pentCDeb = db.execute("select ifnull(sum(Value), 0) Valor from sys_financialmovement where not isnull(CaixaID) AND PaymentMethodID IN (9) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
entCDeb = pentCDeb("Valor")
'response.write( entCDeb &"<br>")


set entDC = db.execute("select ifnull(sum(Value),0) Valor from sys_financialmovement where not isnull(CaixaID) AND PaymentMethodID IN (1, 2) AND ((AccountAssociationIDDebit=7 AND AccountAssociationIDCredit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
    'response.write( "select sum(Value) Valor from sys_financialmovement where not isnull(CaixaID) AND PaymentMethodID IN (1, 2) AND ((AccountAssociationIDDebit=7 AND AccountAssociationIDCredit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"" )
EntDinheiroCheque = entDC("Valor")
'response.write("<br> Entradas em dinheiro: "& EntDinheiroCheque)
set saiD = db.execute("select ifnull(sum(Value),0) Valor from sys_financialmovement where not isnull(CaixaID) AND ((AccountAssociationIDCredit=7 AND AccountAssociationIDDebit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
'response.write("select sum(Value) Valor from sys_financialmovement where not isnull(CaixaID) AND ((AccountAssociationIDCredit=7 AND AccountAssociationIDDebit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
SaiDinheiro = saiD("Valor")
'response.write("<br> SaiDinheiro: "& SaiDinheiro)
FechamentoCaixaCalculado = EntDinheiroCheque - SaiDinheiro
'response.write("<br> FechamentoCaixaCalculado: "& FechamentoCaixaCalculado)


set reps = db.execute("select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE "& filtroData("ii.DataExecucao") &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &") AND ContaCredito LIKE '%\_%'")
Repasses = reps("Repasses")
'vl2 = l1("Valor")-Repasses
'ultimo -> vl2 = l1("Valor")+entCDeb+entCCred-Repasses

'> ITEM 2 ------------------------------------------------------------------
set vval = db.execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE  ii.DataExecucao = "& mData &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &")")
set vrep = db.execute("select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.DataExecucao = "& mData &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &") AND ContaCredito LIKE '%\_%'")
'vl2 = ccur(vval("Valor")) - ccur(vrep("Repasses"))
'< ITEM 2 ------------------------------------------------------------------


sql = "select fcx.CaixaID, fcx.Dinheiro Valor, fcx.DinheiroInformado, fcx.Dinheiro Dinheiro, IFNULL(fcx.Credito, 0) Credito, IFNULL(fcx.Debito,0) Debito from caixa cx INNER JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID INNER join fechamentocaixa fcx on fcx.CaixaID=cx.id where cc.Empresa="& UnidadeID &" and "& filtroData("cx.dtFechamento") &" GROUP BY fcx.CaixaID"
if session("User")=81920 then
    response.write(sql)
end if
set l3 = db.execute(sql)

Dinheiro = 0
Credito = 0
Debito = 0

'ValorFechamento = 0
ValorFechamentoInformado = 0
RecebimentosNaoExecutados = 0
ValorCreditosUtilizados = 0
RepasseDeOutrasDatas = 0
RepassesNaoPagos = 0
servicosNaoExecutados = 0
servicosExecutadosEmOutraData = 0
vl4 = 0
devolucoes = 0
OutrasDespesas = 0

Caixas = ""

if not l3.eof then
    while not l3.eof
    'vl4 = l1("Valor") - vl2
        CaixaID = l3("CaixaID")

        if not isnull(CaixaID) then
            if Caixas="" then
                Caixas=CaixaID
            else
                Caixas=Caixas&", "& CaixaID
            end if
        end if


        Dinheiro = Dinheiro + l3("Dinheiro")
        Credito = Credito + l3("Credito")
        Debito = Debito + l3("Debito")
        'ValorFechamento = ValorFechamento + l3("Valor")
        ValorFechamentoInformado = ValorFechamentoInformado + l3("DinheiroInformado")

        'bloco passado para baixo sem considerar caixaId :-0
        if false then
            sqlNaoPago="SELECT sum(Value-IFNULL(ValorPago, 0)) ValorAberto FROM sys_financialmovement WHERE (ValorPago < Value or ValorPago IS NULL)  AND UnidadeID="&UnidadeID&" AND CaixaID="&CaixaID&" AND CD='C' AND Type='Bill'"
            if session("User")=81920 then
                response.Write("<br>"& sqlNaoPago &"<br>")
            end if

            set MovementsNaoPagasSQL = db.execute(sqlNaoPago )
            if not MovementsNaoPagasSQL.eof then
                if not isnull(MovementsNaoPagasSQL("ValorAberto")) then
                    RecebimentosNaoExecutados=RecebimentosNaoExecutados + MovementsNaoPagasSQL("ValorAberto")
                end if
            end if
        end if

    l3.movenext
    wend
    l3.close
    set l3=nothing


'valor sem caixa
    sqlNaoPago="SELECT sum(Value-IFNULL(ValorPago, 0)) ValorAberto FROM sys_financialmovement WHERE (ValorPago < Value or ValorPago IS NULL) AND UnidadeID="&UnidadeID&" AND CaixaID IS NULL AND Date="&mData&" AND CD='C' AND Type='Bill'"

    set MovementsNaoPagasSQL = db.execute(sqlNaoPago )
    if not MovementsNaoPagasSQL.eof then
        if not isnull(MovementsNaoPagasSQL("ValorAberto")) then
            RecebimentosNaoExecutados=RecebimentosNaoExecutados + MovementsNaoPagasSQL("ValorAberto")
        end if
    end if


end if

sqlNaoPago="SELECT sum(Value-IFNULL(ValorPago, 0)) ValorAberto FROM sys_financialmovement WHERE (ValorPago < Value or ValorPago IS NULL)  AND UnidadeID="&UnidadeID&" AND "&filtroData("Date")&" AND CD='C' AND Type='Bill'"

set MovementsNaoPagasSQL = db.execute(sqlNaoPago )
if not MovementsNaoPagasSQL.eof then
    if not isnull(MovementsNaoPagasSQL("ValorAberto")) then
        RecebimentosNaoExecutados=RecebimentosNaoExecutados + MovementsNaoPagasSQL("ValorAberto")
    end if
end if

sqlRepasseOutrosDias="SELECT idesc.PagamentoID, mov.AccountIDDebit,mov.Value ValorPagamento,  mov.Date DataPagamento, "&_
                      "SUM(rat.Valor) ValorRepasse, ii.DataExecucao, rat.ContaCredito, (CASE "&_
                      "when isnull(mov.Date) then 'NaoPago' "&_
                      "when ii.DataExecucao <> mov.Date AND ii.DataExecucao="& mydatenull(Data) &" then 'NaoPago' "&_
                      "when ii.DataExecucao <> mov.Date then 'DataDiferente' "&_
                      "end )Motivo, rat.ItemDescontadoID, midesc.PaymentMethodID "&_
                      " "&_
                      " FROM rateiorateios rat  "&_
                      " "&_
                      "INNER JOIN itensinvoice ii ON ii.id=rat.ItemInvoiceID "&_
                      "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                      "LEFT JOIN itensdescontados idesc ON rat.ItemContaAPagar=idesc.ItemID "&_
                      "LEFT JOIN sys_financialmovement mov  ON idesc.PagamentoID=mov.id "&_
                      " "&_
                            "LEFT JOIN itensdescontados idescrr ON idescrr.id=rat.ItemDescontadoID "&_
 		                    "LEFT JOIN sys_financialmovement midesc ON midesc.id=idescrr.PagamentoID "&_
                      "WHERE ( "&_
                      "("& filtroData("ii.DataExecucao") &" and mov.Value is null)  "&_
                      " "&_
                      "or  "&_
                      "(ii.DataExecucao < mov.Date AND "& filtroData("mov.Date") &") "&_
                          "or  "&_
                          "(ii.DataExecucao="& mydatenull(Data) &") "&_
                      " "&_
                      ") "&_
                      "AND i.CompanyUnitID="&UnidadeID&" "&_
                      "AND (rat.ContaCredito NOT IN ('0', '0_0')) "&_
                            "AND midesc.PaymentMethodID NOT IN(8,9) "&_
                      " "&_
                      "GROUP BY Motivo"
    'response.write( sqlRepasseOutrosDias )
set RepassesDiferentesSQL = db.execute(sqlRepasseOutrosDias )
'response.write( sqlRepasseOutrosDias )
if not RepassesDiferentesSQL.eof then

    while not RepassesDiferentesSQL.eof
        'if RepassesDiferentesSQL("PaymentMethodID")<>8 and RepassesDiferentesSQL("PaymentMethodID")<>9 then
            if RepassesDiferentesSQL("Motivo")="NaoPago" then
                RepassesNaoPagos= RepassesNaoPagos + RepassesDiferentesSQL("ValorRepasse")
            elseif RepassesDiferentesSQL("Motivo")="DataDiferente" then
                RepasseDeOutrasDatas= RepasseDeOutrasDatas + RepassesDiferentesSQL("ValorRepasse")
            end if
        'end if
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

vl4 = vl2 - ValorFechamentoInformado

'BLOCO 2
set pDesp = db.execute("select COALESCE(sum(idesc.Valor),0) Despesas FROM sys_financialmovement m "&_
"INNER JOIN itensdescontados idesc ON idesc.PagamentoID=m.id "&_
"INNER JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
"INNER JOIN sys_financialexpensetype exp ON exp.id=ii.CategoriaID "&_
"WHERE exp.Name='Repasses' AND m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit NOT IN(1,7) AND NOT ISNULL(m.CaixaID) AND m.Date="& mData &" AND m.Type='Pay' AND m.UnidadeID="& UnidadeID &" "&_
"")
DespesasRepasse = pDesp("Despesas")

set pDesp = db.execute("select COALESCE(sum(m.Value),0) Despesas FROM sys_financialmovement m "&_
"INNER JOIN itensdescontados idesc ON idesc.PagamentoID=m.id "&_
"INNER JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
"INNER JOIN sys_financialexpensetype exp ON exp.id=ii.CategoriaID "&_
"WHERE exp.Name!='Repasses' AND m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit NOT IN(1,7) AND NOT ISNULL(m.CaixaID) AND m.Date="& mData &" AND m.Type='Pay' AND m.UnidadeID="& UnidadeID &" "&_
"")
OutrasDespesas = pDesp("Despesas")

sql = "SELECT sum(ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo)) Valor "&_
"FROM itensinvoice ii "&_
"LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID  "&_
"WHERE "& filtroData("i.sysDate") &" AND i.CD='C' AND i.CompanyUnitID="& UnidadeID &" AND ii.Tipo='S' AND ii.Executado = ''"
'dd(sql)
set ServicosNaoExecutadosSQL = db.execute(sql)

set ServicosNaoExecutadosSQL = db.execute(sql)
if not ServicosNaoExecutadosSQL.eof then
    if not isnull(ServicosNaoExecutadosSQL("Valor")) then
        servicosNaoExecutados=ServicosNaoExecutadosSQL("Valor")
    end if
end if

sql = "SELECT sum(ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo)) Valor "&_
"FROM itensinvoice ii "&_
"LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID  "&_
"WHERE "& filtroData("i.sysDate") &" AND i.CD='C' AND i.CompanyUnitID="& UnidadeID &" AND ii.Tipo='S' AND ii.Executado = 'S' AND ii.DataExecucao != i.sysDate"
'dd(sql)
set ServicosExecutadosEmOutraDataSQL = db.execute(sql)
if not ServicosExecutadosEmOutraDataSQL.eof then
    if not isnull(ServicosExecutadosEmOutraDataSQL("Valor")) then
        servicosExecutadosEmOutraData=ServicosExecutadosEmOutraDataSQL("Valor")
    end if
end if


sql = "SELECT SUM(d.TotalDevolucao) TotalDevolucao FROM devolucoes d INNER JOIN sys_financialinvoices i ON i.id=d.invoiceID WHERE "& filtroData("d.sysDate") &" AND i.CD='C' AND i.CompanyUnitID="& UnidadeID &""
set DevolucoesSQL = db.execute(sql)

if not DevolucoesSQL.eof then
    if not isnull(DevolucoesSQL("TotalDevolucao")) then
        devolucoes=ccur(DevolucoesSQL("TotalDevolucao"))
    end if
end if




sqlDebitoECredito = "select idesc.id ItemDescontadoID, m.PaymentMethodID, ii.id ItemInvoiceID, ii.InvoiceID, ii.DataExecucao, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, ii.Quantidade, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal, idesc.Valor ValorDescontado FROM itensinvoice ii "&_
"LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
"LEFT JOIN procedimentos proc ON proc.id=ii.ItemID  "&_
"LEFT JOIN itensdescontados idesc ON idesc.ItemID=ii.id  "&_
"LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID  "&_
"WHERE "& filtroData("ii.DataExecucao") &" AND i.CompanyUnitID="& UnidadeID &" AND ii.DataExecucao=i.sysDate AND ii.Executado='S' AND m.PaymentMethodID IN (8,9,1) ORDER BY ii.DataExecucao"

set RecebimentosDebitoECreditoSQL= db.execute(sqlDebitoECredito)
TotalCredito = 0
TotalDebito = 0
TotalDinheiro = 0
RepasseCartao = 0

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

    ValorLiquido = RecebimentosDebitoECreditoSQL("ValorDescontado")-TotalRepasse

    RepasseCartao = RepasseCartao + TotalRepasse

    if RecebimentosDebitoECreditoSQL("PaymentMethodID")=8 then
        TotalCredito= TotalCredito +ValorLiquido
    elseif RecebimentosDebitoECreditoSQL("PaymentMethodID")=9 then
        TotalDebito= TotalDebito +ValorLiquido
    elseif RecebimentosDebitoECreditoSQL("PaymentMethodID")=1 then
        TotalDinheiro= TotalDinheiro +ValorLiquido
    end if
RecebimentosDebitoECreditoSQL.movenext
wend
RecebimentosDebitoECreditoSQL.close
set RecebimentosDebitoECreditoSQL=nothing


sqlDebitoECredito = "select idesc.id ItemDescontadoID, m.PaymentMethodID, ii.id ItemInvoiceID, ii.InvoiceID, ii.DataExecucao, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, ii.Quantidade, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal, idesc.Valor ValorDescontado FROM itensinvoice ii "&_
"LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
"LEFT JOIN procedimentos proc ON proc.id=ii.ItemID  "&_
"LEFT JOIN itensdescontados idesc ON idesc.ItemID=ii.id  "&_
"LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID  "&_
"WHERE "& filtroData("ii.DataExecucao") &" AND i.CompanyUnitID="& UnidadeID &" AND ii.DataExecucao!=i.sysDate AND ii.Executado='S' ORDER BY ii.DataExecucao"

set RecebimentoLiquidoDeOutrasDatasSQL= db.execute(sqlDebitoECredito)
'dd(RecebimentoLiquidoDeOutrasDatasSQL)
RecebimentoLiquidoDeOutrasDatas = 0

while not RecebimentoLiquidoDeOutrasDatasSQL.eof

    TotalRepasse = 0
    ValorPago = 0
    set rr = db.execute("select rr.Valor, (iip.Quantidade*(iip.ValorUnitario+iip.Acrescimo-iip.Desconto)) ValorItemAPagar, (select ifnull(sum(Valor), 0) from itensdescontados where ItemID=rr.ItemContaAPagar) ValorPagoItemP from rateiorateios rr LEFT JOIN itensinvoice iip ON iip.id=rr.ItemContaAPagar WHERE ContaCredito LIKE '%\_%' AND ItemInvoiceID="& RecebimentoLiquidoDeOutrasDatasSQL("ItemInvoiceID") &" "& sqlIDesc &" ")
    while not rr.eof
        TotalRepasse = TotalRepasse+rr("Valor")
        BalancoPagto = rr("ValorItemAPagar") - rr("ValorPagoItemP")
    rr.movenext
    wend
    rr.close
    set rr = nothing

    ValorLiquido = RecebimentoLiquidoDeOutrasDatasSQL("ValorDescontado")-TotalRepasse

    RecebimentoLiquidoDeOutrasDatas = RecebimentoLiquidoDeOutrasDatas + ValorLiquido

RecebimentoLiquidoDeOutrasDatasSQL.movenext
wend
RecebimentoLiquidoDeOutrasDatasSQL.close
set RecebimentoLiquidoDeOutrasDatasSQL=nothing


transferenciasBancarias = 0

set TransferenciasBancariasSQL = db.execute("SELECT COALESCE(SUM(idesc.Valor),0)-COALESCE(SUM(rr.Valor),0) totalTransfer FROM sys_financialmovement m "&_
"LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id "&_
"LEFT JOIN rateiorateios rr ON rr.ItemInvoiceID = idesc.ItemID "&_
"WHERE "&_
"PaymentMethodID IN (3, 7, 15) AND m.UnidadeID="& UnidadeID &"  AND m.`Type` IN ('Pay','Transfer') AND m.CD IN ('D','') AND "&filtroData("m.Date")&";")

if not TransferenciasBancariasSQL.eof then
    transferenciasBancarias = TransferenciasBancariasSQL("totalTransfer")
end if

'    response.Write( RepasseCartao )

'7 + 6 + 10 + 12 - 11 + 13
    'response.Write(TotalCredito)
'3.1 + 6 + 7 + 9 + 10 - 11 + 12 - 13 + 14

ResultadoFinal = ValorFechamentoInformado + ( transferenciasBancarias + TotalCredito + TotalDebito) + RecebimentosNaoExecutados + ValorCreditosUtilizados - RepassesNaoPagos + RepasseDeOutrasDatas - servicosExecutadosEmOutraData - servicosNaoExecutados + devolucoes + OutrasDespesas + RecebimentoLiquidoDeOutrasDatas

'response.write("ValorFechamentoInformado + ( transferenciasBancarias + TotalCredito + TotalDebito) + RecebimentosNaoExecutados + ValorCreditosUtilizados - RepassesNaoPagos + RepasseDeOutrasDatas - servicosExecutadosEmOutraData - servicosNaoExecutados + devolucoes + OutrasDespesas + RecebimentoLiquidoDeOutrasDatas")
'response.write("<Br>")
'response.write(ValorFechamentoInformado &"+ ("& transferenciasBancarias &"+"& TotalCredito &"+"& TotalDebito&") +"& RecebimentosNaoExecutados &"+"& ValorCreditosUtilizados &"-"& RepassesNaoPagos &"+"& RepasseDeOutrasDatas &"-"& servicosExecutadosEmOutraData &"-"& servicosNaoExecutados &"+"& devolucoes &"+"& OutrasDespesas &"+"& RecebimentoLiquidoDeOutrasDatas )

TotalDiferenca=  ValorCreditosUtilizados + RepasseDeOutrasDatas - RepassesNaoPagos - servicosExecutadosEmOutraData - servicosNaoExecutados - RecebimentosNaoExecutados + RecebimentoLiquidoDeOutrasDatas

vl2 = (l1("Valor")+entCDeb+entCCred)  - DespesasRepasse - OutrasDespesas - RepasseCartao + RepasseDeOutrasDatas + RecebimentosNaoExecutados - RepassesNaoPagos

if true then
    'producao p grupo
    set vval = db.execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID INNER JOIN procedimentos proc ON proc.id=ii.ItemID WHERE  ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &")")
    sqlRep = "select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID INNER JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &") AND ContaCredito LIKE '%\_%'"
    set vrep = db.execute( sqlRep )
    Valor = ccur(vval("Valor"))
    Repasses = ccur(vrep("Repasses"))
    ValorLiquido = Valor - Repasses
    ValorBruto = Valor

    vl2=ValorLiquido
end if

ResultadoFinal= ResultadoFinal - vl2

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
            <td class="text-right"><%= fn(ValorBruto) %></td>
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
        <tr class="hidden">
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
        <tr class="linha-fechamento" data-id="4">
            <td>4. Transferências bancárias</td>
            <td class="text-right"><%= fn(transferenciasBancarias) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="5">
            <td>5. Entradas em dinheiro menos saídas</td>
            <td class="text-right"><%= fn(TotalDinheiro) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="6">
            <td>6. Entradas em cartão de crédito</td>
            <td class="text-right"><%= fn(TotalCredito) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="7">
            <td>7. Entradas em cartão de débito</td>
            <td class="text-right"><%= fn(TotalDebito) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="8.1">
            <td>8.1. Despesa de repasse</td>
            <td class="text-right"><%= fn(DespesasRepasse) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="8.2">
            <td>8.2. Outras despesas</td>
            <td class="text-right"><%= fn(OutrasDespesas) %></td>
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
            <td>11. Repasses não pagos na data da execução</td>
            <td class="text-right"><%= fn(RepassesNaoPagos) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="12">
            <td>12. Repasses pagos de outros dias</td>
            <td class="text-right"><%= fn(RepasseDeOutrasDatas) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="13.1">
            <td>13.1. Serviços não executados</td>
            <td class="text-right"><%= fn(servicosNaoExecutados) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="13.2">
            <td>13.2. Serviços executados em outra data</td>
            <td class="text-right"><%= fn(servicosExecutadosEmOutraData) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="14">
            <td>14. Devoluções</td>
            <td class="text-right"><%= fn(devolucoes) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="15">
            <td>15. Recebimento liquido de outras datas</td>
            <td class="text-right"><%= fn(RecebimentoLiquidoDeOutrasDatas) %></td>
        </tr>
        <tr class="linha-fechamento" data-id="16" style="display: none;">
            <td>16. [Diferenca.Descricao]</td>
            <td class="text-right">NaN</td>
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
        <tr>
            <th></th>
            <th class="text-right">(3.1 + (4 + 6 + 7) + 9 + 10 - 11 + 12 - 13 + 14 + 15) - 2</th>
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

            $modal.find(".modal-body").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)

            changeModalTitle(title);

            $.get("DetalhamentoFechamentoCaixa.asp", {
                linhaId: id,
                caixas: '<%=Caixas%>',
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