<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
refID    = req("I")
checksID = req("v")
multipleModal_sessionSQL = Session("multipleModal_session")

RESPONSE.WRITE(multipleModal_session)
if checksID="" then
  checks_varItensDefault = "var itensDefault = [];"
else
  checks_varItensDefault = "var itensDefault = '"&checksID&"'.split(',');"

  conteudoHeader = ""&_
  "<h3 class='text-center'>Itens Adicionados</h3>"&_
  "<div style='max-height:200px;overflow: auto;'>"&_
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





  qItemWhere = " WHERE id IN("&converteEncapsulamento(",'",checksID)&")"
  qItemSQL = multipleModal_sessionSQL&qItemWhere
  'response.write("<pre>"&qItemSQL&"</pre>")
  set ItemSQL = db.execute(qItemSQL)
  if not ItemSQL.eof then
    while not ItemSQL.eof

      item_id   = ItemSQL("id")
      item_Nome = ItemSQL("nome")
      checkboxNome = "itemBusca"&item_id

      conteudoHTML = ""&_
      "<tr>"&_
      "  <td># "&item_id&"</td>"&_
      "  <td>"&item_Nome&"</td>"&_
      "  <td width='60'>"&_
      "    <div class='checkbox-custom checkbox-success'>"&_
      "      <input checked onclick='preencheArrayItensSelecionados(this)' type='checkbox' name='itemBusca[]' class='qfMultiple' id='"&checkboxNome&"' value='"&item_id&"'>"&_
      "      <label for='"&checkboxNome&"' class='checkbox'></label>"&_
      "    </div>"&_
      "  </td>"&_
      "</tr>"

      if conteudo="" then
        conteudo = conteudoHTML
      else
        conteudo = conteudo&conteudoHTML
      end if
    ItemSQL.movenext
    wend
    ItemSQL.close
    set ItemSQL = nothing

  end if

conteudoItensHTML = conteudoHeader&conteudo&conteudoFooter
end if
%>


<form method="POST" id="form-pesquisa" action="">
  <input type="text" class="form-control" name="busca" id="busca" placeholder="Busque pelo ID ou nome" >
</form>


<%
'DIV RESPONSÁVEL POR GERAR RESULTADOS DA BUSCA
response.write("<div id='resultado'></div>")
'EXIBE HTML DO INPUT HIDDEN
response.write(conteudoItensHTML)
%>

<script type="text/javascript">

var buscaValor = $("#busca");

//$(buscaValor).keyup(function() {
$(buscaValor).ready(function() {
  
  if (buscaValor.val()==''){
    $.post(
      'quickField_multipleModalBusca.asp?<%="I="&req("I")&"&v="&checksID%>',
      buscaValor,
      function(resultado){
        $("#resultado").html(resultado);
      }
    );
  };

  $(buscaValor).keyup(function() {
    $.post(
      'quickField_multipleModalBusca.asp?<%="I="&req("I")&"&v="&checksID%>',
      buscaValor,
      function(resultado){
      $("#resultado").html(resultado);
    }
  );
  });
});

<%=checks_varItensDefault%>
var itensSelecionados=itensDefault;

//######################################################################
function preencheArrayItensSelecionados(checkbox) {
  var $check = $(checkbox);
  var isSelecionado = $check.prop("checked");
  var valor = $check.val();
  
  if(isSelecionado){

    if(!itensSelecionados.includes(valor)){
      itensSelecionados.push(valor);
    }
    itensSelecionados = $.makeArray( itensSelecionados );

  }else{
    var removeItem = valor;
    itensSelecionados.splice( $.inArray(removeItem,itensSelecionados) ,1 );

    
  }

  //console.log(itensSelecionados);


}

//PREPARA ITENS PARA SALVAR
$(".components-modal-submit-btn").click(function(){
  //console.log(itensSelecionados+' INPUTID = <%=refID%>')

  $('#<%=refID%>').val(itensSelecionados);

});
//######################################################################

</script>