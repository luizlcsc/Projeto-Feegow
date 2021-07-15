<!--#include file="./../connect.asp"-->
<%
'RECEBE VALORES E RETORNA VIA AJAX ||| EXEMPLO DE USO modalSADT.asp |||
' $(document).ready(function () {
'     $("select[name=gProcedimentoID]").change(function () {
'         $.post("./Classes/AjaxReturn.asp",
'             {
'                 itemVal: $(this).val(),
'                 itemTab: "Procedimentos",
'                 itemCol: "TipoProcedimentoID"
'             }, 
'             function (valor) {
'                 $("#TipoProcedimentoID").val(valor);
'             }
'         );           
'     });
' });

valor   = ref("itemVal")&""
tabela  = ref("itemTab")&""
coluna  = ref("itemCol")&""
if valor<>"" and tabela<>"" and coluna<>"" then
  'ADICIONAR VALIDADOR DE TABELAS/COLUNAS
  qItemSQL = "SELECT "&coluna&" FROM `"&tabela&"` WHERE id="&valor
  set itemSQL = db.execute(qItemSQL)
  if not itemSQL.eof then
    itemReturn = itemSQL(coluna)&""
    if itemReturn="" then
      itemReturn=0
    end if
    response.write(itemReturn)
  end if
  itemSQL.close
  set itemSQL = nothing
end if
%>