<!--#include file="connect.asp"-->
<%
LinhaID = req("LinhaID")
Data = req("Data")
Caixas = req("Caixas")
UnidadeID = req("UnidadeID")

%>
<table class="table table-striped">
    <%

if LinhaID=6 or LinhaID=7 or LinhaID=5 or LinhaID=4 then

    %>
<thead>
    <tr>
        <th>Paciente</th>
        <th>DataHora</th>
        <th>Procedimento</th>
        <th>Valor</th>
        <th>Valor liquido</th>
        <th>#</th>
    </tr>
</thead>
<tbody>
    <%

if LinhaID=6 then
    FormaPagamentoID="8"
elseif LinhaID=5 then
    FormaPagamentoID="1"
elseif LinhaID=4 then
    FormaPagamentoID="15,7,5,6"
elseif LinhaID=7 then
    FormaPagamentoID="9"
end if

sqlDebitoECredito = "select idesc.id ItemDescontadoID, m.sysDate, m.PaymentMethodID, ii.id ItemInvoiceID, ii.InvoiceID, ii.DataExecucao, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, pac.NomePaciente, pac.id PacienteID, ii.Quantidade, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal, idesc.Valor ValorDescontado FROM itensinvoice ii INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID   LEFT JOIN pacientes pac ON (pac.id=i.AccountID AND i.AssociationAccountID=3) INNER JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN itensdescontados idesc ON idesc.ItemID=ii.id LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID WHERE ii.DataExecucao = "& mydatenull(Data) &" AND i.CompanyUnitID="& UnidadeID &" AND ii.Executado='S' AND m.PaymentMethodID IN ("&FormaPagamentoID&") ORDER BY ii.DataExecucao"
' dd(sqlDebitoECredito)
set RecebimentosDebitoECreditoSQL= db.execute(sqlDebitoECredito)
TotalCredito = 0
TotalDebito = 0
ValorTotal = 0
ValorTotalLiquido=0

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

    ValorTotal= ValorTotal+RecebimentosDebitoECreditoSQL("ValorDescontado")
    ValorLiquido = RecebimentosDebitoECreditoSQL("ValorDescontado")-TotalRepasse

    ValorTotalLiquido = ValorTotalLiquido+ ValorLiquido

    if RecebimentosDebitoECreditoSQL("PaymentMethodID")=8 then
        TotalCredito= TotalCredito +ValorLiquido
    elseif RecebimentosDebitoECreditoSQL("PaymentMethodID")=9 then
        TotalDebito= TotalDebito +ValorLiquido
    end if
    %>
<tr>
    <td><a target="_blank" href="./?P=Pacientes&Pers=1&I=<%=RecebimentosDebitoECreditoSQL("PacienteID")%>"><%=RecebimentosDebitoECreditoSQL("NomePaciente")%></a></td>
    <td><%=RecebimentosDebitoECreditoSQL("sysDate")%></td>
    <td><%=RecebimentosDebitoECreditoSQL("NomeProcedimento")%></td>
    <td><%=fn(RecebimentosDebitoECreditoSQL("ValorDescontado"))%></td>
    <td><%=fn(ValorLiquido)%></td>
    <td><a href="./?P=invoice&I=<%=RecebimentosDebitoECreditoSQL("InvoiceID")%>&A=&Pers=1&T=C&Ent=" target="_blank" class="btn btn-primary btn-xs"><i class="far fa-external-link"></i></a></td>
</tr>
    <%

RecebimentosDebitoECreditoSQL.movenext
wend
RecebimentosDebitoECreditoSQL.close
set RecebimentosDebitoECreditoSQL=nothing

    %>
</tbody>
<tfoot>
<tr>
    <td colspan="3"></td>
    <th><%=fn(ValorTotal)%></th>
    <th><%=fn(ValorTotalLiquido)%></th>
    <th></th>
</tr>
</tfoot>
    <%
elseif LinhaID=13 then

      '  SELECT ii.id, ii.InvoiceID,(ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo)) Valor FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE (DATE(i.sysDate)='2018-12-19') AND i.CD='C' AND i.CompanyUnitID=7 AND ii.Tipo='S' AND ii.Executado = ''

sql = "SELECT ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo) Valor, pac.NomePaciente, ii.InvoiceID, proc.NomeProcedimento, i.sysDate FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN pacientes pac ON (pac.id=i.AccountID AND i.AssociationAccountID=3) LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE i.sysDate = "& mydatenull(Data) &" AND i.CD='C' AND i.CompanyUnitID="& UnidadeID &" AND ii.Tipo='S' AND ii.Executado = ''"
set ServicosNaoExecutadosSQL = db.execute(sql)

    %>
<thead>
    <tr class="info">
        <th>Paciente</th>
        <th>Data</th>
        <th>Procedimento</th>
        <th>Valor</th>
        <th>#</th>
    </tr>
</thead>
<tbody>
    <%

while not ServicosNaoExecutadosSQL.eof
    servicosNaoExecutados=ServicosNaoExecutadosSQL("Valor")


    %>
<tr>
    <td><%=ServicosNaoExecutadosSQL("NomePaciente")%></td>
    <td><%=ServicosNaoExecutadosSQL("sysDate")%></td>
    <td><%=ServicosNaoExecutadosSQL("NomeProcedimento")%></td>
    <td><%=fn(ServicosNaoExecutadosSQL("Valor"))%></td>
    <td><a href="./?P=invoice&I=<%=ServicosNaoExecutadosSQL("InvoiceID")%>&A=&Pers=1&T=C&Ent=" target="_blank" class="btn btn-primary btn-xs"><i class="far fa-external-link"></i></a></td>
</tr>
    <%
ServicosNaoExecutadosSQL.movenext
wend
ServicosNaoExecutadosSQL.close
set ServicosNaoExecutadosSQL=nothing
%>
</tbody>
<%

elseif LinhaID=14 then

      '  SELECT ii.id, ii.InvoiceID,(ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo)) Valor FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE (DATE(i.sysDate)='2018-12-19') AND i.CD='C' AND i.CompanyUnitID=7 AND ii.Tipo='S' AND ii.Executado = ''

sql = "SELECT i.id InvoiceID, IFNULl(ii.Quantidade * (ii.ValorUnitario - ii.Desconto + ii.Acrescimo),d.totalDevolucao) TotalDevolucao, pac.NomePaciente, proc.NomeProcedimento, d.sysDate DataDevolucao FROM devolucoes d INNER JOIN devolucoes_itens di ON di.devolucoesID=d.id LEFT JOIN itensinvoice ii ON ii.id=di.itensInvoiceID LEFT JOIN procedimentos proc on proc.id=ii.ItemID INNER JOIN sys_financialinvoices i ON i.id=d.invoiceID INNER JOIN pacientes pac ON pac.id=i.AccountID and i.AssociationAccountID=3 WHERE date(d.sysDate)="&mydatenull(Data)&" AND i.CD='C' AND i.CompanyUnitID="& UnidadeID &" AND (ii.Tipo='S' AND ii.Executado = 'C' or ii.id is null) AND d.sysActive=1"
set DevolucoesSQL = db.execute(sql)

    %>
<thead>
    <tr class="info">
        <th>Paciente</th>
        <th>Data</th>
        <th>Procedimento</th>
        <th>Valor</th>
        <th>#</th>
    </tr>
</thead>
<tbody>
    <%

while not DevolucoesSQL.eof
    %>
<tr>
    <td><%=DevolucoesSQL("NomePaciente")%></td>
    <td><%=DevolucoesSQL("DataDevolucao")%></td>
    <td><%=DevolucoesSQL("NomeProcedimento")%></td>
    <td><%=fn(ccur(DevolucoesSQL("TotalDevolucao")))%></td>
    <td><a href="./?P=invoice&I=<%=DevolucoesSQL("InvoiceID")%>&A=&Pers=1&T=C&Ent=" target="_blank" class="btn btn-primary btn-xs"><i class="far fa-external-link"></i></a></td>
</tr>
    <%
DevolucoesSQL.movenext
wend
DevolucoesSQL.close
set DevolucoesSQL=nothing
%>
</tbody>
<%

elseif LinhaID=11 or LinhaID=12 then


sqlRepasseOutrosDias="SELECT idesc.PagamentoID,ii.InvoiceID, mov.AccountIDDebit,mov.Value ValorPagamento, i.sysDate,  mov.Date DataPagamento,  "&_
                      "round(rat.Valor) ValorRepasse, ii.DataExecucao, rat.ContaCredito, (CASE "&_
                      "when mov.Date is null then 'NaoPago' "&_
                      "when ii.DataExecucao <> mov.Date AND ii.DataExecucao="& mydatenull(Data) &" then 'NaoPago' "&_
                      "when ii.DataExecucao < mov.Date then 'DataDiferente' "&_
                      "end )Motivo, pac.NomePaciente, proc.NomeProcedimento "&_
                      " "&_
                      " FROM rateiorateios rat  "&_
                      " "&_
                      "INNER JOIN itensinvoice ii ON ii.id=rat.ItemInvoiceID "&_
                      "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                      "LEFT JOIN pacientes pac ON (pac.id=i.AccountID AND i.AssociationAccountID=3) INNER JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                      "LEFT JOIN itensdescontados idesc ON rat.ItemContaAPagar=idesc.ItemID "&_
                      "LEFT JOIN sys_financialmovement mov  ON idesc.PagamentoID=mov.id "&_
                      " "&_
                            "LEFT JOIN itensdescontados idescrr ON idescrr.id=rat.ItemDescontadoID "&_
 		                    "LEFT JOIN sys_financialmovement midesc ON midesc.id=idescrr.PagamentoID "&_
                      "WHERE ( "&_
                      "(ii.DataExecucao="& mydatenull(Data) &" and mov.Value is null)  "&_
                      " "&_
                      "or  "&_
                      "(ii.DataExecucao < mov.Date AND mov.Date="&mydatenull(Data)&") "&_
                          "or  "&_
                          "(ii.DataExecucao="& mydatenull(Data) &") "&_
                      " "&_
                      ") "&_
                      "AND i.CompanyUnitID="&UnidadeID&" "&_
                      "AND (rat.ContaCredito NOT IN ('0', '0_0')) "&_
                            "AND midesc.PaymentMethodID NOT IN(8,9) "&_
                      " "
set RepassesDiferentesSQL = db.execute(sqlRepasseOutrosDias )
 %>
<thead>
    <tr class="info">
        <th>Executante</th>
        <th>Paciente</th>
        <th>Data</th>
        <th>Procedimento</th>
        <th>Valor pendente</th>
        <th>#</th>
    </tr>
</thead>
<tbody>
    <%
if not RepassesDiferentesSQL.eof then

    while not RepassesDiferentesSQL.eof
        MostraLinha=False

        if RepassesDiferentesSQL("Motivo")="NaoPago" and LinhaID=11 then
            MostraLinha=True
        elseif RepassesDiferentesSQL("Motivo")="DataDiferente" and LinhaID=12 then
            MostraLinha=True
        end if

        if RepassesDiferentesSQL("ValorRepasse")<=0 then
            MostraLinha=False
        end if

        if instr(RepassesDiferentesSQL("ContaCredito"), "_") then

        spltConta = split(RepassesDiferentesSQL("ContaCredito"), "_")

        name = accountName(spltConta(0), spltConta(1))

        if MostraLinha then
        %>
        <tr>
            <td><%=name%></td>
            <td><%=RepassesDiferentesSQL("NomePaciente")%></td>
            <td><%=RepassesDiferentesSQL("sysDate")%></td>
            <td><%=RepassesDiferentesSQL("NomeProcedimento")%></td>
            <td><%=fn(RepassesDiferentesSQL("ValorRepasse"))%></td>
            <td><a href="./?P=invoice&I=<%=RepassesDiferentesSQL("InvoiceID")%>&A=&Pers=1&T=C&Ent=" target="_blank" class="btn btn-primary btn-xs"><i class="far fa-external-link"></i></a></td>
        </tr>
            <%
        end if
        end if
    RepassesDiferentesSQL.movenext
    wend
    RepassesDiferentesSQL.close
    set RepassesDiferentesSQL=nothing
end if
%>
</tbody>
<%

elseif LinhaID=9 then

%>

<thead>
    <tr class="info">
        <th>Paciente</th>
        <th>Valor Total</th>
        <th>Valor pendente</th>
        <th>Procedimento</th>
        <th>Data</th>
        <th>#</th>
    </tr>
</thead>
<tbody>
<%
sqlNaoPago="SELECT mov.InvoiceID, mov.Value ValorTotal, mov.Date, mov.Value-IFNULL(mov.ValorPago, 0) ValorAberto, pac.NomePaciente, proc.NomeProcedimento FROM sys_financialmovement mov "&_
"LEFT JOIN sys_financialinvoices i ON i.id=mov.InvoiceID LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id LEFT JOIN pacientes pac ON (pac.id=i.AccountID AND i.AssociationAccountID=3) LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
"WHERE (mov.ValorPago < mov.Value or mov.ValorPago IS NULL) AND mov.CaixaID IN ("&Caixas&") AND mov.CD='C' AND mov.Type='Bill' "

sqlNaoPago= sqlNaoPago&" UNION ALL SELECT mov.InvoiceID, mov.Value ValorTotal, mov.Date, mov.Value-IFNULL(mov.ValorPago, 0) ValorAberto, pac.NomePaciente, proc.NomeProcedimento FROM sys_financialmovement mov "&_
"LEFT JOIN sys_financialinvoices i ON i.id=mov.InvoiceID LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id LEFT JOIN pacientes pac ON (pac.id=i.AccountID AND i.AssociationAccountID=3) LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
"WHERE (mov.ValorPago < mov.Value or mov.ValorPago IS NULL) AND mov.UnidadeID="&UnidadeID&" AND mov.CaixaID IS NULL AND mov.Date="&mydatenull(Data)&" AND mov.CD='C' AND mov.Type='Bill' "

'sqlNaoPago="SELECT sum(Value-IFNULL(ValorPago, 0)) ValorAberto FROM sys_financialmovement WHERE (ValorPago < Value or ValorPago IS NULL) AND CaixaID="&CaixaID&" AND CD='C' AND Type='Bill'"

set MovementsNaoPagasSQL = db.execute(sqlNaoPago )
while not MovementsNaoPagasSQL.eof
    %>
<tr>
    <td><%=MovementsNaoPagasSQL("NomePaciente")%></td>
    <td><%=fn(MovementsNaoPagasSQL("ValorTotal"))%></td>
    <td><%=fn(MovementsNaoPagasSQL("ValorAberto"))%></td>
    <td><%=MovementsNaoPagasSQL("NomeProcedimento")%></td>
    <td><%=MovementsNaoPagasSQL("Date")%></td>
    <td><a href="./?P=invoice&I=<%=MovementsNaoPagasSQL("InvoiceID")%>&A=&Pers=1&T=C&Ent=" target="_blank" class="btn btn-primary btn-xs"><i class="far fa-external-link"></i></a></td>
</tr>
    <%
MovementsNaoPagasSQL.movenext
wend
MovementsNaoPagasSQL.close
set MovementsNaoPagasSQL=nothing
%>
</tbody>
<%


elseif LinhaID="8.1" or LinhaID="8.2" then

%>

<thead>
    <tr class="info">
        <th>Conta</th>
        <th>Data</th>
        <th>Usuário</th>
        <th>Valor Total</th>
    </tr>
</thead>
<tbody>
<%
sqlAccount = ""
if LinhaID="8.1" then
    sqlAccount = " AND m.AccountAssociationIDDebit=5"
else
    sqlAccount = " AND m.AccountAssociationIDDebit!=5"
end if

sqlDespesas = "select m.sysUser, m.Value, m.AccountAssociationIDDebit, m.AccountIDDebit, m.Date FROM sys_financialmovement m "&_
"WHERE m.AccountAssociationIDCredit=7 "&sqlAccount&"  AND m.AccountAssociationIDDebit NOT IN(1,7) AND NOT ISNULL(m.CaixaID) AND m.Date="& mydatenull(Data) &" AND m.Type='Pay' AND m.UnidadeID="& UnidadeID &""

set DespesasSQL = db.execute(sqlDespesas )

ValorTotal=0

while not DespesasSQL.eof

        name = accountName(DespesasSQL("AccountAssociationIDDebit"), DespesasSQL("AccountIDDebit"))

        ValorTotal = ValorTotal + DespesasSQL("Value")
    %>
<tr>
    <td><%=name%></td>
    <td><%=DespesasSQL("Date")%></td>
    <td><%=nameInTable(DespesasSQL("sysUser"))%></td>
    <td><%=fn(DespesasSQL("Value"))%></td>
</tr>
    <%
DespesasSQL.movenext
wend
DespesasSQL.close
set DespesasSQL=nothing
%>
</tbody>
<tfoot>
<tr>
    <td colspan="3"></td>
    <th><%=fn(ValorTotal)%></th>
</tr>
</tfoot>
<%

end if
    %>
</table>
<%
%>