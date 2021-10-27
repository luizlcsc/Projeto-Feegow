<!--#include file="connect.asp"-->
<% 'if session("Banco")="clinic2803" then response.Redirect("./?P=error&Pers=1") end if %>
<form method="post" action="" id="frmLog">
    <br />
    <div class="panel">
        <div class="panel-body">
            <%=quickfield("datepicker", "De", "De", 2, date(), "", "", "") %>
            <%=quickfield("datepicker", "Ate", "Até", 2, date(), "", "", "") %>
            <%=quickfield("users", "Usuario", "Usuário", 2, ref("Usuario"), "", "", "") %>
            <%=quickfield("simpleSelect", "Recurso", "Recurso", 2, "", "select tableName id, name Nome from cliniccentral.sys_resources order by Nome", "Nome", " empty required no-select2 ") %>
            <div class="col-md-2">
                <label>Operação</label><br />
                <span class="checkbox-custom">
                    <input type="checkbox" id="OperacaoI" name="Operacao" value="I" /><label for="OperacaoI">Inserção</label>
                </span>
                <span class="checkbox-custom">
                    <input type="checkbox" id="OperacaoA" name="Operacao" value="A" /><label for="OperacaoA">Alteração</label>
                </span>
                <span class="checkbox-custom">
                    <input type="checkbox" id="OperacaoX" name="Operacao" value="X" /><label for="OperacaoX">Exclusão</label>
                </span>
            </div>
            <div class="col-md-2">
                <label>&nbsp;</label><br />
                <button class="btn btn-primary">BUSCAR</button>
            </div>
        </div>
    </div>
</form>

<div id="logsResult" class="panel"></div>

<script type="text/javascript">
    $("#frmLog").submit(function () {
        $("#logsResult").html("<i class='far fa-cog fa-spin'></i> Carregando...");
        $.post("DefaultLog.asp", $(this).serialize(), function (data) {
            $("#logsResult").html(data);
        });
        return false;
    });

    $(".crumb-active a").html("Logs de Ações");
    $(".crumb-icon a span").attr("class", "far fa-history");
</script>