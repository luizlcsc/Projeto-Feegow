<!--#include file="connect.asp"-->
<%
FormID = req("FormID")
set frm = db.execute("select * from buiforms where id="&FormID)
%>
<form method="post" action="" id="formEstilo">
<div class="modal-header">
	<h4>Estilo do Formul&aacute;rio</h4>
</div>
<div class="modal-body">

  <div class="label label-info label-lg btn-block">ATEN&Ccedil;&Atilde;O: Caso tenha dificuldades em personalizar seu formul&aacute;rio, conte com nossa equipe de suporte.</div>
  <hr />
  <div class="row">
  	<div class="col-md-4">
    	<label><input type="checkbox" name="LadoALado" id="LadoALado" value="S" onclick="editStyle('LaL', '', '', '', $(this).prop('checked'));"<% If frm("LadoALado")="S" Then %> checked="checked"<% End If %> /><span class="lbl"> Campos ao lado do r&oacute;tulo</span></label>
    </div>
  </div>
  <hr />
  <div class="row">
	<%
	'splRotulos = split("Caixa Externa|Campos|R&oacute;tulo dos Campos|R&oacute;tulo dos Grupos|Caixa dos Grupos", "|")
    'splCampos = split("caixa|input|label|labelGrupo|caixaGrupo", "|")

	splRotulos = split("Caixa Externa|Campos|R&oacute;tulo dos Campos", "|")
	splCampos = split("caixa|input|label", "|")
	for cp=0 to ubound(splCampos)
		tipo = splCampos(cp)
		Rotulo = splRotulos(cp)
		%>
		<div class="col-md-4" id="div<%=tipo%>">
        	<!--#include file="formEstiloTipo.asp"-->
        </div>
		<%
	next
	%>
  </div>
</div>
<div class="modal-footer">
	<button class="btn btn-success btn-sm"><i class="far fa-save"></i> Salvar</button>
</div>
</form>
<script>
$("#formEstilo").submit(function(){
	$.post("saveFormEstilo.asp?FormID=<%=FormID%>", $(this).serialize(), function(data, status){ eval(data) });
	return false;
});
<!--#include file="jQueryFunctions.asp"-->

function editStyle(Action, Tipo, Rotulo, I, txtUpdate){
	$.post("chamaFormEstiloTipo.asp?FormID=<%=FormID%>", {Action:Action, Tipo:Tipo, Rotulo:Rotulo, I:I, txtUpdate:txtUpdate}, function(data, status){
		$("#div"+Tipo).html(data);
		if(Action=='LaL'){
			refLay();
		}
	});
}
</script>