<!--#include file="connect.asp"-->
<br>
<div class="panel">
    <div class="panel-body">
        <div class="row">
            <div class="col-md-4">
                <%= selectInsert("Buscar por paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", " ", "", "") %>
            </div>

            <%=quickField("empresa", "UnidadeID", "Unidade da pendência", 3, UnidadeID, "", "", "")%>

            <div class="col-md-3">
                <%= selectInsert("Buscar por procedimento", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " ", "", "") %>
            </div>

            <div class="col-md-2">
                <br>
                <button type="button" class="btn btn-primary btn-block">Buscar</button>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <br>
                <table class="table table-striped">
                    <thead>
                        <tr class="success">
                            <th>Paciente</th>
                            <th>Zona</th>
                            <th>Itens</th>
                            <th>Data</th>
                            <th>Hora</th>
                            <th>Status</th>
                            <th>Aguardando paciente</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        set PendenciasSQL = db.execute("SELECT pend.*, pac.NomePaciente, ps.NomeStatus FROM pendencias pend LEFT JOIN pacientes pac ON pac.id= pend.PacienteID LEFT JOIN pendenciasstatus ps ON ps.id=pend.StatusID ORDER BY pend.sysDate")
                        while not PendenciasSQL.eof
                            %>
                            <tr>
                                <th><%=PendenciasSQL("NomePaciente")%></th>
                                <th><%=PendenciasSQL("Zonas")%></th>
                                <th>1</th>
                                <th><%=PendenciasSQL("Datas")%></th>
                                <th><%=PendenciasSQL("Horarios")%></th>
                                <th><%=PendenciasSQL("NomeStatus")%></th>
                                <th></th>
                                <th>
                                    <button type="button" class="btn btn-xs btn-primary"><i class="far fa-edit"></i></button>
                                    <button type="button" class="btn btn-success btn-xs"><i class="far fa-check"></i></button>
                                    <button type="button" class="btn btn-xs btn-danger"><i class="far fa-trash"></i></button>
                                </th>
                            </tr>

                            <%
                        PendenciasSQL.movenext
                        wend
                        PendenciasSQL.close
                        set PendenciasSQL = nothing
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script >

    $(".crumb-active a").html("Pendências");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "far fa-exclamation-circle");

</script>