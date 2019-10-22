<!--#include file="connect.asp"-->
<%

%>
<div class="row">
    <form class="form-components">
        <div class="col-md-12">
            <div class="col-md-4">
                <label for="UnimedToken">Token</label>
                <input required type="text" id="UnimedToken" class="form-control">
            </div>

            <div class="col-md-5">
                <label for="PatientCard">Matricula</label>
                <input required type="text" id="PatientCard" class="form-control">
            </div>

            <div class="col-md-3">
                    <br>
                <button class="btn btn-system btn-importar-dados">
                    Importar laudos
                </button>
            </div>
        </div>
    </form>
</div>

<script >

$(document).ready(function() {
    $(".form-components").submit(function() {
        $(".btn-importar-dados").attr("disabled", true);

        importarLaudos($("#UnimedToken").val(), $("#PatientCard").val());

        return false;
    });
});

function importarLaudos(token, card) {

    getUrl("unimed/resultado-laudos", {
            dateStart: "2018-01-01",
            dateEnd: "2019-01-01",
            patientToken: token,
            patientCard: card,
            patientId: "<%=req("PacienteID")%>",
            professionalId: "<% if session("table")="profissionais" then response.write(session("idInTable")) end if %>"
    }, function(data) {
        alert(data.content);
    });

}

</script>