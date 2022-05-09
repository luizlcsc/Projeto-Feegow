<!--#include file="connect.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->
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


sql = " SELECT age.Hora,     conv.NomeConvenio  ,                                                      "&chr(13)&_
      "        IF(proc2.NomeProcedimento is NULL, GROUP_CONCAT(proc.NomeProcedimento SEPARATOR '<br>'),"&chr(13)&_
      "           CONCAT(GROUP_CONCAT(proc.NomeProcedimento SEPARATOR '<br>'), '<br>',                 "&chr(13)&_
      "                  GROUP_CONCAT(proc2.NomeProcedimento SEPARATOR '<br>'))) Procedimentos,        "&chr(13)&_
      "  coalesce(sys_financialcompanyunits.Sigla,'') as Sigla                                         "&chr(13)&_
      " FROM agendamentos age                                                                          "&chr(13)&_
      "  LEFT JOIN agendamentosprocedimentos agproc ON agproc.AgendamentoID = age.id                   "&chr(13)&_
      "  LEFT JOIN convenios conv ON conv.id = age.ValorPlano and age.rdValorPlano='P'                 "&chr(13)&_
      "  LEFT JOIN procedimentos proc ON proc.id = age.TipoCompromissoID                               "&chr(13)&_
      "  LEFT JOIN procedimentos proc2 ON proc2.id = agproc.TipoCompromissoID                          "&chr(13)&_
      "  LEFT JOIN locais ON locais.id = age.LocalID                                                   "&chr(13)&_
      "  LEFT JOIN sys_financialcompanyunits ON sys_financialcompanyunits.id = locais.UnidadeID        "&chr(13)&_
      " WHERE age.PacienteID = "&PacienteID&"                                                          "&chr(13)&_
      "   and age.Data = "&mydatenull(DataAgendamento)&"                                               "

set AgendamentoProcedimentoSQL = db.execute(sql)

if not AgendamentoProcedimentoSQL.eof then
    AgendamentoProcedimentos = AgendamentoProcedimentoSQL("Procedimentos")
    AgendamentoHora = AgendamentoProcedimentoSQL("Hora")
end if

if not PacienteSQL.eof then
    if not ProtocoloSQL.eof then
        AgendamentoProtocolo = ProtocoloSQL("id")
    else
        AgendamentoProtocolo = AgendamentoID
    end if

    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Agendamento.Protocolo]", AgendamentoProtocolo)
    if AgendamentoProcedimentos&"" <> "" then
        EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Agendamento.Procedimentos]", AgendamentoProcedimentos)
    end if
    if AgendamentoHora&"" <> "" then
        EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Agendamento.Hora]", formatdatetime(AgendamentoHora, 4))
    end if

    if not ProcedimentoSQL.eof then
        NomeProcedimento =  ProcedimentoSQL("NomeProcedimento")&""
    end if
    
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Agendamento.Data]", DataAgendamento)
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Data.DDMMAAAA]", formatdatetime(now(), 2))
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Procedimento.Nome]", NomeProcedimento)
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Profissional.Nome]", NomeProfissional)
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Local.Sigla]", AgendamentoProcedimentoSQL("Sigla"))
    EtiquetaAgendamento = replace(EtiquetaAgendamento, "[Paciente.Convenio]", AgendamentoProcedimentoSQL("NomeConvenio")&"")

	EtiquetaAgendamento = unscapeOutput(replaceTags(EtiquetaAgendamento, PacienteSQL("id"), session("User"), session("Unidade")))
	EtiquetaAgendamento = tagsConverte(EtiquetaAgendamento,"AgendamentoID_"&AgendamentoID,"")
	EtiquetaAgendamento = tagsConverte(EtiquetaAgendamento,"ProfissionalID_"&ProfissionalID,"")
	EtiquetaAgendamento = tagsConverte(EtiquetaAgendamento,"ProcedimentoID_"&ProcedimentoID,"")
    
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