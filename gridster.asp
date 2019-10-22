<!--#include file="connect.asp"-->
<%
	I = req("I")
%>
<!--#include file="newFormEstilo.asp"-->

  <div id="demo-1" class="gridster">
    <ul style="background-color:#fff; min-width:820px; max-width:820px;">
    <%
	set campos = db.execute("select c.*, f.LadoALado, tc.possuiColuna from buicamposforms c LEFT JOIN buiforms f on f.id=c.FormID LEFT JOIN cliniccentral.buitiposcamposforms tc on tc.id=c.TipoCampoID where c.FormID="&I&" and c.GrupoID=0 order by c.Ordem")
	while not campos.eof
      possuiColuna = campos("possuiColuna")
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

	gridster[0] = $("#demo-1 ul").gridster({
	  namespace:'#demo-1',
	  widget_base_dimensions: [50, 25],
	  widget_margins: [4, 4],
	  helper: 'clone',
	  resize: {
		enabled: true,
		start: function(e, ui, $widget) 
		{
			$("iframe"). css("display", "none");
		},
		stop: function(e, ui, $widget) 
		{
			$("#save").click();
			$("iframe"). css("display", "block");
		}
	  },
	  draggable: 
	  {
		stop: function(e, ui, $widget) 
		{
			$("#save").click();
			$("iframe"). css("display", "block");
		},
		start: function(e, ui, $widget) 
		{
			$("iframe"). css("display", "none");
		}
	  }
	}).data('gridster');
  });

function addCampo(TipoCampoID, G){
  $.post("formAddCampo.asp?TipoCampoID="+TipoCampoID+"&I=<%=I%>&GrupoID="+G, '', function(data, status){ eval(data) });
}
function removeCampo(CampoID, G){
  if(confirm('Tem certeza de que deseja excluir este campo?\nATENÇÃO: Caso haja dados inseridos neste campo, os mesmos serão perdidos!')){
	  $.post("formRemoveCampo.asp?CampoID="+CampoID+"&I=<%=I%>&GrupoID="+G, '', function(data, status){ eval(data) });
  }
}
$("#frmForm").submit(function(){
  var new_ordem = '';
  $('.campo').each(function() {
	new_ordem += ';' + $(this).attr('id') +'|'+ $(this).attr('data-sizey') +'|'+ $(this).attr('data-sizex') +'|'+ $(this).attr('data-col') +'|'+ $(this).attr('data-row');
  });
  $.post("formsOrdenar.asp", {ordem: new_ordem}, function(data, status){ eval(data) });
});
function editCampo(I){
//  $("#modal").html('Carregando...');
  $("#modal-narrow").modal("show");
  $.post("formsEditaCampo.asp?I="+I+"&W=0&F=<%=I%>", '', function(data, status){ $("#modal-narrow-content").html(data) });
}
</script>

<!--#include file="disconnect.asp"-->