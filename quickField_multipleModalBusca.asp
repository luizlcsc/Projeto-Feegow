<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="sqls/sqlUtils.asp"-->

<%
checksID  = ref("v")
refID     = "multipleModal_"&req("I")
formBusca = req("busca")

valores =  Split(refID,"_"&"") 'EX. Procedimentos_4785
if Ubound(valores) >=1 then tipo  = valores(1) end if
if Ubound(valores) > 2 then valor = valores(2) end if

qItemBuscaWhere = " AND (id='"&formBusca&"' OR nome LIKE '%"&formBusca&"%') "
'response.write(tipo)
Select Case tipo
  Case "Profissionais", "ProfissionaisLaudo"
    multipleModal_sessionSQL = getProfissionaisSqlQuickField()
    if checksID<>"" then
      qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento(",'",converteEncapsulamento("|,",checksID))&")) "
      'dd(qItemBuscaWhere)
    end if
  Case "TabelasParticulares"
    multipleModal_sessionSQL = getTabelasParticularesSQLQuickField()
    if checksID<>"" then
      qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento("|,",checksID)&")) "
    end if
  Case "Unidades", "ProcedimentosGrupos", "Procedimentos", "ProfissionaisGrupos", "Profissionais"
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,false)
    if checksID<>"" then
      qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento("|,",checksID)&")) "
    end if
  Case "Especialidades", "EspecialidadesLaudo"
    if tipo="EspecialidadesLaudo" then
      tipo = "Especialidades"
      Condicao = "id+"
    else
      Condicao = false
    end if
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,Condicao)
    if checksID<>"" then
      qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento("|,",checksID)&")) "
    end if
  Case "SomenteProfissionais"
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,"sql")
    if checksID<>"" then
      qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento("|,",checksID)&")) "
    end if
  Case "SomenteEspecialidades"
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,"sql")
    if checksID<>"" then
      qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento("|,",checksID)&")) "
    end if
  Case "Convenios"
    multipleModal_sessionSQL = getTabelasConveniosSQLQuickField()

  Case "Usuarios","UsuariosLivres","OmitirValorGuia"

    if tipo="UsuariosLivres" then
      Condicao = "profissionais"
    else
      Condicao = false
    end if
    'Redefine outros tipos para usuários para a Query
    tipo = "Usuarios"


    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,Condicao)

    if checksID<>"" then
      qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento("|,",checksID)&")) "
    end if

  Case "Cid10"
    multipleModal_sessionSQL = getSQLQuickField(tipo,false,false,"sql")
    qItemBuscaWhere = " AND (id='"&formBusca&"' OR nome LIKE '%"&formBusca&"%' OR codigo LIKE '%"&formBusca&"%') "
    if checksID<>"" then
      qItemBuscaWhere = qItemBuscaWhere&" AND (id NOT IN("&converteEncapsulamento("|,",checksID)&")) "
    end if

  Case else
    multipleModal_sessionSQL = Session("multipleModal_session")
    qItemBuscaWhere = " WHERE id IN("&converteEncapsulamento("|,",converteEncapsulamento(",'",checksID))&")"
End Select

conteudoHeader = ""&_
"<div style='position: relative; height:300px; overflow:auto;'><div style='position: absolute; top: 0; width:100%;'>"&_
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

  'DEFINIR COLUNAS E TABELA DINAMICAMENTE...
  qItemBuscaSQL = multipleModal_sessionSQL&qItemBuscaWhere&" limit 0,100"
  'response.write("<pre>"&qItemBuscaSQL&"</pre>")
  'dd("((( "&qItemBuscaSQL&"   )))")
  SET ItemBuscaSQL = db.execute(qItemBuscaSQL)
  if ItemBuscaSQL.eof then
    resultadoBuscaHTML = ""&_
      "<tr>"&_
      " <td colspan='3'><i>Nenhum registro localizado com o termo <strong><i>"&formBusca&"<i></strong></i></td>"&_
      "</tr>"
  else
    while not ItemBuscaSQL.eof

      item_id     = cstr(ItemBuscaSQL("id"))
      item_Nome   = ItemBuscaSQL("nome")
      item_Codigo = item_id

      if FieldExists(ItemBuscaSQL, "codigo") then
        item_Codigo = ItemBuscaSQL("codigo")
      end if

      checkboxNome = "itemBuscas"&item_id

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
      "  <td><code># "&item_Codigo&"</code></td>"&_
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
  if formBusca<>"" then
    termoBuscaHTML = "<small>(Resultado da Busca por: "&formBusca&")</small>" 
  end if
  'IMPRIME RESULTADO DA BUSCA
  cabecalhoBusca = ""&_
  "<h3 class='text-center'>"&_
  "  Adicionar itens"&_
    termoBuscaHTML&_
  "</h3>"
  response.write(cabecalhoBusca&conteudoHeader&conteudoBusca&conteudoFooter)
  'response.write(conteudoBusca)

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