<!--#include file="connect.asp"-->
<%
if ref("E")="E" then
    TriagemProcedimentos = ref("TriagemProcedimentos")
    sqlUpdate="UPDATE sys_config SET TriagemEspecialidades='"&ref("TriagemEspecialidades")&"', TriagemProcedimentos='"&TriagemProcedimentos&"', Triagem='"&ref("Triagem")&"' WHERE id=1"
    db_execute(sqlUpdate)

    %>

    <script type="text/javascript">
        new PNotify({
            title: 'Salvo com sucesso!',
            text: '',
            type: 'success',
            delay: 3000
        });
    </script>
    <%
end if


set TriagemConfigSQL = db.execute("SELECT TriagemEspecialidades, TriagemProcedimentos, Triagem FROM sys_config WHERE id=1")

if not TriagemConfigSQL.eof then
    Triagem=TriagemConfigSQL("Triagem")
    TriagemEspecialidades=TriagemConfigSQL("TriagemEspecialidades")
    TriagemProcedimentos=TriagemConfigSQL("TriagemProcedimentos")
end if
%>
<div class="row">
<form id="frmTriagem">
    <input type="hidden" name="E" value="E" />
    <div class="col-md-2">
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="Triagem" id="Triagem" value="S"<%if Triagem="S" then response.write(" checked ") end if %> /> <label for="Triagem">Módulo Triagem</label>
        </div>
    </div>
    <%= quickfield("multiple", "TriagemProcedimentos", "Procedimentos que exigem triagem", 4, TriagemProcedimentos, "select id, NomeProcedimento from procedimentos where Ativo='on' and sysActive=1 order by NomeProcedimento", "NomeProcedimento", "") %>
    <%= quickfield("multiple", "TriagemEspecialidades", "Especialidades que realizam triagem", 4, TriagemEspecialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>

    <div class="col-md-2">
        <br>
        <button class="btn btn-primary">
            Salvar
        </button>
    </div>
</form>
</div>
<script >
<!--#include file="JQueryFunctions.asp"-->

$("#frmTriagem").submit(function(){
    $.post("ConfigTriagem.asp", $(this).serialize(), function(data){
       $("#divTriagem").html(data);
    });
    return false;
    });


</script>