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
set vca = db.execute("select NGuiaPrestador from tissguiaquimioterapia where ConvenioID like '"&ref("gConvenioID")&"' and NGuiaPrestador like '"&ref("NGuiaPrestador")&"' and id!="&I)
if not vca.eof then
	erro = "J&aacute; existe uma guia com este n&uacute;mero no prestador."
end if

ObrigarValidade = 0
BloquearAlteracoes = 0
set vcaBloq = db.execute("select ifnull(BloquearAlteracoes, 0) BloquearAlteracoes, ifnull(ObrigarValidade, 0) ObrigarValidade from convenios where id="&treatvalzero(ref("gConvenioID")))
if not vcaBloq.EOF then
    BloquearAlteracoes = ccur(vcaBloq("BloquearAlteracoes"))
    ObrigarValidade = ccur(vcaBloq("ObrigarValidade"))
end if
if ObrigarValidade=1 then
    if not isdate(ref("ValidadeCarteira")) then
        erro = "É obrigatório o preenchimento da validade da carteira para este convênio."
    end if
end if

set vcaProc = db.execute("select * from tissmedicamentosquimioterapia where GuiaID="&I)
if vcaProc.eof then
	erro = "Insira ao menos um medicamento na guia."
end if

if erro<>"" then
	%>
    new PNotify({
        title: ' ERRO!',
        text: '<%=erro%>',
        type: 'danger',
    });
    <%
else

	set vpac = db.execute("select * from pacientes where id="&ref("gPacienteID"))
	if not vpac.eof then
		if not isnull(vpac("ConvenioID1")) AND vpac("ConvenioID1")=ccur(ref("gConvenioID")) then
			Numero = 1
		elseif not isnull(vpac("ConvenioID2")) AND vpac("ConvenioID2")=ccur(ref("gConvenioID")) then
			Numero = 2
		elseif not isnull(vpac("ConvenioID3")) AND vpac("ConvenioID3")=ccur(ref("gConvenioID")) then
			Numero = 3
		else
			Numero = ""
		end if
	end if

	'Contratado solicitante
	if ref("tipoContratadoSolicitante")="E" and BloquearAlteracoes=0 then
		set vca = db.execute("select * from contratadoexternoconvenios where ConvenioID like '"&ref("gConvenioID")&"' and ContratadoExternoID like '"&ref("ContratadoExternoID")&"'")
		if vca.eof then
			db_execute("insert into contratadoexternoconvenios (ContratadoExternoID, ConvenioID, CodigoNaOperadora) values ("&treatvalzero(ref("ContratadoExternoID"))&", "&treatvalzero(ref("gConvenioID"))&", '"&ref("ContratadoSolicitanteCodigoNaOperadora")&"')")
		else
			db_execute("update contratadoexternoconvenios set ContratadoExternoID="&treatvalzero(ref("ContratadoExternoID"))&", ConvenioID="&treatvalzero(ref("gConvenioID"))&", CodigoNaOperadora='"&ref("ContratadoSolicitanteCodigoNaOperadora")&"' where id="&vca("id"))
		end if
	end if
    set datant = db.execute("select gs.PacienteID from tissguiaquimioterapia gs left join tissmedicamentosquimioterapia gis on gis.GuiaID=gs.id where gs.id="&I)'tem q ser antes pra pegar os dados antes do update

	'//-> fim do atualiza os dados do paciente, profissional, convenio, contratado e medicamentos
	sql = "update tissguiaquimioterapia set NGuiaReferenciada='"&ref("NGuiaReferenciada")&"', CNS='"&ref("CNS")&"', RegistroANS='"&ref("RegistroANS")&"', NGuiaPrestador='"&ref("NGuiaPrestador")&"', Senha='"&ref("Senha")&"', ConvenioID="&treatvalzero(ref("gConvenioID"))&", PlanoID="&treatvalzero(ref("PlanoID"))&", AtendimentoID="&treatvalzero(ref("AtendimentoID"))&", AgendamentoID="&treatvalzero(ref("AgendamentoID"))&", DataAutorizacao="&mydatenull(ref("DataAutorizacao"))&", DataValidadeSenha="&mydatenull(ref("DataValidadeSenha"))&", NGuiaOperadora='"&ref("NGuiaOperadora")&"', NumeroCarteira='"&ref("NumeroCarteira")&"', PacienteID="&treatvalzero(ref("gPacienteID"))&", Peso='"&ref("Peso")&"', Idade='"&ref("Idade")&"', Altura='"&ref("Altura")&"', SuperficieCorporal='"&ref("SuperficieCorporal")&"', Sexo='"&ref("Sexo")&"', ProfissionalSolicitanteID="&treatvalzero(ref("ProfissionalID"))&", Telefone='"&ref("Cel1")&"', Email='"&ref("Email")&"', DataDiagnostico="&mydatenull(ref("DataDiagnostico"))&", ValidadeCarteira="&mydatenull(ref("ValidadeCarteira"))&", Cid1='"&ref("Cid1")&"', Cid2='"&ref("Cid2")&"', Cid3='"&ref("Cid3")&"', Cid4='"&ref("Cid4")&"', Estadiamento='"&ref("Estadiamento")&"', TipoQuimioterapia='"&ref("TipoQuimioterapia")&"', Finalidade='"&ref("Finalidade")&"', ECOG='"&ref("ECOG")&"', PlanoTerapeutico='"&ref("PlanoTerapeutico")&"', DiagnosticoCitoHistopatologico='"&ref("DiagnosticoCitoHistopatologico")&"', InfoRelevante='"&ref("InfoRelevante")&"', Cirurgia='"&ref("Cirurgia")&"', DataRealizacao="&mydatenull(ref("DataRealizacao"))&", AreaIrradiada='"&ref("AreaIrradiada")&"', DataAplicacao="&mydatenull(ref("DataAplicacao"))&", Observacoes='"&ref("Observacoes")&"', NumeroCicloPrevisto="&treatvalzero(ref("NumeroCicloPrevisto"))&", CicloAtual="&treatvalzero(ref("CicloAtual"))&", IntervaloEntreCiclos="&treatvalzero(ref("IntervaloEntreCiclos"))&", DataSolicitacao="&mydatenull(ref("DataSolicitacao"))&", UnidadeID="&treatvalzero(ref("UnidadeID"))&", sysActive=1 where id="&I
	db_execute(sql)

	set guia = db.execute("select * from tissguiaquimioterapia where id="&I)
	%>
    if( $.isNumeric($("#PacienteID").val()) )
    {
        ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
        loadAgenda($("#Data").val(), $("#ProfissionalID").val());
    }else{
        location.href='./?P=tissbuscaguias&ConvenioID=<%=guia("ConvenioID")%>&T=GuiaQuimioterapia&LoteID=<%=guia("LoteID")%>&Pers=1';
    }
    <%
end if
%>