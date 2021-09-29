<!--#include file="connect.asp"-->
<%
DataDe  = req("DataDe")
DataAte = req("DataAte")
reqdebug   = req("debug")

if DataDe="" then
	DataDe = date()
end if
if DataAte="" then
	DataAte = date()
end if
%>

<h4>Formulários</h4>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rBuscaRelatorio">
    <input type="hidden" name="debug" value="<%=reqdebug%>">
    <div class="clearfix form-actions">
    	<div class="row">
            <%=quickField("simpleSelect", "FormID", "Formulário", 3, "", "select id, Nome from buiforms where sysActive=1", "Nome", "")%>
            <%=quickField("datepicker", "DataDe", "Data inicio", 3, "", " input-mask-date ", "", "")%>
            <%=quickField("datepicker", "DataAte", "Data fim", 3, "", " input-mask-date ", "", "")%>
			<div id="forms-campos"></div>

            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Gerar</button>
            </div>
        </div>

    </div>
</form>
<script>

$("#FormID").change(function() {
    $.get("carregaCamposDoFormulario.asp", {FormID: $(this).val()}, function(data) {
        $("#forms-campos").html(data);
        $(".input-mask-date").mask("99/99/9999")
    });
});
<!--#include file="jQueryFunctions.asp"-->
</script>