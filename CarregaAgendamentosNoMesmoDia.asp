<!--#include file="connect.asp"-->
<%
Data=req("Data")
PacienteID=req("PacienteID")
StaID=req("StaID")

set StatusSQL = db.execute("SELECT StaConsulta, id FROM staconsulta WHERE id="&StaID)

set AgendamentoBaseSQL = db.execute("SELECT a.Data, pac.NomePaciente FROM agendamentos a INNER JOIN pacientes pac ON pac.id=a.PacienteID WHERE Data="&mydatenull(Data)&" AND PacienteID="&treatvalzero(PacienteID)&" LIMIT 1")
%>
 <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">&times;</button>
    <h4 class="modal-title">Agendamentos no mesmo dia</h4>
</div>
<div class="modal-body">
    <%
     set AgendamentosSQL = db.execute("select a.PacienteID, a.id, a.Notas, a.Data, a.id, a.ProfissionalID, a.LocalID, a.StaID, s.StaConsulta, a.Hora, pac.NomePaciente, pac.Cel1, trat.Tratamento, concat(if(isnull(pro.NomeSocial) or pro.NomeSocial='', pro.NomeProfissional, pro.NomeSocial)) NomeProfissional,"&_
                 "esp.Especialidade, proc.NomeProcedimento, l.Nomelocal, eq.NomeEquipamento, a.rdValorPlano, a.ValorPlano, conv.NomeConvenio, tab.NomeTabela FROM agendamentos a LEFT JOIN staconsulta s ON a.StaID=s.id LEFT JOIN pacientes pac ON pac.id=a.PacienteID "&_
                 "LEFT JOIN profissionais pro ON pro.id=a.ProfissionalID "&_
                 "LEFT JOIN tratamento trat ON trat.id=pro.TratamentoID "&_
                 "LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN locais l ON l.id=a.LocalID "&_
                 "LEFT JOIN equipamentos eq ON eq.id=a.EquipamentoID LEFT JOIN convenios conv ON conv.id=a.ValorPlano LEFT JOIN tabelaparticular tab ON tab.id=a.TabelaParticularID "&_
                 "WHERE Data="&mydatenull(Data)&" AND PacienteID="&treatvalzero(PacienteID)&" ORDER BY Hora")

%>
<strong>Paciente: <%=AgendamentoBaseSQL("NomePaciente")%></strong> <br>
<strong>Data: <%=AgendamentoBaseSQL("Data")%></strong> <br> <br>

<div class="alert alert-default">
  <strong>Atenção!</strong> Este paciente possui mais de um agendamento para esta data. <br> <br>
  Deseja alterar todos os agendamentos para <strong><%=StatusSQL("StaConsulta")%></strong> <img src='assets/img/<%=StatusSQL("id")%>.png'>?
</div>

 <table id="datatable2" class="table table-hover table-striped table-bordered">
        <thead>
            <tr>
                <th width="1%"></th>
                <th>Hora</th>
                <th>Profissional</th>
                <th>Procedimento</th>
                <th>Valor/Convênio</th>
                <th>Observações</th>
            </tr>
        </thead>
        <tbody>
<%
     while not AgendamentosSQL.eof
        if AgendamentosSQL("rdValorPlano")="V" then
            if  aut("valordoprocedimentoV")=0 then
                Convenio = "Particular"
            else
                Convenio = "R$ "& fn(AgendamentosSQL("ValorPlano"))
            end if
        else
            Convenio = AgendamentosSQL("NomeConvenio")
        end if

        %>
<tr>
    <td>
        <div class="checkbox-custom checkbox-primary">
            <input checked type="checkbox" class="ace " name="AgendamentoMarcadoID" id="AgendamentoID<%=AgendamentosSQL("id")%>" value="<%=AgendamentosSQL("id")%>">
            <label class="checkbox" for="AgendamentoID<%=AgendamentosSQL("id")%>"></label>
        </div>
    </td>
    <td><%=formatdatetime(AgendamentosSQL("Hora"), 4)%></td>
    <td><%=AgendamentosSQL("NomeProfissional")%></td>
    <td><%=AgendamentosSQL("NomeProcedimento")%></td>
    <td><%=Convenio%></td>
    <td><%=AgendamentosSQL("Notas")%></td>
</tr>
        <%
     AgendamentosSQL.movenext
     wend
     AgendamentosSQL.close
     set AgendamentosSQL=nothing
    %>
    </tbody>
</table>
</div>
<div class="modal-footer">
    <button type="button" class="btn btn-default" data-dismiss="modal">Cancelar</button>
    <button type="button" class="btn btn-primary" onclick="ConfirmarAlteracao()">Alterar selecionados</button>
</div>
<script >
    function ConfirmarAlteracao() {
        var agendamentos=[];
        var $agendamentosMarcados = $("input[name=AgendamentoMarcadoID]");

        $.each($agendamentosMarcados, function() {
            if($(this).prop("checked")){
                agendamentos.push($(this).val());
            }
        });

        $.post("AlteraStatusAgendamento.asp", {
           AgendamentosID: agendamentos,
           S: '<%=StaID%>',
           PacienteID: '<%=PacienteID%>'
        }, function(data) {
            $("#modal-table").modal("hide");
            eval(data);
        });
    }
</script>