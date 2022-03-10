<!--#include file="connect.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->
<%
if req("AgendamentoID") then
    set AgendamentoSQL = db.execute("SELECT age.id, age.PacienteID, age.Data, age.Hora, pac.NomePaciente, pac.Nascimento, age.Procedimentos, prof.id AS ProfissionalID, prof.NomeProfissional, IF(age.rdValorPlano='P', 'Convênio', 'Particular') Forma FROM agendamentos age LEFT JOIN pacientes pac ON pac.id=age.PacienteID LEFT JOIN profissionais prof ON prof.id=age.ProfissionalID WHERE age.id="&req("AgendamentoID"))
    if not AgendamentoSQL.EOF then
        Agendamento = AgendamentoSQL("id")&""
        Prontuario = AgendamentoSQL("PacienteID")&""
        Data = AgendamentoSQL("Data")&""
        Hora = formatdatetime(AgendamentoSQL("Hora"),4)&""
        Paciente = AgendamentoSQL("NomePaciente")&""
        Nascimento = AgendamentoSQL("Nascimento")&""
        Procedimentos = AgendamentoSQL("Procedimentos")&""
        Profissional = AgendamentoSQL("NomeProfissional")&""
        ProfissionalID = AgendamentoSQL("ProfissionalID")&""
        Forma = AgendamentoSQL("Forma")&""

        ModeloImpressaoAgendamento =""

        set ImpressoAgenda = db.execute("SELECT Agendamentos FROM impressos WHERE id=1")
        if not ImpressoAgenda.EOF then
            ModeloImpressaoAgendamento = ImpressoAgenda("Agendamentos")&""
            'DESATIVADO E APLICADO A FUNÇÃO PADRÃO DE TAGS
            'ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.ID]", Agendamento)
            'ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Prontuario]", Prontuario)
            'ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.Data]", Data)
            'ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Agendamento.Hora]", Hora)
            'ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Nome]", Paciente)
            'ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Paciente.Nascimento]", Nascimento)
            'ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Profissional.Nome]", Profissional)


            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Procedimentos.Nome]", Procedimentos)
            ModeloImpressaoAgendamento = replace(ModeloImpressaoAgendamento, "[Forma.Nome]", Forma)
            
            'INCLUSÃO DA NOVA FUNÇÃO TAGS | Rafael Maia 02/07/2020
            ModeloImpressaoAgendamento = tagsConverte(ModeloImpressaoAgendamento,"PacienteID_"&Prontuario&"|ProfissionalID_"&ProfissionalID&"|AgendamentoID_"&Agendamento&"|ProcedimentoNome_"&Procedimentos,"")

            ModeloImpressaoAgendamento = unscapeOutput(ModeloImpressaoAgendamento)

            response.write(ModeloImpressaoAgendamento)

        end if
    end if
end if
%>
<script>
print();
</script>
