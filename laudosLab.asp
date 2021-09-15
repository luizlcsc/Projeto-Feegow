<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Laudos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Lista de Laudos Laboratoriais (via integração)");
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

sqlProfissionais = "SELECT p.id, p.NomeProfissional " &_
             " FROM profissionais p " &_
             " WHERE sysActive AND ativo='on'  " &_
             " ORDER BY NomeProfissional "
%>


    <div class="panel">
        <div class="panel-body mt20">
            <div class="row">
                <%' = quickfield("simpleSelect", "ProcedimentoID", "Procedimento", 2, "", "select distinct(concat('G', pg.id)) id, concat('&raquo; ', trim(NomeGrupo)) NomeProcedimento from procedimentosgrupos pg inner join procedimentos proc on proc.GrupoID=pg.id where proc.Laudo=1 and proc.sysActive UNION ALL select id, NomeProcedimento from procedimentos where ativo='on' and Laudo", "NomeProcedimento", "") %>
                <div class="col-md-2">
                    <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", "", "", "") %>
                </div>
                <!--<%=quickfield("simpleSelect", "ProfissionalID", "Profissional", 3, ProfissionalID, sqlProfissionais, "NomeProfissional", "") %>
                <input type="hidden" name="ProfissionalID" value="<%=ProfissionalID%>">                   -->
                 <% 
                    IF session("UnidadeID") = 0 THEN
                        response.write(quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, "", "", "", ""))
                    END IF                    
                %>
            </div>
            <div class="row mt20">
                <%= quickfield("number", "id", "Identificação do Laudo", 2, id, "", "", "") %>
                <%= quickfield("datepicker", "De", "De", 2, De, "", "", "") %>
                <%= quickfield("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
                <%= quickfield("simpleSelect", "TipoData", "Tipo", 2, "1", "select '1' id, 'Data de criação' TipoData UNION SELECT '2' id, 'Previsão de entrega' TipoData", "TipoData", "empty") %>
                <%= quickfield("multiple", "Status", "Status", 2, "", "select id, Status FROM laudostatus ", "Status", "") %>
                <div class="col-md-2">
                    <button class="btn btn-primary btn-block mt20" onclick="buscalaudos()"><i class="far fa-search bigger-110"></i> Buscar</button>
                </div>
            </div>

        </div>
    </div>
    


<div class="panel">
    <div class="panel-heading">
      <span class="panel-title">
        <span class="far fa-table"></span>Lista de Laudos Laboratoriais</span>
      <div class="pull-right">

      </div>
    </div>
    <div class="panel-body pn" id="divListaLaudos">
        
    </div>
</div>
<script type="text/javascript">
    function buscalaudos()
    {
        $("#divListaLaudos").html('<table width="100%"><tbody><TR><TD style="text-align: center;"><i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i></TD></TR></tbody></table>');
        var id  = $("#id").val();
        var datade = $("#De").val();
        var dataate = $("#Ate").val();
        var tipodata = $("#TipoData").val();
        var unidade = $("#Unidades").val();
        var profissional = $("#ProfissionalID").val();
        var status = $("#Status").val();
        var paciente = $("#PacienteID").val();
        postUrl("labs-integration/listar-laudos",{id:id,datade:datade, dataate:dataate, tipodata:tipodata, unidade:unidade, profissional:profissional, status:status, paciente:paciente}, function(data) {
            $("#divListaLaudos").hide();
            $("#divListaLaudos").html(data);
            $("#divListaLaudos").fadeIn('slow');
        });
    }

</script>


