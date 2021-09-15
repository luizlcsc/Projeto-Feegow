<!--#include file="connect.asp"-->
<%
De=date()
Ate=date()
%>
<br>
<div class="panel">
    <div class="panel-body">
        <form method="get" target="_blank" action="PrintStatement.asp">
            <input type="hidden" name="R" value="LogLoginsResultado">
            <div class="clearfix form-actions">
                <div class="row">
                    <%=quickfield("datepicker", "De", "De", 2, De, "", "", "")%>
                    <%=quickfield("datepicker", "Ate", "At&eacute;", 2, Ate, "", "", "")%>
                    <%
                    if session("Admin") = 1 then
                    %>
                        <%=quickField("simpleSelect", "Usuario", "Usuário", 3, "", "select lu.id, Nome from cliniccentral.licencasusuarios lu LEFT JOIN sys_users su on su.id=lu.id where lu.LicencaID="&replace(session("Banco"), "clinic", "")&" and lu.Nome not like '' order by lu.Nome", "Nome", " empty ")%>
                    <%
                    else
                        %>
                        <input type="hidden" name="Usuario" value="<%=session("User")%>">
                        <%
                    end if
                    %>
                </div>

                <div class="col-md-3 pull-right">
                    <label>&nbsp;</label><br>
                    <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Buscar</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script type="text/javascript">
    $("#frmLog").submit(function () {
        $("#logsResult").html("<i class='far fa-cog fa-spin'></i> Carregando...");
        $.post("DefaultLog.asp", $(this).serialize(), function (data) {
            $("#logsResult").html(data);
        });
        return false;
    });

    $(".crumb-active a").html("Logs de Acessos");
    $(".crumb-icon a span").attr("class", "far fa-history");
</script>