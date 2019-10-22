<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
ProcedimentoID = req("ProcedimentoID")
AgendamentoID = req("AgendamentoID")
ProfissionalID = req("ProfissionalID")
DataAgendamento = req("DataAgendamento")

set ImpressosSQL = db.execute("SELECT EtiquetaAgendamento FROM impressos WHERE id=1")
EtiquetaAgendamento = ""
if not ImpressosSQL.EOF then
    EtiquetaAgendamento = ImpressosSQL("EtiquetaAgendamento")
end if
set PacienteSQL = db.execute("SELECT IF(NomeSocial='' OR NomeSocial IS NULL, NomePaciente, NomeSocial)NomePaciente, Nascimento, id FROM pacientes WHERE id="&PacienteID)
set ProcedimentoSQL = db.execute("SELECT NomeProcedimento FROM procedimentos WHERE id="&ProcedimentoID)

sqlProtocolo = "SELECT id FROM laudos WHERE PacienteID="&treatvalzero(PacienteID)&" AND ProcedimentoID="&treatvalzero(ProcedimentoID)&" ORDER BY id DESC LIMIT 1"
set ProtocoloSQL = db.execute(sqlProtocolo)

NomeProfissional=""
if ProfissionalID&""<>"" then
    set ProfissionalSQL = db.execute("SELECT NomeProfissional FROM profissionais WHERE id="&ProfissionalID)
    if not ProfissionalSQL.eof then
        NomeProfissional = ProfissionalSQL("NomeProfissional")
    end if
end if

set AgendamentoProcedimentoSQL = db.execute("SELECT IF(proc2.NomeProcedimento is NULL, GROUP_CONCAT(proc.NomeProcedimento SEPARATOR '<br>'), CONCAT(GROUP_CONCAT(proc.NomeProcedimento SEPARATOR '<br>'), '<br>', GROUP_CONCAT(proc2.NomeProcedimento SEPARATOR '<br>'))) Procedimentos "&_
                                            "FROM agendamentos age  "&_
                                            "LEFT JOIN agendamentosprocedimentos agproc ON agproc.AgendamentoID=age.id  "&_
                                            "LEFT JOIN procedimentos proc ON proc.id=age.TipoCompromissoID "&_
                                            "LEFT JOIN procedimentos proc2 ON proc2.id=agproc.TipoCompromissoID  "&_
                                            "WHERE age.PacienteID="&PacienteID&" and age.Data="&mydatenull(DataAgendamento)&" ")
if not AgendamentoProcedimentoSQL.eof then
    AgendamentoProcedimentos = AgendamentoProcedimentoSQL("Procedimentos")
end if

if not PacienteSQL.eof then
    if not ProtocoloSQL.eof then
        AgendamentoProtocolo = ProtocoloSQL("id")
    else
        AgendamentoProtocolo = AgendamentoID
    end if

    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Agendamento.Protocolo]", AgendamentoProtocolo)
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Agendamento.Procedimentos]", AgendamentoProcedimentos)
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Agendamento.Data]", DataAgendamento)
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Data.DDMMAAAA]", formatdatetime(now(), 2))
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Procedimento.Nome]", ProcedimentoSQL("NomeProcedimento"))
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Profissional.Nome]", NomeProfissional)

	Cabecalho = replaceTags(EtiquetaAgendamento, PacienteSQL("id"), session("User"), session("Unidade"))
    %>
<style>
@page
{
    size:  auto;   /* auto is the initial value */
    margin: 0;  /* this affects the margin in the printer settings */
}

html
{
    background-color: #FFFFFF;
    margin: 0;  /* this affects the margin on the html before sending to printer */
}

body
{
    margin: 3px; /* margin you want for the content */
    font-size: 13px;
}
</style>

<%=EtiquetaAgendamento%>


<script>
    print();
</script>
    <%
end if
%>