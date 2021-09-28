<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Laudos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("lista de laudos");
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
                <%= quickfield("simpleSelect", "ProcedimentoID", "Procedimento", 2, "", "select distinct(concat('G', pg.id)) id, concat('&raquo; ', trim(NomeGrupo)) NomeProcedimento from procedimentosgrupos pg inner join procedimentos proc on proc.GrupoID=pg.id where proc.Laudo=1 and proc.sysActive UNION ALL select id, NomeProcedimento from procedimentos where ativo='on' and Laudo", "NomeProcedimento", "empty ") %>
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
                <%= quickfield("simpleSelect", "ConvenioID", "Convênio", 2, "", "select id, NomeConvenio from convenios WHERE sysActive=1 AND ativo='on' order by NomeConvenio", "NomeConvenio", "") %>
                <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, "", "", "", "")%>
            </div>
            <div class="row mt20">
                <%= quickfield("number", "id", "Identificação do Laudo", 2, id, "", "", "") %>
                <%= quickfield("datepicker", "De", "De", 2, De, "", "", "") %>
                <%= quickfield("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
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
    <div class="panel-heading">
      <span class="panel-title">
        <span class="far fa-table"></span>Lista de laudos</span>
      <div class="pull-right">

      </div>
    </div>
    <div class="panel-body pn" id="divListaLaudos">
    </div>
</div>

<script type="text/javascript">
    var whatsAppAlertado = false;

    $(function () {
        $("#frmLaudos").submit(function () {
            var carregando  = ' <div class=\"panel-body pn\" id=\"divListaLaudos\" style=\"text-align: center;\"> <i class=\"far fa-circle-o-notch fa-spin\" style="text-align: center; margin: 30px;"></i>  </div>';
            $("#divListaLaudos").html(carregando);
            $.post("listaLaudos.asp", $(this).serialize(), function (data) {
                $("#divListaLaudos").html(data);
            });
            return false;
        });    

        var url_string = window.location.href;
        var url = new URL(url_string);
        const paciente_id = url.searchParams.get("PacienteID");
        const data_abertura = url.searchParams.get("De");
        
        if(paciente_id){
            $("#frmLaudos").submit();
        }
    });

    function entrega(I,tipo) {
            $("#modal-table").modal("show");
            $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
            if (tipo == 'html')
            {
                $.post("laudoEntrega.asp?L="+I, "", function (data) { $("#modal").html(data) });
            } 
            else
            {
                $.post("laudoEntregaPDF.asp?L="+I, "", function (data) { $("#modal").html(data) });
            }
    }
</script>

