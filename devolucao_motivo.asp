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
$('#modal-components').on('hidden.bs.modal', function (e) {
  location.reload();
})

})
</script>

<%

%>
<!--#include file="disconnect.asp"-->
