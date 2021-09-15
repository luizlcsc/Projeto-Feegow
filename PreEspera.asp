<!--#include file="connect.asp"-->
<%
session("Guiche") = request.Cookies("Guiche")
%>
<br>
<script type="text/javascript">
    $(".crumb-active a").html("Pré-espera");
</script>
<div class="panel">
    <div class="panel-row">
        <div class="row">
            <div class="col-md-12">
            <div class="clearfix form-actions">
                <%=quickfield("text", "Guiche", "Nome do seu guichê", 4, request.Cookies("Guiche"), "", "", " required") %>
                <div class="col-xs-2">
                    <label>&nbsp;</label><br />
                    <button type="button" onclick="saveGuiche('Guiche', 0, $('#Guiche').val())" class="btn btn-sm btn-primary btn-block"><i class="far fa-save"> Salvar</i></button>
                </div>
            </div>
        </div>
        </div>

            <div class="row" id="listaPreEspera" style="margin-top: 20px">
            <div class="col-md-12">
                <%server.execute("listaPreEspera.asp") %>
            </div>
            </div>
        <br>
    </div>
</div>

<script type="text/javascript">

    function atualizaPacienteGuiche(Campo, id, Ticket) {
        setTimeout(function() {
            if (id==-1){
                id = $("#"+Campo).val();
            }
            $.post("saveGuiche.asp", {
              Action: "AtualizaPaciente",
              PacienteID: id,
              Ticket: Ticket
            }, function (data) {
              eval(data);
            });
        },100);
    }
    function saveGuiche(Action, Ticket, Val) {
        $.post("saveGuiche.asp", {
            Action: Action,
            Ticket: Ticket,
            Val: Val
        }, function (data) {
            eval(data);
            listaPreEspera()
        });
    }

    function listaPreEspera() {
        $.get("listaPreEspera.asp", function (data) {
            $("#listaPreEspera").html(data);
        });
    }
</script>