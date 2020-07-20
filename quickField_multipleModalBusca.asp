<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
refID     = "multipleModal_"&req("I")
formBusca = ref("busca")
checksID  = req("v")

multipleModal_sessionSQL = Session("multipleModal_session")

conteudoHeader = ""&_
"<div style='border-bottom:1px dotted #ccc'>"&_
"<table class='table'>"&_
"  <thead>"&_
"    <tr>"&_
"      <th width='150'>Código</th>"&_
"      <th colspan='2'>Nome</th>"&_
"    </tr>"&_
"  </thead>"&_
"  <tbody>"

'conteudo = ""&_
'  "<tr>"&_
'  " <td colspan='3'><i>Nenhum registro localizado com o termo <strong><i>dasdasd<i></strong></i></td>"&_
'  "</tr>"

conteudoFooter = ""&_
"  </tbody>"&_
"</table>"&_
"</div>"

if formBusca<>"" then
  qItemBuscaWhere = " WHERE "
  qItemBuscaWhere = qItemBuscaWhere&" (id='"&formBusca&"' OR NomeProcedimento LIKE '%"&formBusca&"%') "
  if checksID<>"" then
    qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento(",'",checksID)&")) "
  end if

  'DEFINIR COLUNAS E TABELA DINAMICAMENTE...
  qItemBuscaSQL = multipleModal_sessionSQL&qItemBuscaWhere&" limit 0,5"
  'response.write("<pre>"&qItemBuscaSQL&"</pre>")
  SET ItemBuscaSQL = db.execute(qItemBuscaSQL)
  if ItemBuscaSQL.eof then
    resultadoBuscaHTML = ""&_
      "<tr>"&_
      " <td colspan='3'><i>Nenhum registro localizado com o termo <strong><i>"&formBusca&"<i></strong></i></td>"&_
      "</tr>"
  else
    while not ItemBuscaSQL.eof

      item_id   = cstr(ItemBuscaSQL("id"))
      item_Nome = ItemBuscaSQL("nome")

      checkboxNome = "itemBusca"&item_id

      'VALIDA CHECKS DO CKECKBOX
      checksID_array=Split(checksID,",")
      for each checksID_item in checksID_array
        'response.write(checksID_item&"("&VarType(checksID_item)&")" &" x "&item_id&"("&VarType(item_id)&")"&"<br>")
        if checksID_item=item_id then
          checked = "checked"
        end if
      next
      
      conteudoBuscaHTML = ""&_
      "<tr>"&_
      "  <td># "&item_id&"</td>"&_
      "  <td>"&item_Nome&"</td>"&_
      "  <td width='60'>"&_
      "    <div class='checkbox-custom checkbox-primary'>"&_
      "      <input "&checked&" onclick='preencheArrayItensSelecionados(this)' type='checkbox' name='itemBusca[]' class='qfMultiple' id='"&checkboxNome&"' value='"&item_id&"'>"&_
      "      <label for='"&checkboxNome&"' class='checkbox'></label>"&_
      "    </div>"&_
      "  </td>"&_
      "</tr>"

      checked = ""
      if conteudoBusca="" then
        conteudoBusca = conteudoBuscaHTML
      else
        conteudoBusca = conteudoBusca&conteudoBuscaHTML
      end if

    
    'response.write("<script>console.log('aaa')</script>")
    ItemBuscaSQL.movenext
    wend
  end if
  ItemBuscaSQL.close
  set ItemBuscaSQL = nothing
  
  'IMPRIME RESULTADO DA BUSCA
  cabecalhoBusca = ""&_
  "<h3 class='text-center'>"&_
  "  Adicionar itens"&_
  "  <small>(Resultado da Busca por: "&formBusca&")</small>"&_
  "</h3>"
  response.write(cabecalhoBusca&conteudoHeader&conteudoBusca&conteudoFooter)
  'response.write(conteudoBusca)
end if
%>


<script type="text/javascript">
$(document).ready(function(){
  $('input:checkbox[name=itemBusca]').click(function(){

    var checkValor = $(this).val();
    if($(this).prop("checked") == true){
      //console.log("check, adiciona."+checkValor);
      $.get('quickField_multipleModalBusca.asp?a=add&I='+checkValor);
      

      //$('#<%'=refID%>').val(checkValor);



    }
    else if($(this).prop("checked") == false){
      //console.log("ñ check, remove."+checkValor);
      $.get('quickField_multipleModalBusca.asp?a=rem&I='+checkValor);
    }
  });
});
</script>