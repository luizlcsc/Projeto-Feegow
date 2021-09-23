<!--#include file="connect.asp"-->
<style>
.card {
  /* Add shadows to create the "card" effect */
  box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
  transition: 0.3s;
}

/* On mouse-over, add a deeper shadow */
.card:hover {
  box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2);
}

/* Add some padding inside the card container */
.container {
  padding: 2px 16px;
}
.card {
  box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
  transition: 0.3s;
  border-radius: 5px; /* 5px rounded corners */
}
</style>
<%
'Não gerar devolução se tiver REPASSE GERADO E/OU NOTA FISCAL GERADA
InvoiceID = req("InvoiceID")
accountId = req("accountId")
%>
<script>
$(function(){

    function ler(data){
        
    }

    $(".recibocancelamento").on('click', function(){
        let url = "devolucao_print.asp?InvoiceID=<%=InvoiceID%>";

        $("<iframe>")                             // create a new iframe element
            .hide()                              // make it invisible
            .attr("src", url)                    // point the iframe to the page you want to print
            .appendTo("body");
    });

})
</script>
<%
'Validar se ja existe devolução
sqlDevolucao = "select totalDevolucao, Motivo, observacao, debitarCaixa , Nome, d.sysDate, tipoOperacao,  invoiceAPagarID,  IF(tipoOperacao = 1,'Devolver (Dinheiro)', 'Deixar de Crédito') op  from devolucoes d inner join motivo_devolucao md ON md.id = d.motivoDevolucaoID " &_ 
                " INNER JOIN cliniccentral.licencasusuarios u ON u.id = d.sysUser " &_
                " WHERE d.invoiceID = " & InvoiceID & " and d.sysActive = 1 "

set rsDevolucao = db.execute(sqlDevolucao)

if not rsDevolucao.eof then 
%>

  <div class="container">
    <p><b>Valor devolução: </b>R$ <%=fn(ccur(rsDevolucao("totalDevolucao")))%></p> 
    <p><b>Motivo: </b><%=rsDevolucao("Motivo")%></p> 
    <p><b>Tipo de operação: </b><%= rsDevolucao("op")%></p> 
    <p><b>Observação: </b><%= rsDevolucao("observacao")%></p> 
    <% if rsDevolucao("debitarCaixa") = 1 then %>
        <p><b>Valor debitado do caixa</b></p>
    <% end if %>
    <p><b>Usuário: </b><%=rsDevolucao("Nome")%></p> 
    <p><b>Data devolução: </b><%=rsDevolucao("sysDate")%></p> 
    <% if rsDevolucao("tipoOperacao") = "1" and not isnull(rsDevolucao("invoiceAPagarID")) then %>
    <a href="?P=invoice&I=<%=rsDevolucao("invoiceAPagarID")%>&A=&Pers=1&T=D" target="_blank" class="btn btn-sm  btn-primary">Ver Contas a Pagar</a>
    <% end if %>
    <a href="#" class="btn btn-danger btn-sm recibocancelamento"><i class="far fa-print"></i> Gerar Recibo de Cancelamento</a>
  </div>

<%
response.end()
end if

sqlTipoOperacao = "select 1 id, 'Devolver' descricao UNION select 0 id, 'Deixar de Crédito' descricao "

sqlTemCredito = "SELECT count(fp.PaymentMethod)  total FROM sys_financialinvoices iv " &_
                "INNER JOIN sys_financialmovement mov ON mov.InvoiceID = iv.id  " &_
                "INNER JOIN sys_financialpaymentmethod fp ON fp.id = mov.PaymentMethodID " &_
                "WHERE " &_
                "mov.InvoiceID IN (" & InvoiceID & ") AND (fp.PaymentMethod LIKE '%crédito%' OR fp.PaymentMethod LIKE '%credito%')  "
set queryTemCredito = db.execute(sqlTemCredito)

if not queryTemCredito.eof then 
    if ccur(queryTemCredito("total")) > 0 and 1=1 then 
        sqlTipoOperacao = sqlTipoOperacao & " UNION select 2 id, 'Estorno Cartão' descricao "
    end if
end if

%>
<%

 if Session("CaixaID")&"" <> "" or aut("movementI") = 1 then 

 %>
<form id="formdevolucao">
<div class="row">
    <%=quickField("selectRadio", "TipoOperacao", "Tipo de operação", 4, "", sqlTipoOperacao, "descricao", " required ")%>
    
    <% if aut("movementI") = 1 and Session("CaixaID")&"" = "" then %>
    <div id="contasaida" style="display: none">
        <%=quickField("selectRadio", "ContaID", "Conta de Saida", 4, "", "SELECT id, AccountName FROM sys_financialcurrentaccounts WHERE (AccountType = 1 or AccountType = 2) AND sysActive = 1 AND Ativo = 'on' and Empresa = " & Session("UnidadeID"), "AccountName", " required ")%>
    </div> 
    <% end if %>

    <%=quickField("selectRadio", "MotivoDevolucao", "Motivo da devolução<br>", 4, "", "select * from motivo_devolucao where sysActive = 1 order by id", "Motivo", " required ")%>
    <%=quickField("memo", "Observacao", "Observação", 12, "", "", "", "") %>
</div>
<%
'ii.Executado != 'S' AND
sql = "select SUM(idesc.Valor) ValorDescontado, p.NomeProcedimento, ii.Desconto, ii.Acrescimo, ii.ValorUnitario, ii.id as iditensinvoice from sys_financialinvoices invoice inner join itensinvoice ii on ii.InvoiceID = invoice.id inner join itensdescontados idesc ON idesc.ItemID=ii.id inner join procedimentos p ON p.id = ii.ItemID where  invoice.id = " & InvoiceID & " GROUP BY ii.id ORDER BY ii.id ASC"
'response.write(sql)
set queryInvoice = db.execute(sql)

if not queryInvoice.eof then
%>
<div class="row">
    <div class="col-md-12">
        <hr class="short alt" />
    </div>

    <div class="col-md-12">
    <table class="table table-condensed ">
        <tr class="primary">
            <th></th>
            <th>Item</th>
            <th>Valor do item</th>
            <th>Valor pago</th>
            <th>Desconto</th>
            <th>Acréscimo</th>
        </tr>
    <%
        while not queryInvoice.eof
    %>
        <tr>
            <td><input type="checkbox" name="iteninvoice" class="iteninvoice" value="<%=queryInvoice("iditensinvoice")%>"></td>
            <td><%=queryInvoice("NomeProcedimento") %></td>
            <td><%=fn(queryInvoice("ValorUnitario")) %></td>
            <td><%=fn(queryInvoice("ValorDescontado")) %></td>
            <td><%=fn(queryInvoice("Desconto")) %></td>
            <td><%=fn(queryInvoice("Acrescimo")) %></td>
        </tr>
    <%
            queryInvoice.movenext
        wend
    %>
    </table>
    </div>

    </div>

    <div class="row mt15">
        <div class="col-md-12">
            <div class="pull-right">
                <button type="button" class="btn btn-danger devolucao"><i class="far fa-times"></i> Gerar Devolução</button>
            </div>
        </div>
    </div>
</form>
<%
end if

else 
%>
<div class="alert alert-warning">
    É necessário manter o caixa aberto para gerar devolução ao paciente
</div>

<% end if %>
<script>
$(function(){

    $("input[name='TipoOperacao']").on('change', function(){
        var tipoOp = $(this).val();
        $("#contasaida").hide();

        if(tipoOp == 1){
            $("#contasaida").show();
        }
    });

    $(".devolucao").on('click', function(){
        var itensinvoiceid = "";

        $(".iteninvoice:checked").each((i, val) => {
            itensinvoiceid += val.value + ","
        })

        var tipoOperacao = $("input[name='TipoOperacao']:checked").val();
        var motivoDevolucao = $("input[name='MotivoDevolucao']:checked").val();
        var Observacao = $("#Observacao").val();
        

        if( itensinvoiceid == "" || motivoDevolucao == undefined || tipoOperacao == undefined || Observacao.length < 5 ){
            new PNotify({ title: 'Preencha todos os campos', type: 'danger', delay: 1000 });
            return false;
        }

        var operacao = function(){
            $.ajax({
                type:"POST",
                url:"devolucao_motivo.asp?InvoiceID=<%=InvoiceID%>&accountId=<%=accountId%>",
                data:$("#formdevolucao").serialize(),
                success:function(data){
                    $("#modal-components .modal-body").html(data);
                }
            });
        }

        if(tipoOperacao == 2){
            //chamar a API do Ze
            $.ajax({
                type:"POST",
                url:"devolucao_motivo.asp?InvoiceID=<%=InvoiceID%>&accountId=<%=accountId%>",
                data:$("#formdevolucao").serialize(),
                success:function(result){
                    operacao();
                }
            });
        }else{
            operacao();
        }

        
    })
})
</script>

<!--#include file="disconnect.asp"-->