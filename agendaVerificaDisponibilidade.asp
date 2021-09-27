<!--#include file="connect.asp"-->
<%
profissionalID = ref("profissionalID")&""
pacienteID = ref("pacienteID")&""
data = ref("data")&""
hora = ref("hora")&""
PropostaID = ref("PropostaID")&""
hora = left(hora,2)&":"&mid(hora, 3, 2)

sqlTotalAgendamento = "SELECT count(id) >= 1 as existeAgendamento "&_
                      "  FROM agendamentos "&_
                      " WHERE ProfissionalID = "&profissionalID&_
                      "   AND Hora = '"&hora&"'"&_
                      "   AND Data = '"&mydate(data)&"'"&_
                      "   AND PacienteID <> "&pacienteID
'response.write(sqlTotalAgendamento)
resTotalAgendamento = db.execute(sqlTotalAgendamento)

if ccur(resTotalAgendamento("existeAgendamento")) = 1 then
%>
    alert("Já existe agendamento neste horário para outro paciente")
<%
else 
%>
    $.post("pendenciasUtilities.asp",{
        acao: "abrirModalRestricaoPreparo",
        ProcedimentoID: ProcedimentoID,
        ProfissionalID: ProfissionalID,
        PropostaID: null
    }, function(data){
        eval(data)
    })
<%
end if
%>