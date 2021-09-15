<!--#include file="connect.asp"-->
<%
GradeID = req("X")

%>
<div class="row">
<%
set GradeSQL = db.execute("SELECT * FROM assfixalocalxprofissional WHERE id="&GradeID)

if not GradeSQL.eof then
    InicioVigencia= GradeSQL("InicioVigencia")
    FimVigencia= GradeSQL("FimVigencia")
    DiaSemana= GradeSQL("DiaSemana")
    ProfissionalID= GradeSQL("ProfissionalID")
    LocalID= GradeSQL("LocalID")

    if InicioVigencia&"" <> "" or FimVigencia&"" <> "" then
        if InicioVigencia&"" <> "" then
            sqlVigencia = " and a.Data >= "&mydatenull(InicioVigencia)
        end if
        if FimVigencia&"" <> "" then
            sqlVigencia = " and a.Data <= "&mydatenull(FimVigencia)
        end if
    end if

    sql = "SELECT a.id, a.Data, a.PacienteID, a.Hora, sta.StaConsulta, proc.NomeProcedimento, prof.NomeProfissional, pac.NomePaciente, pac.Tel1, pac.Cel1 FROM agendamentos a " &_
    " INNER JOIN pacientes pac ON pac.id=a.PacienteID"&_
    " LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID"&_
    " INNER JOIN staconsulta sta ON sta.id=a.StaID"&_
    " INNER JOIN profissionais prof ON prof.id=a.ProfissionalID"&_
    " WHERE a.Data>=CURDATE() AND ProfissionalID="&ProfissionalID&" AND a.StaID!= 11 AND dayofweek(a.Data)="&DiaSemana&""&sqlVigencia
    set AgendamentosNoPeriodoSQL = db.execute(sql)

    if not AgendamentosNoPeriodoSQL.eof then
    %>
<div class="col-md-12">
    <div class="alert alert-default">
        <strong>Atenção!</strong> Existem agendamentos que ficarão sem um grade definida.  <br>
        Os agendamentos abaixo <strong>não serão</strong> excluídos e nem desmarcados.
    </div>

    <div class="col-md-1 col-md-offset-11 mb20">
        <button type="button" class="btn btn-sm  btn-success" title="Gerar Excel" onclick="downloadExcel()"><i class="far fa-table"></i></button>
    </div>

    <div id="table-agendamentos-sem-grade">
    <table class="table table-striped">
        <thead>
            <tr class="primary">
                <th>Data</th>
                <th>Hora</th>
                <th>Status</th>
                <th>Profissional</th>
                <th>Procedimento</th>
                <th>Paciente</th>
                <th>Telefone</th>
                <th></th>
            </tr>
        </thead>
         <tbody>
        <%
            while not AgendamentosNoPeriodoSQL.eof
                NomePaciente = AgendamentosNoPeriodoSQL("NomePaciente")
                TextoWhatsApp = "Olá "&NomePaciente&"! Precisaremos desmarcar o seu agendamento do dia "&AgendamentosNoPeriodoSQL("Data")&".  Para quando podemos remarcar?"
                CelWhatsApp = "55"&AgendamentosNoPeriodoSQL("Cel1")
                CelWhatsApp = replace(CelWhatsApp, "(", "")
                CelWhatsApp = replace(CelWhatsApp, ")", "")
                CelWhatsApp = replace(CelWhatsApp, "-", "")
                CelWhatsApp = replace(CelWhatsApp, " ", "")
                HoraAgendamento = AgendamentosNoPeriodoSQL("Hora")
                if HoraAgendamento&""<>"" then
                    HoraAgendamento = formatdatetime(HoraAgendamento, 4)
                end if
                %>
                     <tr>
                         <td><%=AgendamentosNoPeriodoSQL("Data")%></td>
                         <td><%=HoraAgendamento%></td>
                         <td><%=AgendamentosNoPeriodoSQL("StaConsulta")%></td>
                         <td><%=AgendamentosNoPeriodoSQL("NomeProfissional")%></td>
                         <td><%=AgendamentosNoPeriodoSQL("NomeProcedimento")%></td>
                         <td><a href="?P=Pacientes&Pers=1&I=<%=AgendamentosNoPeriodoSQL("PacienteID")%>"><%=NomePaciente%></a></td>
                         <td><a target="_blank" href="https://api.whatsapp.com/send?phone=<%=CelWhatsApp%>&text=<%=TextoWhatsApp%>"><%=AgendamentosNoPeriodoSQL("Cel1")%></a> </td>
                         <td><a target="_blank" href="?P=Agenda-1&Pers=1&AgendamentoID=<%=AgendamentosNoPeriodoSQL("id")%>" class="btn btn-primary btn-xs"><i class="far fa-external-link"></i></a></td>
                     </tr>
                <%
            AgendamentosNoPeriodoSQL.movenext
            wend
            AgendamentosNoPeriodoSQL.close
            set AgendamentosNoPeriodoSQL=nothing
            %>
         </tbody>

    </table>
    </div>
</div>
<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>

<div class="col-md-3 col-md-offset-9">
    <button class="btn btn-danger mt20" onclick="ForceDeleteGrade()" type="button"><i class="far fa-trash"></i> Deletar grade mesmo assim</button>
</div>
        <%
    end if

end if

%>
</div>
<script >
function downloadExcel(){
    $("#htmlTable").val($("#table-agendamentos-sem-grade").html());
    var tk = localStorage.getItem("tk");

    $("#formExcel").attr("action", domain+"reports/download-excel?title=Extrato&tk="+tk).submit();
}

function ForceDeleteGrade() {
    ajxContent('Horarios-1&T=Profissionais&X=<%=GradeID%>&Force=1', <%=ProfissionalID%>, 1, 'divHorarios');
    closeComponentsModal();
}

</script>