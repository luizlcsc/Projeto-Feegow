<!--#include file="connect.asp"-->
<div class="panel">
	<div class="panel-head">
	</div>
	<div class="panel-body">
		<%= quickfield("simpleSelect", "persProcedimentos", "Adicionar Procedimento", 6, "", "select concat('Procedimento-', id) id, NomeProcedimento FROM procedimentos where sysActive=1 and Ativo='on' AND ExibirAgendamentoOnline=1 ORDER BY NomeProcedimento", "NomeProcedimento", "") %>
		<%= quickfield("simpleSelect", "persEspecialidades", "Adicionar Especialidade", 6, "", "select  concat('Especialidade-', id) id, Especialidade FROM especialidades where sysActive=1 ORDER BY Especialidade", "Especialidade", "") %>
	</div>
</div>

<script type="text/javascript">
$("#persProcedimentos, #persEspecialidades").change(function(){
	$("#modal-table").modal("hide");
	aoAba("P", $(this).val()+'-<%= req("AbaID") %>' );
});
</script>