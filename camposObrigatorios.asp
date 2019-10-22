<!--#include file="connect.asp"-->
<%
FormID = req("F")
%>
<form action="" method="post" id="formObriga">
<div class="clearfix form-actions">
  <div class="btn-group col-md-2">
    <button class="btn btn-primary btn-sm btn-block dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> Inserir Grupo <span class="fa fa-caret-down icon-on-right"></span></button>
    <ul class="dropdown-menu dropdown-info">
      <li><a href="javascript:addPerm('Paciente');"><i class="fa fa-plus"></i> Pacientes</a></li>
      <li><a href="javascript:addPerm('Agendamento');" ><i class="fa fa-plus"></i> Agendamento</a></li>
      <li><a href="javascript:addPerm('AltAge');" class="hidden"><i class="fa fa-plus"></i> Alteração do agendamento para "aguardando"</a></li>
    </ul>
  </div>
  <div class="col-xs-2 pull-right">
	<button class="btn btn-sm btn-success btn-block"><i class="fa fa-save"></i> Salvar</button>
  </div>
</div>
<div class="row">
</div>
<br />
<div class="row">
 <div class="col-md-12" id="ObrigaTabela">
    <%server.Execute("obrigaCamposTabela.asp")%>
 </div>
</div>

</form>

<script>
function addPerm(T){
	$.post("obrigaCamposTabela.asp?F=<%=req("F")%>", {A:'Add', T:T}, function(data, status) { $("#ObrigaTabela").html(data) });
}
function xPerm(I){
	$.post("obrigaCamposTabela.asp?F=<%=req("F")%>", {A:'Remove', I:I}, function(data, status) { $("#ObrigaTabela").html(data) });
}

$("#formObriga").submit(function(){
	$.post("saveFormObriga.asp", $("#formObriga").serialize(), function(data, status){ eval(data) } );
	return false;
})
</script>