<!--#include file="connect.asp"-->
<%
LaudoID = req("L")
set l = db.execute("select l.*, p.NomePaciente from laudos l LEFT JOIN pacientes p ON p.id=l.PacienteID WHERE l.id="& LaudoID)
if not l.eof then
    NomePaciente = l("NomePaciente")
    ProfissionalID = l("ProfissionalID")
    if ProfissionalID&""="" then
        %>
        <script>
            $("#modal-table").modal("hide");
            alert("Preencha o laudador.");
        </script>
        <%
    end if
end if

if ProfissionalID&""<>"" then
%>

<div class="panel-heading">
    <span class="panel-title"><i class="far fa-print"></i> Entrega de Laudo <small>&raquo; por <%= session("nameUser") %></small></span>
</div>
<div class="panel-body">
    <div class="col-md-6">
        <div class="row hidden">
            <div class="col-md-12 checkbox-custom checkbox-primary">
                <input type="checkbox" name="Entregue" id="Entregue" value="1" /><label for="Entregue"> Entregue</label>
            </div>
        </div>
        <div class="row">
            <%= quickfield("datepicker", "DataEntrega", "Data", 6, date(), "", "", "") %>
            <%= quickfield("timepicker", "HoraEntrega", "Hora", 6, time(), "", "", "") %>
        </div>
        <div class="row mt10">
            <%= quickfield("text", "Receptor", "Entregue a", 12, NomePaciente, "", "", "") %>
        </div>
    </div>
    <div class="col-md-6">
        <%= quickfield("memo", "ObsEntrega", "Observações", 12, Obs, "", "", " rows='5' ") %>
    </div>

</div>
<div class="panel-footer text-right">

    <div class="btn-group">
        <a href="javascript:saveLaudo('Entrega', 1); openPrint();" class="btn btn-sm btn-info"><i class="far fa-print"></i> ENTREGAR E IMPRIMIR</a>
        <button class="btn btn-sm btn-info dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="far fa-angle-down icon-only"></i></button>
        <ul class="dropdown-menu dropdown-info">
            <li>
                <a href="javascript:saveLaudo('Entrega', 0)"><i class="far fa-exit"></i> SOMENTE ENTREGAR</a>
                <a href="javascript:openPrint()"><i class="far fa-print"></i> SOMENTE IMPRIMIR</a>
            </li>
        </ul>
    </div>

</div>
<%
end if
%>

<script type="text/javascript">
function openPrint(){
	var tk = localStorage.getItem("tk");

	window.open(domain+'print-medical-report?p=<%= l("PacienteID") %>&m=<%= l("FormID") %>&i=<%= l("FormPID") %>&l=<%= l("id") %>&tk='+tk);
}
<!--#include file="JQueryFunctions.asp"-->
</script>