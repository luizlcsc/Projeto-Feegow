<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Coleta");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("lista de Conferência");
    $(".crumb-icon a span").attr("class", "far fa-file-text");
</script>

<%
De = date()
Ate = date()
if req("De")<>"" then
    De = req("De")
end if
if req("PacienteID")<>"" then
    PacienteID = req("PacienteID")
end if

Unidades = "|"& session("UnidadeID") &"|"

if lcase(session("Table"))="profissionais" then
    ProfissionalID = session("idInTable")
    Unidades = ""
end if
%>

<form id="frmLaudos">
    <div class="panel">
        <div class="panel-body mt20">
            <div class="row">
                <%= quickfield("simpleSelect", "labid", "Laboratório", 2, "1", "SELECT id, nomelaboratorio FROM cliniccentral.labs ORDER BY nomelaboratorio", "nomelaboratorio", "empty") %>
                <%= quickfield("simpleSelect", "ProcedimentoID", "Procedimento", 2, "", "select distinct(concat('G', pg.id)) id, concat('&raquo; ', trim(NomeGrupo)) NomeProcedimento from procedimentosgrupos pg inner join procedimentos proc on proc.GrupoID=pg.id where proc.Laudo=1 and proc.sysActive  AND integracaopleres  = 'S' UNION ALL select id, NomeProcedimento from procedimentos where ativo='on' and Laudo AND integracaopleres  = 'S'", "NomeProcedimento", "") %>
                <div class="col-md-2">
                    <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", "", "", "") %>
                </div>
                <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, "", "", "", "")%>
            </div>
            <div class="row mt20">

                <%= quickfield("datepicker", "Data", "Data", 2, De, "", "", "") %>
                <%= quickfield("simpleSelect", "TipoData", "Tipo", 2, "1", "select '1' id, 'Data de criação' TipoData UNION SELECT '2' id, 'Previsão de entrega' TipoData", "TipoData", "empty") %>
                <%= quickfield("multiple", "Status", "Status", 2, "", "select id, Status FROM laudostatus ", "Status", "") %>
                <div class="col-md-2">
                    <button class="btn btn-primary btn-block mt20"><i class="far fa-search bigger-110"></i> Buscar</button>
                </div>
            </div>

        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-body" id="divListaExames">
    </div>
</div>

<script type="text/javascript">
    var whatsAppAlertado = false;

    $("#frmLaudos").submit(function () {
        $.post("listaLaudos.asp", $(this).serialize(), function (data) {
            $("#divListaExames").html(data);
        });
        return false;
    });

    $("#frmLaudos").submit();


</script>

