<!--#include file="connect.asp"-->
<%
if req("AgendamentoID") then
    set AgendamentoSQL = db.execute("SELECT age.id, age.PacienteID, age.Data, age.Hora, pac.NomePaciente,  pac.Cep, pac.CPF, sex.Nomesexo, pac.Nascimento, age.Procedimentos, prof.NomeProfissional, IF(age.rdValorPlano='P', 'Convênio', 'Particular') Forma"&_ 
                    " FROM agendamentos age LEFT JOIN pacientes pac ON pac.id=age.PacienteID "&_
                    " LEFT JOIN profissionais prof ON prof.id=age.ProfissionalID"&_
                    " left join sexo sex on sex.id = pac.Sexo"&_ 
                    " WHERE age.id="&req("AgendamentoID"))

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
        CPF = AgendamentoSQL("CPF")&""
        Sexo = AgendamentoSQL("Nomesexo")&""
        Cep = AgendamentoSQL("Cep")&""

        ModeloImpressaoAgendamento =""

        set ImpressoAgenda = db.execute("SELECT Agendamentos FROM impressos WHERE id=1")
        if not ImpressoAgenda.EOF then
            ModeloImpressaoAgendamento = ImpressoAgenda("Agendamentos")&""
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.ID]", Agendamento)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.Data]", Data)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.Hora]", Hora)
            
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Procedimentos.Nome]", Procedimentos)
            
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Profissional.Nome]", Profissional)
            
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Prontuario]", Prontuario)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Nome]", Paciente)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Nascimento]", Nascimento)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.CPF]", CPF)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Sexo]", Sexo)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Cep]", Cep)
            
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Forma.Nome]", Forma)


            response.write(ModeloImpressaoAgendamento)

        end if
    end if
end if
%>
<script>
print();
</script>
