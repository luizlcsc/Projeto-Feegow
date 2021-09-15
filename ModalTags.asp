<!--#include file="connect.asp"-->

<%
'ATIVA EXIBIÇÃO DAS QUERYS
sDev = 0
qTagsCategorias = "SELECT * FROM cliniccentral.tags_categorias"

'LISTAGEM COM CATEGORIAS DAS TAGS 
set sqlTagsCategorias = db.execute(qTagsCategorias)
conta = 0
while not sqlTagsCategorias.eof
  conta = conta+1
  tags_categorias_id = sqlTagsCategorias("id")
  tags_categorias_categoria = sqlTagsCategorias("categoria")
  tags_categorias_icone = sqlTagsCategorias("icone")


  qTags = ""&_
  "SELECT tag.*,tagMod.Modulo  "&_
  "FROM cliniccentral.tags AS tag  "&_
  "LEFT JOIN cliniccentral.tags_modulos tagMod ON tagMod.TagID=tag.id  "&_
  "LEFT JOIN cliniccentral.tags_categorias tagCat ON tagCat.id=tag.tags_categorias_id  "&_
  "WHERE (tag.Padrao=1 AND tagCat.id = '"&tags_categorias_id&"') OR (tagMod.Modulo='"&req("P")&"' AND tagMod.Recurso='"&req("R")&"' AND tagCat.id = '"&tags_categorias_id&"')  "&_
  "GROUP BY tag.id "&_
  "ORDER BY tag.padrao"
  if sDev=1 then
    response.write("<pre>"&replace(qTags,"  ","<br>")&"</pre>")
  end if

  set sqlTags = db.execute(qTags)
  if sqlTags.eof then
    tabCreate = 0
  else
    tabCreate = 1
    while not sqlTags.eof

      tags_tagNome = "["&sqlTags("tagNome")&"]"
      tags_Resultado = sqlTags("Resultado")
      tags_Descricao = sqlTags("Descricao")
      'tags_Exemplo = replaceTags(tags_tagNome,0,0,0)
      tags_copy = "<code class='copyableInput "&tags_tagNome&"' id='"&tags_tagNome&"'>"&tags_tagNome&"</code>"
      tags_copy = "<button type='button' class='copyableInputButton btn btn-xs btn-dark' onclick='copyToClipboard(`"&tags_tagNome&"`)'><i class='far fa-paste'></i></button>"&tags_copy

      tagsGridHTML = ""&_
      "<tr>"&_
        "<td>"&tags_copy&"</td>"&_
        "<td>"& tags_Descricao &"</td>"&_
      "</tr>"

      if tagsGrid = "" then
        tagsGrid = tagsGridHTML
      else
        tagsGrid = tagsGrid&tagsGridHTML
      end if
    sqlTags.movenext
    wend
  end if
  sqlTags.close
  set sqlTags = nothing

  tabsCategoriasHTML =  ""&_
  "<li class='active'>"&_
    "<a href='#abaTag"&tags_categorias_id&"' data-toggle='tab' aria-expanded='true'> <i class='"&tags_categorias_icone&" text-purple pr5'></i> "&tags_categorias_categoria&" </a>"&_
  "</li>"

  tabsContentHTML = ""&_
  "<div id='abaTag"&tags_categorias_id&"' class='tab-pane active'><p>"&_
  "<table class='table mbn'>"&_
    "<thead>"&_
      "<tr class='primary'>"&_
        "<th>TAG</th>"&_
        "<th>Descrição</th>"&_
      "</tr>"&_
    "</thead>"&_
    "<tbody>"&_
      tagsGrid&_
    "</tbody>"&_
  "</table>"&_
  "</p></div>"
  
  if conta>1 then
    tabsCategoriasHTML = replace(tabsCategoriasHTML,"class='active'","class=''")
    tabsCategoriasHTML = replace(tabsCategoriasHTML,"aria-expanded='true''","aria-expanded='false'")
   
    tabsContentHTML = replace(tabsContentHTML,"class='tab-pane active'","class='tab-pane'")

  end if
  if tabCreate = 1 then
    tabsCategoriasHTML = tabsCategoriasHTML
  else
    tabsCategoriasHTML =""
  end if
  tagsGrid = ""

  if tabsCategorias ="" then
    tabsCategorias = tabsCategoriasHTML
    tabsContent = tabsContentHTML
  else
    tabsCategorias = tabsCategorias&tabsCategoriasHTML
    tabsContent = tabsContent&tabsContentHTML
  end if

sqlTagsCategorias.movenext
wend
sqlTagsCategorias.close
set sqlTagsCategorias = nothing
%>


<div class="row">
  <div class="col-md-12">
    <div class="bs-component">
      <div class="tab-block mb25">
        <ul class="nav tabs-left">
          <%=tabsCategorias%>
        </ul>
        <div class="tab-content">
          <%=tabsContent%>
        </div>
      </div>
    <div id="source-button" class="btn btn-primary btn-xs" style="display: none;">&lt; &gt;</div></div>
  </div>
</div>

<script>
function copyToClipboard(target) {
    var element = document.getElementById(target);
    var text = element.innerHTML;
    CopyToClipboard(text);
    //alert("A Tag "+ text +" foi copiada com sucesso!");
    showMessageDialog("A tag "+text+" foi copiada para  sua área de transferência.", "success", "Tag copiada!", 5000);
}

function CopyToClipboard (text) {
	// Copies a string to the clipboard. Must be called from within an 
	// event handler such as click. May return false if it failed, but
	// this is not always possible. Browser support for Chrome 43+, 
	// Firefox 42+, Safari 10+, Edge and IE 10+.
	// IE: The clipboard feature may be disabled by an administrator. By
	// default a prompt is shown the first time the clipboard is 
	// used (per session).
	if (window.clipboardData && window.clipboardData.setData) {
		// IE specific code path to prevent textarea being shown while dialog is visible.
		return clipboardData.setData("Text", text); 

  } else if (document.queryCommandSupported && document.queryCommandSupported("copy")) {
    var textarea = document.createElement("textarea");
    textarea.textContent = text;
    textarea.style.position = "fixed";  // Prevent scrolling to bottom of page in MS Edge.
    document.body.appendChild(textarea);
    textarea.select();

    try {
      return document.execCommand("copy");  // Security exception may be thrown by some browsers.
    } catch (ex) {
      //console.warn("Cópia de tag falhou.", ex);
      showMessageDialog("A tag "+text+" \n não foi copiada para área de transferência.", "danger", "ERRO!", 5000);
      return false;
    } finally {
      document.body.removeChild(textarea);
    }
	}
}
</script>