<!--#include file="connect.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from dre_modelos where id="& req("I"))
tableName=req("P")
id=req("I")
%>
    <form method="post" id="frm" name="frm" action="save.asp">
        <input type="hidden" name="I" value="<%=req("I")%>" />
        <input type="hidden" name="P" value="<%=req("P")%>" />
		<br>
		<div class="panel">
			<div class="panel-body" id="dre_modelos_panel">
                <button class="btn btn-primary btn-sm hidden" id="save"> <i class="far fa-save"></i> Salvar </button>
				<div class="row">
					<%=quickField("text", "NomeModelo", "Nome do Modelo", "6", reg("NomeModelo"), "", "", "")%>

					<button type="button" class="mt25 btn btn-default" onclick="lin('L', 'I', '')">+ Adicionar linha</button>
					<button type="button" class="mt25 btn btn-alert" onclick="lin('T', 'I', '')">+ Adicionar totalizador</button>
				</div>
				<hr class="short alt">

				<div class="row" id="linhas">
					<div class="col-md-12">
						<% server.execute("dre_conflinhas.asp") %>
					</div>
				</div>
			</div>
		</div>
	</form>

<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>


<%
if aut("dre_conflinhasA")=0 then
%>
$("button, input, select", "#dre_modelos_panel").attr("disabled", true);
<%
end if
%>
});



</script>
<%=header(req("P"), "Gerenciar Modelo de DRE", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
