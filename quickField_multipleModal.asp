<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="sqls/sqlUtils.asp"-->
<%
checksID   = req("v")
refID      = req("I")

valores =  Split(refID,"_"&"") 'EX. Procedimentos_4785
if Ubound(valores) >=0 then tipo  = valores(0) end if
if Ubound(valores) > 0 then valor = valores(1) end if

IF checksID = "" THEN
   checksID = ref("v")
END IF

checksID = Replace(checksID," ","")

Select Case tipo
  Case "Profissionais", "ProfissionaisLaudo"
    multipleModal_sessionSQL = getProfissionaisSqlQuickField()
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",converteEncapsulamento(",'",checksID))&")"

  Case "TabelasParticulares"
    multipleModal_sessionSQL = getTabelasParticularesSQLQuickField()
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",checksID)&")"
  Case "Convenios"
    multipleModal_sessionSQL = getTabelasConveniosSQLQuickField()
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",checksID)&")"

  'Novo formato para filtrar os dados
  Case "Unidades", "ProcedimentosGrupos", "Procedimentos", "Especialidades", "EspecialidadesLaudo", "ProfissionaisGrupos", "Profissionais"
    if tipo="EspecialidadesLaudo" then
      tipo = "Especialidades"
      Condicao = "id+"
    else
      Condicao = false
    end if
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,Condicao)
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",checksID)&")"

  Case "SomenteProfissionais"
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,false)
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",checksID)&") ORDER BY 2"

  Case "SomenteEspecialidades"
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,"sql")
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",checksID)&")"

  Case "Usuarios","UsuariosLivres","OmitirValorGuia"
    tipo = "Usuarios"
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,false)
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",checksID)&")"

  Case "Cid10"
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,"sql")
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",checksID)&")"

  Case else
    multipleModal_sessionSQL = Session("multipleModal_session")
    qItemWhere = " AND id IN("&converteEncapsulamento("|,",checksID)&")"
End Select

if checksID="" then
  checks_varItensDefault = "var itensDefault = [];"
else
  checks_varItensDefault = "var itensDefault = '"&checksID&"'.split(',');"

  conteudoHeader = ""&_
  "<h3 class='text-center'>Itens Adicionados</h3>"&_
  "<div style='position: relative; height:300px; overflow:auto;'><div style='position: absolute; width:100%;'>"&_
  "<table class='table'>"&_
  "  <thead>"&_
  "    <tr class='primary'>"&_
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
  "</div></div>"





  qItemSQL = multipleModal_sessionSQL&qItemWhere
  'response.write("<pre>"&qItemSQL&"</pre>")
  'dd(qItemSQL)
  set ItemSQL = db.execute(qItemSQL)
  ' response.write(qItemSQL)
  if not ItemSQL.eof then
    while not ItemSQL.eof

      item_id      = ItemSQL("id")
      item_Nome    = ItemSQL("nome")
      item_Codigo  = item_id
      checkboxNome = "itemBusca"&item_id

      if FieldExists(ItemBuscaSQL, "codigo") then
        item_Codigo = ItemBuscaSQL("codigo")
      end if

      conteudoHTML = ""&_
      "<tr>"&_
      "  <td><code># "&item_Codigo&"</code></td>"&_
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
  <input type="text" class="form-control" name="busca" id="busca" placeholder="Busque pelo nome ou código" >
</form>


<%
'DIV RESPONSÁVEL POR GERAR RESULTADOS DA BUSCA
response.write("<div id='resultado'></div>")
'EXIBE HTML DO INPUT HIDDEN
response.write(conteudoItensHTML)

%>

<script type="text/javascript">

var buscaValor = $("#busca");
var valueClearKeyUp = null;

<%=checks_varItensDefault%>
var itensSelecionados=itensDefault;

//$(buscaValor).keyup(function() {
$(buscaValor).ready(function() {

  if (buscaValor.val()==''){
    $.post(
      'quickField_multipleModalBusca.asp?<%="I="&req("I")&"&tipo="&tipo%>',
      {v:'<%=checksID%>'},
      function(resultado){
        $("#resultado").html(resultado);
        itensSelecionados.forEach((item) =>{
                let valor = item.replace(/\|/g, '')
                $("[name='itemBusca[]'][value='"+valor+"']").prop("checked",true);
        });
      }
    );
  };

  $(buscaValor).keyup(function() {

      clearTimeout(valueClearKeyUp);

   valueClearKeyUp  = setTimeout(() => {
         $.post(
              'quickField_multipleModalBusca.asp?<%="I="&req("I")&"&tipo="&tipo%>&busca='+$(buscaValor).val(),
              {v:'<%=checksID%>'},
              function(resultado){
                $("#resultado").html(resultado);
                itensSelecionados.forEach((item) =>{
                    let valor = item.replace(/\|/g, '')
                    $("[name='itemBusca[]'][value='"+valor+"']").prop("checked",true);
                })
              }
          );
    },1000)

  });
});



//######################################################################
function preencheArrayItensSelecionados(checkbox) {
  var $check = $(checkbox);
  var isSelecionado = $check.prop("checked");
  var valor = $check.val();

  $("[name='itemBusca[]'][value='"+valor+"']").prop("checked",isSelecionado);

  if(isSelecionado){

    if(!itensSelecionados.includes('|'+valor+'|')){
      itensSelecionados.push('|'+valor+'|');
    }
    itensSelecionados = $.makeArray( itensSelecionados );
  }else{
    var removeItem = "|"+valor+"|";
    itensSelecionados.splice(itensSelecionados.indexOf(removeItem),1 );
  }
}


//PREPARA ITENS PARA SALVAR
$(".components-modal-submit-btn").click(function(){
  $('#<%=refID%>').val(itensSelecionados).trigger('change');

  <%
  if req("acao")<>"" then
  %>
  $.post(
    'quickField_multipleModalSave.asp',
    {
      v:itensSelecionados+'',
      iId:'<%=refID%>',
      tab:'<%=req("Tb")%>'
    },
      function(resultado){
        $("#resultado").html(resultado);
        <%
        if req("refresh")=1 then
        %>
          document.location.reload(true);
        <%
        end if
        %>
      }

  );
  <%
  end if
  %>

});
//######################################################################

</script>