<!--#include file="connect.asp"-->
<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
<script type="text/javascript" src="assets/js/jquery.min.js"></script>
<link rel="stylesheet" type="text/css" href="site/demo.css">
<link rel="stylesheet" type="text/css" href="site/jquery.gridster.css">
<script src="site/jquery.gridster.js" type="text/javascript" charset="utf-8"></script>
<%
	GrupoID = req("GrupoID")
	I = req("FormID")
%>
<!--#include file="newFormEstilo.asp"-->
<%
%>
<div id="demo-<%=GrupoID%>" class="gridster">
<ul>
<%
set campos = db.execute("select c.*, f.LadoALado from buicamposforms c LEFT JOIN buiforms f on f.id=c.FormID where c.GrupoID="&GrupoID&" order by c.Ordem")
while not campos.eof
  TipoCampoID = campos("TipoCampoID")
  RotuloCampo = campos("RotuloCampo")
  Checado = campos("Checado")
  CampoID = campos("id")
  Texto = campos("Texto")
  pTop = campos("pTop")
  pLeft = campos("pLeft")
  Colunas = campos("Colunas")
  Linhas = campos("Linhas")
  LadoALado = campos("LadoALado")
  Ordem = campos("Ordem")
  ValorPadrao = campos("ValorPadrao")
  GrupoID = campos("GrupoID")
  Largura = campos("Largura")
  %>
  <!--#include file="formsCompiladorCampo.asp"-->
  <%
campos.movenext
wend
campos.close
set campos=nothing
%>
</ul>
</div>

<script type="text/javascript">
var gridster = [];

$(function(){

	gridster[<%=GrupoID%>] = $("#demo-<%=GrupoID%> ul").gridster({
	  namespace:'#demo-<%=GrupoID%>',
	  widget_base_dimensions: [40, 20],
	  widget_margins: [4, 4],
	  helper: 'clone',
	  resize: {
		enabled: true,
		stop: function(e, ui, $widget) 
		{
			saveOrder();`// THIS WILL BE YOUR NEW COL and ROW  `
		}
	  },
	  draggable: 
	  {
		stop: function(e, ui, $widget) 
		{
			saveOrder();`// THIS WILL BE YOUR NEW COL and ROW  `
		}
	  }
	}).data('gridster');
});

function addSubgrid(txt, c, r){
	gridster[<%=GrupoID%>].add_widget(txt, c, r);
}

function saveOrder(){
  var new_ordem = '';
  $('.campo').each(function() {
	new_ordem += ';' + $(this).attr('id') +'|'+ $(this).attr('data-sizey') +'|'+ $(this).attr('data-sizex') +'|'+ $(this).attr('data-col') +'|'+ $(this).attr('data-row');
  });
  $.post("formsOrdenar.asp", {ordem: new_ordem}, function(data, status){ eval(data) });
}
function removeCampo(CampoID, G){
  if(confirm('Tem certeza de que deseja excluir este campo?\nATENÇÃO: Caso haja dados inseridos neste campo, os mesmos serão perdidos!')){
	  $.post("formRemoveCampo.asp?CampoID="+CampoID+"&I=<%=I%>&GrupoID="+G, '', function(data, status){ eval(data) });
  }
}
</script>

<!--#include file="disconnect.asp"-->