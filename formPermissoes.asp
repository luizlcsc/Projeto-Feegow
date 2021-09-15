<!--#include file="connect.asp"-->
<%
FormID = req("F")
%>
<form action="" method="post" id="formPermissoes">
<div class="modal-header">
	<h2>Permiss&otilde;es Deste Formul&aacute;rio</h2>
</div>
<div class="modal-body">
    <div class="row">
      <div class="btn-group col-md-2">
        <button class="btn btn-primary btn-sm btn-block dropdown-toggle" data-toggle="dropdown"><i class="far fa-plus"></i> Inserir Grupo <span class="far fa-caret-down icon-on-right"></span></button>
        <ul class="dropdown-menu dropdown-info">
          <li><a href="javascript:addPerm('P');"><i class="far fa-plus"></i> Profissionais</a></li>
          <li><a href="javascript:addPerm('F');"><i class="far fa-plus"></i> Funcionários</a></li>
          <li><a href="javascript:addPerm('E');"><i class="far fa-plus"></i> Especialidades</a></li>
        </ul>
      </div>
    </div>
<br />
	<div class="row">
     <div class="col-md-12" id="PermissoesTabela">
     	<%server.Execute("formPermissoesTabela.asp")%>
     </div>
    </div>
</div>

<div class="modal-footer">
	<button class="btn btn-sm btn-default" type="button" onClick="$('#modal-table').modal('hide');"><i class="far fa-remove"></i> Cancelar</button>
	<button class="btn btn-sm btn-success"><i class="far fa-save"></i> Salvar</button>
</div>
</form>

<script>
function addPerm(T){
	$.post("formPermissoesTabela.asp?F=<%=req("F")%>", {A:'Add', T:T}, function(data, status) { $("#PermissoesTabela").html(data) });
}
function xPerm(I){
	$.post("formPermissoesTabela.asp?F=<%=req("F")%>", {A:'Remove', I:I}, function(data, status) { $("#PermissoesTabela").html(data) });
}

$("#formPermissoes").submit(function(){
	$.post("saveFormPermissoes.asp?F=<%=FormID%>", $("#formPermissoes").serialize(), function(data, status){ eval(data) } );
	return false;
})
</script>