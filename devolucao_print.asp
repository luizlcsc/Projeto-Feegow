<!--#include file="connect.asp"-->
<!--#include file="extenso.asp"-->
<style type="text/css">
    @media print {
        .pagebreak { display: block; page-break-after: always; }
    }
</style>

<% 
InvoiceID = req("InvoiceID")

sqlDevolucao = "select d.id as iddevolucao, totalDevolucao, Motivo, observacao, debitarCaixa , Nome, d.sysDate, tipoOperacao,  invoiceAPagarID,  IF(tipoOperacao = 1,'Devolver (Dinheiro)', 'Deixar de Crédito') op  from devolucoes d inner join motivo_devolucao md ON md.id = d.motivoDevolucaoID " &_ 
                " INNER JOIN cliniccentral.licencasusuarios u ON u.id = d.sysUser " &_
                " WHERE d.invoiceID = " & InvoiceID & " and d.sysActive = 1 "
set rsDevolucao = db.execute(sqlDevolucao)

if not rsDevolucao.eof then 
%>
  <h2>Devolução da conta</h2>
    <p><b>Valor devolução: </b>R$ <%=fn(ccur(rsDevolucao("totalDevolucao")))%></p> 
    <p><b>Motivo: </b><%=rsDevolucao("Motivo")%></p> 
    <p><b>Tipo de operação: </b><%= rsDevolucao("op")%></p> 
    <p><b>Observação: </b><%= rsDevolucao("observacao")%></p> 
    <% if rsDevolucao("debitarCaixa") = 1 then %>
        <p><b>Valor debitado do caixa</b></p>
    <% end if %>
    <p><b>Usuário: </b><%=rsDevolucao("Nome")%></p> 
    <p><b>Data devolução: </b><%=rsDevolucao("sysDate")%></p> 
<%

sqlItensDevolucao = "SELECT ValorUnitario, Desconto, NomeProcedimento  FROM devolucoes_itens di INNER JOIN itensinvoice ii ON di.itensInvoiceID = ii.id INNER JOIN procedimentos p ON ii.ItemID = p.id " &_ 
            " where di.devolucoesID = " & rsDevolucao("iddevolucao")
set rsItensDevolucao = db.execute(sqlItensDevolucao)
if not rsItensDevolucao.eof  then 
%>
<table>
    <tr>
    <th>PROCEDIMENTO</th>
    <th>VALOR</th>
    <th>DESCONTO</th>
    </tr>
<%
while not rsItensDevolucao.eof 
%>
    <tr>
        <td><%=rsItensDevolucao("NomeProcedimento") %></td>
        <td><%=fn(rsItensDevolucao("ValorUnitario")) %></td>
        <td><%=fn(rsItensDevolucao("Desconto")) %></td>
    </tr>
<%
rsItensDevolucao.movenext
wend
%>
</table>
<%
end if
end if
%>
<script>

    print();


</script>