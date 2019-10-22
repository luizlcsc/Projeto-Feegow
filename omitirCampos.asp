<!--#include file="connect.asp"-->
<%
FormID = req("F")
%>
<form action="" method="post" id="formOmissao">
<div class="clearfix form-actions">
  <div class="btn-group col-md-2">
    <button class="btn btn-primary btn-sm btn-block dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> Inserir Grupo <span class="fa fa-caret-down icon-on-right"></span></button>
    <ul class="dropdown-menu dropdown-info">
      <li><a href="javascript:addPerm('P');"><i class="fa fa-plus"></i> Profissionais</a></li>
      <li><a href="javascript:addPerm('F');"><i class="fa fa-plus"></i> Funcionários</a></li>
      <li><a href="javascript:addPerm('E');"><i class="fa fa-plus"></i> Especialidades</a></li>
      <li><a href="javascript:addPerm('C');"><i class="fa fa-plus"></i> Tela de Checkin</a></li>
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
 <div class="col-md-12" id="PermissoesTabela">
    <%server.Execute("omitirCamposTabela.asp")%>
 </div>
</div>

</form>

<script>
function addPerm(T){
	$.post("omitirCamposTabela.asp?F=<%=req("F")%>", {A:'Add', T:T}, function(data, status) { $("#PermissoesTabela").html(data) });
}
function xPerm(I){
	$.post("omitirCamposTabela.asp?F=<%=req("F")%>", {A:'Remove', I:I}, function(data, status) { $("#PermissoesTabela").html(data) });
}

$("#formOmissao").submit(function(){
	$.post("saveFormOmissao.asp", $("#formOmissao").serialize(), function(data, status){ eval(data) } );
	return false;
})
</script>