<!--#include file="connect.asp"-->
<%
Acao = req("A")
ItemID = req("ItemID")
BotaoID = req("B")

if Acao="S" then
	if BotaoID="" then
		db.execute("insert into aoabasitensbotoes set Texto='"& ref("Texto") &"', ProcedimentoID="& ref("ProcedimentoID") &", EspecialidadeID="& treatvalnull(ref("EspecialidadeID")) &", ItemID="& ItemID)
	else
		db.execute("update aoabasitensbotoes set Texto='"& ref("Texto") &"', ProcedimentoID="& ref("ProcedimentoID") &", EspecialidadeID="& treatvalnull(ref("EspecialidadeID")) &" WHERE id="& BotaoID)
	end if
	%>
	$("#modal-table").modal("hide");
	aoAba();
	<%
elseif Acao="X" then
	db.execute("delete from aoabasitensbotoes where id="& BotaoID)
	%>
	$("#modal-table").modal("hide");
	aoAba();
	<%
else
	if BotaoID<>"" then
		set b = db.execute("select * from aoabasitensbotoes where id="& BotaoID)
		if not b.eof then
			Texto = b("Texto")
			ProcedimentoID = b("ProcedimentoID")
			EspecialidadeID = b("EspecialidadeID")
		end if
	end if
	%>
	<form action="" method="post" id="frmItemBtn">
		<div class="panel-heading">
			<span class="panel-title">Edição de Botão</span>
		</div>
		<div class="panel-body">
			<%= quickfield("text", "Texto", "Texto de exibição", 4, Texto, "", "", " required ") %>
			<%= quickfield("simpleSelect", "ProcedimentoID", "Procedimento", 4, ProcedimentoID, "select id, NomeProcedimento FROM procedimentos where sysActive=1 AND ativo='on' and ExibirAgendamentoOnline=1 ORDER BY NomeProcedimento", "NomeProcedimento", " required empty ") %>
			<%= quickfield("simpleSelect", "EspecialidadeID", "Especialidade", 4, EspecialidadeID, "select id, Especialidade FROM especialidades WHERE sysActive=1 ORDER BY Especialidade", "Especialidade", " empty ") %>
		</div>
		<div class="panel-footer text-right">
			<button class="btn btn-danger" type="button" onclick="removeBtn()"><i class="fa fa-remove"></i> EXCLUIR</button>
			<button class="btn btn-primary"><i class="fa fa-save"></i> SALVAR</button>
		</div>
	</form>
<script type="text/javascript">
	$("#frmItemBtn").submit(function(){
		$.post("agendamentoOnlineProcPers.asp?A=S&B=<%= BotaoID %>&ItemID=<%= ItemID %>", $(this).serialize(), function(data){
			eval(data);
		});
		return false;
	});

	function removeBtn(){
		$.get("agendamentoOnlineProcPers.asp?A=X&B=<%= BotaoID %>&ItemID=<%= ItemID %>", function(data){
			eval(data)});
	}

	<!--#include file="JQueryFunctions.asp"-->
</script>
	<%
end if
%>
