<div id="pageContent">Carregando...</div>
<script type="text/javascript">
function arvore(CD, X, I, CategoriaSuperior){
	$.ajax({
		type:"POST",
		url:"planocontas.asp?CD="+CD+"&X="+X+"&I="+I+"&CategoriaSuperior="+CategoriaSuperior,
		success:function(data){
			$("#pageContent").html(data);
		}
	});
}
arvore('D', '', '');

function chamagritter()
{
	/*$.gritter.add({
		title: '<i class="far fa-save"></i> Lista reordenada com sucesso.',
		text: '',
		class_name: 'gritter-success gritter-light'
	});*/

	location.reload()
}
</script>