<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<style type="text/css">
    @media print {
        td, th {
            #font-size:10px;
        }
    }
    .rel, .linha-fechamento {
        cursor:pointer;
    }
</style>


<%
'PENDENCIAS - EXIBIR A FRAÇÃO NÃO PAGA NO DESDOBRAMENTO DE FORMAS DE PAGTO



server.ScriptTimeout = 50

function filtroData(dataColuna)
    if TipoPeriodoData="DIA" then
        filtroData = " (DATE("&dataColuna&")="&mydatenull(Data)&") "
    else
        filtroData = " (MONTH("&dataColuna&")=MONTH("&mydatenull(Data)&") and YEAR("&dataColuna&")=YEAR("&mydatenull(Data)&")) "
    end if
end function


'atualiza o folhão
%>
<div class="hidden">
    <%
    server.execute("FechamentoDetalhado.asp")'REABILITAR
    %>
</div>
<%
UnidadeID = req("U")
Data = req("Data")
mData = mydatenull(Data)
UsarDataMensal=req("UsarDataMensal")

set u = db.execute("select id, NomeFantasia from (select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits) t where id="& UnidadeID)
if not u.eof then
    NomeFantasia = u("NomeFantasia")
end if

%>

<div class="container">
    <h2 class="text-center">ANÁLISE COMPLETA
        <br />
        <small><%= NomeFantasia &" - "& Data %></small>
    </h2>
    <table class="table table-hover mt25" id="tabelaFechamentoCaixa">
        <tr>
            <th>SERVIÇOS</th>
            <th>VALOR TOTAL</th>
            <th>DESPESAS/REPASSES</th>
            <th>VALOR LÍQUIDO</th>
        </tr>
        <tr class="rel" data-tipo="ServicosExecutados" data-titulo="Serviços executados">
            <%
            '!!!!!!SERVIÇOS EXECUTADOS!!!!!!
            sql = "select sum(TotalFaturado) tServicosExecutados from temp_fechamentodetalhado where DtExecucao="& mData &" AND sysUser="& session("User") &" AND Executado='S' "
               ' response.write( sql )
            set pserv = db.execute( sql )    
            tServicosExecutados = pserv("tServicosExecutados")
            sql = "SELECT SUM(rr.Valor) trServicosExecutados FROM rateiorateios rr LEFT JOIN temp_fechamentodetalhado tf ON tf.ItemInvoiceID=rr.ItemInvoiceID WHERE tf.DtExecucao="& mData &" AND rr.ContaCredito LIKE '%\_%' AND tf.sysUser="& session("User") &" AND tf.Executado='S' "
               ' response.Write( sql )
            set prserv = db.execute( sql )
            trServicosExecutados = prServ("trServicosExecutados")
            %>

            <td>Serviços executados</td>
            <td class="text-right"><%= fn(tServicosExecutados) %></td>
            <td class="text-right"><%= fn(trServicosExecutados) %></td>
            <td class="text-right"><%= fn(tServicosExecutados - trServicosExecutados) %></td>
        </tr>
        <%
        PartePaga = 0
        sql = "SELECT pm.PaymentMethod, m.PaymentMethodID, SUM(idesc.Valor) Total FROM temp_fechamentodetalhado tf LEFT JOIN itensdescontados idesc ON idesc.ItemID=tf.ItemInvoiceID LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE tf.DtExecucao="& mData &" AND tf.sysUser="& session("User") &" AND tf.Executado='S' AND NOT ISNULL(m.PaymentMethodID) GROUP BY pm.id ORDER BY pm.id DESC"
        set distPM = db.execute( sql )
        while not distPM.eof
                PartePaga = PartePaga+distPM("Total")
                'repasses nesta forma de pagto
                Total = distPM("Total")
                sql = "SELECT SUM(rr.Valor) Total FROM rateiorateios rr LEFT JOIN temp_fechamentodetalhado tf ON tf.ItemInvoiceID=rr.ItemInvoiceID LEFT JOIN itensdescontados idesc ON idesc.ItemID=tf.ItemInvoiceID LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID WHERE tf.DtExecucao="& mData &" AND tf.Executado='S' AND rr.ContaCredito LIKE '%\_%' AND tf.sysUser="& session("User") &" AND m.PaymentMethodID='"& distPM("PaymentMethodID") &"'"
                PaymentMethod = distPM("PaymentMethod")
                set rdistPM = db.execute( sql )
                rrValor = rdistPM("Total")
                    %>
                    <tr>
                        <td class="pl50"><%= PaymentMethod %></td>
                        <td class="text-right"><%= fn( Total ) %></td>
                        <td class="text-right"><%= fn( rrValor ) %></td>
                        <td class="text-right"><%= fn( Total - rrValor ) %></td>
                    </tr>
                    <%
        distPM.movenext
        wend
        distPM.close
        set distPM = nothing

        if PartePaga<tServicosExecutados then
            rrValor = 0
            Total=0

            sql = "SELECT SUM(rr.Valor) Total FROM rateiorateios rr LEFT JOIN temp_fechamentodetalhado tf ON tf.ItemInvoiceID=rr.ItemInvoiceID WHERE tf.DtExecucao="& mData &" AND tf.Executado='S' AND rr.ContaCredito LIKE '%\_%' AND tf.sysUser="& session("User") &" AND ISNULL(rr.ItemDescontadoID)"
            set pNaoPagoDtExec = db.execute("SELECT ItemInvoiceID, TotalFaturado, TotalPagoNaDataRelatorio FROM temp_fechamentodetalhado WHERE TotalPagoNaDataRelatorio<TotalFaturado AND DtExecucao="& mData)
            while not pNaoPagoDtExec.eof
                Total = pNaoPagoDtExec("TotalFaturado")-pNaoPagoDtExec("TotalPagoNaDataRelatorio")
                set rr = db.execute("SELECT SUM(rr.Valor) Valor FROM rateiorateios rr LEFT JOIN temp_fechamentodetalhado fd ON fd.ItemInvoiceID=rr.ItemInvoiceID WHERE rr.ItemDescontadoID=0 AND rr.ItemInvoiceID="& pNaoPagoDtExec("ItemInvoiceID") )
                rrValor = rrValor + rr("Valor")
            pNaoPagoDtExec.movenext
            wend
            pNaoPagoDtExec.close
            set pNaoPagoDtExec = nothing

            PaymentMethod = "Não pago na data de execução"
                %>
                <tr>
                    <td class="pl50"><%= PaymentMethod %></td>
                    <td class="text-right"><%= fn( Total ) %></td>
                    <td class="text-right"><%= fn( rrValor ) %></td>
                    <td class="text-right"><%= fn( Total - rrValor ) %></td>
                </tr>
                <%
        end if
        %>
        <tr class="rel" data-tipo="NaoExecutados" data-titulo="Serviços faturados não executados">
            <%
            '!!!!!SERVIÇOS NÃO EXECUTADOS!!!!!
            sql = "select sum(TotalFaturado) tServicosNaoExecutados from temp_fechamentodetalhado where DtFaturamento="& mData &" AND sysUser="& session("User") &" AND Executado='' "
               ' response.write( sql )
            set pserv = db.execute( sql )    
            tServicosNaoExecutados = pserv("tServicosNaoExecutados")
            sql = "SELECT SUM(rr.Valor) trServicosNaoExecutados FROM rateiorateios rr LEFT JOIN temp_fechamentodetalhado tf ON tf.ItemInvoiceID=rr.ItemInvoiceID WHERE tf.DtFaturamento="& mData &" AND tf.Executado='' AND rr.ContaCredito LIKE '%\_%' AND tf.sysUser="& session("User") &" AND tf.Executado='' "
               ' response.Write( sql )
            set prserv = db.execute( sql )
            trServicosNaoExecutados = prServ("trServicosNaoExecutados")
            %>

            <td>Serviços faturados não executados</td>
            <td class="text-right"><%= fn(tServicosNaoExecutados) %></td>
            <td class="text-right"><%= fn(trServicosNaoExecutados) %></td>
            <td class="text-right"><%= fn(tServicosNaoExecutados - trServicosNaoExecutados) %></td>
        </tr>
        <%
        PartePaga = 0
        sql = "SELECT pm.PaymentMethod, m.PaymentMethodID, SUM(idesc.Valor) Total FROM temp_fechamentodetalhado tf LEFT JOIN itensdescontados idesc ON idesc.ItemID=tf.ItemInvoiceID LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE tf.DtFaturamento="& mData &" AND tf.sysUser="& session("User") &" AND tf.Executado='' GROUP BY pm.id ORDER BY pm.id DESC"
        set distPM = db.execute( sql )
        while not distPM.eof
            PartePaga = PartePaga+distPM("Total")
            Total = distPM("Total")
            sql = "SELECT SUM(rr.Valor) Total FROM rateiorateios rr LEFT JOIN temp_fechamentodetalhado tf ON tf.ItemInvoiceID=rr.ItemInvoiceID LEFT JOIN itensdescontados idesc ON idesc.ItemID=tf.ItemInvoiceID LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID WHERE tf.DtFaturamento="& mData &" AND tf.Executado='' AND rr.ContaCredito LIKE '%\_%' AND tf.sysUser="& session("User") &" AND m.PaymentMethodID='"& distPM("PaymentMethodID") &"'"
            PaymentMethod = distPM("PaymentMethod")
            set rdistPM = db.execute( sql )
            rrValor = rdistPM("Total")
            %>
            <tr>
                <td class="pl50"><%= PaymentMethod %></td>
                <td class="text-right"><%= fn( Total ) %></td>
                <td class="text-right"><%= fn( rrValor ) %></td>
                <td class="text-right"><%= fn( Total - rrValor ) %></td>
            </tr>
            <%
        distPM.movenext
        wend
        distPM.close
        set distPM = nothing
        if PartePaga<tServicosNaoExecutados then
            rrValor = 0
            'sql = "SELECT SUM(rr.Valor) Total FROM rateiorateios rr LEFT JOIN temp_fechamentodetalhado tf ON tf.ItemInvoiceID=rr.ItemInvoiceID WHERE tf.DtFaturamento="& mData &" AND tf.Executado='' AND rr.ContaCredito LIKE '%\_%' AND tf.sysUser="& session("User") &" AND ISNULL(rr.ItemDescontadoID)"
            sql2 = "SELECT ItemInvoiceID, TotalFaturado, TotalPagoNaDataRelatorio FROM temp_fechamentodetalhado WHERE TotalPagoNaDataRelatorio<TotalFaturado AND Executado='' AND DtFaturamento="& mData

            set pNaoPagoDtExec = db.execute(sql2)
            while not pNaoPagoDtExec.eof
                TotalNaoPago = pNaoPagoDtExec("TotalFaturado")-pNaoPagoDtExec("TotalPagoNaDataRelatorio")
                set rr = db.execute("SELECT SUM(rr.Valor) Valor FROM rateiorateios rr LEFT JOIN temp_fechamentodetalhado fd ON fd.ItemInvoiceID=rr.ItemInvoiceID WHERE rr.ItemDescontadoID=0 AND rr.ItemInvoiceID="& pNaoPagoDtExec("ItemInvoiceID") )
                rrValor = rrValor + rr("Valor")
            pNaoPagoDtExec.movenext
            wend
            pNaoPagoDtExec.close
            set pNaoPagoDtExec = nothing
                        
            PaymentMethod = "Não pago na data do faturamento"
            %>
            <tr>
                <td class="pl50"><%= PaymentMethod %></td>
                <td class="text-right"><%= fn( TotalNaoPago-PartePaga ) %></td>
                <td class="text-right"><%= fn( rrValor ) %></td>
                <td class="text-right"><%= fn( Total - rrValor ) %></td>
            </tr>
            <%
        end if

        'NF
        set contaNFne = db.execute("select count(id) qtd from temp_fechamentodetalhado where NFnaoemitida=1 and sysUser="& session("user"))
        NFNaoEmitida = contaNFne("qtd")

        set somaNFok = db.execute("select sum(ValorNotasOk) TotalNFok from temp_fechamentodetalhado where sysUser="& session("User"))
        TotalNFok = somaNFok("TotalNFok")

        set somaNFbad = db.execute("select sum(ValorNotasBad) TotalNFbad from temp_fechamentodetalhado where sysUser="& session("User"))
        TotalNFbad = somaNFbad("TotalNFbad")
        %>
        <tr class="rel" data-tipo="NFNaoEmitida" data-titulo="NFSEs não emitidas">
            <td>NFSEs não emitidas</td>
            <td class="text-right"><%= NFNaoEmitida %></td>
        </tr>
        <tr class="rel" data-tipo="TotalNFOk" data-titulo="Valor em NFSEs emitidas com sucesso">
            <td>Valor em NFSEs emitidas com sucesso</td>
            <td class="text-right"><%= fn(TotalNFOk) %></td>
        </tr>
        <tr class="rel" data-tipo="TotalNFBad" data-titulo="Valor em NFSEs emitidas">
            <td>Valor em NFSEs emitidas com observações</td>
            <td class="text-right"><%= fn(TotalNFBad) %></td>
        </tr>
        <tr>
            <th colspan="3">FECHAMENTO</th>
        <%
        set entDC = db.execute("select ifnull(sum(Value),0) Valor from sys_financialmovement where not isnull(CaixaID) AND PaymentMethodID IN (1, 2) AND ((AccountAssociationIDDebit=7 AND AccountAssociationIDCredit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
        EntDinheiroCheque = entDC("Valor")
        'response.write("<br> Entradas em dinheiro: "& EntDinheiroCheque)
        set saiD = db.execute("select ifnull(sum(Value),0) Valor from sys_financialmovement where not isnull(CaixaID) AND ((AccountAssociationIDCredit=7 AND AccountAssociationIDDebit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
        SaiDinheiro = saiD("Valor")
        'response.write("<br> SaiDinheiro: "& SaiDinheiro)
        FechamentoCaixaCalculado = EntDinheiroCheque - SaiDinheiro
        'response.write("<br> FechamentoCaixaCalculado: "& FechamentoCaixaCalculado)
        %>
        </tr>
        <tr style="cursor:pointer" onclick="window.open('PrintStatement.asp?R=rRelatorioCaixa&Tipo=Diario&Data=<%= Data %>&UnidadeID=<%= UnidadeID %>')">
            <td>Fechamento de caixa calculado</td>
            <td class="text-right"><%= fn(FechamentoCaixaCalculado) %></td>
            <td class="text-right"></td>
        </tr>
        <%
        ValorFechamentoInformado = 0
        RecebimentosNaoExecutados = 0
        ValorCreditosUtilizados = 0
        RepasseDeOutrasDatas = 0
        RepassesNaoPagos = 0
        servicosNaoExecutados = 0
        vl4 = 0

        sql = "select fcx.CaixaID, fcx.Dinheiro Valor, ifnull(fcx.DinheiroInformado, 0) DinheiroInformado, fcx.Dinheiro Dinheiro, IFNULL(fcx.Credito, 0) Credito, IFNULL(fcx.Debito,0) Debito from caixa cx INNER JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID INNER join fechamentocaixa fcx on fcx.CaixaID=cx.id where cc.Empresa="& UnidadeID &" and cx.dtFechamento="& mData &" GROUP BY fcx.CaixaID"
            'response.write( sql )
        set l3 = db.execute(sql)

        Dinheiro = 0
        Credito = 0
        Debito = 0

        'ValorFechamento = 0
        if not l3.eof then
            while not l3.eof
                CaixaID = l3("CaixaID")

                Dinheiro = Dinheiro + l3("Dinheiro")
                Credito = Credito + l3("Credito")
                Debito = Debito + l3("Debito")
                ValorFechamentoInformado = ValorFechamentoInformado + l3("DinheiroInformado")

                sqlNaoPago="SELECT sum(Value-IFNULL(ValorPago, 0)) ValorAberto FROM sys_financialmovement WHERE (ValorPago < Value or ValorPago IS NULL) AND CaixaID="&CaixaID&" AND CD='C' AND Type='Bill'"
                if session("User")=81920 then
                    'response.Write("<br>"& sqlNaoPago &"<br>")
                end if

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
        %>















<%

UnidadeID = req("U")
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


set entDC = db.execute("select sum(Value) Valor from sys_financialmovement where not isnull(CaixaID) AND PaymentMethodID IN (1, 2) AND ((AccountAssociationIDDebit=7 AND AccountAssociationIDCredit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
EntDinheiroCheque = entDC("Valor")
'response.write("<br> Entradas em dinheiro: "& EntDinheiroCheque)
set saiD = db.execute("select sum(Value) Valor from sys_financialmovement where not isnull(CaixaID) AND ((AccountAssociationIDCredit=7 AND AccountAssociationIDDebit NOT IN(1, 7)) ) and Date="& mData &" and UnidadeID="& treatvalzero(UnidadeID) &"")
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
    'response.write(sql)
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
        if session("User")=81920 then
            'response.Write("<br>"& sqlNaoPago &"<br>")
        end if

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
set pDesp = db.execute("select sum(m.Value) Despesas FROM sys_financialmovement m WHERE m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit NOT IN(1,7) AND NOT ISNULL(m.CaixaID) AND m.Date="& mData &" AND m.Type='Pay' AND m.UnidadeID="& UnidadeID &"")
Despesas = pDesp("Despesas")

set pDespTrans = db.execute("select sum(m.Value) Despesas FROM sys_financialmovement m WHERE m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit NOT IN(1,7) AND NOT ISNULL(m.CaixaID) AND m.Date="& mData &" AND m.Type='Transfer' AND m.UnidadeID="& UnidadeID &"")
Transferencias = pDespTrans("Despesas")

sql = "SELECT sum(ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo)) Valor FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE "& filtroData("i.sysDate") &" AND i.CD='C' AND i.CompanyUnitID="& UnidadeID &" AND ii.Tipo='S' AND ii.Executado = ''"
'response.write(sql)
set ServicosNaoExecutadosSQL = db.execute(sql)

if not ServicosNaoExecutadosSQL.eof then
    if not isnull(ServicosNaoExecutadosSQL("Valor")) then
        servicosNaoExecutados=ServicosNaoExecutadosSQL("Valor")
    end if
end if



sqlDebitoECredito = "select idesc.id ItemDescontadoID, m.PaymentMethodID, ii.id ItemInvoiceID, ii.InvoiceID, ii.DataExecucao, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, ii.Quantidade, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal, idesc.Valor ValorDescontado FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN itensdescontados idesc ON idesc.ItemID=ii.id LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID WHERE "& filtroData("ii.DataExecucao") &" AND i.CompanyUnitID="& UnidadeID &" AND ii.Executado='S' AND m.PaymentMethodID IN (8,9) ORDER BY ii.DataExecucao"
set RecebimentosDebitoECreditoSQL= db.execute(sqlDebitoECredito)
TotalCredito = 0
TotalDebito = 0
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

    ValorLiquido = RecebimentosDebitoECreditoSQL("ValorTotal")-TotalRepasse

    RepasseCartao = RepasseCartao + TotalRepasse

    if RecebimentosDebitoECreditoSQL("PaymentMethodID")=8 then
        TotalCredito= TotalCredito +ValorLiquido
    elseif RecebimentosDebitoECreditoSQL("PaymentMethodID")=9 then
        TotalDebito= TotalDebito +ValorLiquido
    end if
RecebimentosDebitoECreditoSQL.movenext
wend
RecebimentosDebitoECreditoSQL.close
set RecebimentosDebitoECreditoSQL=nothing

'    response.Write( RepasseCartao )

'7 + 6 + 10 + 12 - 11 + 13
    'response.Write(TotalCredito)
'3.1 + 6 + 7 + 9 + 10 - 11 + 12 - 13

ResultadoFinal = ValorFechamentoInformado + TotalCredito + TotalDebito + RecebimentosNaoExecutados + ValorCreditosUtilizados - RepassesNaoPagos + RepasseDeOutrasDatas - servicosNaoExecutados


TotalDiferenca=  ValorCreditosUtilizados + RepasseDeOutrasDatas - RepassesNaoPagos - servicosNaoExecutados - RecebimentosNaoExecutados

vl2 = (l1("Valor")+entCDeb+entCCred)  - Despesas - Transferencias - RepasseCartao + RepasseDeOutrasDatas + RecebimentosNaoExecutados - RepassesNaoPagos

if true then
    'producao p grupo
    set vval = db.execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID INNER JOIN procedimentos proc ON proc.id=ii.ItemID WHERE  ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &")")
    sqlRep = "select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID INNER JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& UnidadeID &") AND ContaCredito LIKE '%\_%'"
    set vrep = db.execute( sqlRep )
    Valor = ccur(vval("Valor"))
    Repasses = ccur(vrep("Repasses"))
    ValorLiquido = Valor - Repasses

    vl2=ValorLiquido
end if

ResultadoFinal= ResultadoFinal - vl2

%>
        <tr data-tipo="FCaixaInfo" style="cursor:pointer" onclick="window.open('PrintStatement.asp?R=rRelatorioCaixa&Tipo=Diario&Data=<%= Data %>&UnidadeID=<%= UnidadeID %>')">
            <td>(-) Fechamento de caixa informado</td>
            <td class="text-right"><%= fn(ValorFechamentoInformado) %></td>
            <td class="text-right"></td>
        </tr>
        <tr>
            <td>Diferença de Caixas</td>
            <td class="text-right"><%= fn(ValorFechamentoInformado - FechamentoCaixaCalculado) %></td>
        </tr>
        <tr>
            <th colspan="3">DETALHAMENTO</th>
        </tr>
        <tr class="linha-fechamento" data-id="5">
            <td>Entradas em dinheiro</td>
            <td class="text-right"><%= fn(EntDinheiroCheque) %></td>
            <td class="text-right"></td>
        </tr>
        <tr class="linha-fechamento" data-id="6">
            <td>Entradas em cartão de crédito</td>
            <td class="text-right"><%= fn(TotalCredito) %></td>
            <td class="text-right"></td>
        </tr>
        <tr class="linha-fechamento" data-id="7">
            <td>Entradas em cartão de débito</td>
            <td class="text-right"><%= fn(TotalDebito) %></td>
            <td class="text-right"></td>
        </tr>
        <tr class="hidden">
            <td>Entradas não associadas a itens contratados</td>
            <td class="text-right">NaN</td>
            <td class="text-right"></td>
        </tr>
        <tr class="hidden">
            <td>Serviços recebidos com caixinha fechado</td>
            <td class="text-right">NaN</td>
            <td class="text-right"></td>
        </tr>
        <tr class="linha-fechamento" data-id="8">
            <td>Despesas de caxinha</td>
            <td class="text-right"><%= fn(Despesas) %></td>
            <td class="text-right"></td>
        </tr>

        <tr class="linha-fechamento" data-id="14">
            <td>Transferencias</td>
            <td class="text-right"><%= fn(Transferencias) %></td>
            <td class="text-right"></td>
        </tr>


        <tr class="hidden">
            <td>Agendamentos não faturados</td>
            <td class="text-right">NaN</td>
            <td class="text-right"></td>
        </tr>
        <tr class="linha-fechamento" data-id="9">
            <td>Serviços não recebidos</td>
            <td class="text-right"><%= fn(RecebimentosNaoExecutados) %></td>
            <td class="text-right"></td>
        </tr>
        <tr class="linha-fechamento" data-id="10">
            <td>Utilização de saldo de paciente</td>
            <td class="text-right"><%= fn(ValorCreditosUtilizados) %></td>
            <td class="text-right"></td>
        </tr>
        <tr class="linha-fechamento" data-id="11">
            <td>Repasses não pagos na data de execução</td>
            <td class="text-right"><%= fn(RepassesNaoPagos) %></td>
            <td class="text-right"></td>
        </tr>
        <tr class="linha-fechamento" data-id="12">
            <td>Repasses pagos de outras datas</td>
            <td class="text-right"><%= fn(RepasseDeOutrasDatas) %></td>
            <td class="text-right"></td>
        </tr>
    </table>
</div>

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


<script type="text/javascript">
    $(".rel").click(function () {
        window.open("PrintStatement.asp?R=FechamentoDetalhado&Det=1&L="+ $(this).attr('data-tipo') +"&T="+ $(this).attr('data-titulo') );
    });

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

            $modal.find(".modal-body").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)

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

