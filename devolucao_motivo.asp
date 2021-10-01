<!--#include file="connect.asp"-->
<!--#include file="Classes/Devolucao.asp"-->
<%

'Não gerar devolução se tiver REPASSE GERADO E/OU NOTA FISCAL GERADA
InvoiceID = req("InvoiceID")
MotivoDevolucao = ref("MotivoDevolucao")
TipoOperacao = ref("TipoOperacao")
iteninvoice = ref("iteninvoice")
Observacao = ref("Observacao")
DebitarCaixa = ref("DebitarCaixa")&""
accountId = req("accountId")&""
contaID = ref("ContaID")&""

' ######################### BLOQUEIO FINANCEIRO ########################################
accounts = Split(accountId, "_")
contabloqueada = verificaBloqueioConta(2, 1, accounts(1), session("UnidadeID"),date() )
if contabloqueada = "1" then
    response.write("A conta não pode ser alterada pois está bloqueada!")
    %>
    <script>
      alert('Esta conta está bloqueada e não pode ser alterada!');
      $('#modal-components').modal('hide');
    </script>
    <%
    Response.End
end if
' ######################################################################################


set devolucaoObj = new Devolucao
exeDevolucao = devolucaoObj.gerarDevolucao(InvoiceID, iteninvoice, accountId, TipoOperacao, MotivoDevolucao, DebitarCaixa, Observacao, contaID)
if exeDevolucao then
    response.write("Conta cancelada com sucesso")
else
    response.write("Conta não cancelada")
end if
%>
<script>
$(function(){
    closeComponentsModal();
    $("#btn-invoice-save").attr("disabled", false);
    showMessageDialog("Itens cancelados com sucesso", "warning");
    itens();

});

</script>

<%

%>
<!--#include file="disconnect.asp"-->
