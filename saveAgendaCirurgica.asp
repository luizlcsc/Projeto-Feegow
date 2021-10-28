<!--#include file="connect.asp"-->
<%
I = req("I")
tipoContratadoSolicitante = ref("tipoContratadoSolicitante")
tipoProfissionalSolicitante = ref("tipoProfissionalSolicitante")
if tipoContratadoSolicitante="I" then
	ContratadoSolicitanteID = ref("ContratadoSolicitanteID")
	'Completa os dados do convenio x contratado interno como na guia de consulta
else
	ContratadoSolicitanteID = ref("ContratadoExternoID")
	'Complata os dados convenio x contratado externo
end if
if tipoProfissionalSolicitante="I" then
	ProfissionalSolicitanteID = ref("ProfissionalSolicitanteID")
	'Completa os dados do convenio x contratado interno como na guia de consulta
else
	ProfissionalSolicitanteID = ref("ProfissionalSolicitanteExternoID")
	'Complata os dados convenio x contratado externo
end if
'1. verifica se já tem guia com esse numero nesse convenio prestador
set vca = db.execute("select NGuiaPrestador from agendacirurgica where ConvenioID like '"&ref("ConvenioID")&"' and NGuiaPrestador like '"&ref("NGuiaPrestador")&"' and id!="&I)
if not vca.eof then
	erro = "J&aacute; existe uma guia com este n&uacute;mero no prestador."
end if

set vcaProc = db.execute("select * from procedimentoscirurgia where GuiaID="&I)
if vcaProc.eof then
	erro = "Insira ao menos um procedimento na guia."
end if
'set vcaProf = db.execute("select * from profissionaiscirurgia where GuiaID="&I)
'if vcaProf.eof then
'	erro = "Insira ao menos um profissional executante na guia."
'end if

if erro<>"" then
	%>
    new PNotify({
        title: '<i class="far fa-thumbs-down"></i> ERRO!',
        text: '<%=erro%>',
        type: 'danger'
    });
	<%
else

    sql = "update agendacirurgica set StatusID='"& ref("StatusID") &"', PacienteID="& treatvalzero(ref("gPacienteID")) &", ConvenioID="& treatvalnull(ref("gConvenioID")) &", PlanoID="& treatvalnull(ref("PlanoID")) &", RegistroANS='"&ref("RegistroANS")&"', rdValorPlano='"& ref("rdValorPlano") &"', Valor="& treatvalzero(ref("Valor")) &", Hora="& mytime(ref("Hora")) &", Senha='"&ref("Senha")&"', NumeroCarteira='"&ref("NumeroCarteira")&"', ContratadoLocalCodigoNaOperadora='"&ref("ContratadoLocalCodigoNaOperadora")&"', ContratadoLocalNome='"&ref("ContratadoLocalNome")&"', ContratadoLocalCNES='"&ref("ContratadoLocalCNES")&"', DataEmissao="& mydatenull(ref("DataEmissao")) &", Observacoes='"&ref("Observacoes")&"', Procedimentos="& treatValZero(ref("vProcedimentos")) &", UnidadeID="& treatvalzero(ref("UnidadeID")) &", LocalExternoID =" & treatvalzero(ref("LocalExternoID")) &", sysActive=1 where id="&I

'	response.Write(sql)
	db.execute(sql)
	set guia = db.execute("select * from agendacirurgica where id="&I)
	%>
        location.href='./?P=listaAgendaCirurgica&Pers=1';
    <%
end if
%>