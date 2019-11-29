<!--#include file="connect.asp"-->
<style>
.inputGroup {
  background-color: #fff;
  display: block;
  position: relative;
}
.inputGroup label {
  padding: 12px 30px;
  width: 100%;
  display: block;
  text-align: center;
  color: #3C454C;
  cursor: pointer;
  position: relative;
  z-index: 2;
  transition: color 200ms ease-in;
  overflow: hidden;
  border-radius: 5px;
  border: 1px solid #f2f2f2;
}
.inputGroup label:before {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  content: '';
  background-color: #f1f1f1;
  position: absolute;
  left: 50%;
  top: 50%;
  opacity: 0;
  z-index: -1;
}

.inputGroup input:checked ~ label:before {
  -webkit-transform: translate(-50%, -50%) scale3d(56, 56, 1);
          transform: translate(-50%, -50%) scale3d(56, 56, 1);
  opacity: 1;
}

.inputGroup input {
    opacity: 0;
}

.inputGroup input{
    opacity: 0;
}
.col-centered{
float: none;
    margin: 0 auto;
}
</style>

<%
obs = req("obs")
AgendamentoID = req("agendamentoId")
CanalID = req("CanalID")

set AgendamentoSQL = db.execute("SELECT pac.NomePaciente, proc.NomeProcedimento, prof.NomeProfissional, age.Data, age.Hora, age.Notas FROM agendamentos age "&_
"INNER JOIN pacientes pac ON pac.id=age.PacienteID "&_
"INNER JOIN profissionais prof ON prof.id=age.ProfissionalID "&_
"INNER JOIN procedimentos proc ON proc.id=age.TipoCompromissoID "&_
"WHERE age.id="&treatvalzero(AgendamentoID))
%>
<input type="hidden" id="agendamento-id-confirmacao" value="<%=AgendamentoID%>">
<%
if not AgendamentoSQL.eof then
    %>
<div class="row">
    <div class="col-md-6">
        <strong>Paciente:</strong> <%=AgendamentoSQL("NomePaciente")%>
    </div>
    <div class="col-md-6">
        <strong>Profissional:</strong> <%=AgendamentoSQL("NomeProfissional")%>
    </div>
    <div class="col-md-6">
        <strong>Procedimento:</strong> <%=AgendamentoSQL("NomeProcedimento")%>
    </div>
    <div class="col-md-6">
        <strong>Observações:</strong> <%=AgendamentoSQL("Notas")%>
    </div>
</div>
    <%
end if
%>
<div class="row">
    <%

    StatusID=req("statusId")
    set StatusSQL = db.execute("SELECT id,StaConsulta FROM staConsulta WHERE id in (1,11,7)")

    while not StatusSQL.eof
    %>
    <div class="col-md-4">
        <div class="inputGroup">
            <input class="status-radio" id="status-<%=StatusSQL("id")%>" <% if StatusID&""=StatusSQL("id")&"" then %>checked<%end if%> name="status-confirmacao" value="<%=StatusSQL("id")%>" type="radio"/>
            <label for="status-<%=StatusSQL("id")%>" class="radio"> <img src='assets/img/<%=StatusSQL("id")%>.png'/> <%=StatusSQL("StaConsulta")%></label>
        </div>
    </div>
    <%

    StatusSQL.movenext
    wend
    StatusSQL.close
    set StatusSQL=nothing
%>
</div>

<div class="row">

<%
if true then
    set CanaisSQL = db.execute("SELECT * FROM cliniccentral.canal_contato_paciente WHERE Selecionavel=1")

    while not CanaisSQL.eof
    %>
<div class="col-md-3">
    <div class="inputGroup">
        <input class="status-radio" id="canal-<%=CanaisSQL("id")%>" <% if CanaisSQL("id")&"" = CanalID&"" then %>checked<% end if%> name="canal" value="<%=CanaisSQL("id")%>" type="radio"/>
        <label for="canal-<%=CanaisSQL("id")%>" class="radio">
        <%=CanaisSQL("NomeCanal")%></label>
    </div>
</div>
    <%
    CanaisSQL.movenext
    wend
    CanaisSQL.close
    set CanaisSQL=nothing
end if
    %>
</div>
<div class="row">

    <div class="col-md-12">
        <label for="ObsConfirmacao">Observações</label>
        <textarea name="ObsConfirmacao" id="ObsConfirmacao" rows="3" class="form-control"><%=obs%></textarea>
    </div>
</div>
<script >
setTimeout(function() {
  $("#ObsConfirmacao").focus();
},500);
</script>