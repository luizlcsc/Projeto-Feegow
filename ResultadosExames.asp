<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
subTitulo = "Resultados Exames"
%>

<div class="panel timeline-add">
    <div class="panel-heading">
        <span class="panel-title"> <%=subTitulo %>
        </span>
    </div>

    <div class="panel">
        <div class="panel-body">
            <div class="app" style="padding-top: 11px;">
                <i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
            </div>
            
            <script type="text/javascript">
                getUrl("unimed/resultado-exames", {
                    patientId: "<%=req("PacienteID")%>",
                    sysUser: "<%=session("User")%>"
                }, function(data) {
                    $(".app").hide();
                    $(".app").html(data);
                    $(".app").fadeIn('slow');
                });
            </script>           
        </div>
    </div>
</div>