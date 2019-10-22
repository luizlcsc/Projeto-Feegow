<!--#include file="connect.asp"-->
<%
reg = db.execute("SELECT * FROM sys_config")
autoSalvarForm = ""
if reg("AutoSalvarFormulario") = 1 then
    autoSalvarForm = "checked"
end if
%>
<div class="checkbox-primary checkbox-custom">
    <input type="checkbox" name="AutoSalvarFormulario"  id="AutoSalvarFormulario" value="1" <%=autoSalvarForm%>>
    <label for="AutoSalvarFormulario">Auto salvar formuário</label>
    <!--<small>Esta opção ir</small>-->
</div>

<script type="text/javascript">
    $("#AutoSalvarFormulario").on("change", function() {
        var val = $(this).prop("checked") ? 1 : 0;
        $.get("salvaregrasdeformulario.asp", {AutoSalvarFormulario: val}, function(data) {

        });
    });
</script>