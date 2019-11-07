<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Laudos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("lista de laudos");
    $(".crumb-icon a span").attr("class", "fa fa-file-text");
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
                <%= quickfield("simpleSelect", "ProcedimentoID", "Procedimento", 2, "", "select distinct(concat('G', pg.id)) id, concat('&raquo; ', trim(NomeGrupo)) NomeProcedimento from procedimentosgrupos pg inner join procedimentos proc on proc.GrupoID=pg.id where proc.Laudo=1 and proc.sysActive UNION ALL select id, NomeProcedimento from procedimentos where ativo='on' and Laudo", "NomeProcedimento", "") %>
                <div class="col-md-2">
                    <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", "", "", "") %>
                </div>
<%

                if lcase(session("Table"))="funcionarios" or aut("|laudooutrosprofissionaisV|")=1 then
                %>
                    <%= quickfield("simpleSelect", "ProfissionalID", "Profissional", 3, ProfissionalID, "select id, NomeProfissional from profissionais where sysActive and ativo='on' order by NomeProfissional", "NomeProfissional", "") %>
                    <%
                else
                    %>
                    <input type="hidden" name="ProfissionalID" value="<%=ProfissionalID%>">
                    <%
                end if
                %>
                <%= quickfield("simpleSelect", "ConvenioID", "Convênio", 2, "", "select id, NomeConvenio from convenios where sysActive order by NomeConvenio", "NomeConvenio", "") %>
                <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, Unidades, "", "", "")%>
            </div>
            <div class="row mt20">
                <%= quickfield("number", "id", "Identificação do Laudo", 2, id, "", "", "") %>
                <%= quickfield("datepicker", "De", "De", 2, De, "", "", "") %>
                <%= quickfield("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
                <%= quickfield("simpleSelect", "TipoData", "Tipo", 2, "1", "select '1' id, 'Data de criação' TipoData UNION SELECT '2' id, 'Previsão de entrega' TipoData", "TipoData", "empty") %>
                <%'= quickfield("multiple", "Prazo", "Prazo de Entrega", 2, "", "select  'Proxima' id, 'Próxima' Descricao UNION ALL select 'Atrasado', 'Atrasado'", "Descricao", "") %>
                <%= quickfield("multiple", "Status", "Status", 2, "", "select id, Status FROM laudostatus ", "Status", "") %>
                <div class="col-md-2">
                    <button class="btn btn-primary btn-block mt20"><i class="fa fa-search bigger-110"></i> Buscar</button>
                </div>
            </div>

        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-body" id="divListaLaudos">
    </div>
</div>

<script type="text/javascript">
    var whatsAppAlertado = false;

    $("#frmLaudos").submit(function () {
        $.post("listaLaudos.asp", $(this).serialize(), function (data) {
            $("#divListaLaudos").html(data);
        });
        return false;
    });

    $("#frmLaudos").submit();


</script>

