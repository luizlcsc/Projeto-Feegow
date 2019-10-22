<!--#include file="connect.asp"-->
<%
if req("AgendamentoID") then
    set AgendamentoSQL = db.execute("SELECT age.id, age.PacienteID, age.Data, age.Hora, pac.NomePaciente, pac.Nascimento, age.Procedimentos, prof.NomeProfissional, IF(age.rdValorPlano='P', 'Convênio', 'Particular') Forma FROM agendamentos age LEFT JOIN pacientes pac ON pac.id=age.PacienteID LEFT JOIN profissionais prof ON prof.id=age.ProfissionalID WHERE age.id="&req("AgendamentoID"))
    if not AgendamentoSQL.EOF then
        Agendamento = AgendamentoSQL("id")&""
        Prontuario = AgendamentoSQL("PacienteID")&""
        Data = AgendamentoSQL("Data")&""
        Hora = formatdatetime(AgendamentoSQL("Hora"),4)&""
        Paciente = AgendamentoSQL("NomePaciente")&""
        Nascimento = AgendamentoSQL("Nascimento")&""
        Procedimentos = AgendamentoSQL("Procedimentos")&""
        Profissional = AgendamentoSQL("NomeProfissional")&""
        Forma = AgendamentoSQL("Forma")&""

        ModeloImpressaoAgendamento =""

        set ImpressoAgenda = db.execute("SELECT Agendamentos FROM impressos WHERE id=1")
        if not ImpressoAgenda.EOF then
            ModeloImpressaoAgendamento = ImpressoAgenda("Agendamentos")&""
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.ID]", Agendamento)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Prontuario]", Prontuario)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.Data]", Data)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.Hora]", Hora)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Nome]", Paciente)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Nascimento]", Nascimento)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Procedimentos.Nome]", Procedimentos)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Profissional.Nome]", Profissional)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Forma.Nome]", Forma)

            response.write(ModeloImpressaoAgendamento)

        end if
    end if
end if
%>
<script>
print();
</script>
