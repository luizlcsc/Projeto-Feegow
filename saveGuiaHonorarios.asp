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
set vca = db.execute("select NGuiaPrestador from tissguiahonorarios where ConvenioID like '"&ref("ConvenioID")&"' and NGuiaPrestador like '"&ref("NGuiaPrestador")&"' and id!="&I)
if not vca.eof then
	erro = "J&aacute; existe uma guia com este n&uacute;mero no prestador."
end if

set vcaProc = db.execute("select * from tissprocedimentoshonorarios where GuiaID="&I)
if vcaProc.eof then
	erro = "Insira ao menos um procedimento na guia."
end if
'set vcaProf = db.execute("select * from tissprofissionaishonorarios where GuiaID="&I)
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

    sql = "update tissguiahonorarios set PacienteID='"&ref("gPacienteID")&"',  CNS='"&ref("CNS")&"', ConvenioID='"&ref("gConvenioID")&"', PlanoID='"&ref("PlanoID")&"', RegistroANS='"&ref("RegistroANS")&"', NGuiaPrestador='"&ref("NGuiaPrestador")&"', NGuiaOperadora='"&ref("NGuiaOperadora")&"', Senha='"&ref("Senha")&"', NumeroCarteira='"&ref("NumeroCarteira")&"', AtendimentoRN='"&ref("AtendimentoRN")&"', NGuiaSolicitacaoInternacao='"&ref("NGuiaSolicitacaoInternacao")&"', Contratado='"&ref("Contratado")&"', CodigoNaOperadora='"&ref("CodigoNaOperadora")&"', CodigoCNES='"&ref("CodigoCNES")&"', ContratadoLocalCodigoNaOperadora='"&ref("ContratadoLocalCodigoNaOperadora")&"', ContratadoLocalNome='"&ref("ContratadoLocalNome")&"', ContratadoLocalCNES='"&ref("ContratadoLocalCNES")&"', DataInicioFaturamento="&mydatenull(ref("DataInicioFaturamento"))&", DataFimFaturamento="&mydatenull(ref("DataFimFaturamento"))&", DataEmissao="&mydatenull(ref("DataEmissao"))&", Observacoes='"&ref("Observacoes")&"', Procedimentos="&treatValZero(ref("vProcedimentos"))&", UnidadeID='"&ref("UnidadeID")&"', sysActive=1 where id="&I

'	response.Write(sql)
	db_execute(sql)
	set guia = db.execute("select * from tissguiahonorarios where id="&I)
	%>
    if( $.isNumeric($("#PacienteID").val()) )
    {
        ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
    }else{
        location.href='./?P=tissbuscaguias&ConvenioID=<%=guia("ConvenioID")%>&T=GuiaHonorarios&LoteID=<%=guia("LoteID")%>&Pers=1';
    }
    <%
end if
%>