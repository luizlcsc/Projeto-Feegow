<!--#include file="connect.asp"-->
<%
AgendamentoID=ref("A")
AgendamentosID=ref("AgendamentosID[]")
StatusID=ref("S")

Forcar=False

if AgendamentoID<> "" then
    AgendamentosID=AgendamentoID
else
    if AgendamentosID="" then
        Response.End
    end if
    Forcar=True
end if

set AgendamentoSQL = db.execute("SELECT * FROM agendamentos WHERE id in ("&AgendamentosID&")")

set AgendamentosNoMesmoDiaSQL = db.execute("SELECT count(id)Qtd FROM agendamentos WHERE Data="&mydatenull(AgendamentoSQL("Data"))&" AND PacienteID="&AgendamentoSQL("PacienteID"))

if cint(AgendamentosNoMesmoDiaSQL("Qtd"))>1 and Forcar=False then
    %>

    $("#modal-table").modal("show");
    $.get("CarregaAgendamentosNoMesmoDia.asp", {Data: "<%=AgendamentoSQL("Data")%>",StaID:"<%=StatusID%>" , PacienteID:"<%=AgendamentoSQL("PacienteID")%>"}, function (data) {
        $("#modal").html(data);
    });
    <%
else

    db.execute("UPDATE agendamentos SET StaID="&treatvalzero(StatusID)&" WHERE id in ("&AgendamentosID&")")
    db.execute("insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID)  "&_
    "(SELECT PacienteID, ProfissionalID, TipoCompromissoID, '', Data, Hora, StaID, '"&session("User")&"', 0,'Alteração de status', 'R', id FROM agendamentos WHERE id in ("&AgendamentosID&"))")
    %>

    showMessageDialog("Status alterado.", "success");
    $("#frm-filtros").submit();
    getUrl("patient-interaction/get-appointment-events", {appointmentId: "<%=AgendamentosID%>", sms: true, email: true })

    <%
end if
%>